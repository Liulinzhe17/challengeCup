//
//  MyAnimatedAnnotationView.h
//  spy on
//
//  Created by 柳麟喆 on 2017/7/4.
//  Copyright © 2017年 lzLiu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>


@interface MyAnimatedAnnotationView : BMKAnnotationView
@property (nonatomic, strong) NSMutableArray *annotationImages;
@property (nonatomic, strong) UIImageView *annotationImageView;

@end
