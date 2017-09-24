//
//  clearCache.m
//  spy on
//
//  Created by 柳麟喆 on 2017/7/12.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "clearCache.h"

@implementation clearCache

-(instancetype)initWithDict:(NSDictionary *)dict{
    if(self=[super init]){
        _tag=[dict objectForKey:@"tag"];
        _status=[dict objectForKey:@"status"];
        _message=[dict objectForKey:@"message"];
    }
    return self;
}
+(instancetype)clearCacheWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}

@end
