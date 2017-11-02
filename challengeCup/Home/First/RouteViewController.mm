//
//  RouteViewController.m
//  spy on
//
//  Created by 柳麟喆 on 2017/6/23.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "RouteViewController.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Base/BMKTypes.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

#import "LLZPickerView.h"
#import "MyAnimatedAnnotationView.h"
#import "XMHelper.h"
#import "stayPoint.h"
#import "detailPoint.h"
#import "uploadData.h"
#import "poiModel.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]
#define BTN_WIDTH 100
#define BTN_HEIGHT 100

@interface RouteViewController ()<BTKTraceDelegate,BTKTrackDelegate,BMKMapViewDelegate,BMKLocationServiceDelegate,UITextFieldDelegate,BTKAnalysisDelegate,BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate>

@property(nonatomic,strong)BMKMapView *mapView;
@property(nonatomic,strong)BMKLocationService *locService;
@property(nonatomic,strong)BMKGeoCodeSearch* geocodesearch;
@property(nonatomic,strong)BMKRouteSearch* routesearch;

@property(nonatomic,strong)UITextField *selTime;//设置时间
@property(nonatomic,strong)UIButton *queryStart;//采集点按钮
@property(nonatomic,strong)UIButton *btnQueryStayPoint;//停留点按钮
@property(nonatomic,strong)UIButton *btnBestRoute;//最常去的路
@property(nonatomic,strong)UILabel *TimeLable;//回放时间

@property(nonatomic,strong)UIButton *btnNav;//导航按钮
@property(nonatomic,strong)UILabel *lbNotice;//提示label

@property(nonatomic,strong)NSMutableArray *selectedRoute;//提供路线的数据源
@property(nonatomic,strong)NSMutableArray *detailRoute;//路线上详细的点
@property(nonatomic,strong)stayPoint *start;//起点
@property(nonatomic,strong)stayPoint *end;//终点
@property(nonatomic,strong)NSMutableArray *test_expect;//预期时间
@property(nonatomic,strong)NSMutableArray *test_reality;//实际时间
@property(nonatomic)NSUInteger test_now;//开始导航的时间
@property(nonatomic,strong)NSMutableArray *mutArray;//存放网络获取的采集点
@property(nonatomic,strong)NSMutableArray *stayPointArray;//存放网络获取的停留点
@property(nonatomic,strong)NSMutableArray *analysisPoints;//停留点两个实例
@property(nonatomic,strong)dispatch_semaphore_t semaphore;//信号量（？？？应该是atomic吧）
@property(nonatomic,strong)dispatch_semaphore_t semaphoreOfAnalysis;

@property(nonatomic,strong)NSString *myEntity;//本机的名字
@property(nonatomic)NSInteger flag;//flag=2,回调导航的点，flag=1回调其他的点




@end

@implementation RouteViewController{
    BMKPointAnnotation *customAnnotation;//图片为point1的标注
    BMKPointAnnotation *startAnnotation;//图片为起点64的标注
    BMKPointAnnotation *endAnnotation;//图片为终点64的标注
    BMKUserLocation *currentLoc;
    BOOL isNavOver;//判断导航是否结束
}
#pragma mark - 懒加载

-(NSString *)myEntity{
    NSString *entity=[USER objectForKey:@"CURRENT_DEVICE_NAME"];
    if (!_myEntity) {
        _myEntity=entity;
    }
    return _myEntity;
}
-(NSMutableArray *)test_expect{
    if (!_test_expect) {
        _test_expect=[[NSMutableArray alloc]init];
    }
    return _test_expect
    ;
}
-(NSMutableArray *)test_reality{
    if (!_test_reality) {
        _test_reality=[[NSMutableArray alloc]init];
    }
    return _test_reality;
}
-(NSMutableArray *)selectedRoute{
    if (!_selectedRoute) {
        _selectedRoute=[[NSMutableArray alloc]init];
    }
    return _selectedRoute;
}
-(NSMutableArray *)detailRoute{
    if (!_detailRoute) {
        _detailRoute=[[NSMutableArray alloc]init];
    }
    return _detailRoute;
}
-(UIButton *)btnNav{
    if (!_btnNav) {
        _btnNav=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-BTN_WIDTH/2,self.view.frame.size.height*0.65, BTN_WIDTH, BTN_HEIGHT)];
        [_btnNav setTitle:@"开始导航" forState:UIControlStateNormal];
        _btnNav.layer.masksToBounds=YES;
        _btnNav.layer.cornerRadius=50;
        [_btnNav setBackgroundColor:[UIColor blueColor]];
        _btnNav.titleLabel.font=[UIFont systemFontOfSize:17];
        [_btnNav addTarget:self action:@selector(btnNavClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnNav;
}
-(UILabel *)lbNotice{
    if (!_lbNotice) {
        _lbNotice=[[UILabel alloc]initWithFrame:CGRectMake(0, 130, self.view.frame.size.width, 40)];
        _lbNotice.textAlignment= NSTextAlignmentCenter;
        _lbNotice.highlighted=YES;
        _lbNotice.textColor=[UIColor redColor];
        _lbNotice.text=@"未导航";
        
    }
    return _lbNotice;
}
-(NSMutableArray *)analysisPoints{
    if (!_analysisPoints) {
        _analysisPoints=[[NSMutableArray alloc]init];
    }
    return _analysisPoints;
}
-(NSMutableArray *)stayPointArray{
    if (!_stayPointArray) {
        _stayPointArray=[[NSMutableArray alloc]init];
    }
    return _stayPointArray;
}
-(NSMutableArray *)mutArray{
    if (!_mutArray) {
        _mutArray=[[NSMutableArray alloc]init];
    }
    return _mutArray;
}
-(UISwitch *)swGather{
    if (!_swGather) {
        _swGather=[[UISwitch alloc]initWithFrame:CGRectMake(35, 100, 100, 40)];
        _swGather.on = NO;
        [_swGather addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];   // 开关事件切换通知
    }
    return _swGather;
}
-(UILabel *)TimeLable{
    if (!_TimeLable) {
        _TimeLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 40)];
        _TimeLable.textAlignment= NSTextAlignmentCenter;
        _TimeLable.highlighted=YES;
        _TimeLable.textColor=[UIColor redColor];
        
    }
    return _TimeLable;
}
-(UITextField *)selTime{
    if (!_selTime) {
        _selTime = [[UITextField alloc]initWithFrame:CGRectMake(35, 40, 100, 40)];
        [_selTime setTextAlignment:NSTextAlignmentCenter];
        [_selTime setBackgroundColor:[UIColor grayColor]];
        _selTime.font=[UIFont systemFontOfSize:17];
        _selTime.text = @"七天前";
        _selTime.delegate = self;
        _selTime.textColor=[UIColor whiteColor];
    }
    return _selTime;
}
-(UIButton *)btnBestRoute{
    if (!_btnBestRoute) {
        _btnBestRoute=[[UIButton alloc]initWithFrame:CGRectMake(20+70+150, 160, 100, 40)];
        [_btnBestRoute setTitle:@"最常去的路" forState:UIControlStateNormal];
        [_btnBestRoute setBackgroundColor:[UIColor grayColor]];
        _btnBestRoute.titleLabel.font=[UIFont systemFontOfSize:17];
        [_btnBestRoute addTarget:self action:@selector(btnClickBestRoute) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnBestRoute;
}
-(UIButton *)btnQueryStayPoint{
    if (!_btnQueryStayPoint) {
        _btnQueryStayPoint=[[UIButton alloc]initWithFrame:CGRectMake(20+70+150, 100, 100, 40)];
        [_btnQueryStayPoint setTitle:@"停留点" forState:UIControlStateNormal];
        [_btnQueryStayPoint setBackgroundColor:[UIColor grayColor]];
        _btnQueryStayPoint.titleLabel.font=[UIFont systemFontOfSize:17];
        [_btnQueryStayPoint addTarget:self action:@selector(btnClickCustom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnQueryStayPoint;
}
-(UIButton *)queryStart{
    if (!_queryStart) {
        _queryStart=[[UIButton alloc]initWithFrame:CGRectMake(20+70+150, 40, 100, 40)];
        [_queryStart setTitle:@"采集点" forState:UIControlStateNormal];
        [_queryStart setBackgroundColor:[UIColor grayColor]];
        _queryStart.titleLabel.font=[UIFont systemFontOfSize:17];
        [_queryStart addTarget:self action:@selector(buttonClickStart) forControlEvents:UIControlEventTouchUpInside];
    }
    return _queryStart;
}
#pragma mark - 视图
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.mapView viewWillAppear];
//    self.mapView.delegate=self;//在updateUserPerferences里执行了
    self.geocodesearch.delegate=self;
    self.routesearch.delegate=self;
}
-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"主界面";
    
    self.geocodesearch=[[BMKGeoCodeSearch alloc]init];
    self.routesearch=[[BMKRouteSearch alloc]init];
    self.mapView=[[BMKMapView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height)];
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    self.mapView.showsUserLocation = YES;//显示定位图层
    self.mapView.mapType=BMKMapTypeStandard;
    self.mapView.zoomLevel=18;
    self.mapView.gesturesEnabled=YES;
    [self.view addSubview:self.mapView];
    
    [self.mapView addSubview:self.queryStart];
    [self.mapView addSubview:self.btnQueryStayPoint];

    [self.mapView addSubview:self.btnBestRoute];
    [self.mapView addSubview:self.selTime];
    [self.mapView addSubview:self.TimeLable];
    [self.mapView addSubview:self.swGather];
    [self.mapView addSubview:self.btnNav];
    [self.mapView addSubview:self.lbNotice];
    //第一次加载的时候更新起点终点
    self.mapView.delegate=self;
    [self addStartAndEndAnnotation:[USER objectForKey:@"startPoint"]];
    [self addStartAndEndAnnotation:[USER objectForKey:@"endPoint"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locService=[[BMKLocationService alloc]init];
        self.locService.delegate=self;
        self.locService.distanceFilter=kCLLocationAccuracyNearestTenMeters;
        [self.locService startUserLocationService];
    });

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getTime:) name:@"time" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showTrack:) name:@"seven" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showStayPointTrack:) name:@"StayPoint" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showAnalysisResult:) name:@"analysis" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUserPreferences:) name:@"settings" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addPoint:) name:@"addPoint" object:nil];
    
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.mapView viewWillDisappear];
    self.mapView.delegate=nil;
    self.geocodesearch.delegate=nil;
    self.routesearch.delegate=nil;

}
-(void)dealloc {
    if (self.geocodesearch != nil) {
        self.geocodesearch = nil;
    }
    if (self.routesearch != nil) {
        self.routesearch = nil;
    }
    if (self.mapView) {
        self.mapView = nil;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark - 向百度鹰眼发起请求
//查询停留点
-(void)queryStayPoint:(NSString *)entity startHour:(NSString *)startHour stopHour:(NSString *)stopHour{
    //纠偏选项 去燥 抽稀 不绑路 精度100 步行 半径20米内停留超过十分钟的采集点
    BTKQueryTrackProcessOption *option = [[BTKQueryTrackProcessOption alloc] init];
    option.mapMatch = false;
    option.transportMode=BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;//步行
    // 构造请求对象
    double kaishihour=[startHour doubleValue];
    double jieshuhour=[stopHour doubleValue];
    NSUInteger endTime = [[NSDate date] timeIntervalSince1970];
    BTKStayPointAnalysisRequest *request = [[BTKStayPointAnalysisRequest alloc] initWithEntityName:entity startTime:endTime - jieshuhour * 3600 endTime:endTime-kaishihour * 3600 stayTime:600 stayRadius:50 processOption:option outputCoordType:BTK_COORDTYPE_BD09LL serviceID:SERVICE_ID tag:222];
    // 发起请求
    [[BTKAnalysisAction sharedInstance] analyzeStayPointWith:request delegate:self];
}
//查询一段时间内的轨迹
-(void)queryHistoryTrack:(NSString *)entity startHour:(NSString *)startHour stopHour:(NSString *)stopHour{
    //纠偏选项 去燥 抽稀 不绑路 精度50 步行
    BTKQueryTrackProcessOption *option = [[BTKQueryTrackProcessOption alloc] init];
    option.denoise = TRUE;
    option.vacuate=TRUE;
    option.mapMatch = TRUE;
    option.radiusThreshold = 50;
    option.transportMode=BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;//步行
    // 构造请求对象
    double kaishihour=[startHour doubleValue];
    double jieshuhour=[stopHour doubleValue];
    NSUInteger endTime = [[NSDate date] timeIntervalSince1970];
    BTKQueryHistoryTrackRequest *request = [[BTKQueryHistoryTrackRequest alloc] initWithEntityName:entity startTime:endTime - jieshuhour * 3600 endTime:endTime-kaishihour * 3600 isProcessed:TRUE processOption:option supplementMode:BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING outputCoordType:BTK_COORDTYPE_BD09LL sortType:BTK_TRACK_SORT_TYPE_DESC pageIndex:1 pageSize:1000 serviceID:SERVICE_ID tag:2];
    // 发起查询请求
    [[BTKTrackAction sharedInstance] queryHistoryTrackWith:request delegate:self];
}
//时间戳查询历史轨迹
-(void)queryHistoryTrack:(NSString *)entity startcuo:(NSString *)startcuo stopcuo:(NSString *)stopcuo{
    //纠偏选项 去燥 抽稀 不绑路 精度50 步行
    BTKQueryTrackProcessOption *option = [[BTKQueryTrackProcessOption alloc] init];
    option.denoise = TRUE;
    option.vacuate=TRUE;
    option.mapMatch = TRUE;
    option.radiusThreshold = 50;
    option.transportMode=BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;//步行
    // 构造请求对象
    double kaishihour=[startcuo doubleValue];
    double jieshuhour=[stopcuo doubleValue];
    BTKQueryHistoryTrackRequest *request = [[BTKQueryHistoryTrackRequest alloc] initWithEntityName:entity startTime:kaishihour endTime:jieshuhour isProcessed:TRUE processOption:option supplementMode:BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING outputCoordType:BTK_COORDTYPE_BD09LL sortType:BTK_TRACK_SORT_TYPE_DESC pageIndex:1 pageSize:1000 serviceID:SERVICE_ID tag:2];
    // 发起查询请求
    [[BTKTrackAction sharedInstance] queryHistoryTrackWith:request delegate:self];
}
#pragma mark - btn、switch点击事件
#pragma mark最常去路线按钮点击事件
- (void)btnClickBestRoute{
    [self.analysisPoints removeAllObjects];
//    [self.RouteDic removeAllObjects];
    [self.mutArray removeAllObjects];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [SVProgressHUD show];
    if (self.stayPointArray.count<1) {
        [SVProgressHUD showErrorWithStatus:@"使用该按钮前，请先点击停留点按钮"];
        [SVProgressHUD dismissWithDelay:3.0];
        return;
    }else if (self.stayPointArray.count==1){
        [SVProgressHUD showErrorWithStatus:@"数据不充足，请多使用"];
        [SVProgressHUD dismissWithDelay:1.0];
        return;
    }
    //marr为加了rank的所有停留点
    NSMutableArray *marr=[[NSMutableArray alloc]init];
    for (int i=0;i<self.stayPointArray.count; i++) {
        NSMutableDictionary *mdic=[[NSMutableDictionary alloc]init];
        mdic=[NSMutableDictionary dictionaryWithObjectsAndKeys:[self.stayPointArray[i] objectForKey:@"start_time"],@"start_time",[self.stayPointArray[i] objectForKey:@"end_time"],@"end_time",[self.stayPointArray[i] objectForKey:@"stay_point"],@"stay_point", nil];
        NSString *str=[NSString stringWithFormat:@"%d",i];
        [mdic setValue:str forKey:@"rank"];
        [marr addObject:mdic];
    }
    //NSLog(@"停留点加rank:%@",marr);
    NSMutableDictionary *tempArr=[[NSMutableDictionary alloc]init];//存放频率的经纬度合体字典
    NSMutableArray *arr=[[NSMutableArray alloc]init];//存放经纬度合体的数组
    NSCountedSet *countedSet = [NSCountedSet set];//存放停留点加rank的集合
    for (int i = 0; i < [marr count]; i++) {
        NSDictionary *point = [marr objectAtIndex:i];
        NSNumber *longitude = [[point objectForKey:@"stay_point"]objectForKey:@"longitude"];
        NSNumber *latitude = [[point objectForKey:@"stay_point"]objectForKey:@"latitude"];
        
        NSString *lon=[XMHelper decimalwithFormat:@"0.000" doubleV:longitude.doubleValue];
        NSString *lat=[XMHelper decimalwithFormat:@"0.000" doubleV:latitude.doubleValue];
        
        
        //将所有点 放到集合里
        NSString *lonlat=[NSString stringWithFormat:@"%@,%@",lon,lat];
        [arr addObject:lonlat];
        [countedSet addObject:lonlat];
    }
    //统计每一个点出现的频率 并保存到tempArr
    for (int j=0; j<arr.count; j++) {
        NSInteger countOfObjec = [countedSet countForObject:arr[j]];
        NSString *cou=[NSString stringWithFormat:@"%d",(int)countOfObjec];
        [tempArr setObject:cou forKey:arr[j]];
    }
    //根据tempArr里的vlaue排序
    NSArray *allvalue = [tempArr allValues];
    NSArray *allkey=[tempArr allKeys];
    allvalue = [allvalue sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = [obj1 compare:obj2];
        if (result==NSOrderedAscending) {
            return NSOrderedDescending;
        }else{
            return NSOrderedSame;
        }
    }];
    //将排序好的结果存到sortArray
    NSMutableArray *sortArray=[[NSMutableArray alloc]init];
    for (int i=0; i<allvalue.count; i++) {
        if (i>0&&[allvalue[i] isEqualToString:allvalue[i-1]]) {
            continue;
        }
        for (NSString *str in allkey) {
            if ([[tempArr objectForKey:str] isEqualToString:allvalue[i]]) {
                [sortArray addObject:str];
            }
        }
    }
    //取频率最高的两个点
    NSString *lon0;
    NSString *lon1;
    NSString *lat0;
    NSString *lat1;
    if (sortArray.count>=2) {
        NSArray *a0=[sortArray[0] componentsSeparatedByString:@","];
        lon0=a0[0];
        lat0=a0[1];
        NSArray *a1=[sortArray[1] componentsSeparatedByString:@","];
        lon1=a1[0];
        lat1=a1[1];
    }else{
        [SVProgressHUD showErrorWithStatus:@"数据不充足，请多使用"];
        [SVProgressHUD dismissWithDelay:1];
    }
    //将停留点具体优化到两块区域
    NSMutableArray *optArr=[[NSMutableArray alloc]init];//频率最高的两块区域的数组
    for (int i=0; i<marr.count; i++) {
        NSDictionary *point = [marr objectAtIndex:i];
        NSNumber *longitude = [[point objectForKey:@"stay_point"]objectForKey:@"longitude"];
        NSNumber *latitude = [[point objectForKey:@"stay_point"]objectForKey:@"latitude"];
        
        NSString *lon=[XMHelper decimalwithFormat:@"0.000" doubleV:longitude.doubleValue];
        NSString *lat=[XMHelper decimalwithFormat:@"0.000" doubleV:latitude.doubleValue];
        //将marr里点的经纬度与频率最高的两个点的经纬度作比较
        if (([lon0 isEqualToString:lon]&&[lat0 isEqualToString:lat])||([lon1 isEqualToString:lon]&&[lat1 isEqualToString:lat])) {
            [optArr addObject:point];
        }
    }
    self.flag=1;
    dispatch_group_t group = dispatch_group_create();
    for (int i=0; i<optArr.count; i++) {
        if (i+1==optArr.count) {
            break;
        }else{
            if (([[optArr[i+1]objectForKey:@"rank"] intValue]-[[optArr[i]objectForKey:@"rank"] intValue])==1) {
                NSString *start=[optArr[i]objectForKey:@"end_time"];
                NSString *stop=[optArr[i+1]objectForKey:@"start_time"];
                //取相邻的任意两个停留点作起始点
                NSNumber *longitude = [[optArr[i] objectForKey:@"stay_point"]objectForKey:@"longitude"];
                NSNumber *latitude = [[optArr[i] objectForKey:@"stay_point"]objectForKey:@"latitude"];
                NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:longitude,@"longitude",latitude,@"latitude" ,nil];
                
                NSNumber *longitude1 = [[optArr[i+1] objectForKey:@"stay_point"]objectForKey:@"longitude"];
                NSNumber *latitude1 = [[optArr[i+1] objectForKey:@"stay_point"]objectForKey:@"latitude"];
                NSDictionary *dic1=[NSDictionary dictionaryWithObjectsAndKeys:longitude1,@"longitude",latitude1,@"latitude" ,nil];
                
                [self.analysisPoints addObject:dic];
                [self.analysisPoints addObject:dic1];
                
                //获取停留点间的轨迹
                if (stop.doubleValue-start.doubleValue>86400) {
                    continue;
                }
                dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    self.semaphore = dispatch_semaphore_create(0);
                    [self queryHistoryTrack:self.myEntity startcuo:start stopcuo:stop];
                    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
                });
            }
        }
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"analysis" object:self.mutArray];
    });
    
    
    
    
}
#pragma mark停留点按钮点击事件
-(void)btnClickCustom{
    //清空所有点、轨迹线、标注
    [self.analysisPoints removeAllObjects];
    [self.mutArray removeAllObjects];
//    [self.RouteDic removeAllObjects];
    [self.stayPointArray removeAllObjects];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [SVProgressHUD show];
    NSString *hour;
    hour=[self hourFromTextField];

    dispatch_group_t group = dispatch_group_create();
    for (int i=0; i<[hour intValue]/24; i++) {
        int k=i*24;
        int j=(i+1)*24;
        NSString *start=[NSString stringWithFormat:@"%d",k];
        NSString *stop=[NSString stringWithFormat:@"%d",j];
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.semaphore = dispatch_semaphore_create(0);
            [self queryStayPoint:self.myEntity startHour:start stopHour:stop];
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"StayPoint" object:self.stayPointArray];
    });

}
#pragma mark采集点按钮点击事件
-(void)buttonClickStart{
    //清空所有点、轨迹线、标注
    [self.analysisPoints removeAllObjects];
    [self.mutArray removeAllObjects];
//    [self.RouteDic removeAllObjects];
    [self.stayPointArray removeAllObjects];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [SVProgressHUD show];
    NSString *hour;
    hour=[self hourFromTextField];
    
    self.flag=1;
    dispatch_group_t group = dispatch_group_create();
    for (int i=0; i<[hour intValue]/24; i++) {
        int k=i*24;
        int j=(i+1)*24;
        NSString *start=[NSString stringWithFormat:@"%d",k];
        NSString *stop=[NSString stringWithFormat:@"%d",j];
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.semaphore = dispatch_semaphore_create(0);
            [self queryHistoryTrack:self.myEntity startHour:start stopHour:stop];
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"seven" object:self.mutArray];
    });

   
    
}
#pragma mark switch点击事件
-(void)switchAction:(UISwitch *)sender{
    UISwitch *switchButton = sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        [self startService];
        [self startGather];
    }else {
        [self stopGather];
        [self stopService];
    }
}
#pragma mark导航按钮点击事件
-(void)btnNavClicked{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    //准备数据源
    [self prepareData];
    //重置即将使用的数据
    self.test_now=0;
    isNavOver=false;
    [self.test_reality removeAllObjects];
    [self.test_expect removeAllObjects];
    if (self.selectedRoute.count<2) {
        [SVProgressHUD showErrorWithStatus:@"数据不充足，请多使用"];
        [SVProgressHUD dismissWithDelay:1];
        return;
        
    }
    NSUInteger now=[[NSDate date]timeIntervalSince1970];
    self.test_now=now;
    NSString *nowTime=[self shijiancuoToTime:[NSString stringWithFormat:@"%lu",(unsigned long)now]];
    double min=999999;
    int index=0;
    NSMutableArray *array=[[NSMutableArray alloc]init];
    for (int i=0; i<self.selectedRoute.count; i=i+2) {
        stayPoint *sp=self.selectedRoute[i];
        if ([self calculateDistanceWithStart:CLLocationCoordinate2DMake(sp.latitude.doubleValue, sp.longitude.doubleValue) end:CLLocationCoordinate2DMake(currentLoc.location.coordinate.latitude, currentLoc.location.coordinate.longitude)]<500){
            
            [array addObject:self.selectedRoute[i]];
            [array addObject:self.selectedRoute[i+1]];
        }
        
    }
    for (int i=0; i<array.count; i=i+2) {
        stayPoint *sp=array[i];
        NSString *ctime=[self shijiancuoToTime:sp.end_time];
        min=MIN(min, [XMHelper compareTime:nowTime with:ctime].doubleValue);
        if ([XMHelper compareTime:nowTime with:ctime].doubleValue==min) {
            index=i;
        }
    }
    dispatch_group_t group = dispatch_group_create();
    if (array.count<1) {
        [SVProgressHUD showErrorWithStatus:@"距离最常去的路线起点或终点太远了"];
        [SVProgressHUD dismissWithDelay:1];
    }else{
        self.start=array[index];
        self.end=array[index+1];
        self.flag=2;
        self.lbNotice.text=@"正在计算时间..";
        
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.semaphore = dispatch_semaphore_create(0);
        [self queryHistoryTrack:self.myEntity startcuo:self.start.end_time stopcuo:self.end.start_time];
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"addPoint" object:self.detailRoute];
    });
    
    
    
}

#pragma mark - 一些计算方法
//距离计算
- (double)calculateDistanceWithStart:(CLLocationCoordinate2D)start end:(CLLocationCoordinate2D)end {
    double meter = 0;
    
    double startLongitude = start.longitude;
    double startLatitude = start.latitude;
    double endLongitude = end.longitude;
    double endLatitude = end.latitude;
    
    double radLatitude1 = startLatitude * M_PI / 180.0;
    double radLatitude2 = endLatitude * M_PI / 180.0;
    double a = fabs(radLatitude1 - radLatitude2);
    double b = fabs(startLongitude * M_PI / 180.0 - endLongitude * M_PI / 180.0);
    
    double s = 22 * asin(sqrt(pow(sin(a/2),2) + cos(radLatitude1) * cos(radLatitude2) * pow(sin(b/2),2)));
    s = s * 6378137;
    
    meter = round(s * 10000) / 10000;
    return meter;
}
//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x;ltY = pt.y;
    rbX = pt.x;rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [self.mapView setVisibleMapRect:rect];
    self.mapView.zoomLevel = self.mapView.zoomLevel - 0.3;
}
//预计倒计时计算
-(double)calculateTimeWithStart:(NSString *)start end:(NSString *)end{
    return end.doubleValue-start.doubleValue;
}
//时间戳转时间(HH:mm)
-(NSString *)shijiancuoToTime:(NSString *)shijiancuo{
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:shijiancuo.intValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}
//准备数据源
-(void)prepareData{
    [SVProgressHUD show];
    if (self.stayPointArray.count<1) {
        [SVProgressHUD showErrorWithStatus:@"使用该按钮前，请先点击停留点按钮"];
        [SVProgressHUD dismissWithDelay:3.0];
        return;
    }else if (self.stayPointArray.count==1){
        [SVProgressHUD showErrorWithStatus:@"数据不充足，请多使用"];
        [SVProgressHUD dismissWithDelay:1.0];
        return;
    }else{
        //marr为加了rank的所有停留点
        NSMutableArray *marr=[[NSMutableArray alloc]init];
        for (int i=0;i<self.stayPointArray.count; i++) {
            stayPoint *sp=[[stayPoint alloc]initWithDict:self.stayPointArray[i]];
            NSString *str=[NSString stringWithFormat:@"%d",i];
            [sp setValue:str forKey:@"rank"];
            [marr addObject:sp];
        }
        NSMutableDictionary *tempArr=[[NSMutableDictionary alloc]init];//存放频率的经纬度合体字典
        NSMutableArray *arr=[[NSMutableArray alloc]init];//存放经纬度合体的数组
        NSCountedSet *countedSet = [NSCountedSet set];//存放停留点加rank的集合
        for (int i = 0; i < marr.count; i++) {
            stayPoint *point = [marr objectAtIndex:i];
            NSNumber *longitude = [point.stay_point objectForKey:@"longitude"];
            NSNumber *latitude = [point.stay_point objectForKey:@"latitude"];
            
            NSString *lon=[XMHelper decimalwithFormat:@"0.000" doubleV:longitude.doubleValue];
            NSString *lat=[XMHelper decimalwithFormat:@"0.000" doubleV:latitude.doubleValue];
            
            
            //将所有点 放到集合里
            NSString *lonlat=[NSString stringWithFormat:@"%@,%@",lon,lat];
            [arr addObject:lonlat];
            [countedSet addObject:lonlat];
        }
        //统计每一个点出现的频率 并保存到tempArr
        for (int j=0; j<arr.count; j++) {
            NSInteger countOfObjec = [countedSet countForObject:arr[j]];
            NSString *cou=[NSString stringWithFormat:@"%d",(int)countOfObjec];
            [tempArr setObject:cou forKey:arr[j]];
        }
        //根据tempArr里的vlaue排序
        NSArray *allvalue = [tempArr allValues];
        NSArray *allkey=[tempArr allKeys];
        allvalue = [allvalue sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSComparisonResult result = [obj1 compare:obj2];
            if (result==NSOrderedAscending) {
                return NSOrderedDescending;
            }else{
                return NSOrderedSame;
            }
        }];
        //将排序好的结果存到sortArray
        NSMutableArray *sortArray=[[NSMutableArray alloc]init];
        for (int i=0; i<allvalue.count; i++) {
            if (i>0&&[allvalue[i] isEqualToString:allvalue[i-1]]) {
                continue;
            }
            for (NSString *str in allkey) {
                if ([[tempArr objectForKey:str] isEqualToString:allvalue[i]]) {
                    [sortArray addObject:str];
                }
            }
        }
        //取频率最高的两个点
        NSString *lon0;
        NSString *lon1;
        NSString *lat0;
        NSString *lat1;
        if (sortArray.count>=2) {
            NSArray *a0=[sortArray[0] componentsSeparatedByString:@","];
            lon0=a0[0];
            lat0=a0[1];
            NSArray *a1=[sortArray[1] componentsSeparatedByString:@","];
            lon1=a1[0];
            lat1=a1[1];
        }else{
            NSLog(@"停留点个数小于2");
        }
        //将停留点具体优化到两块区域
        NSMutableArray *optArr=[[NSMutableArray alloc]init];//频率最高的两块区域的数组
        for (int i=0; i<marr.count; i++) {
            stayPoint *point = [marr objectAtIndex:i];
            NSNumber *longitude = [point.stay_point objectForKey:@"longitude"];
            NSNumber *latitude = [point.stay_point objectForKey:@"latitude"];
            
            NSString *lon=[XMHelper decimalwithFormat:@"0.000" doubleV:longitude.doubleValue];
            NSString *lat=[XMHelper decimalwithFormat:@"0.000" doubleV:latitude.doubleValue];
            //将marr里点的经纬度与频率最高的两个点的经纬度作比较
            if (([lon0 isEqualToString:lon]&&[lat0 isEqualToString:lat])||([lon1 isEqualToString:lon]&&[lat1 isEqualToString:lat])) {
                [optArr addObject:point];
            }
        }
        //bestRoutePoint：存放最常去的线路的起点终点信息
        NSMutableArray *bestRoutePoint=[[NSMutableArray alloc]init];
        for (int i=0; i<optArr.count; i++) {
            if (i+1==optArr.count) {
                break;
            }else{
                stayPoint *i1=optArr[i+1];
                stayPoint *i0=optArr[i];
                if (([i1.rank intValue]-[i0.rank intValue])==1) {
                    [bestRoutePoint addObject:i0];
                    [bestRoutePoint addObject:i1];
                }
            }
        }
        //移除不理想的路线
        double min=999999;
        for (int i=0; i<bestRoutePoint.count; i=i+2) {
            stayPoint *b1=bestRoutePoint[i+1];
            stayPoint *b0=bestRoutePoint[i];
            min=MIN(min, [b1.start_time doubleValue]-[b0.end_time doubleValue]);
        }
        
        [self.selectedRoute removeAllObjects];
        
        for (int i=0; i<bestRoutePoint.count; i=i+2) {
            stayPoint *b1=bestRoutePoint[i+1];
            stayPoint *b0=bestRoutePoint[i];
            if(min*3>([b1.start_time doubleValue]-[b0.end_time doubleValue])){
                [self.selectedRoute addObject:b0];
                [self.selectedRoute addObject:b1];
                NSLog(@"开始:%@,结束:%@",[self shijiancuoToTime:b0.end_time],[self shijiancuoToTime:b1.start_time]);
            }
        }
    }
    
    
}
//地图自动缩放
-(void)mapAutoZoom{
    CLLocationDegrees minLon = 180.0;
    CLLocationDegrees maxLon = -180.0;
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees maxLat = -90.0;
    for (int i=0; i<self.detailRoute.count; i++) {
        detailPoint *dp=[[detailPoint alloc]initWithDict:self.detailRoute[i]];
        minLon = MIN(minLon, dp.longitude.doubleValue);
        maxLon = MAX(maxLon, dp.longitude.doubleValue);
        minLat = MIN(minLat, dp.latitude.doubleValue);
        maxLat = MAX(maxLat, dp.latitude.doubleValue);
    }
    //起终点也要缩放的啊
    minLon = MIN(minLon, self.start.longitude.doubleValue);
    maxLon = MAX(maxLon, self.start.longitude.doubleValue);
    minLat = MIN(minLat, self.start.latitude.doubleValue);
    maxLat = MAX(maxLat, self.start.latitude.doubleValue);
    minLon = MIN(minLon, self.end.longitude.doubleValue);
    maxLon = MAX(maxLon, self.end.longitude.doubleValue);
    minLat = MIN(minLat, self.end.latitude.doubleValue);
    maxLat = MAX(maxLat, self.end.latitude.doubleValue);
    // 获取轨迹的中心点和经纬度范围，确定轨迹的经纬度区域
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake((minLat + maxLat) * 0.5f, (minLon + maxLon) * 0.5f);
    BMKCoordinateSpan viewSapn;
    // 经纬度范围乘以一个大于1的系数，以在绘制轨迹时留出边缘部分
    viewSapn.longitudeDelta = (maxLon - minLon) * 1.2;
    viewSapn.latitudeDelta = (maxLat - minLat) * 1.2;
    BMKCoordinateRegion viewRegion;
    viewRegion.center = centerCoord;
    viewRegion.span = viewSapn;
    // 设定当前地图的显示范围
    [self.mapView setRegion:viewRegion animated:YES];
}
//添加起点终点
-(void)addStartAndEndAnnotation:(NSDictionary *)dic{
    NSString *type=[dic objectForKey:@"type"];
    NSString *title=[dic objectForKey:@"address"];
    NSString *lat=[dic objectForKey:@"latitude"];
    NSString *lon=[dic objectForKey:@"longitude"];
    NSString *subtitle=[NSString stringWithFormat:@"经度：%@,纬度：%@",lon,lat];
    if ([type isEqualToString:@"1"]) {
        [self.mapView removeAnnotation:startAnnotation];
        startAnnotation = [[BMKPointAnnotation alloc]init];
        startAnnotation.title=title;
        startAnnotation.subtitle=subtitle;
        startAnnotation.coordinate=CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
        [self.mapView addAnnotation:startAnnotation];
    }else if ([type isEqualToString:@"2"]){
        [self.mapView removeAnnotation:endAnnotation];
        endAnnotation = [[BMKPointAnnotation alloc]init];
        endAnnotation.title=title;
        endAnnotation.subtitle=subtitle;
        endAnnotation.coordinate=CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
        [self.mapView addAnnotation:endAnnotation];
    }

}
#pragma mark - 弹出提醒框
-(void)showAlert{
    NSString *str=[NSString stringWithFormat:@"预期%@，实际%@",self.test_expect,self.test_reality];
    UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:@"测试" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok=[UIAlertAction actionWithTitle:@"上传数据" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        //将数据上传到Bmob后台
        [self uploadDataToBmob];
    }];
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:ok];
    [alertVC addAction:cancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}
#pragma mark - 上传数据（entity，采集时间，导航结果）
-(void)uploadDataToBmob{
    [SVProgressHUD show];
    //起始点、终点的经纬度信息
    BmobGeoPoint *startPoint=[[BmobGeoPoint alloc]initWithLongitude:self.start.longitude.doubleValue WithLatitude:self.start.latitude.doubleValue];
    BmobGeoPoint *endPoint=[[BmobGeoPoint alloc]initWithLongitude:self.end.longitude.doubleValue WithLatitude:self.end.latitude.doubleValue];
    //实体、定位周期、导航结果信息
    uploadData *udata=[[uploadData alloc]init];
    udata.entity=self.myEntity;
    NSUInteger gt=[self intervalsFromSlider:[[USER objectForKey:@"gatherTimes"]intValue]];
    udata.gatherTimes=[NSString stringWithFormat:@"%d 秒",(int)gt];
    udata.test_expect=self.test_expect;
    udata.test_reality=self.test_reality;
    NSDictionary *dic=@{@"startPoint":startPoint,
                        @"endPoint":endPoint,
                        @"entity":udata.entity,
                        @"gatherTimes":udata.gatherTimes,
                        @"test_expect":udata.test_expect,
                        @"test_reality":udata.test_reality};
    //往spyOn表添加一行数据
    BmobObject *ob = [BmobObject objectWithClassName:@"spyOn"];
    [ob saveAllWithDictionary:dic];
    
    [ob saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            [SVProgressHUD showWithStatus:@"上传成功！"];
            [SVProgressHUD dismissWithDelay:1.0];
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error]];
            [SVProgressHUD dismissWithDelay:3.0];
        }
    }];
}
#pragma mark - 选择定位周期
-(NSUInteger)intervalsFromSlider:(NSUInteger)intervals{
    NSUInteger a=30;
    switch (intervals) {
        case 0:
            a=2;break;
        case 1:
            a=5;break;
        case 2:
            a=15;break;
        case 3:
            a=30;break;
        case 4:
            a=60;break;
        case 5:
            a=180;break;
        case 6:
            a=300;break;
        default:
            break;
    }
    return a;
}
#pragma mark - 选择时间
-(NSString *)hourFromTextField{
    NSString *hour;
    if ([self.selTime.text isEqual:@"一天前"]) {
        hour=@"24";
    }else if ([self.selTime.text isEqual:@"两天前"]){
        hour=@"48";
    }else if ([self.selTime.text isEqual:@"三天前"]){
        hour=@"72";
    }else if ([self.selTime.text isEqual:@"四天前"]){
        hour=@"96";
    }else if ([self.selTime.text isEqual:@"五天前"]){
        hour=@"120";
    }else if ([self.selTime.text isEqual:@"六天前"]){
        hour=@"144";
    }else if ([self.selTime.text isEqual:@"七天前"]){
        hour=@"168";
    }else{
        hour=@"168";
    }
    return hour;
}
#pragma mark - 开启关闭服务
#pragma mark 关闭
-(void)shutDownService{
    [self stopGather];
    [self stopService];
    
}
#pragma mark 开启
-(void)openUpService{
    [self startService];
    [self startGather];
}
#pragma mark - 通知回调
//处理回调数据并且显示停留点
-(void)showStayPointTrack:(NSNotification *)noti{
    
    NSMutableArray *array=noti.object;
    // 去除经纬度为(0,0)的点 将剩余的轨迹点存储在poisWithoutZero中
    NSMutableArray *poisWithoutZero = [[NSMutableArray alloc] init]; ;
    for (int i = 0; i < [array count]; i++) {
        NSDictionary *point = [array objectAtIndex:i];
        NSNumber *longitude = [[point objectForKey:@"stay_point"]objectForKey:@"longitude"];
        NSNumber *latitude = [[point objectForKey:@"stay_point"]objectForKey:@"latitude"];
        if (fabs(longitude.doubleValue - 0) < 0.001 && fabs(latitude.doubleValue - 0) < 0.001) {
            continue;
        }
        [poisWithoutZero addObject:point];
    }
    //无停留点直接拦截
    if ([poisWithoutZero count]<1) {
        [SVProgressHUD showErrorWithStatus:@"无停留点，请多使用"];
        [SVProgressHUD dismissWithDelay:1];
        return;
    }
    
    //label信息
    self.TimeLable.text=@"以下是分析的结果";
    // 手动分配内存存储轨迹点，并获取最小经度minLon、最大经度maxLon、最小纬度minLat、最大纬度maxLat
    CLLocationCoordinate2D *locations = new CLLocationCoordinate2D[poisWithoutZero.count];
    CLLocationDegrees minLon = 180.0;
    CLLocationDegrees maxLon = -180.0;
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees maxLat = -90.0;
    //除去相邻但距离小于250米的停留点
    for (int i=0; i<[poisWithoutZero count]; i++) {
        if (i+1<poisWithoutZero.count) {
            NSDictionary *point = [poisWithoutZero objectAtIndex:i];
            NSDictionary *point1=[poisWithoutZero objectAtIndex:i+1];
            NSNumber *startLon = [[point objectForKey:@"stay_point"]objectForKey:@"longitude"];
            NSNumber *startLat = [[point objectForKey:@"stay_point"]objectForKey:@"latitude"];
            NSNumber *endLon = [[point1 objectForKey:@"stay_point"]objectForKey:@"longitude"];
            NSNumber *endLat = [[point1 objectForKey:@"stay_point"]objectForKey:@"latitude"];
            
            double meter=[self calculateDistanceWithStart:CLLocationCoordinate2DMake(startLat.doubleValue, startLon.doubleValue) end:CLLocationCoordinate2DMake(endLat.doubleValue, endLon.doubleValue)];
            //NSLog(@"%d和%d的meter:%f",i,i+1,meter);
            if (meter<250) {
                [poisWithoutZero removeObjectAtIndex:i+1];
                i--;
            }
            
        }
    }
    //把处理好的poisWithoutZero替换掉stayPointArray
    [self.stayPointArray removeAllObjects];
    self.stayPointArray=[NSMutableArray arrayWithArray:poisWithoutZero];
    
    for (int i = 0; i < [poisWithoutZero count]; i++) {
        NSDictionary *point = [poisWithoutZero objectAtIndex:i];
        NSNumber *longitude = [[point objectForKey:@"stay_point"]objectForKey:@"longitude"];
        NSNumber *latitude = [[point objectForKey:@"stay_point"]objectForKey:@"latitude"];
        
        
        minLon = MIN(minLon, longitude.doubleValue);
        maxLon = MAX(maxLon, longitude.doubleValue);
        minLat = MIN(minLat, latitude.doubleValue);
        maxLat = MAX(maxLat, latitude.doubleValue);
        
        locations[i] = CLLocationCoordinate2DMake(latitude.doubleValue,longitude.doubleValue);
        BMKPointAnnotation *a1=[[BMKPointAnnotation alloc]init];
        a1.coordinate=locations[i];
        
        NSString *startTime=[point objectForKey:@"start_time"];
        NSString *endTime=[point objectForKey:@"end_time"];
        NSString *lon=[NSString stringWithFormat:@"%@",longitude];
        NSString *lat=[NSString stringWithFormat:@"%@",latitude];
        NSString *title=[NSString stringWithFormat:@"%d.%@到%@",i,[XMHelper timeFromTimeStamp:startTime],[XMHelper timeFromTimeStamp:endTime]];
        NSString *subtitle=[NSString stringWithFormat:@"经度：%.7f，纬度：%.7f",lon.doubleValue,lat.doubleValue];
        a1.title=title;
        a1.subtitle=subtitle;
        [self.mapView addAnnotation:a1];
    }
    
    
    
    // 获取轨迹的中心点和经纬度范围，确定轨迹的经纬度区域
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake((minLat + maxLat) * 0.5f, (minLon + maxLon) * 0.5f);
    BMKCoordinateSpan viewSapn;
    // 经纬度范围乘以一个大于1的系数，以在绘制轨迹时留出边缘部分
    viewSapn.longitudeDelta = (maxLon - minLon) * 1.2;
    viewSapn.latitudeDelta = (maxLat - minLat) * 1.2;
    BMKCoordinateRegion viewRegion;
    viewRegion.center = centerCoord;
    viewRegion.span = viewSapn;
    
    // 回到主线程，绘制轨迹线
    dispatch_async(dispatch_get_main_queue(), ^{
        if (poisWithoutZero.count > 1) {
            // 设定当前地图的显示范围
            [self.mapView setRegion:viewRegion animated:YES];
        } else {
            NSLog(@"停留点小于两个");
        }
    });
    
    delete [] locations;
    
    
}
//处理回调数据并且显示轨迹
-(void)showTrack:(NSNotification *)noti{
    
    NSMutableArray *array=noti.object;
    // 去除经纬度为(0,0)的点 将剩余的轨迹点存储在poisWithoutZero中
    NSMutableArray *poisWithoutZero = [[NSMutableArray alloc] init]; ;
    for (int i = 0; i < [array count]; i++) {
        NSDictionary *point = [array objectAtIndex:i];
        NSNumber *longitude = [point objectForKey:@"longitude"];
        NSNumber *latitude = [point objectForKey:@"latitude"];
        if (fabs(longitude.doubleValue - 0) < 0.001 && fabs(latitude.doubleValue - 0) < 0.001) {
            continue;
        }
        [poisWithoutZero addObject:point];
    }
    //没有数据直接拦截
    if ([poisWithoutZero count]<1) {
        [SVProgressHUD showErrorWithStatus:@"无采集点，请多使用"];
        [SVProgressHUD dismissWithDelay:1];
        return;
    }else{
        [SVProgressHUD showSuccessWithStatus:@"查询成功"];
        [SVProgressHUD dismissWithDelay:0.5];
    }
    // 手动分配内存存储轨迹点，并获取最小经度minLon、最大经度maxLon、最小纬度minLat、最大纬度maxLat
    CLLocationCoordinate2D *locations = new CLLocationCoordinate2D[poisWithoutZero.count];
    CLLocationDegrees minLon = 180.0;
    CLLocationDegrees maxLon = -180.0;
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees maxLat = -90.0;
    
    for (int i = 0; i < [poisWithoutZero count]; i++) {
        NSDictionary *point = [poisWithoutZero objectAtIndex:i];
        NSNumber *longitude = [point objectForKey:@"longitude"];
        NSNumber *latitude = [point objectForKey:@"latitude"];
        
        minLon = MIN(minLon, longitude.doubleValue);
        maxLon = MAX(maxLon, longitude.doubleValue);
        minLat = MIN(minLat, latitude.doubleValue);
        maxLat = MAX(maxLat, latitude.doubleValue);
        
        locations[i] = CLLocationCoordinate2DMake(latitude.doubleValue,longitude.doubleValue);
        //以标注的形式添加到地图上
        customAnnotation=[[BMKPointAnnotation alloc]init];
        customAnnotation.coordinate=locations[i];
        customAnnotation.title=[XMHelper timeFromTimeStamp:[[poisWithoutZero objectAtIndex:i]objectForKey:@"loc_time"]] ;
        [self.mapView addAnnotation:customAnnotation];
        
    }
    //label信息
    NSDictionary *lableInfo=[poisWithoutZero objectAtIndex:[poisWithoutZero count]-1];
    NSString *lastTime=[lableInfo objectForKey:@"loc_time"];
    NSString *confromTimespStr=[XMHelper timeFromTimeStamp:lastTime];
    NSString *str=[NSString stringWithFormat:@"正在为你回放轨迹至%@",confromTimespStr];
    self.TimeLable.text=str;
    
    // 获取轨迹的中心点和经纬度范围，确定轨迹的经纬度区域
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake((minLat + maxLat) * 0.5f, (minLon + maxLon) * 0.5f);
    BMKCoordinateSpan viewSapn;
    // 经纬度范围乘以一个大于1的系数，以在绘制轨迹时留出边缘部分
    viewSapn.longitudeDelta = (maxLon - minLon) * 1.2;
    viewSapn.latitudeDelta = (maxLat - minLat) * 1.2;
    BMKCoordinateRegion viewRegion;
    viewRegion.center = centerCoord;
    viewRegion.span = viewSapn;
    
    if (poisWithoutZero.count > 1) {
        // 设定当前地图的显示范围
        [self.mapView setRegion:viewRegion animated:YES];
    } else {
        NSLog(@"采集点小于2个");
    }
    
    delete [] locations;
    
}
//处理回调数据并且显示最常去的线路
-(void)showAnalysisResult:(NSNotification *)noti{
    //如果没有常去的两个停留点
    if (self.analysisPoints.count<2) {
        [SVProgressHUD showErrorWithStatus:@"数据不充足，请多使用"];
        [SVProgressHUD dismissWithDelay:1];
        return;
    }
    //cusArr最常去的两块区域间的轨迹点
    NSMutableArray *cusArr=noti.object;
    //8频率字典
    NSMutableDictionary *ArrRate=[[NSMutableDictionary alloc]init];
    // 手动分配内存存储轨迹点，并获取最小经度minLon、最大经度maxLon、最小纬度minLat、最大纬度maxLat
    CLLocationCoordinate2D *locations = new CLLocationCoordinate2D[cusArr.count];
    CLLocationDegrees minLon = 180.0;
    CLLocationDegrees maxLon = -180.0;
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees maxLat = -90.0;
    
    NSMutableArray *arr=[[NSMutableArray alloc]init];//存放轨迹点的数组
    NSCountedSet *countedSet = [NSCountedSet set];//存放轨迹点的集合
    for (int i = 0; i < [cusArr count]; i++) {
        NSDictionary *point = [cusArr objectAtIndex:i];
        NSNumber *longitude = [point objectForKey:@"longitude"];
        NSNumber *latitude = [point objectForKey:@"latitude"];
        
        NSString *lon=[XMHelper decimalwithFormat:@"0.0000" doubleV:longitude.doubleValue];
        NSString *lat=[XMHelper decimalwithFormat:@"0.0000" doubleV:latitude.doubleValue];
        
        
        //将所有点 放到集合里
        NSString *lonlat=[NSString stringWithFormat:@"%@,%@",lon,lat];
        [arr addObject:lonlat];
        [countedSet addObject:lonlat];
    }
    //统计每一个点出现的频率 并保存到ArrRate
    for (int j=0; j<arr.count; j++) {
        NSInteger countOfObjec = [countedSet countForObject:arr[j]];
        NSString *cou=[NSString stringWithFormat:@"%d",(int)countOfObjec];
        [ArrRate setObject:cou forKey:arr[j]];
    }
    //根据ArrRate里的vlaue排序
    NSArray *allvalue = [ArrRate allValues];
    NSArray *allkey=[ArrRate allKeys];
    allvalue = [allvalue sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = [obj1 compare:obj2];
        if (result==NSOrderedAscending) {
            return NSOrderedDescending;
        }else{
            return NSOrderedSame;
        }
    }];
    //将排序好的结果存到sortArray
    NSMutableArray *sortArray=[[NSMutableArray alloc]init];
    for (int i=0; i<allvalue.count; i++) {
        if (i>0&&[allvalue[i] isEqualToString:allvalue[i-1]]) {
            continue;
        }
        for (NSString *str in allkey) {
            if ([[ArrRate objectForKey:str] isEqualToString:allvalue[i]]) {
                [sortArray addObject:str];
            }
        }
    }
    NSMutableArray *highRatePoint=[[NSMutableArray alloc]init];
    //取频率最高的前八个点 加标注
    if (sortArray.count>=8) {
        for (int i=0; i<8; i++) {
            NSArray *a=[sortArray[i] componentsSeparatedByString:@","];
            NSString *lon=a[0];
            NSString *lat=a[1];
            NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:lon,@"longitude",lat,@"latitude", nil];
            [highRatePoint addObject:dic];
            customAnnotation=[[BMKPointAnnotation alloc]init];
            customAnnotation.coordinate=CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
            [self.mapView addAnnotation:customAnnotation];
            locations[i] = CLLocationCoordinate2DMake(lat.doubleValue,lon.doubleValue);
            minLon = MIN(minLon, lon.doubleValue);
            maxLon = MAX(maxLon, lon.doubleValue);
            minLat = MIN(minLat, lat.doubleValue);
            maxLat = MAX(maxLat, lat.doubleValue);
        }
    }else{
        for (int i=0; i<sortArray.count; i++) {
            NSArray *a=[sortArray[i] componentsSeparatedByString:@","];
            NSString *lon=a[0];
            NSString *lat=a[1];
            NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:lon,@"longitude",lat,@"latitude", nil];
            [highRatePoint addObject:dic];
            customAnnotation=[[BMKPointAnnotation alloc]init];
            customAnnotation.coordinate=CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
            [self.mapView addAnnotation:customAnnotation];
            locations[i] = CLLocationCoordinate2DMake(lat.doubleValue,lon.doubleValue);
            minLon = MIN(minLon, lon.doubleValue);
            maxLon = MAX(maxLon, lon.doubleValue);
            minLat = MIN(minLat, lat.doubleValue);
            maxLat = MAX(maxLat, lat.doubleValue);
        }
    }
    delete [] locations;
    //开始路径规划
    NSMutableArray *saveSortedArr=[[NSMutableArray alloc]init];//存放排好序的高频率点
    NSMutableArray *tempArr=[NSMutableArray arrayWithArray:highRatePoint];
    
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    NSNumber *lat=[self.analysisPoints[0]objectForKey:@"latitude"];
    NSNumber *lon=[self.analysisPoints[0]objectForKey:@"longitude"];
    start.pt=CLLocationCoordinate2DMake(lat.doubleValue,lon.doubleValue);
    minLon = MIN(minLon, lon.doubleValue);
    maxLon = MAX(maxLon, lon.doubleValue);
    minLat = MIN(minLat, lat.doubleValue);
    maxLat = MAX(maxLat, lat.doubleValue);
    customAnnotation=[[BMKPointAnnotation alloc]init];
    customAnnotation.coordinate=CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
    [self.mapView addAnnotation:customAnnotation];
    [saveSortedArr addObject:start];
    
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    NSNumber *lat1=[self.analysisPoints[1]objectForKey:@"latitude"];
    NSNumber *lon1=[self.analysisPoints[1]objectForKey:@"longitude"];
    end.pt=CLLocationCoordinate2DMake(lat1.doubleValue, lon1.doubleValue);
    minLon = MIN(minLon, lon1.doubleValue);
    maxLon = MAX(maxLon, lon1.doubleValue);
    minLat = MIN(minLat, lat1.doubleValue);
    maxLat = MAX(maxLat, lat1.doubleValue);
    customAnnotation=[[BMKPointAnnotation alloc]init];
    customAnnotation.coordinate=CLLocationCoordinate2DMake(lat1.doubleValue, lon1.doubleValue);
    [self.mapView addAnnotation:customAnnotation];
    
    
    
    BMKPlanNode *temp=[[BMKPlanNode alloc]init];
    for (int j=0; j<highRatePoint.count; j++) {
        int k=0;
        BMKPlanNode *min=[[BMKPlanNode alloc]init];
        NSNumber *lat2=[tempArr[0]objectForKey:@"latitude"];
        NSNumber *lon2=[tempArr[0]objectForKey:@"longitude"];
        min.pt=CLLocationCoordinate2DMake(lat2.doubleValue, lon2.doubleValue);
        temp=min;
        double minDistance=[self calculateDistanceWithStart:start.pt end:min.pt];
        
        for (int i=0; i<tempArr.count; i++) {
            
            BMKPlanNode *middle=[[BMKPlanNode alloc]init];
            NSNumber *latMid=[tempArr[i]objectForKey:@"latitude"];
            NSNumber *lonMid=[tempArr[i]objectForKey:@"longitude"];
            middle.pt=CLLocationCoordinate2DMake(latMid.doubleValue, lonMid.doubleValue);
            
            if (minDistance>[self calculateDistanceWithStart:start.pt end:middle.pt]) {
                minDistance=[self calculateDistanceWithStart:start.pt end:middle.pt];
                k=i;
                temp=middle;
                
            }
        }
        //加高频率点至saveSortedArr
        BMKPlanNode *node=[[BMKPlanNode alloc]init];
        NSNumber *la=[[tempArr objectAtIndex:k]objectForKey:@"latitude"];
        NSNumber *lo=[[tempArr objectAtIndex:k]objectForKey:@"longitude"];
        node.pt=CLLocationCoordinate2DMake(la.doubleValue, lo.doubleValue);
        [saveSortedArr addObject:node];
        
        [tempArr removeObjectAtIndex:k];
        start=temp;
        
    }
    [saveSortedArr addObject:end];
    
    dispatch_group_t group = dispatch_group_create();
    BMKWalkingRoutePlanOption *walkingRouteSearchOption = [[BMKWalkingRoutePlanOption alloc]init];
    //步行路线检索
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int k=0; k<saveSortedArr.count-1; k++) {
            walkingRouteSearchOption.from=[saveSortedArr objectAtIndex:k];
            walkingRouteSearchOption.to=[saveSortedArr objectAtIndex:k+1];
            self.semaphoreOfAnalysis = dispatch_semaphore_create(0);
            [self.routesearch walkingSearch:walkingRouteSearchOption];
            dispatch_semaphore_wait(self.semaphoreOfAnalysis, DISPATCH_TIME_FOREVER);
        }
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
    });
    
    
    
    
    // 获取轨迹的中心点和经纬度范围，确定轨迹的经纬度区域
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake((minLat + maxLat) * 0.5f, (minLon + maxLon) * 0.5f);
    BMKCoordinateSpan viewSapn;
    // 经纬度范围乘以一个大于1的系数，以在绘制轨迹时留出边缘部分
    viewSapn.longitudeDelta = (maxLon - minLon) * 1.2;
    viewSapn.latitudeDelta = (maxLat - minLat) * 1.2;
    BMKCoordinateRegion viewRegion;
    viewRegion.center = centerCoord;
    viewRegion.span = viewSapn;
    
    
    // 设定当前地图的显示范围
    [self.mapView setRegion:viewRegion animated:YES];
    
    //清除mutArray,防止影响常去路线按钮
    [self.mutArray removeAllObjects];
    
    
    
}
//加标注
-(void)addPoint:(NSNotification *)noti{
    //拦截
    NSMutableArray *arr=noti.object;
    if (arr.count<1) {
        return;
    }
    customAnnotation=[[BMKPointAnnotation alloc]init];
    customAnnotation.coordinate=CLLocationCoordinate2DMake(self.start.latitude.doubleValue, self.start.longitude.doubleValue);
    customAnnotation.title=[self shijiancuoToTime:self.start.end_time];
    [self.mapView addAnnotation:customAnnotation];
    
    customAnnotation=[[BMKPointAnnotation alloc]init];
    customAnnotation.coordinate=CLLocationCoordinate2DMake(self.end.latitude.doubleValue, self.end.longitude.doubleValue);
    customAnnotation.title=[self shijiancuoToTime:self.end.start_time];
    [self.mapView addAnnotation:customAnnotation];
    
    for (int i=0; i<self.detailRoute.count; i++) {
        detailPoint *p=[[detailPoint alloc]initWithDict:self.detailRoute[i]];
        customAnnotation=[[BMKPointAnnotation alloc]init];
        customAnnotation.coordinate=CLLocationCoordinate2DMake(p.latitude.doubleValue, p.longitude.doubleValue);
        customAnnotation.title=[self shijiancuoToTime:p.loc_time];
        [self.mapView addAnnotation:customAnnotation];
    }
    //倒计时（end-start）
    double time=[self calculateTimeWithStart:self.start.end_time end:self.end.start_time];
    self.lbNotice.text=[NSString stringWithFormat:@"预计%.0f秒到达目的地",time];
    //自动调整地图大小
    [self mapAutoZoom];
}

//通知-获取选择时间
-(void)getTime:(NSNotification *)notification{
    self.selTime.text=notification.object;
}
//更新用户配置
-(void)updateUserPreferences:(NSNotification *)noti{
    self.mapView.delegate=self;
    //更新采集上传时间
    NSUInteger intervals=[[USER objectForKey:@"gatherTimes"] intValue];
    NSUInteger a=30;
    a=[self intervalsFromSlider:intervals];
    [[BTKAction sharedInstance] changeGatherAndPackIntervals:a packInterval:a delegate:self];
    //更新起点终点
    [self addStartAndEndAnnotation:[USER objectForKey:@"startPoint"]];
    [self addStartAndEndAnnotation:[USER objectForKey:@"endPoint"]];
}
#pragma mark - 代理方法
#pragma mark - UITextFieldDelegate代理方法
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    LLZPickerView *picker=[[LLZPickerView alloc]init];
    picker.array=@[@"一天前",@"两天前",@"三天前",@"四天前",@"五天前",@"六天前",@"七天前"];
    picker.title=@"选择时间";
    [picker show];
    return NO;
}
#pragma mark - BTKAnalysisDelegate代理方法
//停留点分析的回调方法
-(void)onAnalyzeStayPoint:(NSData *)response{
    // JSON数据解析
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *message = [dic objectForKey:@"message"];

    if ([status longValue] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"分析成功"];
            [SVProgressHUD dismissWithDelay:0.5];
        });
        NSArray *array=[dic objectForKey:@"stay_points"];
        [self.stayPointArray addObjectsFromArray:array];
       
        NSSortDescriptor *des1 = [NSSortDescriptor sortDescriptorWithKey:@"end_time" ascending:YES];
        [self.stayPointArray sortUsingDescriptors:@[des1]];
        NSLog(@"%@：停留点一共请求完成了:%d",message,(int)self.stayPointArray.count);
        //NSLog(@"停留点：%@",self.stayPointArray);
        dispatch_semaphore_signal(self.semaphore);
    }else{
        dispatch_semaphore_signal(self.semaphore);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",message]];
            [SVProgressHUD dismissWithDelay:2.0];
        });
    }

}
#pragma mark - BTKTrackDelegate代理方法
//轨迹查询的回调方法
-(void)onQueryHistoryTrack:(NSData *)response{
    
    // JSON数据解析
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *message = [dic objectForKey:@"message"];

    if (self.flag==1) {
        if ([status longValue] == 0) {
            NSArray *array=[dic objectForKey:@"points"];
            [self.mutArray addObjectsFromArray:array];
            NSSortDescriptor *des2 = [NSSortDescriptor sortDescriptorWithKey:@"loc_time" ascending:NO];
            [self.mutArray sortUsingDescriptors:@[des2]];
            //删除掉速度为0的点
//            NSMutableArray *arr=[[NSMutableArray alloc]init];
//            arr=self.mutArray;
//            for (NSUInteger i=0; i<arr.count; i++) {
//                NSString *speed=[arr[i]objectForKey:@"speed"];
//                if ((speed.doubleValue-0)<=0.00001) {
//                    [self.mutArray removeObjectAtIndex:i];
//                }
//            }
            NSLog(@"%@:采集点一共请求完成了:%d",message,(int)self.mutArray.count);
            dispatch_semaphore_signal(self.semaphore);
        }else{
            dispatch_semaphore_signal(self.semaphore);
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",message]];
            [SVProgressHUD dismissWithDelay:2.0];
        }
    }else if(self.flag==2){
        if ([status longValue] == 0) {
            [SVProgressHUD showWithStatus:@"智能计算中..."];
            [SVProgressHUD dismissWithDelay:0.5];
            NSMutableArray *array=[dic objectForKey:@"points"];
            //删除掉速度为0的点
            for (NSUInteger i=0; i<array.count; i++) {
                NSString *speed=[array[i]objectForKey:@"speed"];
                if ((speed.doubleValue-0)<=0.00001) {
                    [array removeObjectAtIndex:i];
                }
            }
            NSLog(@"导航一共请求完成了:%d",(int)array.count);
            [self.detailRoute removeAllObjects];
            self.detailRoute=array;
            dispatch_semaphore_signal(self.semaphore);
        }else{
            dispatch_semaphore_signal(self.semaphore);
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",message]];
            [SVProgressHUD dismissWithDelay:2.0];
        }

    }

}
#pragma mark - BMKGeoCodeSearchDelegate代理方法
//逆地理编码回调方法
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        //注释代码内容：根据回调的地理位置，增加标注
//        CLLocationCoordinate2D coor=result.location;
//        customAnnotation=[[BMKPointAnnotation alloc]init];
//        customAnnotation.coordinate=coor;
//        customAnnotation.title=@"地点";
//        customAnnotation.subtitle=result.address;
//        [self.mapView selectAnnotation:customAnnotation animated:NO];
//        [self.mapView addAnnotation:customAnnotation];
        NSLog(@"逆地理编码成功");
        
    }else{
        NSLog(@"逆地理编码error：%d",error);
    }
}
#pragma mark - BMKRouteSearchDelegate代理方法
//步行路径规划回调方法
- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    [SVProgressHUD dismiss];
    //[self.mapView removeOverlays:self.mapView.overlays];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)[result.routes objectAtIndex:0];
        //size路段的个数
        NSInteger size = [plan.steps count];
        //路段上点集合的个数
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:i];
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
            for(int k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过temppoints构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [self.mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        //[self mapViewFitPolyLine:polyLine];
    }else{
        NSLog(@"步行路径规划回调error:%d",error);
    }
    dispatch_semaphore_signal(self.semaphoreOfAnalysis);
}

#pragma mark - BMKMapViewDelegate代理方法
//标注点击事件
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{}
// 根据overlay生成对应的View
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
        polylineView.lineWidth = 2.0;
        
        return polylineView;
    }
    return nil;
}
// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if (annotation==customAnnotation)
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
            
        }
        annotationView.image = [UIImage imageNamed:@"point1.png"];
        annotationView.canShowCallout=YES;
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, 5);
        return annotationView;
    }
    if (annotation==startAnnotation)
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
            
        }
        annotationView.image = [UIImage imageNamed:@"起点64.png"];
        annotationView.canShowCallout=YES;
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, 5);
        return annotationView;
    }
    if (annotation==endAnnotation)
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
            
        }
        annotationView.image = [UIImage imageNamed:@"终点64.png"];
        annotationView.canShowCallout=YES;
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, 5);
        return annotationView;
    }
    //动画annotation
    NSString *AnnotationViewID = @"AnimatedAnnotation";
    MyAnimatedAnnotationView *annotationView = nil;
    if (annotationView == nil) {
        annotationView = [[MyAnimatedAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 1; i < 4; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"poi_%d.png", i]];
        [images addObject:image];
    }
    annotationView.annotationImages = images;
    annotationView.canShowCallout=YES;
    return annotationView;
    
}
#pragma mark - BMKLocationServiceDelegate代理方法
//用户方向更新后，会调用此函数
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [self.mapView updateLocationData:userLocation];
}
//用户位置更新后，会调用此函数
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    currentLoc=userLocation;
    [self.mapView updateLocationData:userLocation];
    if (self.detailRoute.count>1) {
        if (!isNavOver) {
            NSUInteger now=[[NSDate date]timeIntervalSince1970];
            NSUInteger result=(now-self.test_now);//实际时间
            double distance=[self calculateDistanceWithStart:CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude) end:CLLocationCoordinate2DMake(self.end.latitude.doubleValue, self.end.longitude.doubleValue)];
            if (distance<200) {
                isNavOver=true;
                self.lbNotice.text=@"你已经到达目的地.";
                double time=0;;
                if ([self.test_expect containsObject:[NSString stringWithFormat:@"%.0f",time]]) {
                    
                }else{
                    [self.test_expect addObject:[NSString stringWithFormat:@"%.0f",time]];
                    [self.test_reality addObject:[NSString stringWithFormat:@"%lu",(unsigned long)result]];
                }
                [self showAlert];
            }else{
                double min=99999;
                int index=(int)(self.detailRoute.count-1);
                for (int i=(int)(self.detailRoute.count-1); i>=0; i--) {
                    detailPoint *dp=[[detailPoint alloc]initWithDict:self.detailRoute[i]];
                    min=MIN(min, [self calculateDistanceWithStart:CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude) end:CLLocationCoordinate2DMake(dp.latitude.doubleValue, dp.longitude.doubleValue)]);
                    if (min==[self calculateDistanceWithStart:CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude) end:CLLocationCoordinate2DMake(dp.latitude.doubleValue, dp.longitude.doubleValue)]) {
                        index=i;
                    }
                }
                
                detailPoint *p=[[detailPoint alloc]initWithDict:self.detailRoute[index]];
                double time=[self calculateTimeWithStart:p.loc_time end:self.end.start_time];
                self.lbNotice.text=[NSString stringWithFormat:@"预计%.0f秒到达目的地",time];
                
                if ([self.test_expect containsObject:[NSString stringWithFormat:@"%.0f",time]]) {
                    
                }else{
                    [self.test_expect addObject:[NSString stringWithFormat:@"%.0f",time]];
                    [self.test_reality addObject:[NSString stringWithFormat:@"%lu",(unsigned long)result]];
                    
                }
            }
            
        }
        
    }

}

#pragma mark - BTKTraceDelegate代理方法
//停止轨迹服务的回调方法
-(void)onStopService:(BTKServiceErrorCode) error{
    if ((int)error==8) {
        NSLog(@"停止服务：成功");
    }else{
        NSLog(@"停止服务：失败");
    }
}
//停止采集的回调方法
-(void)onStopGather:(BTKGatherErrorCode) error{
    if ((int)error==6) {
        NSLog(@"停止采集：成功");
    }else{
        NSLog(@"停止采集：失败");
    }
}
//开启轨迹服务的回调方法
-(void)onStartService:(BTKServiceErrorCode) error{
    if ((int)error==0) {
        NSLog(@"开始服务：成功");
    }else{
        NSLog(@"开始服务：失败");
    }
}
//开始采集的回调方法
-(void)onStartGather:(BTKGatherErrorCode) error{
    if ((int)error==0) {
        NSLog(@"开始采集：成功");
    }else{
        NSLog(@"开始采集：失败");
    }
}
//更改采集和打包上传周期的结果的回调方法
-(void)onChangeGatherAndPackIntervals:(BTKChangeIntervalErrorCode) error{
    if ((int)error==0) {
        NSLog(@"更改定位周期的结果：成功");
    }else{
        NSLog(@"更改定位周期的结果：失败");
    }
    
}
#pragma mark - 和百度鹰眼交互
//开启轨迹服务
-(void) startService {
    // 设置开启轨迹服务时的服务选项，指定本次服务以“entityA”的名义开启
    BTKStartServiceOption *op = [[BTKStartServiceOption alloc] initWithEntityName:self.myEntity];
    // 开启服务
    [[BTKAction sharedInstance] startService:op delegate:self];
    [[BTKAction sharedInstance] setLocationAttributeWithActivityType:CLActivityTypeOther desiredAccuracy:kCLLocationAccuracyNearestTenMeters distanceFilter:10];
}
//关闭轨迹服务
-(void) stopService {
    [[BTKAction sharedInstance] stopService:self];
}
//开始采集
-(void) startGather{
    [[BTKAction sharedInstance] startGather:self];
}
//停止采集
-(void) stopGather{
    [[BTKAction sharedInstance] stopGather:self];
}
#pragma mark - ??????
- (NSString*)getMyBundlePath1:(NSString *)filename
{
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}
@end


