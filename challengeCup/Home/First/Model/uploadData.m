//
//  uploadDate.m
//  spy on
//
//  Created by 柳麟喆 on 2017/9/21.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "uploadData.h"

@implementation uploadData

-(instancetype)initWithDict:(NSDictionary *)dict{
    if(self=[super init]){
        _entity=[dict objectForKey:@"entity"];
        _gatherTimes=[dict objectForKey:@"gatherTimes"];
        _test_expect=[dict objectForKey:@"test_expect"];
        _test_reality=[dict objectForKey:@"test_reality"];
    }
    return self;
}
+(instancetype)uploadDataWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}
@end
