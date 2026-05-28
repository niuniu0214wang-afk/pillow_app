//
//  DeviceModeController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/23.
//  UI改造：接入 DataCenter 真实数据，加空状态，修复侧边栏选中指示器 (2026-05-26)

#import "DeviceModeController.h"
#import "../Views/ItemView.h"
#import "../Views/BedCell.h"
#import "SearchController.h"
#import "../Tools/DataCenter.h"
#import "MainController.h"
#import "PillowController.h"


@interface DeviceModeController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (nonatomic, strong) UILabel *mainTitleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UITextField *searchTF;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *emptyView;        // 空状态视图

@property (nonatomic, strong) NSArray *sideData;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) NSMutableArray *sideItemViews;

// 当前展示的设备列表（来自 DataCenter）
@property (nonatomic, strong) NSArray *displayDevices;
@property (nonatomic, strong) NSArray *categoryDevices;

@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) BLEManager *manager;

@end

@implementation DeviceModeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;
    self.manager = [BLEManager shareInstance];
    self.manager.deviceName = @"MJ-1";

    [self setupMainView];
    [self setupSideBar];
    [self reloadDevices];

    // 监听设备列表变化（连接/断开后刷新）
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDevices)
                                                 name:@"uploadBedList"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 数据加载

// 从 DataCenter 加载设备列表，过滤当前分类（0=床垫 1=枕头）
- (void)reloadDevices {
    NSArray<BedModel *> *all = [[DataCenter shareInstance] getAllBeds];
    NSArray *filtered = @[];
    if (self.selectIndex == 60) {
        // 智能床垫：BedNormal / BedPro / BedMax
        filtered = [all filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(BedModel *bed, NSDictionary *b) {
                return bed.mode != PillowNormal;
            }]];
    } else {
        // 智能枕
        filtered = [all filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(BedModel *bed, NSDictionary *b) {
                return bed.mode == PillowNormal;
            }]];
    }
    self.categoryDevices = filtered;
    [self applySearchFilter];
}

#pragma mark - 左侧侧边导航栏

- (void)setupSideBar {
    self.sideData = @[
        @{@"title":@"智能床垫", @"image":@"chuang_normal"},
        @{@"title":@"智能枕",   @"image":@"zhentou"}
    ];
    self.selectIndex = 60;
    self.sideItemViews = [NSMutableArray array];

    for (int i = 0; i < self.sideData.count; i++) {
        NSDictionary *dict = self.sideData[i];
        ItemView *item = [[ItemView alloc] initWithFrame:CGRectMake(0, i * 74 + (STATUS_BAR_HEIGHT + 130), 74, 74)
                                               withTitle:dict[@"title"]
                                           withImageName:dict[@"image"]];
        item.tag = i + 60;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemPressed:)];
        [item addGestureRecognizer:tap];
        if (i == 0) { item.isSelected = YES; }
        [self.view addSubview:item];
        [self.sideItemViews addObject:item];
    }
}

#pragma mark - 右侧主内容区域

- (void)setupMainView {
    self.mainTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, STATUS_BAR_HEIGHT, iPhoneWidth - 110, 35)];
    self.mainTitleLabel.text = @"设备管理";
    self.mainTitleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightLight];
    self.mainTitleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.mainTitleLabel];

    self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, CGRectGetMaxY(self.mainTitleLabel.frame) + 4, iPhoneWidth - 110, 18)];
    self.subTitleLabel.text = @"连接并管理您的智能设备";
    self.subTitleLabel.font = [UIFont systemFontOfSize:13];
    self.subTitleLabel.textColor = [UIColor colorWithValue:@"#4b5563"];
    [self.view addSubview:self.subTitleLabel];

    // 搜索框
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(90, CGRectGetMaxY(self.subTitleLabel.frame) + 10, iPhoneWidth - 110, 40)];
    searchView.backgroundColor = [UIColor colorWithValue:@"#111111"];
    searchView.layer.cornerRadius = 12.0;
    searchView.layer.masksToBounds = YES;
    searchView.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    searchView.layer.borderWidth = 1.0;
    [self.view addSubview:searchView];

    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 16, 16)];
    searchIcon.image = [UIImage systemImageNamed:@"magnifyingglass"];
    searchIcon.tintColor = [UIColor colorWithValue:@"#4b5563"];
    [searchView addSubview:searchIcon];

    self.searchTF = [[UITextField alloc] initWithFrame:CGRectMake(34, 8, searchView.bounds.size.width - 44, 24)];
    self.searchTF.attributedPlaceholder = [[NSAttributedString alloc]
        initWithString:@"搜索设备名称或型号…"
            attributes:@{NSForegroundColorAttributeName: [UIColor colorWithValue:@"#4b5563"]}];
    self.searchTF.borderStyle = UITextBorderStyleNone;
    self.searchTF.textColor = [UIColor whiteColor];
    self.searchTF.font = [UIFont systemFontOfSize:14];
    self.searchTF.delegate = self;
    [self.searchTF addTarget:self action:@selector(searchTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [searchView addSubview:self.searchTF];

    // CollectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    CGFloat cvX = 82;
    CGFloat cvY = STATUS_BAR_HEIGHT + 130;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(cvX, cvY, iPhoneWidth - cvX - 8, iPhoneHeight - cvY - TAB_BAR_HEIGHT)
                                             collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BedCell" bundle:nil]
          forCellWithReuseIdentifier:@"BedCell"];

    // 空状态视图
    self.emptyView = [[UIView alloc] initWithFrame:self.collectionView.frame];
    self.emptyView.hidden = YES;
    [self.view addSubview:self.emptyView];

    UIImageView *emptyIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.emptyView.bounds.size.width - 48)/2, 80, 48, 48)];
    emptyIcon.image = [UIImage systemImageNamed:@"bed.double"];
    emptyIcon.tintColor = [UIColor colorWithValue:@"#27272a"];
    [self.emptyView addSubview:emptyIcon];

    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(emptyIcon.frame) + 12, self.emptyView.bounds.size.width, 20)];
    emptyLabel.text = @"暂无设备";
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.font = [UIFont systemFontOfSize:14];
    emptyLabel.textColor = [UIColor colorWithValue:@"#4b5563"];
    [self.emptyView addSubview:emptyLabel];

    UILabel *emptyHint = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(emptyLabel.frame) + 6, self.emptyView.bounds.size.width, 16)];
    emptyHint.text = @"点击设备卡片搜索并添加";
    emptyHint.textAlignment = NSTextAlignmentCenter;
    emptyHint.font = [UIFont systemFontOfSize:12];
    emptyHint.textColor = [UIColor colorWithValue:@"#374151"];
    [self.emptyView addSubview:emptyHint];
}

#pragma mark - 侧边栏点击

- (void)itemPressed:(UIGestureRecognizer *)recognizer {
    NSInteger index = recognizer.view.tag;
    if (index == self.selectIndex) { return; }

    ItemView *selectedItem = (ItemView *)recognizer.view;
    selectedItem.isSelected = YES;
    ItemView *lastItem = (ItemView *)[self.view viewWithTag:self.selectIndex];
    lastItem.isSelected = NO;

    self.manager.deviceName = (index == 60) ? @"MJ-1" : @"MJ-2";
    self.selectIndex = index;
    [self reloadDevices];
}

- (void)searchTextChanged:(UITextField *)textField {
    [self applySearchFilter];
}

- (void)applySearchFilter {
    NSString *keyword = [self.searchTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (keyword.length == 0) {
        self.displayDevices = self.categoryDevices ?: @[];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(BedModel *bed, NSDictionary *bindings) {
            NSString *name = bed.bedName ?: @"";
            NSString *mac = bed.mac ?: @"";
            NSString *mode = bed.mode == PillowNormal ? @"Pillow" : @"Mattress";
            return [name rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound ||
                   [mac rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound ||
                   [mode rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound;
        }];
        self.displayDevices = [self.categoryDevices filteredArrayUsingPredicate:predicate];
    }
    [self.collectionView reloadData];
    self.emptyView.hidden = (self.displayDevices.count > 0);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // 真实数据；空时 +1 用于显示"添加"卡片
    return self.displayDevices.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BedCell" forIndexPath:indexPath];

    if ((NSUInteger)indexPath.item < self.displayDevices.count) {
        BedModel *bed = self.displayDevices[indexPath.item];
        cell.bedName.text = bed.bedName.length > 0 ? bed.bedName : @"智能床垫";
        NSString *modeStr = @"BedNormal";
        if (bed.mode == BedPro)  modeStr = @"BedPro";
        if (bed.mode == BedMax)  modeStr = @"BedMax";
        if (bed.mode == PillowNormal) modeStr = @"Pillow";
        cell.bedMode.text = modeStr;
        // 已连接：绿色边框
        BOOL connected = (bed.state == CBPeripheralStateConnected);
        cell.boomView.layer.borderWidth  = connected ? 1.0 : 0;
        cell.boomView.layer.borderColor  = [UIColor colorWithValue:@"#22c55e" alpha:0.5].CGColor;
    } else {
        // 最后一格：添加按钮
        cell.bedName.text = @"添加设备";
        cell.bedMode.text = @"点击搜索";
        cell.boomView.layer.borderWidth = 1.0;
        cell.boomView.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ((NSUInteger)indexPath.item < self.displayDevices.count) {
        BedModel *bed = self.displayDevices[indexPath.item];
        [DataCenter shareInstance].connectedBed = bed;
        [BLEManager shareInstance].mode = bed.mode;
        if (bed.mode == PillowNormal) {
            PillowController *pillowVC = [[PillowController alloc] init];
            [self.navigationController pushViewController:pillowVC animated:YES];
        } else {
            MainController *mainVC = [[MainController alloc] init];
            mainVC.bed = bed;
            [self.navigationController pushViewController:mainVC animated:YES];
        }
        return;
    }
    SearchController *searchVC = [[SearchController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = (self.collectionView.bounds.size.width - 30) / 2.0;
    return CGSizeMake(w, w * 1.15);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 12;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

@end
