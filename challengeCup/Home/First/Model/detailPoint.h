//
//  detailPoint.h
//  spy on
//
//  Created by 柳麟喆 on 2017/7/17.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface detailPoint : NSObject

@property(nonatomic,strong)NSString *height;
@property(nonatomic,strong)NSString *radius;
@property(nonatomic,strong)NSString *speed;
@property(nonatomic,strong)NSString *direction;
@property(nonatomic,strong)NSString *loc_time;
@property(nonatomic,strong)NSString *latitude;
@property(nonatomic,strong)NSString *create_time;
@property(nonatomic,strong)NSString *longitude;


-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)detailPointWithDict:(NSDictionary *)dict;

@end
