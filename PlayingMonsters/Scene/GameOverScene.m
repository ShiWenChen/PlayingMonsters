//
//  GameOverScene.m
//  PlayingMonsters
//
//  Created by ShiWen on 2017/10/17.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "GameOverScene.h"
#import "HomeScene.h"

@implementation GameOverScene
-(instancetype)initWithSize:(CGSize)size adSuccessful:(BOOL)success{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        NSString *message;
        if (success) {
            NSLog(@"成功" );
            message = @"Ah,you succeeded!😱😱😱";
            
        }else{
            NSLog(@"失败");
            message = @"Ah,you fail!😞😞😞";
        }
//        ChalkboardSE-Bold   Chalkduster
        SKLabelNode *lableNode = [[SKLabelNode alloc]initWithFontNamed:@"Chalkduster"];
        lableNode.text = message;
        lableNode.fontSize = 40;
        lableNode.position = CGPointMake(self.size.width/2, self.size.height/2);
        lableNode.fontColor = [SKColor blackColor];
        [self addChild:lableNode];
        
        //        Click anywhere to start again
        
        SKLabelNode *lableAgain = [[SKLabelNode alloc]initWithFontNamed:@"ChalkboardSE-Bold"];
        lableAgain.text = @"Touch anywhere to challenge again😊";
        lableAgain.fontSize = 20;
        lableAgain.position = CGPointMake(self.size.width/2, self.size.height/2-100);
        lableAgain.fontColor = [SKColor greenColor];
        [self addChild:lableAgain];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    HomeScene *homeScene = [[HomeScene alloc] initWithSize:self.size];
    [self.view presentScene:homeScene transition:[SKTransition doorsOpenVerticalWithDuration:1]];
}
@end
