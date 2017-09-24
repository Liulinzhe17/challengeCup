//
//  SportAnnotationView.h
//  spy on
//
//  Created by 柳麟喆 on 2017/7/3.
//  Copyright © 2017年 lzLiu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

// 自定义BMKAnnotationView，用于显示运动者
@interface SportAnnotationView : BMKAnnotationView

@property (nonatomic, strong) UIImageView *imageView;

@end

