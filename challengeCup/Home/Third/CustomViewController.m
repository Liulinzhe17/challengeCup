//
//  CustomViewController.m
//  spy on
//
//  Created by 柳麟喆 on 2017/6/23.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "CustomViewController.h"

#import "clearCache.h"


@interface CustomViewController ()<BTKTrackDelegate>

@property(nonatomic,strong)UIButton *clearCache;

@end

@implementation CustomViewController

-(UIButton *)clearCache{
    if (!_clearCache) {
        _clearCache=[[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-130,self.view.frame.size.width, 50)];
        [_clearCache setTitle:@"清理空间" forState:UIControlStateNormal];
        [_clearCache setBackgroundColor:[UIColor redColor]];
        _clearCache.titleLabel.font=[UIFont systemFontOfSize:19];
        [_clearCache addTarget:self action:@selector(clearCacheClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearCache;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title=@"用户";
//    [self.view addSubview:self.clearCache];
}

#pragma mark - 清除缓存按钮点击事件
-(void)clearCacheClicked{
    BTKClearTrackCacheRequest *request = [[BTKClearTrackCacheRequest alloc] initWithOptions:nil serviceID:SERVICE_ID tag:33];
    [[BTKTrackAction sharedInstance] clearTrackCacheWith:request delegate:self];
}
#pragma mark - 清空缓存的回调方法
-(void)onClearTrackCache:(NSData *)response{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    clearCache *clear=[[clearCache alloc]initWithDict:dic];
    if (clear.status.intValue==0) {
        [SVProgressHUD showSuccessWithStatus:clear.message];
        [SVProgressHUD dismissWithDelay:0.5];
    }else{
        [SVProgressHUD showErrorWithStatus:clear.message];
        [SVProgressHUD dismissWithDelay:0.5];
    }
}
@end
