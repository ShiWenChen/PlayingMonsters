//
//  GameOverScene.m
//  PlayingMonsters
//
//  Created by ShiWen on 2017/10/17.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "GameOverScene.h"

@implementation GameOverScene
-(instancetype)initWithSize:(CGSize)size adloser:(BOOL)loser{
    if (self = [super initWithSize:size]) {
        if (loser) {
            NSLog(@"失败" );
        }else{
            NSLog(@"成功");
        }
    }
    return self;
}

@end
