//
//  clearCache.h
//  spy on
//
//  Created by 柳麟喆 on 2017/7/12.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface clearCache : NSObject

@property(nonatomic,strong)NSString *tag;
@property(nonatomic,strong)NSString *status;
@property(nonatomic,strong)NSString *message;

-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)clearCacheWithDict:(NSDictionary *)dict;

@end
