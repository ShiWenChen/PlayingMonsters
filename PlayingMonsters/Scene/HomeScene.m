//
//  HomeScene.m
//  PlayingMonsters
//
//  Created by ShiWen on 2017/10/17.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "HomeScene.h"
#import "GameOverScene.h"
#define ARC4RANDOM_MAX      0x100000000
//碰撞区分
static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

@interface HomeScene()<SKPhysicsContactDelegate>
{
    dispatch_source_t timer;
    
}

@property (nonatomic,strong) SKSpriteNode *plateNode;

@property (nonatomic,assign) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic,assign) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic,assign) int totalScore;
@property (nonatomic,strong) SKLabelNode *lbNode;
@property (nonatomic,strong) SKLabelNode *lbTime;

@property (nonatomic,strong) SKEmitterNode *borkenEmitterNode;
@property (nonatomic,assign) double timeinterval;
@property (nonatomic,assign) double maxSpeed;
@property (nonatomic,assign) double minSpeed;
@property (nonatomic,assign) int timeCount;

@end
//建议内联函数 点加
static inline CGPoint add (CGPoint a,CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}
//点减
static inline CGPoint reduce (CGPoint a,CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}
//数乘
static inline CGPoint rwMult (CGPoint a,float b)
{
    return CGPointMake(a.x * b, a.y * b);
}

//计算点坐标长度 勾股定理
static inline float rwLenth (CGPoint a)
{
    return sqrtf(a.x * a.x + a.y * a.y);
}

//计算基向量
static inline CGPoint rwNormalize(CGPoint a)
{
    float lenth = rwLenth(a);
    return CGPointMake(a.x/lenth, a.y/lenth);
}

@implementation HomeScene

-(instancetype)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        self.timeinterval = 1.000000;
        self.minSpeed = 4.00;
        self.maxSpeed = 6.00;

        self.backgroundColor = [SKColor colorWithRed:95.0/255.0 green:195.0/255.0 blue:1 alpha:1.0];
        self.plateNode = [SKSpriteNode spriteNodeWithImageNamed:@"player.png"];
        self.plateNode.position = CGPointMake(self.plateNode.size.width/2, self.size.height/2);
        [self addChild:self.plateNode];
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;


        
        
        [self addChild:self.lbTime];
    }
    return self;
}
//添加怪物
-(void)addMonster{
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster.png"];
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = projectileCategory;
    monster.physicsBody.collisionBitMask = 0;
//    在Y轴随机产生怪物
    int minY = monster.size.height/2;
    int maxY = self.frame.size.height - monster.size.height/2;
    int rangeY = maxY - minY;
    int Y = (arc4random() % rangeY) + minY;
//    double Y = floorf(((double)arc4random() / ARC4RANDOM_MAX) * rangeY);
    
//    设置怪物坐标 在屏幕右侧边缘
    monster.position = CGPointMake(self.size.width +monster.size.width/2, Y);
    [self addChild:monster];
    
//    设置怪物速度
    self.minSpeed -= 0.01;
    self.maxSpeed -= 0.01;
    if (self.minSpeed < 1) {
        self.minSpeed = 1;
    }
    if (self.maxSpeed < 2) {
        self.maxSpeed = 2;
    }
    double rangeDuration = self.maxSpeed - self.minSpeed;
    double actualDuration = floorf(((double)arc4random() / ARC4RANDOM_MAX) * rangeDuration)+ self.minSpeed;

//    创建移动动画
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, Y) duration:actualDuration];
    SKAction *removeNode = [SKAction removeFromParent];
//    没打中，减分
    SKAction *reduceScore = [SKAction runBlock:^{
        [self calculateScores:-1];
        [self runAction:[SKAction playSoundFileNamed:@"shoot.wav" waitForCompletion:NO]];
        
    } queue:dispatch_get_main_queue()];
    [monster runAction:[SKAction sequence:@[actionMove,reduceScore,removeNode]]];
    
}

/**
 每帧动画都会调用该方法

 @param currentTime 当前已过去的时间
 */
-(void)update:(NSTimeInterval)currentTime{
    self.timeinterval -= 0.0001;
//    让怪物在一定的时间间隔内生成
    CFTimeInterval  timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    
    if (timeSinceLast > 1) {
        timeSinceLast = 1/60.0;
    }
    self.lastUpdateTimeInterval = currentTime;
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.timeinterval < 0.0) {
        self.timeinterval = 0;
    }
//    测试数据
//    self.timeinterval = 0;
//    测试数据结束
    if (self.lastSpawnTimeInterval > self.timeinterval) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}
//发射子弹
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    发射声音
    [self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    
//    获取触摸坐标
    UITouch *touch = [touches anyObject ];
    CGPoint touchPoint = [touch locationInNode:self];
//    设置子弹初识位置
    
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.position = self.plateNode.position;
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    
//    确定子弹位置偏移  子弹起始坐标与点击坐标 的向量
    CGPoint offset = reduce(touchPoint, projectile.position);
    if (offset.x < 0) return;
    [self addChild:projectile];
//    计算偏移量的基向量
    CGPoint drection = rwNormalize(offset);
//    扩大的点，让其脱离屏幕
    CGPoint shootAmout = rwMult(drection, 1000);
//    计算最终向量
    CGPoint endPoint = add(shootAmout, projectile.position);
    
//  让子弹转起来
    SKAction *rotateAction = [SKAction rotateByAngle:360 duration:1];
    [projectile runAction:[SKAction repeatActionForever:rotateAction]];
    
    
    
//    移动速度
    float velocity = 480/1.0;
//    移动时间
    float realMoveDuration = self.size.width/velocity;
    SKAction *actionMove = [SKAction moveTo:endPoint duration:realMoveDuration];
//    移动结束，删除节点
    SKAction *removeAction = [SKAction removeFromParent];
//    创建动画组合，依次执行
    SKAction *sequenceAction = [SKAction sequence:@[actionMove,removeAction]];
    [projectile runAction:sequenceAction];
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    SKPhysicsBody *projectile ,*monster;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        projectile = contact.bodyA;
        monster = contact.bodyB;
    }else{
        projectile = contact.bodyB;
        monster = contact.bodyA;
    }
    if ((projectile.categoryBitMask == projectileCategory) && !0 &&(monster.categoryBitMask == monsterCategory) && !0) {
        [self runAction:[SKAction playSoundFileNamed:@"enemyHit.wav" waitForCompletion:NO]];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"broken" ofType:@"sks"];
        SKEmitterNode *borkenEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        borkenEmitter.position = contact.contactPoint;
        [self addChild:borkenEmitter];
        [self projectile:(SKSpriteNode *)projectile.node didCollideWithMonster:(SKSpriteNode *)monster.node adEmitter:borkenEmitter];
    }
}


//碰撞处理
-(void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster adEmitter:(SKEmitterNode *)emitterNode{
    NSLog(@"子弹打中怪物");
    
    
    [projectile removeFromParent];
    [monster removeFromParent];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [emitterNode removeFromParent];
    });
    [self calculateScores:2];
    
    
}

//计分 打中 + 2 逃跑 -1
-(void)calculateScores:(int)score{
    self.totalScore += score;
    if (self.totalScore == -2000) {
        [self gameOverWithRelust:NO];
    }
    self.lbNode.text = [NSString stringWithFormat:@"目前得分:%i",self.totalScore];
    
    
    
}
-(SKLabelNode *)lbNode{
    if (!_lbNode) {
        _lbNode = [[SKLabelNode alloc] init];
        _lbNode.position = CGPointMake(self.size.width/2, self.size.height-20);
        _lbNode.fontColor = [SKColor redColor];
        _lbNode.fontSize = 14;
        _lbNode.text = @"目前得分:0";
        [self addChild:_lbNode];
    }
    return _lbNode;
}
-(SKLabelNode *)lbTime{
    if (!_lbTime) {
        _lbTime = [[SKLabelNode alloc] init];
        _lbTime.position = CGPointMake(self.size.width-50, self.size.height-20);
        _lbTime.fontColor = [SKColor blackColor];
        
        _lbTime.fontSize = 14;
        [self timeStr];

    }
    return _lbTime;
}
-(void)timeStr{
    //        创建队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        int hours = self.timeCount / 3600;
        int minutes = (self.timeCount - (3600*hours)) / 60;
        int seconds = self.timeCount % 60;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (minutes == 5) {
                [self gameOverWithRelust:YES];
            }
           self.lbTime.text = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",hours,minutes,seconds];
        });
        self.timeCount ++;
        
    });
    dispatch_resume(timer);
}
-(SKEmitterNode *)borkenEmitterNode{
    if (!_borkenEmitterNode) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"broken" ofType:@"sks"];
        _borkenEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    return _borkenEmitterNode;
}
//成绩低于-2000或者时间超过5分钟，结束游戏 超过5分钟，成功
-(void)gameOverWithRelust:(BOOL)relust{
    dispatch_source_cancel(timer);
    self.timeCount = 0;
    self.totalScore = 0;
    GameOverScene *gameOver = [[GameOverScene alloc] initWithSize:self.size adSuccessful:relust];
    
    [self.view presentScene:gameOver transition:[SKTransition doorsCloseVerticalWithDuration:1]];
}














@end
