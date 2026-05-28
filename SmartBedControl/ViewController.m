//
//  ViewController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/2.
//

#import "ViewController.h"
#import "Views/BedCell.h"
#import "pages/SearchController.h"
#import "pages/MainController.h"


@interface ViewController () <UICollectionViewDelegate,UICollectionViewDataSource,bleManagerDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *bedArr;
//@property (strong, nonatomic) NSMutableArray *bedArr;
@property (strong, nonatomic) BLEManager *bleManager;
@property (strong, nonatomic) NSDictionary *selectedDic;
@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    self.navigationController.navigationBarHidden = YES;
    _bleManager = [BLEManager shareInstance];
    _bleManager.delegate = self;
    
}


- (void)viewDidLoad {
    NSLog(@"viewDidLoad");

    
    //_bedArr = [NSMutableArray new];
    self.view.backgroundColor = [UIColor colorWithValue:@"#070F25"];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, iPhoneWidth, SCALE(455));
    imageView.image = [UIImage imageNamed:@"jianbian"];
    [self.view addSubview:imageView];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 280, 40)];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:30 weight:16.0];
    label.text = @"Hi，欢迎回家";
    [self.view addSubview:label];
    
    UIButton *btn  = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(iPhoneWidth - 50, 66, 30, 30);
    [btn setBackgroundImage:[UIImage systemImageNamed:@"plus.circle"] forState:UIControlStateNormal];
    [btn setTintColor:[UIColor whiteColor]];
    [btn addTarget:self action:@selector(searchDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical; // 垂直滚动
//    layout.minimumLineSpacing = 10;      // 行间距
//    layout.minimumInteritemSpacing = 20;  // 列间距
//    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10); // section 边距

    // 2. 创建 UICollectionView
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame) + 25, iPhoneWidth, iPhoneHeight - CGRectGetMaxY(label.frame) - 25 - TAB_BAR_HEIGHT) collectionViewLayout:layout];
    
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;

    // 3. 添加到视图
    [self.view addSubview:_collectionView];

    
    [_collectionView registerNib:[UINib nibWithNibName:@"BedCell" bundle:nil]
     forCellWithReuseIdentifier:@"BedCell"];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadBedList:) name:@"uploadBedList" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadBedName:) name:@"uploadBedName" object:nil];
    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"deviceData"]) {
//        self.bedArr= [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceData"];
//        [_collectionView reloadData];
//    }else{
//        
//    }
    
    BOOL isOpen = [[DataCenter shareInstance] openDB];
    if (!isOpen) {
        //[MJProgressHUD onlyShowMessage:@"数据库打开失败" afterDelay:1.5 showAddTo:self.view];
        NSLog(@"数据库打开失败");
    }else{
        self.bedArr = [[DataCenter shareInstance] getAllBeds];
        [DataCenter shareInstance].deviceArr = self.bedArr;
        [_collectionView reloadData];
    }
    
}

- (void)uploadBedList:(NSNotification *)notif
{
    
    self.bedArr = [DataCenter shareInstance].deviceArr;
    [_collectionView reloadData];
    
}

- (void)uploadBedName:(NSNotification *)notif
{
//    self.bedArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceData"];
//
//    NSLog(@"获取到设备列表----%@",self.bedArr);
//    [_collectionView reloadData];
    
    self.bedArr = [DataCenter shareInstance].deviceArr;
    [_collectionView reloadData];
    
}




#pragma mark - UICollectionViewDataSource

// 1. 返回 section 数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1; // 默认1个section
}

// 2. 返回每个 section 的 item 数量
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return _bedArr.count;
}

// 3. 配置每个 cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 复用 cell
    BedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BedCell" forIndexPath:indexPath];
    BedModel *bed = _bedArr[indexPath.row];
    cell.bedName.text = bed.bedName;
//    NSDictionary *bedDict = _bedArr[indexPath.row];
//    cell.bedName.text = bedDict[@"name"];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

// 1. 点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"选中了第 %ld 个 item", (long)indexPath.item);
    
    //self.selectedDic = _bedArr[indexPath.row];
    BedModel *bed = _bedArr[indexPath.row];
    //if ([DataCenter shareInstance].state != CBPeripheralStateConnected) {
        MainController *mainVC = [[MainController alloc] init];
        mainVC.bed = bed ;
        [self.navigationController pushViewController:mainVC animated:YES];
//    }else{
//        [_bleManager didCancelConnect];
//    }
    
}

// 2. 是否高亮
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout

// 1. 每个 item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 固定大小
    return CGSizeMake(165, 125);
    
//    // 动态大小（根据内容）
//    NSString *text = self.dataArray[indexPath.item];
//    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
//    return CGSizeMake(textSize.width + 20, 50);
}

// 2. 每个 section 的边距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

// 3. 行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

// 4. 列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 30;
}



- (void)searchDevice
{
    SearchController *searchVC = [[SearchController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}


- (void)didDisconnected:(CBPeripheral *)peripheral
{
    NSLog(@"设备已经断开连接");
//    MainController *mainVC = [[MainController alloc] init];
//    mainVC.deviceDict = self.selectedDic ;
//    [self.navigationController pushViewController:mainVC animated:YES];
//    [DataCenter shareInstance].state = CBPeripheralStateDisconnected;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


@end
