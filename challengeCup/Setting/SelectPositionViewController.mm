//
//  SelectPositionViewController.m
//  challengeCup
//
//  Created by 柳麟喆 on 2017/10/28.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "SelectPositionViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Base/BMKTypes.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "poiModel.h"

@interface SelectPositionViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)BMKMapView *map;
@property(nonatomic,strong)BMKLocationService *locService;
@property(nonatomic,strong)BMKGeoCodeSearch *geocodesearch;
@property(nonatomic,strong)UITableView *mapTableView;

@property(nonatomic,strong)NSMutableArray *poiArr;//大小为11的poi数组

@end

@implementation SelectPositionViewController{
    BMKPointAnnotation *divAnnotation;//图片为（起点/终点）64的标注
    BOOL isFirst;//isFirst为yes：第一次进入否则为no
    int cellIndex;//被选中cell的索引
}
#pragma mark - 懒加载
-(UITableView *)mapTableView{
    if (!_mapTableView) {
        _mapTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 10+SCREEN_HEIGHT/2, SCREEN_WIDTH, SCREEN_HEIGHT/2-10) style:UITableViewStylePlain];
        _mapTableView.delegate=self;
        _mapTableView.dataSource=self;
        _mapTableView.backgroundColor=LLZRGBA(255, 255, 255, 1.0);
    }
    return _mapTableView;
}
-(NSMutableArray *)poiArr{
    if (!_poiArr) {
        _poiArr=[[NSMutableArray alloc]init];
    }
    return _poiArr;
}
#pragma mark - 视图
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.map viewWillAppear];
    self.map.delegate=self;
    self.geocodesearch.delegate=self;
    isFirst=YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeNavTitle];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.view.backgroundColor=LLZRGBA(239, 239, 244, 1.0);
    
    self.map=[[BMKMapView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT/2-10)];
    self.map.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    self.map.showsUserLocation = YES;//显示定位图层
    self.map.mapType=BMKMapTypeStandard;
    self.map.zoomLevel=18;
    self.map.gesturesEnabled=YES;
    [self.view addSubview:self.map];
    
    self.locService=[[BMKLocationService alloc]init];
    self.locService.delegate=self;
    self.locService.distanceFilter=kCLLocationAccuracyNearestTenMeters;
    [self.locService startUserLocationService];
    
    self.geocodesearch=[[BMKGeoCodeSearch alloc]init];
    [self.view addSubview:self.mapTableView];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.map viewWillDisappear];
    self.map.delegate=nil;
    self.geocodesearch.delegate=nil;
}
-(void)dealloc {
    if (self.geocodesearch != nil) {
        self.geocodesearch = nil;
    }
    if (self.map) {
        self.map = nil;
    }
}
#pragma mark - 添加大头针
-(void)addPoint{
    [self.map removeAnnotations:self.map.annotations];
    divAnnotation = [[BMKPointAnnotation alloc]init];
    divAnnotation.coordinate=self.map.centerCoordinate;
    [self.map addAnnotation:divAnnotation];
}
#pragma mark - 保存并返回
-(void)save{
    poiModel *p=[[poiModel alloc]init];
    //加载了poi列表
    if (self.poiArr.count>0) {
        p=self.poiArr[cellIndex];
        NSDictionary *dic=@{@"type":[NSString stringWithFormat:@"%d",(int)self.type],@"poiModel":p};
        //发送通知
        [[NSNotificationCenter defaultCenter]postNotificationName:@"startOrEnd" object:dic];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 更改导航栏标题
-(void)changeNavTitle{
    if (self.type==1) {
        self.navigationItem.title=@"起点";
    }else if (self.type==2){
        self.navigationItem.title=@"终点";
    }
}
#pragma mark - 发送反geo检索
-(void)sendReverseGeo{
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = self.map.centerCoordinate;
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [self.geocodesearch reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag){
        NSLog(@"反geo检索发送成功");
    }else{
        NSLog(@"反geo检索发送失败");
    }
}
#pragma mark - tableviewDelegate代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 11;
}
//配置特定行中的单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier =[NSString stringWithFormat:@"Cell%d,%d", (int)indexPath.section, (int)indexPath.row];//以indexPath来唯一确定cell
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if (self.poiArr.count>indexPath.row) {
        poiModel *poi=[[poiModel alloc]init];
        poi=self.poiArr[indexPath.row];
        cell.textLabel.text =poi.address;
        cell.detailTextLabel.text=[NSString stringWithFormat:@"经度：%@,纬度：%@",poi.longitude,poi.latitude];
    }else{
        cell.textLabel.text=@"正在加载中...";
        //不可点击
        cell.userInteractionEnabled=NO;
        cell.textLabel.textColor = LLZRGBA(100, 100, 100, 0.5);
    }
    return cell;
}

//设置单元格的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
//选中cell之后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *index;
    for (int i=0; i<11; i++) {
        index=[NSIndexPath indexPathForRow:i inSection:0];
        [tableView cellForRowAtIndexPath:index].accessoryType=UITableViewCellAccessoryNone;
    }
    [tableView cellForRowAtIndexPath:indexPath].accessoryType=UITableViewCellAccessoryCheckmark;
    cellIndex=(int)indexPath.row;
    //地图中心为选中的cell
//    poiModel *p=self.poiArr[cellIndex];
//    self.map.centerCoordinate=CLLocationCoordinate2DMake(p.latitude.doubleValue, p.longitude.doubleValue);
}
#pragma mark - BMKMapViewDelegate代理方法
// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]){
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        //起点/终点标注
        if (annotation==divAnnotation)
        {
            if (self.type==1) {
                annotationView.image = [UIImage imageNamed:@"起点64.png"];
            }else if (self.type==2){
                annotationView.image = [UIImage imageNamed:@"终点64.png"];
            }
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView.centerOffset = CGPointMake(0, 5);
            return annotationView;
        }
        return annotationView;
    }
    return nil;
}
//地图区域改变完成后会调用此接口
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    //发起geo检索
    [self sendReverseGeo];
}
//地图状态改变完成后会调用此接口
- (void)mapStatusDidChanged:(BMKMapView *)mapView{
    //将大头针固定在地图中央
    [self addPoint];
}
#pragma mark - BMKLocationServiceDelegate代理方法
//用户位置更新后，会调用此函数
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [self.map updateLocationData:userLocation];
    if (isFirst) {
        [self sendReverseGeo];
        isFirst=NO;
    }
}
#pragma mark - BMKGeoCodeSearchDelegate代理方法
//逆地理编码回调方法
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        //删除原先poiArr里的元素
        [self.poiArr removeAllObjects];

        poiModel *dic=[[poiModel alloc]init];
        dic.address=result.sematicDescription;//poi名字
        dic.latitude=[NSString stringWithFormat:@"%f",result.location.latitude];//纬度
        dic.longitude=[NSString stringWithFormat:@"%f",result.location.longitude];//经度
//        NSLog(@"逆地理编码成功:%@",dic);
        [self.poiArr addObject:dic];
        BMKPoiInfo *zhoubian=[[BMKPoiInfo alloc]init];
        for (int i=0; i<result.poiList.count; i++) {
            zhoubian=result.poiList[i];
            poiModel *dic=[[poiModel alloc]init];
            dic.address=zhoubian.name;//poi名字
            dic.longitude=[NSString stringWithFormat:@"%f",zhoubian.pt.longitude];//经度
            dic.latitude=[NSString stringWithFormat:@"%f",zhoubian.pt.latitude];//经度
            //poi回调结果存到poiArr数组中
            [self.poiArr addObject:dic];
//            NSLog(@"poiArr[%d]:%@",i,dic.address);
        }
        [self.mapTableView reloadData];
    }else{
        NSLog(@"逆地理编码error：%d",error);
    }
}
@end
