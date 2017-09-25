//
//  YDViewController.m
//  spy on
//
//  Created by 柳麟喆 on 2017/8/18.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "YDViewController.h"
#import "MMainViewController.h"

@interface YDViewController ()<UIScrollViewDelegate,BTKEntityDelegate>{
    UIPageControl *pageControl;
    UIScrollView *myscrollView;
    BOOL flag;//判断是否第一次使用app
}

@end

@implementation YDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startAutoGather];
    [self upLoadEntity];
    
    myscrollView=[[UIScrollView alloc]initWithFrame:LLZRect(0, 0, 1, 1)];
    for (int i=0; i<3; i++) {
        UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"YD_%d.png",i]];
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        if (i==2) {
            imageView.userInteractionEnabled=YES;
            UIButton *button=[UIButton buttonWithType:UIButtonTypeSystem];
            button.frame=CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT *7/8, SCREEN_WIDTH/3, SCREEN_HEIGHT/16);
            [button setTitle:@"立即体验" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            button.layer.borderWidth=2;
            button.clipsToBounds=YES;
            button.layer.cornerRadius=5;
            button.layer.borderColor = [UIColor blueColor].CGColor;
            [button addTarget:self action:@selector(go:) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:button];
        }
        imageView.image=image;
        [myscrollView addSubview:imageView];
    }
    myscrollView.bounces = NO;
    myscrollView.pagingEnabled = YES;
    myscrollView.showsHorizontalScrollIndicator = NO;
    myscrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, SCREEN_HEIGHT);
    myscrollView.delegate = self;
    [self.view addSubview:myscrollView];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 3, SCREEN_HEIGHT * 15 / 16, SCREEN_WIDTH / 3, SCREEN_HEIGHT / 16)];
    pageControl.numberOfPages = 3;
    pageControl.pageIndicatorTintColor = [UIColor yellowColor];
    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    
    [self.view addSubview:pageControl];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)go:(UIButton *)sender{
    flag = YES;
    // 保存用户数据
    [USER setBool:flag forKey:@"notFirst"];
    [USER synchronize];
    // 切换根视图控制器
    self.view.window.rootViewController = [[MMainViewController alloc] init];
    
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 计算当前在第几页
    pageControl.currentPage = (NSInteger)(scrollView.contentOffset.x / SCREEN_WIDTH);
}
#pragma mark - 默认自动开启采集
-(void)startAutoGather{
    [USER setBool:YES forKey:@"isAutoGather"];
}
#pragma mark - 将本机名字作为entity
-(void)upLoadEntity{
    NSString *entity=[[UIDevice currentDevice]name];
    [USER setObject:entity forKey:@"CURRENT_DEVICE_NAME"];
    //发起添加entity的请求
    [self addEntity:entity];
}
#pragma mark - 添加entity 请求
-(void)addEntity:(NSString *)entity{
    BTKAddEntityRequest *request = [[BTKAddEntityRequest alloc] initWithEntityName:entity entityDesc:nil columnKey:nil serviceID:SERVICE_ID tag:9];
    [[BTKEntityAction sharedInstance] addEntityWith:request delegate:self];
}
#pragma mark - 添加entity 回调
-(void)onAddEntity:(NSData *)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"add entity response: %@", dict);
}
@end
