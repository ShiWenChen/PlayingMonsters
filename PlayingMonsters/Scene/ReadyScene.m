//
//  ReadyScene.m
//  PlayingMonsters
//
//  Created by ShiWen on 2017/10/19.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "ReadyScene.h"
#import "HomeScene.h"

@implementation ReadyScene
-(instancetype)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor blackColor];
        SKLabelNode *lableReady = [[SKLabelNode alloc]initWithFontNamed:@"ChalkboardSE-Bold"];
        lableReady.text = @"are you ready?🤐🤐🤐";
        lableReady.fontSize = 50;
        lableReady.position = CGPointMake(self.size.width/2, self.size.height/2);
        lableReady.fontColor = [SKColor redColor];
        [self addChild:lableReady];
        
        SKLabelNode *lableAgain = [[SKLabelNode alloc]initWithFontNamed:@"Copperplate"];
        lableAgain.text = @"Touch anwhere begin👻";
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
