//
//  TestViewController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/3.
//

#import "TestViewController.h"

@interface TestViewController ()
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *updateButton;
@end

@implementation TestViewController






- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.22 green:0.13 blue:0.35 alpha:1.0]; // 深紫色背景
        
    [self setupNavigationBar];
    [self setupMattressVisualArea];
    [self setupSideSegment];
    [self setupAdjustmentSliders];
    [self setupFunctionButtons];
    [self setupBottomTabBar];
}

- (void)setupNavigationBar {
    // 左侧返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    [backButton setTintColor:UIColor.whiteColor];
    [backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    // 右侧设置按钮
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [settingsButton setImage:[UIImage systemImageNamed:@"gearshape"] forState:UIControlStateNormal];
    [settingsButton setTintColor:UIColor.whiteColor];
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.rightBarButtonItem = settingsItem;
    
    // 标题和用户信息
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.text = @"设置中心";
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    // 用户信息视图
    UIView *userHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 60, 60)];
    avatarView.image = [UIImage imageNamed:@"avatar"]; // 替换为你的头像图片
    avatarView.layer.cornerRadius = 30;
    avatarView.clipsToBounds = YES;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 25, 200, 30)];
    nameLabel.text = @"Hello, Ellie";
    nameLabel.textColor = UIColor.whiteColor;
    nameLabel.font = [UIFont boldSystemFontOfSize:24];
    
    UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 55, 200, 20)];
    welcomeLabel.text = @"欢迎回来";
    welcomeLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    welcomeLabel.font = [UIFont systemFontOfSize:14];
    
    [userHeaderView addSubview:avatarView];
    [userHeaderView addSubview:nameLabel];
    [userHeaderView addSubview:welcomeLabel];
    [self.view addSubview:userHeaderView];
}

- (void)setupMattressVisualArea {
    self.mattressVisualView = [[UIView alloc] initWithFrame:CGRectMake(16, 120, self.view.bounds.size.width - 32, 200)];
    self.mattressVisualView.backgroundColor = [UIColor clearColor];
    
    // 床垫可视化图片
    UIImageView *mattressImageView = [[UIImageView alloc] initWithFrame:self.mattressVisualView.bounds];
    mattressImageView.image = [UIImage imageNamed:@"mattress_visual"]; // 替换为你的床垫透视图
    mattressImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.mattressVisualView addSubview:mattressImageView];
    
    // 床垫分段调节条
    CGFloat barWidth = (self.mattressVisualView.bounds.size.width - 60) / 6;
    CGFloat barHeight = 80;
    CGFloat startY = 140;
    
    for (int i = 0; i < 6; i++) {
        UIView *barContainer = [[UIView alloc] initWithFrame:CGRectMake(10 + i * (barWidth + 10), startY, barWidth, barHeight)];
        barContainer.backgroundColor = [UIColor colorWithRed:0.45 green:0.25 blue:0.45 alpha:0.8];
        barContainer.layer.cornerRadius = 8;
        
        UIButton *upButton = [UIButton buttonWithType:UIButtonTypeSystem];
        upButton.frame = CGRectMake(0, 0, barWidth, 30);
        [upButton setImage:[UIImage systemImageNamed:@"chevron.up"] forState:UIControlStateNormal];
        [upButton setTintColor:UIColor.whiteColor];
        
        UIButton *downButton = [UIButton buttonWithType:UIButtonTypeSystem];
        downButton.frame = CGRectMake(0, barHeight - 30, barWidth, 30);
        [downButton setImage:[UIImage systemImageNamed:@"chevron.down"] forState:UIControlStateNormal];
        [downButton setTintColor:UIColor.whiteColor];
        
        [barContainer addSubview:upButton];
        [barContainer addSubview:downButton];
        [self.mattressVisualView addSubview:barContainer];
    }
    
    [self.view addSubview:self.mattressVisualView];
}

- (void)setupSideSegment {
    self.sideSegment = [[UISegmentedControl alloc] initWithItems:@[@"左侧设置", @"右侧设置"]];
    self.sideSegment.frame = CGRectMake(32, 340, self.view.bounds.size.width - 64, 44);
    self.sideSegment.selectedSegmentIndex = 1;
    self.sideSegment.tintColor = [UIColor colorWithRed:0.15 green:0.75 blue:0.35 alpha:1.0];
    [self.sideSegment setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.whiteColor} forState:UIControlStateNormal];
    [self.view addSubview:self.sideSegment];
}

- (void)setupAdjustmentSliders {
    NSArray *zoneNames = @[@"肩部", @"腰部", @"背部", @"臀部", @"腿部", @"脚部"];
    NSMutableArray *sliders = [NSMutableArray array];
    CGFloat sliderWidth = 40;
    CGFloat sliderHeight = 250;
    CGFloat startX = 32;
    CGFloat spacing = (self.view.bounds.size.width - 64 - 6 * sliderWidth) / 5;
    
    for (int i = 0; i < 6; i++) {
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(startX + i * (sliderWidth + spacing), 400, sliderWidth, sliderHeight)];
        slider.transform = CGAffineTransformMakeRotation(-M_PI_2); // 垂直旋转
        slider.minimumValue = 0;
        slider.maximumValue = 100;
        slider.value = 50;
        slider.minimumTrackTintColor = [UIColor colorWithRed:0.95 green:0.65 blue:0.35 alpha:1.0];
        slider.maximumTrackTintColor = [UIColor colorWithWhite:0.3 alpha:0.5];
        slider.thumbTintColor = UIColor.whiteColor;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(slider.frame.origin.x, slider.frame.origin.y + sliderHeight + 10, sliderWidth, 20)];
        label.text = zoneNames[i];
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:label];
        [self.view addSubview:slider];
        [sliders addObject:slider];
    }
    self.adjustmentSliders = sliders;
    
    // 右侧硬度标签
    NSArray *hardnessLabels = @[@"硬", @"偏硬", @"适中", @"偏软", @"软"];
    CGFloat labelY = 400;
    for (int i = 0; i < 5; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 40, labelY + i * 50, 40, 20)];
        label.text = hardnessLabels[i];
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:label];
    }
    
    // 保存设置按钮
    self.saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.saveButton.frame = CGRectMake(32, 680, self.view.bounds.size.width - 64, 50);
    self.saveButton.backgroundColor = [UIColor colorWithRed:0.35 green:0.25 blue:0.45 alpha:1.0];
    [self.saveButton setTitle:@"保存设置" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.saveButton.layer.cornerRadius = 8;
    [self.view addSubview:self.saveButton];
    
    // 恢复平整和实时更新按钮
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.resetButton.frame = CGRectMake(self.view.bounds.size.width / 2 - 100, 300, 140, 36);
    self.resetButton.backgroundColor = [UIColor colorWithRed:0.15 green:0.75 blue:0.35 alpha:1.0];
    [self.resetButton setTitle:@"恢复平整" forState:UIControlStateNormal];
    [self.resetButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.resetButton.layer.cornerRadius = 4;
    
    self.updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.updateButton.frame = CGRectMake(self.view.bounds.size.width / 2 + 40, 300, 140, 36);
    self.updateButton.backgroundColor = UIColor.whiteColor;
    [self.updateButton setTitle:@"实时更新" forState:UIControlStateNormal];
    [self.updateButton setTitleColor:[UIColor colorWithRed:0.22 green:0.13 blue:0.35 alpha:1.0] forState:UIControlStateNormal];
    self.updateButton.layer.cornerRadius = 4;
    
    [self.view addSubview:self.resetButton];
    [self.view addSubview:self.updateButton];
}

- (void)setupFunctionButtons {
    CGFloat buttonWidth = (self.view.bounds.size.width - 48) / 2;
    CGFloat buttonHeight = 80;
    CGFloat startY = 750;
    
    NSArray *buttonData = @[
        @{@"title": @"头部调节", @"subtitle": @"头部舒适调节", @"icon": @"bed.double"},
        @{@"title": @"身体调节", @"subtitle": @"身体舒适调节", @"icon": @"figure.walk"},
        @{@"title": @"睡眠报告", @"subtitle": @"查看您的报告", @"icon": @"chart.bar"},
        @{@"title": @"AI策略", @"subtitle": @"使用自动调节", @"icon": @"a.circle"}
    ];
    
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        CGFloat x = (i % 2 == 0) ? 16 : 16 + buttonWidth + 16;
        CGFloat y = startY + (i / 2) * (buttonHeight + 16);
        button.frame = CGRectMake(x, y, buttonWidth, buttonHeight);
        button.backgroundColor = [UIColor colorWithRed:0.35 green:0.25 blue:0.45 alpha:0.8];
        button.layer.cornerRadius = 12;
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
        iconView.image = [UIImage systemImageNamed:buttonData[i][@"icon"]];
        iconView.tintColor = UIColor.whiteColor;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 15, buttonWidth - 66, 25)];
        titleLabel.text = buttonData[i][@"title"];
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 40, buttonWidth - 66, 20)];
        subtitleLabel.text = buttonData[i][@"subtitle"];
        subtitleLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        subtitleLabel.font = [UIFont systemFontOfSize:14];
        
        [button addSubview:iconView];
        [button addSubview:titleLabel];
        [button addSubview:subtitleLabel];
        [self.view addSubview:button];
    }
}

- (void)setupBottomTabBar {
    UIView *tabBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 80, self.view.bounds.size.width, 80)];
    tabBar.backgroundColor = [UIColor colorWithRed:0.35 green:0.25 blue:0.45 alpha:0.8];
    
    NSArray *tabIcons = @[@"house", @"chart.bar", @"person.circle"];
    CGFloat tabWidth = self.view.bounds.size.width / 3;
    
    for (int i = 0; i < 3; i++) {
        UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeSystem];
        tabButton.frame = CGRectMake(i * tabWidth, 0, tabWidth, 80);
        [tabButton setImage:[UIImage systemImageNamed:tabIcons[i]] forState:UIControlStateNormal];
        [tabButton setTintColor:UIColor.whiteColor];
        [tabBar addSubview:tabButton];
    }
    
    [self.view addSubview:tabBar];
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
