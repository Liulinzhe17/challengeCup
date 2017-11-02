//
//  poiModel.m
//  challengeCup
//
//  Created by 柳麟喆 on 2017/10/29.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "poiModel.h"

@implementation poiModel

-(instancetype)initWithDict:(NSDictionary *)dict{
    if(self=[super init]){
        _address=[dict objectForKey:@"address"];
        _latitude=[dict objectForKey:@"latitude"];
        _longitude=[dict objectForKey:@"longitude"];
    }
    return self;
}
+(instancetype)poiModelWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}
@end
