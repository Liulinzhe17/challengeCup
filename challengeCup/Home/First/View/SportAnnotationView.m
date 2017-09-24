//
//  SportAnnotationView.m
//  spy on
//
//  Created by 柳麟喆 on 2017/7/3.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "SportAnnotationView.h"

@implementation SportAnnotationView

@synthesize imageView = _imageView;

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBounds:CGRectMake(0.f, 0.f, 22.f, 22.f)];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 22.f, 22.f)];
        _imageView.image = [UIImage imageNamed:@"ice.png"];
        [self addSubview:_imageView];
    }
    return self;
}

@end
