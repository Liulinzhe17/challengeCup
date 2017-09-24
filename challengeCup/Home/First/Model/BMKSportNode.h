//
//  BMKSportNode.h
//  spy on
//
//  Created by 柳麟喆 on 2017/7/3.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

// 运动结点信息类
@interface BMKSportNode : NSObject

//经纬度
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
//方向（角度）
@property (nonatomic, assign) CGFloat angle;
//距离
@property (nonatomic, assign) CGFloat distance;
//速度
@property (nonatomic, assign) CGFloat speed;

@end
