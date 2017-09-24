//
//  XMHelper.m
//  spy on
//
//  Created by 柳麟喆 on 2017/9/13.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "XMHelper.h"

@implementation XMHelper

#pragma mark - 时间戳转时间
+(NSString *)timeFromTimeStamp:(NSString *)timeStamp{
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeStamp.intValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}
#pragma mark - 格式话小数 四舍五入类型
+(NSString *)decimalwithFormat:(NSString *)format doubleV:(double)doubleV{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:format];
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:doubleV]];
}
#pragma mark - 比较两时间相差多少
+(NSString *)compareTime:(NSString *)time1 with:(NSString *)time2{
    
    NSArray *arr1=[time1 componentsSeparatedByString:@":"];
    NSString *hour1=arr1[0];
    NSString *minute1=arr1[1];
    
    NSArray *arr2=[time2 componentsSeparatedByString:@":"];
    NSString *hour2=arr2[0];
    NSString *minute2=arr2[1];
    
    int result=abs((hour1.intValue*60+minute1.intValue)-(hour2.intValue*60+minute2.intValue));
    return [NSString stringWithFormat:@"%d",result];
    
}
@end
