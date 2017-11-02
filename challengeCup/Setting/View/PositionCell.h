//
//  PositionCell.h
//  challengeCup
//
//  Created by 柳麟喆 on 2017/10/28.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PositionCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *startIMG;
@property (strong, nonatomic) IBOutlet UIImageView *endIMG;
@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *endLabel;

@end
