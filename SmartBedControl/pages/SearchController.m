//
//  SearchController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/2.
//

#import "SearchController.h"
#import "../Views/DeviceCell.h"
#import "../SceneDelegate.h"
#import "../controllers/MineController.h"
#import "../Tools/DataCenter.h"
#import "MainController.h"
#import "PillowController.h"

@interface SearchController ()<UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,bleManagerDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) BLEManager *bleManager;
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) NSArray *deviceArr;
@property (strong, nonatomic) UIView *animationView;

@end

@implementation SearchController


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bleManager = [BLEManager shareInstance];
    _bleManager.delegate = self;
    if (self.deviceName.length > 0) {
        _bleManager.deviceName = self.deviceName;
    }
    [_bleManager didStartScanDevice:YES];
        
    self.view.backgroundColor = mainColor;
    

    UIImageView *scanImage = [[UIImageView alloc] init];
    scanImage.image = [UIImage imageNamed:@"pic2"];
    scanImage.frame = CGRectMake(30, STATUS_BAR_HEIGHT + 100, 48, 48);
    [self.view addSubview:scanImage];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanImage.frame) + 20, STATUS_BAR_HEIGHT + 102, 200, 20)];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = [UIColor whiteColor];
    label.text = @"正在扫描周围蓝牙设备...";
    [self.view addSubview:label];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanImage.frame) + 20, CGRectGetMaxY(label.frame) + 5, iPhoneWidth - CGRectGetMaxX(scanImage.frame) - 40, 20)];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.font = [UIFont systemFontOfSize:13.0];
    messageLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    messageLabel.text = @"请将手机靠近设备硬件，距离建议在1米以内";
    [self.view addSubview:messageLabel];
        
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scanImage.frame) + 20, iPhoneWidth, iPhoneHeight - CGRectGetMaxY(scanImage.frame) - safeBottom - 20)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"DeviceCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"deviceCell"];
    
    [self creatNavgationBar];
    
}


- (void)creatNavgationBar
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, STATUS_BAR_HEIGHT + 14, 15, 24);
    [backBtn setBackgroundImage:[UIImage systemImageNamed:@"chevron.backward"] forState:UIControlStateNormal];
    backBtn.tintColor = [UIColor colorWithValue:@"#6b7280"];
    [backBtn addTarget:self action:@selector(backToViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backBtn.frame) + 20, STATUS_BAR_HEIGHT + 14, 160, 24)];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:15.0];
    label.text = @"蓝牙配对";
    [self.view addSubview:label];
}

- (void)backToViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _deviceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceCell *cell = (DeviceCell *)[tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = _deviceArr[indexPath.row];
    CBPeripheral *per = dic[@"device"];
    cell.nameLabel.text = per.name;
    cell.rssiLabel.text = dic[@"mac"];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [_bleManager didStopScanDevice];
    [self showConnectedAnimation];
    NSDictionary *dic = _deviceArr[indexPath.row];
    _dict = dic;
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"connectedBed" object:dic];
    CBPeripheral *per = dic[@"device"];
    [_bleManager didConnectDevice:per];
    
}


#pragma mark- BLEManagerDelegate


//搜索到到的设备
- (void)didScanResultDevices:(NSArray *)deviceArr
{
    _deviceArr = deviceArr;
    [_tableView reloadData];
}

- (void)didConnectedSuccessful:(CBPeripheral *)peripheral
{
    NSLog(@"连接成功");
}

- (void)writeCharacteristicDiscoverdSuccess:(CBPeripheral *)peripheral
{
    NSLog(@"搜索页面-可以通讯了");
    
    [self hiddleConnectedAnimation];
    _bleManager.isFirstBed = YES;
    
    if ([peripheral.name containsString:@"MJ-10"]) {
        _bleManager.mode = BedNormal;
    }else if ([peripheral.name containsString:@"MJ-11"]) {
        _bleManager.mode = BedPro;
    }else{
        _bleManager.mode = PillowNormal;
    }

    BedModel *bed = [self connectedBedForPeripheral:peripheral];
    [DataCenter shareInstance].connectedBed = bed;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadBedList" object:nil];
    [MJProgressHUD onlyShowMessage:@"设备连接成功" afterDelay:0.8 showAddTo:self.view];
    [self openConnectedDevice:bed];
}


- (BOOL)localHasThisBed:(NSString *)mac
{
    
    NSArray *array = [DataCenter shareInstance].deviceArr;
    
    //NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceData"];
    BOOL isHase = NO;
    for (int i = 0; i < array.count; i++) {
        BedModel *bed = array[i];
        if ([bed.mac isEqualToString:mac]) {
            isHase = YES;
            break;
        }
    }
    return isHase;
}

- (BedModel *)connectedBedForPeripheral:(CBPeripheral *)peripheral
{
    NSString *mac = self.dict[@"mac"] ?: peripheral.identifier.UUIDString ?: @"";
    NSArray<BedModel *> *allBeds = [[DataCenter shareInstance] getAllBeds];
    for (BedModel *bed in allBeds) {
        if ([bed.mac isEqualToString:mac]) {
            bed.mode = _bleManager.mode;
            bed.state = peripheral.state;
            bed.myPer = peripheral;
            bed.bedName = bed.bedName.length > 0 ? bed.bedName : [self defaultNameForMode:_bleManager.mode];
            return bed;
        }
    }

    BedModel *bed = [[BedModel alloc] init];
    bed.mode = _bleManager.mode;
    bed.bedName = [self defaultNameForMode:_bleManager.mode];
    bed.mac = mac;
    bed.letfUser = 0;
    bed.rightUser = 0;
    bed.state = peripheral.state;
    bed.myPer = peripheral;
    [[DataCenter shareInstance] addBed:bed];

    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[DataCenter shareInstance].deviceArr ?: @[]];
    [tempArr addObject:bed];
    [DataCenter shareInstance].deviceArr = tempArr.copy;
    return bed;
}

- (NSString *)defaultNameForMode:(BedMode)mode
{
    if (mode == PillowNormal) {
        return @"DreamPillow Pro";
    }
    if (mode == BedPro) {
        return @"SmartRest Elite";
    }
    return @"AI Adaptive Mattress Pro";
}

- (void)openConnectedDevice:(BedModel *)bed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentDeviceDidChangeNotification" object:nil];
    if (bed.mode == PillowNormal) {
        PillowController *pillowVC = [[PillowController alloc] init];
        [self.navigationController pushViewController:pillowVC animated:YES];
        return;
    }

    MainController *mainVC = [[MainController alloc] init];
    mainVC.bed = bed;
    [self.navigationController pushViewController:mainVC animated:YES];
}

- (void)showConnectedAnimation
{

    UIWindow *window = [QuickTools mainWindow];
    UIColor *color = [UIColor colorWithValue:@"#000000" alpha:0.8];
    
    self.animationView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.animationView.backgroundColor = color;
    [window addSubview:self.animationView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth - 50, 210)];
    view.center = CGPointMake(iPhoneWidth/2, iPhoneHeight/2);
    view.backgroundColor = [UIColor colorWithValue:@"#111111"];
    view.layer.cornerRadius = 24.0;
    view.layer.masksToBounds = YES;
    [self.animationView addSubview:view];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    indicator.center = CGPointMake(view.frame.size.width/2, 80);
    indicator.color = [UIColor colorWithValue:@"#00d4ff"];
    [view addSubview:indicator];
    [indicator startAnimating];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(indicator.frame) + 5, view.frame.size.width - 40, 20)];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.font = [UIFont systemFontOfSize:17.0];
    loadingLabel.text = @"正在配对...";
    [view addSubview:loadingLabel];
    
    UILabel *modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(loadingLabel.frame), view.frame.size.width - 40, 20)];
    modeLabel.textAlignment = NSTextAlignmentCenter;
    modeLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    modeLabel.font = [UIFont systemFontOfSize:14.0];
    modeLabel.text = @"SmartRest SR-1000";
    [view addSubview:modeLabel];
}

- (void)hiddleConnectedAnimation
{
    if (self.animationView) {
        [self.animationView removeFromSuperview];
        self.animationView = nil;
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_bleManager didStopScanDevice];
    //_bleManager.delegate = nil;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
