//
//  AppDelegate.mm
//  spy on
//
//  Created by 柳麟喆 on 2017/6/22.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "AppDelegate.h"
#import "MMainViewController.h"
#import "YDViewController.h"
#import "RouteViewController.h"
#import "setGatherTimesViewController.h"

#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@interface AppDelegate ()<BMKGeneralDelegate>
@property BMKMapManager *mapManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [self.mapManager start:AK generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    //初始化鹰眼服务器
    if ([self initService]) {
        NSLog(@"服务初始化成功");
    }else{
        NSLog(@"服务初始化失败");
    }
    //Bmob授权
    [Bmob registerWithAppKey:@"02ce6eb20fba1c7a14062c4a4ee28087"];
    
    
    
    self.window =[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor whiteColor];
    /*正确开始*/
    if (![USER boolForKey:@"notFirst"]) {
        YDViewController *yd=[[YDViewController alloc]init];
        self.window.rootViewController = yd;
    }else{
        MMainViewController *mmain=[[MMainViewController alloc]init];
        self.window.rootViewController = mmain;
    }
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    RouteViewController *map=[[RouteViewController alloc]init];
    [map shutDownService];
}
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}
#pragma mark -服务器初始化
-(BOOL)initService{
    BTKServiceOption *sop = [[BTKServiceOption alloc] initWithAK:AK mcode:MCODE serviceID:SERVICE_ID keepAlive:true];
    return [[BTKAction sharedInstance] initInfo:sop];
}
@end
