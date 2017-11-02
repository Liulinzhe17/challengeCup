//
//  poiModel.h
//  challengeCup
//
//  Created by 柳麟喆 on 2017/10/29.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface poiModel : NSObject
@property(nonatomic,strong)NSString *address;
@property(nonatomic,strong)NSString *latitude;
@property(nonatomic,strong)NSString *longitude;


-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)poiModelWithDict:(NSDictionary *)dict;
@end
