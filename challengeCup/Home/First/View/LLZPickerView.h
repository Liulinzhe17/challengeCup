//
//  LLZPickerView.h
//  spy on
//
//  Created by 柳麟喆 on 2017/7/3.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLZPickerView : UIView

@property (nonatomic,strong) NSArray *array;
@property (nonatomic,strong) NSString *title;

+(instancetype)pickerView;

//弹出
-(void)show;

@end
