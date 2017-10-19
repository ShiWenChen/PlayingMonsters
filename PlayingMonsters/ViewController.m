//
//  ViewController.m
//  PlayingMonsters
//
//  Created by ShiWen on 2017/10/17.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "ViewController.h"
#import "HomeScene.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SKView *skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
//        创建SCene
        SKScene *homeScene = [HomeScene sceneWithSize:CGSizeMake(skView.bounds.size.width, skView.bounds.size.height)];
        homeScene.scaleMode = SKSceneScaleModeAspectFill;
        
        [skView presentScene:homeScene];
    }
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
