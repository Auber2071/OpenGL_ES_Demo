//
//  ViewController.m
//  OpenGLTest
//
//  Created by Edward on 2018/9/4.
//  Copyright © 2018年 Edward. All rights reserved.
//

#import "ViewController.h"
#import "PyramidViewController.h"
#import "PlanetViewController.h"
#import "CircularConeViewController.h"
#import "SquareViewController.h"
#import "MoonAndEarthViewController.h"

@interface ViewController ()
@property (nonatomic, strong, nullable) UIButton *planetBtn;
@property (nonatomic, strong, nullable) UIButton *cubeBtn;
@property (nonatomic, strong, nullable) UIButton *squareBtn;
@property (nonatomic, strong, nullable) UIButton *circularBtn;
@property (nonatomic, strong, nullable) UIButton *MoonEarthBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.cubeBtn = [self getDesignButtonWithTitle:@"金字塔"];
    self.planetBtn = [self getDesignButtonWithTitle:@"球体"];
    self.squareBtn = [self getDesignButtonWithTitle:@"立方体"];
    self.circularBtn = [self getDesignButtonWithTitle:@"圆锥体"];
    self.MoonEarthBtn = [self getDesignButtonWithTitle:@"地球 月亮 横屏进入"];

    [self.view addSubview:self.cubeBtn];
    [self.view addSubview:self.planetBtn];
    [self.view addSubview:self.squareBtn];
    [self.view addSubview:self.circularBtn];
    [self.view addSubview:self.MoonEarthBtn];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat btnWidth = 100;
    CGFloat btnHeight = 60;
    CGFloat padding = 10;
    CGFloat btnX = (CGRectGetWidth(self.view.frame) - btnWidth * 3 - padding * 4)/3.f;
    [self.cubeBtn setFrame:CGRectMake(btnX, 80, btnWidth, btnHeight)];
    
    [self.planetBtn setFrame:CGRectMake(CGRectGetMaxX(self.cubeBtn.frame) + padding,
                                        CGRectGetMinY(self.cubeBtn.frame),
                                        btnWidth, btnHeight)];
    
    [self.squareBtn setFrame:CGRectMake(CGRectGetMaxX(self.planetBtn.frame) + padding,
                                        CGRectGetMinY(self.planetBtn.frame),
                                        btnWidth, btnHeight)];
    
    [self.circularBtn setFrame:CGRectMake(btnX,
                                          CGRectGetMaxY(self.cubeBtn.frame) + padding,
                                          btnWidth, btnHeight)];
    
    [self.MoonEarthBtn setFrame:CGRectMake(CGRectGetMaxX(self.circularBtn.frame) + padding,
                                           CGRectGetMinY(self.circularBtn.frame),
                                           btnWidth * 2 + padding, btnHeight)];
}



- (UIButton *)getDesignButtonWithTitle:(NSString *)btnTitle {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:btnTitle forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = 1.f;
    button.layer.cornerRadius = 5.f;
    return button;
}

- (void)buttonClick:(UIButton *)sender {
    if (sender == self.cubeBtn) {
        PyramidViewController *cubeVC = [[PyramidViewController alloc] init];
        cubeVC.title = sender.titleLabel.text;
        [self.navigationController pushViewController:cubeVC animated:YES];

    } else if ( sender == self.planetBtn) {
        PlanetViewController *planetVC = [[PlanetViewController alloc] init];
        planetVC.title = sender.titleLabel.text;
        [self.navigationController pushViewController:planetVC animated:YES];
        
    } else if (sender == self.circularBtn) {
        CircularConeViewController *planetVC = [[CircularConeViewController alloc] init];
        planetVC.title = sender.titleLabel.text;
        [self.navigationController pushViewController:planetVC animated:YES];
        
    } else if (sender == self.squareBtn) {
        SquareViewController *cubeVC = [[SquareViewController alloc] init];
        cubeVC.title = sender.titleLabel.text;
        [self.navigationController pushViewController:cubeVC animated:YES];
        
    } else if (sender == self.MoonEarthBtn) {
        MoonAndEarthViewController *cubeVC = [[MoonAndEarthViewController alloc] init];
        cubeVC.title = sender.titleLabel.text;
        [self.navigationController pushViewController:cubeVC animated:YES];
    }
}


@end
