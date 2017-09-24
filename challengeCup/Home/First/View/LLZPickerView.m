//
//  LLZPickerView.m
//  spy on
//
//  Created by 柳麟喆 on 2017/7/3.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "LLZPickerView.h"

@interface LLZPickerView()<UIPickerViewDelegate,UIPickerViewDataSource>

/** view */
@property (nonatomic,strong) UIView *topView;
/** button */
@property (nonatomic,strong) UIButton *doneBtn;
/** pickerView */
@property (nonatomic,strong) UIPickerView *pickerView;
/** srting */
@property (nonatomic,strong) NSString *result;

@end

@implementation LLZPickerView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:LLZRect(0, 0, 1, 917/667)];
    
    if (self)
    {
        self.backgroundColor = LLZRGBA(0, 0, 0, 0.3);
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.topView = [[UIView alloc]initWithFrame:LLZRect(0, 667/667, 1, 250/667)];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.topView];
    
    //为view上面的两个角做成圆角。不喜欢的可以注掉
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.topView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.topView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.topView.layer.mask = maskLayer;
    
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.doneBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.doneBtn setFrame:LLZRect(320/375, 5/667, 50/375, 40/667)];
    [self.doneBtn addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.doneBtn];
    
    UILabel *titlelb = [[UILabel alloc]initWithFrame:LLZRect(100/375, 0, 175/375, 50/667)];
    titlelb.backgroundColor = [UIColor clearColor];
    titlelb.textAlignment = NSTextAlignmentCenter;
    titlelb.textColor=[UIColor purpleColor];
    titlelb.text = self.title;
    titlelb.font = LLZFont(20/375);
    [self.topView addSubview:titlelb];
    
    self.pickerView = [[UIPickerView alloc]init];
    [self.pickerView setFrame:LLZRect(0, 50/667, 1, 200/667)];
    [self.pickerView setBackgroundColor:LLZRGBA(240, 239, 245, 1)];
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    [self.pickerView selectRow:0 inComponent:0 animated:YES];
    [self.topView addSubview:self.pickerView];
    
}

//快速创建
+(instancetype)pickerView;
{
    return [[self alloc]init];
}

//弹出
- (void)show
{
    [self showInView:[UIApplication sharedApplication].keyWindow];
}

//添加弹出移除的动画效果
- (void)showInView:(UIView *)view
{
    // 浮现
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint point = self.center;
        point.y -= 250;
        self.center = point;
    } completion:^(BOOL finished) {
        
    }];
    [view addSubview:self];
}

-(void)quit
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        CGPoint point = self.center;
        point.y += 250;
        self.center = point;
    } completion:^(BOOL finished) {
        if (!self.result) {
            self.result = self.array[0];
        }
        NSLog(@"%@",self.result);
        [[NSNotificationCenter defaultCenter]postNotificationName:@"time" object:self.result];
        [self removeFromSuperview];
    }];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.array count];
}

#pragma mark - 代理
// 返回第component列第row行的标题
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.array[row];
}

// 选中第component第row的时候调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.result = self.array[row];
}


@end
