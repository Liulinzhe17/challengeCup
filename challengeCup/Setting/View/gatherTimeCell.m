//
//  gatherTimeCell.m
//  spy on
//
//  Created by 柳麟喆 on 2017/8/31.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "gatherTimeCell.h"

@implementation gatherTimeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //cell不可选中
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        [self addSubview:self.slider];
        
    }
    return self;
}
#pragma mark - 懒加载
-(customSlider *)slider{
    if (!_slider) {
        _slider=[[customSlider alloc]initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 55)];
        _slider.backgroundColor = [UIColor whiteColor];
        _slider.sliderBarHeight = 1;
        _slider.numberOfPart = 7;
        _slider.thumbImage = [UIImage imageNamed:@"spyon_chicken.png"];
        _slider.partNameOffset = CGPointMake(0, -15);
        _slider.thumbSize = CGSizeMake(20, 20);
        _slider.partSize = CGSizeMake(2, 10);
        _slider.partColor=[UIColor lightGrayColor];
        _slider.partNameArray = @[@"2秒",@"5秒",@"15秒",@"30秒",@"1分钟",@"3分钟",@"5分钟"];
        [_slider addTarget:self action:@selector(sliderValueChange) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}
#pragma mark - 滑条触发事件
-(void)sliderValueChange{
    //NSLog(@"current index = %d",(int)self.slider.value);
    
}
@end
