//
//  detailPoint.m
//  spy on
//
//  Created by 柳麟喆 on 2017/7/17.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "detailPoint.h"

@implementation detailPoint

-(instancetype)initWithDict:(NSDictionary *)dict{
    if(self=[super init]){
        _height=[dict objectForKey:@"height"];
        _radius=[dict objectForKey:@"radius"];
        _speed=[dict objectForKey:@"speed"];
        _create_time=[dict objectForKey:@"create_time"];
        _direction=[dict objectForKey:@"direction"];
        _latitude=[dict objectForKey:@"latitude"];
        _loc_time=[dict objectForKey:@"loc_time"];
        _longitude=[dict objectForKey:@"longitude"];
    }
    return self;
}
+(instancetype)detailPointWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}

@end
