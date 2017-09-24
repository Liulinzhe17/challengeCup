//
//  RouteViewController.h
//  spy on
//
//  Created by 柳麟喆 on 2017/6/23.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteViewController : UIViewController

@property(nonatomic,strong)UISwitch *swGather;//是否采集位置信息

//关闭服务
-(void)shutDownService;
//开启服务
-(void)openUpService;
//更新用户配置
-(void)updateUserPreferences:(NSNotification *)noti;

@end
