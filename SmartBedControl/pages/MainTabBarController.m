//
//  MainTabBarController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/22.
//

#import "MainTabBarController.h"
#import "MainController.h"
#import "../controllers/MineController.h"
#import "../controllers/SleepDataController.h"
#import "../Tools/BLEManager.h"
#import "../Tools/DataCenter.h"

#import "../controllers/MineController.h"
#import "../controllers/SleepDataController.h"
#import "SearchController.h"
#import "DeviceModeController.h"

#import "PillowController.h"

@interface MainTabBarController ()
@property (nonatomic, assign) BedMode displayedMode;

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;

    // Tab Bar 背景色 #0d0d0d，顶部分隔线 #1a1a1a
    self.tabBar.translucent = NO;
    self.tabBar.barTintColor = [UIColor colorWithValue:@"#0d0d0d"];

    // 顶部分隔线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.5)];
    topLine.backgroundColor = [UIColor colorWithValue:@"#1a1a1a"];
    [self.tabBar addSubview:topLine];

    // 文字颜色：选中白色，未选中 #4b5563
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor colorWithValue:@"#0d0d0d"];

    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSForegroundColorAttributeName] = [UIColor colorWithValue:@"#4b5563"];
    normalAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:10.0];

    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    selectedAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:10.0];

    appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs;
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs;

    self.tabBar.standardAppearance = appearance;
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = appearance;
    }

    [self creatTabBarControllers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentDeviceDidChange) name:@"CurrentDeviceDidChangeNotification" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self currentDeviceDidChange];
}

- (void)creatTabBarControllers
{
    self.displayedMode = [self currentDeviceMode];

    UIViewController *homeVC;
    if (self.displayedMode == PillowNormal) {
        homeVC = [[PillowController alloc] init];
    } else {
        homeVC = [[MainController alloc] init];
    }
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    UITabBarItem *tabBarItemZero = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                                 image:[[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                   tag:0];
    tabBarItemZero.selectedImage = [[UIImage imageNamed:@"home_high"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    homeNav.tabBarItem = tabBarItemZero;
    [self addChildViewController:homeNav];

    SleepDataController *dataVC = [[SleepDataController alloc] init];
    UITabBarItem *tabBarItemOne = [[UITabBarItem alloc] initWithTitle:@"睡眠"
                                                                image:[[UIImage imageNamed:@"data_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                  tag:1];
    tabBarItemOne.selectedImage = [[UIImage imageNamed:@"data_high"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    dataVC.tabBarItem = tabBarItemOne;
    [self addChildViewController:dataVC];

    MineController *mineVC = [[MineController alloc] init];
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.navigationBarHidden = YES;
    UITabBarItem *tabBarItemTwo = [[UITabBarItem alloc] initWithTitle:@"我的"
                                                               image:[[UIImage imageNamed:@"mine_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                 tag:2];
    tabBarItemTwo.selectedImage = [[UIImage imageNamed:@"mine_high"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mineNav.tabBarItem = tabBarItemTwo;
    [self addChildViewController:mineNav];

    self.selectedIndex = 0;
}

- (BedMode)currentDeviceMode
{
    BedModel *connectedBed = [DataCenter shareInstance].connectedBed;
    if (connectedBed) {
        return connectedBed.mode;
    }
    return [BLEManager shareInstance].mode;
}

- (void)currentDeviceDidChange
{
    BedMode mode = [self currentDeviceMode];
    if (mode == self.displayedMode || self.viewControllers.count == 0) {
        return;
    }

    self.displayedMode = mode;
    NSMutableArray *controllers = [self.viewControllers mutableCopy];
    UIViewController *replacementRoot = mode == PillowNormal ? [[PillowController alloc] init] : [[MainController alloc] init];
    UINavigationController *replacementNav = [[UINavigationController alloc] initWithRootViewController:replacementRoot];
    replacementNav.tabBarItem = ((UIViewController *)controllers.firstObject).tabBarItem;
    controllers[0] = replacementNav;
    self.viewControllers = controllers.copy;
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
