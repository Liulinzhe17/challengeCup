//
//  stayPoint.h
//  spy on
//
//  Created by 柳麟喆 on 2017/7/14.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface stayPoint : NSObject

@property(nonatomic,strong)NSString *duration;
@property(nonatomic,strong)NSString *start_time;
@property(nonatomic,strong)NSString *end_time;
@property(nonatomic,strong)NSString *rank;

@property(nonatomic,strong)NSDictionary *stay_point;
@property(nonatomic,strong)NSString *latitude;
@property(nonatomic,strong)NSString *longitude;
@property(nonatomic,strong)NSString *coord_type;



-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)stayPointWithDict:(NSDictionary *)dict;


@end
