//
//  MineController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/22.
//

#import "MineController.h"
#import "../Views/MineCell.h"
#import "../Views/FamilyCell.h"
#import "UserMessageController.h"
#import "../pages/DeviceModeController.h"
#import "../pages/MainController.h"
#import "../pages/PillowController.h"

typedef NS_ENUM(NSInteger, MJProfileDetailType) {
    MJProfileDetailTypeDevice,
    MJProfileDetailTypeAlarm,
    MJProfileDetailTypeMattressAuto,
    MJProfileDetailTypePillowSnore,
    MJProfileDetailTypeAbout,
    MJProfileDetailTypeAccount,
    MJProfileDetailTypeHelp
};

@interface MJProfileDetailController : UIViewController
@property (nonatomic, assign) MJProfileDetailType type;
@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, copy) NSArray<NSDictionary *> *items;
- (instancetype)initWithType:(MJProfileDetailType)type title:(NSString *)title;
@end

@interface MineController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSArray<NSDictionary *> *> *dataSource;
@property (strong, nonatomic) NSArray *profileValues;
@property (assign, nonatomic) BOOL currentDeviceIsPillow;
@property (strong, nonatomic) BedModel *currentDevice;
@end

#define labelWidth (iPhoneWidth - 120) / 5

@implementation MineController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self rebuildDataSource];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;
    self.profileValues = @[@"175cm", @"65kg", @"25", @"男", @"侧睡"];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, STATUS_BAR_HEIGHT, 70, 25)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"我的";
    titleLabel.font = [UIFont systemFontOfSize:18.0];
    [self.view addSubview:titleLabel];

    UIButton *langBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    langBtn.frame = CGRectMake(iPhoneWidth - 74, STATUS_BAR_HEIGHT - 1, 54, 30);
    langBtn.layer.cornerRadius = 10.0;
    langBtn.layer.masksToBounds = YES;
    langBtn.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    langBtn.layer.borderWidth = 1.0;
    langBtn.backgroundColor = [UIColor colorWithValue:@"#111111"];
    [langBtn setTitle:@"EN" forState:UIControlStateNormal];
    [langBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    langBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [langBtn addTarget:self action:@selector(showLanguageHint) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:langBtn];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLabel.frame) + 20, iPhoneWidth - 40, iPhoneHeight - TAB_BAR_HEIGHT - STATUS_BAR_HEIGHT - 45) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    [_tableView registerNib:[UINib nibWithNibName:@"MineCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MineCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"FamilyCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FamilyCell"];
    [self rebuildDataSource];
}

- (void)rebuildDataSource
{
    self.currentDevice = [self resolvedCurrentDevice];
    self.currentDeviceIsPillow = [self isPillowDevice:self.currentDevice];

    NSString *deviceName = self.currentDevice.bedName.length > 0 ? self.currentDevice.bedName : (self.currentDeviceIsPillow ? @"DreamPillow Pro" : @"AI Adaptive Mattress Pro");
    NSString *deviceType = self.currentDeviceIsPillow ? @"已连接 · 智能枕" : @"已连接 · SR-1000";

    NSArray *section1 = @[
        @{@"title":deviceName, @"image":@"connected", @"detail":deviceType, @"action":@"device"},
        @{@"title":@"添加 / 管理设备", @"image":@"deviceGroup", @"detail":@"选择智能床垫或智能枕，并管理已连接设备", @"action":@"devices"}
    ];

    NSArray *settings = self.currentDeviceIsPillow ? @[
        @{@"title":@"体感闹钟", @"image":@"set", @"detail":@"07:30 · 启用体感唤醒", @"action":@"alarm"},
        @{@"title":@"鼾声干预", @"image":@"feed", @"detail":@"枕头专属：强度、灵敏度、干预时段", @"action":@"snore"}
    ] : @[
        @{@"title":@"体感闹钟", @"image":@"set", @"detail":@"07:30 · 启用体感唤醒", @"action":@"alarm"},
        @{@"title":@"自动调节模式设定", @"image":@"bedMode", @"detail":@"轻柔 / 标准 / 加强 · 勿动模式", @"action":@"auto"}
    ];

    NSArray *section3 = @[
        @{@"title":@"关于我们", @"image":@"version", @"detail":@"隐私政策、用户协议、版本说明", @"action":@"about"},
        @{@"title":@"账号与安全", @"image":@"relock", @"detail":@"注销账号、隐私授权", @"action":@"account"},
        @{@"title":@"帮助与客服", @"image":@"kong", @"detail":@"连接、报告和调节说明", @"action":@"help"}
    ];

    self.dataSource = @[section1, settings, section3];
}

- (BedModel *)resolvedCurrentDevice
{
    BedModel *connected = [DataCenter shareInstance].connectedBed;
    if (connected) {
        return connected;
    }

    NSArray<BedModel *> *all = [[DataCenter shareInstance] getAllBeds];
    BedMode mode = [BLEManager shareInstance].mode;
    for (BedModel *bed in all) {
        if (bed.mode == mode) {
            return bed;
        }
    }
    return all.firstObject;
}

- (BOOL)isPillowDevice:(BedModel *)device
{
    if (device) {
        return device.mode == PillowNormal;
    }
    return [BLEManager shareInstance].mode == PillowNormal;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 210;
    }
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [self headerUserView];
    }
    if (section == 1) {
        return [self headerLabelView:self.currentDeviceIsPillow ? @"枕头设置" : @"床垫设置"];
    }
    if (section == 2) {
        return [self headerLabelView:@"系统"];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == 2 ? 76 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section != 2) {
        return nil;
    }
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];

    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.frame = CGRectMake(0, 10, iPhoneWidth - 40, 56);
    logoutBtn.layer.cornerRadius = 12.0;
    logoutBtn.layer.masksToBounds = YES;
    logoutBtn.backgroundColor = [UIColor colorWithValue:@"#ef4444" alpha:0.05];
    logoutBtn.layer.borderColor = [UIColor colorWithValue:@"#ef4444" alpha:0.3].CGColor;
    logoutBtn.layer.borderWidth = 1.0;
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor colorWithValue:@"#ef4444"] forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(confirmLogout) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:logoutBtn];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = self.dataSource[indexPath.section];
    NSDictionary *dict = array[indexPath.row];

    MineCell *cell = (MineCell *)[tableView dequeueReusableCellWithIdentifier:@"MineCell" forIndexPath:indexPath];
    cell.titleLabel.text = dict[@"title"];
    cell.detailLabel.text = dict[@"detail"];
    cell.icon.image = [UIImage imageNamed:dict[@"image"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - 表头视图
- (UIView *)headerUserView
{
    UIView *boomView = [[UIView alloc] init];
    boomView.backgroundColor = [UIColor clearColor];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth - 40, 170)];
    view.backgroundColor = [UIColor colorWithValue:@"#111111"];
    view.layer.cornerRadius = 20.0;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    view.layer.borderWidth = 1.0;
    [boomView addSubview:view];

    UIImageView *userImage = [[UIImageView alloc] init];
    userImage.image = [UIImage imageNamed:@"user"];
    userImage.frame = CGRectMake(20, 20, 64, 64);
    userImage.layer.cornerRadius = 32.0;
    userImage.layer.masksToBounds = YES;
    [view addSubview:userImage];

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userImage.frame) + 10, 20, 100, 25)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:20.0];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = @"用户";
    [view addSubview:nameLabel];

    UILabel *nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userImage.frame) + 10, 46, 160, 25)];
    nickNameLabel.textColor = [UIColor colorWithValue:@"#9ca3af"];
    nickNameLabel.font = [UIFont systemFontOfSize:14.0];
    nickNameLabel.textAlignment = NSTextAlignmentLeft;
    nickNameLabel.text = @"SmartRest 用户";
    [view addSubview:nickNameLabel];

    for (int i = 0; i < 5; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20 + i%5*(labelWidth + 10), CGRectGetMaxY(userImage.frame) + 8, labelWidth, 28)];
        label.layer.cornerRadius = 14.0;
        label.layer.masksToBounds = YES;
        label.backgroundColor = [UIColor colorWithValue:@"#1a1a1a"];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = self.profileValues[i];
        [view addSubview:label];
    }

    UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    messageBtn.frame = CGRectMake(20, CGRectGetMaxY(userImage.frame) + 48, 140, 28);
    messageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [messageBtn setTitle:@"编辑个人信息 →" forState:UIControlStateNormal];
    [messageBtn setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateNormal];
    messageBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [messageBtn addTarget:self action:@selector(openUserMessage) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:messageBtn];

    UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(view.frame) + 15, 90, 25)];
    deviceLabel.textAlignment = NSTextAlignmentLeft;
    deviceLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    deviceLabel.text = @"我的设备";
    deviceLabel.font = [UIFont systemFontOfSize:12.0];
    [boomView addSubview:deviceLabel];

    return boomView;
}

- (UIView *)headerLabelView:(NSString *)title
{
    UIView *boomView = [[UIView alloc] init];
    boomView.backgroundColor = [UIColor clearColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 120, 20)];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor colorWithValue:@"#6b7280"];
    label.text = title;
    label.font = [UIFont systemFontOfSize:12.0];
    [boomView addSubview:label];

    return boomView;
}

- (void)openUserMessage
{
    UserMessageController *messageVC = [[UserMessageController alloc] init];
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = self.dataSource[indexPath.section][indexPath.row];
    NSString *action = item[@"action"];

    if ([action isEqualToString:@"devices"]) {
        DeviceModeController *deviceVC = [[DeviceModeController alloc] init];
        [self.navigationController pushViewController:deviceVC animated:YES];
        return;
    }
    if ([action isEqualToString:@"device"]) {
        if (self.currentDeviceIsPillow) {
            PillowController *pillowVC = [[PillowController alloc] init];
            [self.navigationController pushViewController:pillowVC animated:YES];
        } else {
            MainController *mainVC = [[MainController alloc] init];
            mainVC.bed = self.currentDevice;
            [self.navigationController pushViewController:mainVC animated:YES];
        }
        return;
    }
    if ([action isEqualToString:@"alarm"]) {
        [self pushDetailType:MJProfileDetailTypeAlarm title:@"体感闹钟"];
        return;
    }
    if ([action isEqualToString:@"auto"]) {
        [self pushDetailType:MJProfileDetailTypeMattressAuto title:@"自动调节模式设定"];
        return;
    }
    if ([action isEqualToString:@"snore"]) {
        [self pushDetailType:MJProfileDetailTypePillowSnore title:@"鼾声干预"];
        return;
    }
    if ([action isEqualToString:@"about"]) {
        [self pushDetailType:MJProfileDetailTypeAbout title:@"关于我们"];
        return;
    }
    if ([action isEqualToString:@"account"]) {
        [self pushDetailType:MJProfileDetailTypeAccount title:@"账号与安全"];
        return;
    }
    if ([action isEqualToString:@"help"]) {
        [self pushDetailType:MJProfileDetailTypeHelp title:@"帮助与客服"];
    }
}

- (void)pushDetailType:(MJProfileDetailType)type title:(NSString *)title
{
    MJProfileDetailController *detailVC = [[MJProfileDetailController alloc] initWithType:type title:title];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)showLanguageHint
{
    [MJProgressHUD onlyShowMessage:@"中英文切换入口已放置，可继续接入 Localizable.strings" afterDelay:1.0 showAddTo:self.view];
}

- (void)confirmLogout
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"退出登录"
                                                                   message:@"确认退出当前账号？"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

@implementation MJProfileDetailController

- (instancetype)initWithType:(MJProfileDetailType)type title:(NSString *)title
{
    self = [super init];
    if (self) {
        _type = type;
        _pageTitle = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;
    [self buildItems];
    [self buildUI];
}

- (void)buildItems
{
    switch (self.type) {
        case MJProfileDetailTypeAlarm:
            self.items = @[
                @{@"title":@"启用体感唤醒", @"detail":@"开"},
                @{@"title":@"唤醒时间", @"detail":@"07:30"},
                @{@"title":@"重复", @"detail":@"周一 至 周五"},
                @{@"title":@"唤醒方式", @"detail":@"体感调节唤醒"}
            ];
            break;
        case MJProfileDetailTypeMattressAuto:
            self.items = @[
                @{@"title":@"轻柔模式", @"detail":@"适合睡眠较浅、敏感人群"},
                @{@"title":@"标准模式", @"detail":@"适合大部分用户"},
                @{@"title":@"加强模式", @"detail":@"更积极的人体工学反馈"},
                @{@"title":@"勿动模式", @"detail":@"22:00 至 06:00 停止自动调节"}
            ];
            break;
        case MJProfileDetailTypePillowSnore:
            self.items = @[
                @{@"title":@"启用鼾声干预", @"detail":@"关"},
                @{@"title":@"干预强度", @"detail":@"中等"},
                @{@"title":@"检测灵敏度", @"detail":@"中等"},
                @{@"title":@"免打扰时段", @"detail":@"22:00 至 06:00"},
                @{@"title":@"干预时间", @"detail":@"23:00 至 06:00"}
            ];
            break;
        case MJProfileDetailTypeAbout:
            self.items = @[
                @{@"title":@"隐私政策", @"detail":@"查看"},
                @{@"title":@"用户协议", @"detail":@"查看"},
                @{@"title":@"APP 版本", @"detail":@"V1.0.1"},
                @{@"title":@"固件版本", @"detail":@"v1.0.4"},
                @{@"title":@"一键反馈", @"detail":@"提交问题和联系方式"}
            ];
            break;
        case MJProfileDetailTypeAccount:
            self.items = @[
                @{@"title":@"注销账号", @"detail":@"需要二次确认"},
                @{@"title":@"撤回隐私政策同意", @"detail":@"撤回后部分联网功能停止使用"}
            ];
            break;
        case MJProfileDetailTypeHelp:
            self.items = @[
                @{@"title":@"设备连接", @"detail":@"选择智能床垫或智能枕后进行蓝牙连接"},
                @{@"title":@"睡眠报告", @"detail":@"查看心率、呼吸、压力和睡眠阶段"},
                @{@"title":@"床垫调节", @"detail":@"自动模式与手动气囊调节"},
                @{@"title":@"枕头调节", @"detail":@"自动高度、手动五区压力和记忆模式"}
            ];
            break;
        default:
            self.items = @[];
            break;
    }
}

- (void)buildUI
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(12, STATUS_BAR_HEIGHT - 2, 44, 36);
    [backBtn setTitle:@"‹" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:32.0 weight:UIFontWeightLight];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, STATUS_BAR_HEIGHT, iPhoneWidth - 76, 28)];
    titleLabel.text = self.pageTitle;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightLight];
    [self.view addSubview:titleLabel];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + 48, iPhoneWidth, iPhoneHeight - STATUS_BAR_HEIGHT - 48)];
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];

    CGFloat y = 0;
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(20, y, iPhoneWidth - 40, self.items.count * 72)];
    card.backgroundColor = [UIColor colorWithValue:@"#111111"];
    card.layer.cornerRadius = 18.0;
    card.layer.masksToBounds = YES;
    card.layer.borderWidth = 1.0;
    card.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    [scrollView addSubview:card];

    for (NSInteger i = 0; i < self.items.count; i++) {
        NSDictionary *item = self.items[i];
        UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, i * 72, card.bounds.size.width, 72)];
        [card addSubview:row];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(18, 14, card.bounds.size.width - 36, 22)];
        title.text = item[@"title"];
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
        [row addSubview:title];

        UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(18, 38, card.bounds.size.width - 36, 18)];
        detail.text = item[@"detail"];
        detail.textColor = [UIColor colorWithValue:@"#6b7280"];
        detail.font = [UIFont systemFontOfSize:12.0];
        [row addSubview:detail];

        if (i < self.items.count - 1) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(18, 71.5, card.bounds.size.width - 36, 0.5)];
            line.backgroundColor = [UIColor colorWithValue:@"#27272a"];
            [row addSubview:line];
        }
    }

    y = CGRectGetMaxY(card.frame) + 16;
    UILabel *note = [[UILabel alloc] initWithFrame:CGRectMake(24, y, iPhoneWidth - 48, 120)];
    note.textColor = [UIColor colorWithValue:@"#6b7280"];
    note.font = [UIFont systemFontOfSize:13.0];
    note.numberOfLines = 0;
    note.text = [self footerNote];
    [scrollView addSubview:note];
    scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(note.frame) + 30);
}

- (NSString *)footerNote
{
    if (self.type == MJProfileDetailTypePillowSnore) {
        return @"鼾声干预仅属于智能枕流程。床垫设备不会展示此入口，也不会发送相关控制命令。";
    }
    if (self.type == MJProfileDetailTypeMattressAuto) {
        return @"此页对应网页原型中床垫的自动调节模式和勿动模式，和枕头的高度/鼾声功能分开。";
    }
    return @"该页面已按网页原型拆成独立二级界面，后续可继续接入真实接口和持久化设置。";
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
