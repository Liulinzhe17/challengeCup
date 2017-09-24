//
//  stayPoint.m
//  spy on
//
//  Created by 柳麟喆 on 2017/7/14.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "stayPoint.h"

@implementation stayPoint

-(instancetype)initWithDict:(NSDictionary *)dict{
    if(self=[super init]){
        _duration=[dict objectForKey:@"duration"];
        _start_time=[dict objectForKey:@"start_time"];
        _end_time=[dict objectForKey:@"end_time"];
        _rank=[dict objectForKey:@"rank"];
        _stay_point=[dict objectForKey:@"stay_point"];
        
        if (_stay_point!=NULL) {
            _latitude=[_stay_point objectForKey:@"latitude"];
            _coord_type=[_stay_point objectForKey:@"coord_type"];
            _longitude=[_stay_point objectForKey:@"longitude"];
        }
    }
    return self;
}
+(instancetype)stayPointWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}
@end
