//
//  XMHelper.h
//  spy on
//
//  Created by 柳麟喆 on 2017/9/13.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMHelper : NSObject

#pragma mark - 时间戳转时间
+(NSString *)timeFromTimeStamp:(NSString *)timeStamp;

#pragma mark - 格式话小数 四舍五入类型
+(NSString *)decimalwithFormat:(NSString *)format doubleV:(double)doubleV;

#pragma mark - 比较两时间相差多少
+(NSString *)compareTime:(NSString *)time1 with:(NSString *)time2;

@end
