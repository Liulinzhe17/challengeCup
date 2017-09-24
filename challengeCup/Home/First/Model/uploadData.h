//
//  uploadDate.h
//  spy on
//
//  Created by 柳麟喆 on 2017/9/21.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface uploadData : NSObject

@property(nonatomic,strong)NSString *entity;//用户手机的名称
@property(nonatomic,strong)NSString *gatherTimes;//采集周期
@property(nonatomic,strong)NSArray *test_reality;//实际使用时间数组
@property(nonatomic,strong)NSArray *test_expect;//预期使用时间数组
//起始点的经度纬度
//@property(nonatomic,strong)NSString *start_latitude;
//@property(nonatomic,strong)NSString *start_longitude;
//终点的经度纬度
//@property(nonatomic,strong)NSString *end_latitude;
//@property(nonatomic,strong)NSString *end_longitude;
-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)uploadDataWithDict:(NSDictionary *)dict;

@end
