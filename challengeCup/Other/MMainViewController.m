//
//  MMainViewController.m
//  spy on
//
//  Created by 柳麟喆 on 2017/8/18.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "MMainViewController.h"
#import "MapViewController.h"
#import "CustomViewController.h"
#import "RouteViewController.h"
#import "setGatherTimesViewController.h"

@interface MMainViewController ()


@end

@implementation MMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MapViewController *v1=[[MapViewController alloc]init];
    v1=[[MapViewController alloc]init];
    v1.tabBarItem.title=@"未启用";
    v1.tabBarItem.image=[UIImage imageNamed:@"game"];
    
    RouteViewController *v2=[[RouteViewController alloc]init];
    v2.tabBarItem.title=@"主界面";
    v2.tabBarItem.image=[UIImage imageNamed:@"game2"];
    v2.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"spyon_Setting.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goSetting)];
    //更新用户配置
    [v2 updateUserPreferences:nil];
    if ([[USER objectForKey:@"isAutoGather"] integerValue]==1) {
        //开启服务
        v2.swGather.on=YES;
        [v2 openUpService];
    }
    
    CustomViewController *v3=[[CustomViewController alloc]init];
    v3.tabBarItem.title=@"用户";
    v3.tabBarItem.image=[UIImage imageNamed:@"game"];
    
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:v1];
    UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:v2];
    UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:v3];
    
    self.viewControllers=[NSArray arrayWithObjects:navController2,navController1,navController3, nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 设置按钮点击事件
-(void)goSetting{
    setGatherTimesViewController *vc=[[setGatherTimesViewController alloc]init];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
@end
