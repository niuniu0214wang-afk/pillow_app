//
//  PillowController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/6.
//

#import "PillowController.h"
#import "../Views/PillowSlider.h"

@interface PillowController ()<PillowSliderDelegate>

@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UIButton *rightBtn;
@property (strong, nonatomic) NSString *pose;

@property (strong, nonatomic) UIButton *lowBtn;
@property (strong, nonatomic) UIButton *midBtn;
@property (strong, nonatomic) UIButton *highBtn;
@property (strong, nonatomic) PillowSlider *supineSlider;
@property (strong, nonatomic) PillowSlider *sideLySlider;


@property (assign, nonatomic) int index;
@property (assign, nonatomic) int area;

@property (assign, nonatomic) BOOL isArea;  //是否是区域调节
@property (assign, nonatomic) int areaPressure; //区域压力阈值
@property (strong, nonatomic) UIButton *autoModeBtn;
@property (strong, nonatomic) UIButton *manualModeBtn;
@property (strong, nonatomic) UIView *autoPanelView;
@property (strong, nonatomic) UIView *manualPanelView;
@property (assign, nonatomic) int recommendedSideHeight;
@property (assign, nonatomic) int recommendedBackHeight;
@property (strong, nonatomic) UIView *heightAdviceOverlay;
@property (strong, nonatomic) UIView *heightAdviceSheet;
@property (strong, nonatomic) NSArray<UIButton *> *manualPressureCards;
@property (strong, nonatomic) NSArray<UILabel *> *manualPressureValueLabels;
@property (strong, nonatomic) UILabel *manualPressureSliderTitleLabel;
@property (strong, nonatomic) UISlider *manualPressureSlider;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *manualPressureValues;
@property (assign, nonatomic) NSInteger selectedManualPressureIndex;
@end

@implementation PillowController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;
    _index = 1;
    _pose = @"01";
    _recommendedSideHeight = 9;
    _recommendedBackHeight = 7;
    _selectedManualPressureIndex = 0;
    NSArray *savedManualPressureValues = [[NSUserDefaults standardUserDefaults] objectForKey:@"pillow_manual_pressure_values"];
    if (savedManualPressureValues.count == 5) {
        _manualPressureValues = [savedManualPressureValues mutableCopy];
    } else {
        _manualPressureValues = [@[@34, @31, @36, @28, @29] mutableCopy];
    }


    UIColor *color = [UIColor colorWithValue:@"ffffff" alpha:0.1];
    UIImage *colorImage = [[ToolHexManager sharedManager] imageWithColor:color];

    UILabel *brandLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, STATUS_BAR_HEIGHT + 7, 80, 30)];
    brandLabel.text = @"BOP";
    brandLabel.textColor = [UIColor whiteColor];
    brandLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightLight];
    [self.view addSubview:brandLabel];

    UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    helpBtn.frame = CGRectMake(iPhoneWidth - 48, STATUS_BAR_HEIGHT + 8, 28, 28);
    helpBtn.layer.cornerRadius = 14.0;
    helpBtn.layer.masksToBounds = YES;
    helpBtn.layer.borderWidth = 1.0;
    helpBtn.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.1].CGColor;
    helpBtn.backgroundColor = [UIColor colorWithValue:@"#ffffff" alpha:0.05];
    [helpBtn setTitle:@"?" forState:UIControlStateNormal];
    [helpBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    helpBtn.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    [helpBtn addTarget:self action:@selector(showPillowHelp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:helpBtn];

    UIView *poseCapsule = [[UIView alloc] initWithFrame:CGRectMake(iPhoneWidth - 164, STATUS_BAR_HEIGHT + 7, 108, 30)];
    poseCapsule.backgroundColor = [UIColor colorWithValue:@"#161616"];
    poseCapsule.layer.cornerRadius = 10.0;
    poseCapsule.layer.masksToBounds = YES;
    [self.view addSubview:poseCapsule];
    poseCapsule.hidden = YES;

    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(4, 3, 48, 24);
    [_leftBtn setTitle:@"仰卧" forState:UIControlStateNormal];
    [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_leftBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_leftBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [_leftBtn setBackgroundImage:colorImage forState:UIControlStateSelected];
    _leftBtn.layer.cornerRadius = 12.0;
    _leftBtn.layer.masksToBounds = YES;
    _leftBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _leftBtn.selected = YES;
    [_leftBtn addTarget:self action:@selector(changeBedSide:) forControlEvents:UIControlEventTouchUpInside];
    [poseCapsule addSubview:_leftBtn];

    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(56, 3, 48, 24);
    [_rightBtn setTitle:@"侧卧" forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_rightBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_rightBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [_rightBtn setBackgroundImage:colorImage forState:UIControlStateSelected];
    _rightBtn.layer.cornerRadius = 12.0;
    _rightBtn.layer.masksToBounds = YES;
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_rightBtn addTarget:self action:@selector(changeBedSide:) forControlEvents:UIControlEventTouchUpInside];
    [poseCapsule addSubview:_rightBtn];



    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, STATUS_BAR_HEIGHT + 48, iPhoneWidth - 60, 20)];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"DreamPillow";
    [self.view addSubview:titleLabel];

    UIView *modeSegment = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLabel.frame) + 14, iPhoneWidth - 40, 48)];
    modeSegment.backgroundColor = [UIColor colorWithValue:@"#111111"];
    modeSegment.layer.cornerRadius = 14.0;
    modeSegment.layer.masksToBounds = YES;
    modeSegment.layer.borderWidth = 1.0;
    modeSegment.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    [self.view addSubview:modeSegment];

    _autoModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _autoModeBtn.frame = CGRectMake(4, 4, modeSegment.frame.size.width / 2.0 - 6, 40);
    _autoModeBtn.layer.cornerRadius = 11.0;
    _autoModeBtn.layer.masksToBounds = YES;
    [_autoModeBtn setTitle:@"自动模式" forState:UIControlStateNormal];
    [_autoModeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [_autoModeBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_autoModeBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
    [_autoModeBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    _autoModeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _autoModeBtn.selected = YES;
    [_autoModeBtn addTarget:self action:@selector(switchPillowMode:) forControlEvents:UIControlEventTouchUpInside];
    [modeSegment addSubview:_autoModeBtn];

    _manualModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _manualModeBtn.frame = CGRectMake(CGRectGetMaxX(_autoModeBtn.frame) + 4, 4, modeSegment.frame.size.width / 2.0 - 6, 40);
    _manualModeBtn.layer.cornerRadius = 11.0;
    _manualModeBtn.layer.masksToBounds = YES;
    [_manualModeBtn setTitle:@"手动模式" forState:UIControlStateNormal];
    [_manualModeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [_manualModeBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_manualModeBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
    [_manualModeBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    _manualModeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_manualModeBtn addTarget:self action:@selector(switchPillowMode:) forControlEvents:UIControlEventTouchUpInside];
    [modeSegment addSubview:_manualModeBtn];

    UIImageView *pollowImage = [[UIImageView alloc] initWithFrame:CGRectMake(iPhoneWidth/2 - 64, CGRectGetMaxY(modeSegment.frame) + 24, 128, 64)];
    pollowImage.image = [UIImage imageNamed:@"pillow"];
    [self.view addSubview:pollowImage];

    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(iPhoneWidth/2 - 28, CGRectGetMaxY(pollowImage.frame) + 10, 56, 28)];
    stateLabel.backgroundColor = [UIColor colorWithValue:@"#22c55e" alpha:0.12];
    stateLabel.layer.cornerRadius = 14.0;
    stateLabel.layer.borderColor = [UIColor colorWithValue:@"#22c55e" alpha:0.25].CGColor;
    stateLabel.layer.borderWidth = 1.0;
    stateLabel.layer.masksToBounds = YES;
    stateLabel.font = [UIFont systemFontOfSize:12.0];
    stateLabel.textAlignment = NSTextAlignmentCenter;
    stateLabel.textColor = [UIColor colorWithValue:@"#22c55e"];
    stateLabel.text = @"在枕";
    [self.view addSubview:stateLabel];

    UILabel *controlLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(stateLabel.frame) + 20, 100, 28)];
    controlLabel.backgroundColor = [UIColor clearColor];
    controlLabel.font = [UIFont systemFontOfSize:12.0];
    controlLabel.textAlignment = NSTextAlignmentLeft;
    controlLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    controlLabel.text = @"高度调节";
    [self.view addSubview:controlLabel];


    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(controlLabel.frame) + 20, iPhoneWidth - 40, 410)];
    testView.backgroundColor = [UIColor colorWithValue:@"#11111111"];
    testView.layer.cornerRadius = 20.0;
    testView.layer.masksToBounds = YES;
    testView.hidden = YES;
    self.manualPanelView = testView;
    [self.view addSubview:testView];

    UILabel *airbagLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 100, 28)];
    airbagLabel.backgroundColor = [UIColor clearColor];
    airbagLabel.font = [UIFont systemFontOfSize:12.0];
    airbagLabel.textAlignment = NSTextAlignmentLeft;
    airbagLabel.textColor = [UIColor colorWithValue:@"#9ca3af"];
    airbagLabel.text = @"气囊调节";
    [testView addSubview:airbagLabel];


    UIImage *highImage = [[ToolHexManager sharedManager] imageWithColor:[UIColor colorWithValue:@"#00d4ff" alpha:0.1]];
    UIImage *normalImage = [[ToolHexManager sharedManager] imageWithColor:[UIColor colorWithValue:@"#ffffff" alpha:0.1]];

    float scal = ((iPhoneWidth - 40) - 290)/4;

    for (int i = 0; i < 5; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
        [btn setBackgroundImage:highImage forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateSelected];
        btn.frame = CGRectMake(20 + i%5*(scal + 50), CGRectGetMaxY(airbagLabel.frame) + 5, 50, 44);
        btn.layer.cornerRadius = 12.0;
        btn.layer.masksToBounds = YES;
        btn.tag = 156 + i;
        if (i == 0) {
            btn.selected = YES;
        }
        [btn setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(pillowControl:) forControlEvents:UIControlEventTouchUpInside];
        [testView addSubview:btn];
    }

    UILabel *areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(airbagLabel.frame) + 59, 100, 28)];
    areaLabel.backgroundColor = [UIColor clearColor];
    areaLabel.font = [UIFont systemFontOfSize:12.0];
    areaLabel.textAlignment = NSTextAlignmentLeft;
    areaLabel.textColor = [UIColor colorWithValue:@"#9ca3af"];
    areaLabel.text = @"区域调节";
    [testView addSubview:areaLabel];

    UIButton *topArea = [UIButton buttonWithType:UIButtonTypeCustom];
    topArea.frame = CGRectMake(20, CGRectGetMaxY(areaLabel.frame) + 10, iPhoneWidth/2 - 45, 44);
    topArea.layer.cornerRadius = 12.0;
    topArea.layer.masksToBounds = YES;
    topArea.tag = 162;
    [topArea setTitle:@"顶部区域" forState:UIControlStateNormal];
    [topArea setBackgroundImage:normalImage forState:UIControlStateNormal];
    [topArea setBackgroundImage:highImage forState:UIControlStateSelected];
    [topArea setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    [topArea setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateSelected];
    [topArea addTarget:self action:@selector(pillowControl:) forControlEvents:UIControlEventTouchUpInside];
    [testView addSubview:topArea];

    UIButton *bommArea = [UIButton buttonWithType:UIButtonTypeCustom];
    bommArea.frame = CGRectMake(CGRectGetMaxX(topArea.frame) + 10, CGRectGetMaxY(areaLabel.frame) + 10, iPhoneWidth/2 - 45, 44);
    bommArea.layer.cornerRadius = 12.0;
    bommArea.layer.masksToBounds = YES;
    bommArea.tag = 161;
    [bommArea setBackgroundImage:normalImage forState:UIControlStateNormal];
    [bommArea setBackgroundImage:highImage forState:UIControlStateSelected];
    [bommArea setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    [bommArea setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateSelected];
    [bommArea setTitle:@"底部区域" forState:UIControlStateNormal];
    [bommArea addTarget:self action:@selector(pillowControl:) forControlEvents:UIControlEventTouchUpInside];
    [testView addSubview:bommArea];

    PillowSlider *airBagSlider = [[PillowSlider alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bommArea.frame) + 25, iPhoneWidth - 40, 130)];
    airBagSlider.delegate = self;
    airBagSlider.title = @"高度";
    [testView addSubview:airBagSlider];



    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.backgroundColor = [UIColor whiteColor];
    saveBtn.layer.cornerRadius = 10.0;
    saveBtn.layer.masksToBounds = YES;
    saveBtn.frame = CGRectMake(iPhoneWidth/2 - 171, CGRectGetMaxY(testView.frame) + 20, 342, 56);
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [saveBtn setTitleColor:mainColor forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];






    UIView *controlBgView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(controlLabel.frame) + 20, iPhoneWidth - 40, 500)];
    controlBgView.backgroundColor = [UIColor colorWithValue:@"#11111111"];
    controlBgView.layer.cornerRadius = 20.0;
    controlBgView.layer.masksToBounds = YES;
    controlBgView.hidden = NO;
    self.autoPanelView = controlBgView;
    [self.view addSubview:controlBgView];

    UILabel *highLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 100, 28)];
    highLabel.backgroundColor = [UIColor clearColor];
    highLabel.font = [UIFont systemFontOfSize:12.0];
    highLabel.textAlignment = NSTextAlignmentLeft;
    highLabel.textColor = [UIColor colorWithValue:@"#9ca3af"];
    highLabel.text = @"整体高度";
    [controlBgView addSubview:highLabel];

    UIColor *normalColor = [UIColor colorWithValue:@"#18181b"];
    UIColor *highColor = [UIColor colorWithValue:@"#00d4ff" alpha:0.1];
    _midBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _midBtn.frame = CGRectMake(iPhoneWidth/2 - 67, CGRectGetMaxY(highLabel.frame) + 5, 94, 40);
    [_midBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:normalColor] forState:UIControlStateNormal];
    [_midBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:highColor] forState:UIControlStateSelected];
    [_midBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    [_midBtn setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateSelected];
    _midBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_midBtn setTitle:@"中" forState:UIControlStateNormal];
    _midBtn.layer.cornerRadius = 12.0;
    _midBtn.layer.masksToBounds = YES;
    [controlBgView addSubview:_midBtn];

    _lowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _lowBtn.frame = CGRectMake(CGRectGetMinX(_midBtn.frame) - 109, CGRectGetMaxY(highLabel.frame) + 5, 94, 40);
    [_lowBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:normalColor] forState:UIControlStateNormal];
    [_lowBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:highColor] forState:UIControlStateSelected];
    [_lowBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    [_lowBtn setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateSelected];
    _lowBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_lowBtn setTitle:@"低" forState:UIControlStateNormal];
    _lowBtn.layer.cornerRadius = 12.0;
    _lowBtn.layer.masksToBounds = YES;
    [controlBgView addSubview:_lowBtn];


    _highBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _highBtn.frame = CGRectMake(CGRectGetMaxX(_midBtn.frame) + 15, CGRectGetMaxY(highLabel.frame) + 5, 94, 40);
    [_highBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:normalColor] forState:UIControlStateNormal];
    [_highBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:highColor] forState:UIControlStateSelected];
    [_highBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    [_highBtn setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateSelected];
    _highBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_highBtn setTitle:@"高" forState:UIControlStateNormal];
    _highBtn.layer.cornerRadius = 12.0;
    _highBtn.layer.masksToBounds = YES;
    [controlBgView addSubview:_highBtn];


    highLabel.hidden = YES;
    _lowBtn.hidden = YES;
    _midBtn.hidden = YES;
    _highBtn.hidden = YES;

    _sideLySlider = [[PillowSlider alloc] initWithFrame:CGRectMake(0, 24, iPhoneWidth - 40, 130)];
    _sideLySlider.title = @"侧睡高度";
    [controlBgView addSubview:_sideLySlider];

    _supineSlider = [[PillowSlider alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_sideLySlider.frame), iPhoneWidth - 40, 130)];
    _supineSlider.title = @"仰睡高度";
    [controlBgView addSubview:_supineSlider];

    UIButton *adviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    adviceBtn.frame = CGRectMake(20, CGRectGetMaxY(_supineSlider.frame) + 8, controlBgView.frame.size.width - 40, 44);
    adviceBtn.layer.cornerRadius = 12.0;
    adviceBtn.layer.masksToBounds = YES;
    adviceBtn.layer.borderWidth = 1.0;
    adviceBtn.layer.borderColor = [UIColor colorWithValue:@"#00d4ff" alpha:0.3].CGColor;
    adviceBtn.backgroundColor = [UIColor colorWithValue:@"#00d4ff" alpha:0.1];
    [adviceBtn setTitle:@"高度建议" forState:UIControlStateNormal];
    [adviceBtn setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateNormal];
    adviceBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [adviceBtn addTarget:self action:@selector(showHeightAdvice) forControlEvents:UIControlEventTouchUpInside];
    [controlBgView addSubview:adviceBtn];

    UILabel *memoryTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(adviceBtn.frame) + 18, controlBgView.frame.size.width - 40, 18)];
    memoryTitle.text = @"睡姿记忆模式";
    memoryTitle.textColor = [UIColor colorWithValue:@"#6b7280"];
    memoryTitle.font = [UIFont systemFontOfSize:12.0];
    [controlBgView addSubview:memoryTitle];

    NSArray *memoryModes = @[@"午睡模式", @"侧睡舒适", @"新增记忆"];
    for (NSInteger i = 0; i < memoryModes.count; i++) {
        UIButton *modeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        modeBtn.frame = CGRectMake(20 + i * ((controlBgView.frame.size.width - 52) / 3.0 + 6), CGRectGetMaxY(memoryTitle.frame) + 10, (controlBgView.frame.size.width - 52) / 3.0, 38);
        modeBtn.layer.cornerRadius = 19.0;
        modeBtn.layer.borderWidth = 1.0;
        modeBtn.layer.borderColor = [UIColor colorWithValue:(i == 2 ? @"#00d4ff" : @"#27272a") alpha:(i == 2 ? 0.35 : 1.0)].CGColor;
        modeBtn.backgroundColor = [UIColor colorWithValue:(i == 2 ? @"#00d4ff" : @"#18181b") alpha:(i == 2 ? 0.10 : 1.0)];
        [modeBtn setTitle:memoryModes[i] forState:UIControlStateNormal];
        [modeBtn setTitleColor:[UIColor colorWithValue:(i == 2 ? @"#00d4ff" : @"#9ca3af")] forState:UIControlStateNormal];
        modeBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [modeBtn addTarget:self action:@selector(showMemoryModeFlow:) forControlEvents:UIControlEventTouchUpInside];
        [controlBgView addSubview:modeBtn];
    }
    memoryTitle.hidden = YES;
    for (UIView *subview in controlBgView.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && CGRectGetMinY(subview.frame) > CGRectGetMaxY(memoryTitle.frame)) {
            subview.hidden = YES;
        }
    }

    saveBtn.frame = CGRectMake(iPhoneWidth/2 - 171, CGRectGetMaxY(controlBgView.frame) + 18, 342, 56);
    [self rebuildReactManualPanel];

}

- (void)switchPillowMode:(UIButton *)btn
{
    BOOL autoMode = btn == self.autoModeBtn;
    self.autoModeBtn.selected = autoMode;
    self.manualModeBtn.selected = !autoMode;
    self.autoPanelView.hidden = !autoMode;
    self.manualPanelView.hidden = autoMode;
}

- (void)changeBedSide:(UIButton *)btn
{
    if (btn.selected == YES) {
        return;
    }
    btn.selected = YES;
    if (btn == _leftBtn) {
        _rightBtn.selected = NO;
        _pose = @"01";
    }else{
        _leftBtn.selected = NO;
        _pose = @"02";
    }
}


- (void)pillowControl:(UIButton *)btn
{
    if (btn.selected == YES) {
        return;
    }
    btn.selected = YES;
    if (btn.tag < 161) {
        _index = (int)btn.tag - 155;
        for (int i = 0; i < 5; i++) {
            UIButton *button = (UIButton *)[self.view viewWithTag:155 + i];
            if (btn.tag != button.tag) {
                button.selected = NO;
            }
        }
        return;
    }
    _isArea = YES;
    _area = (int)btn.tag - 160;
    NSInteger btnTag = btn.tag == 161 ? 162 : 161;
    UIButton *button = (UIButton *)[self.view viewWithTag:btnTag];
    button.selected = NO;
}


- (void)pillowSlider:(PillowSlider *)slider pressureValue:(int)value
{
    if (_isArea) {
        NSData *data = [ControlCenter controlPillowArea:_area pressureValue:value];
        [[BLEManager shareInstance] didSendMessageToDevice:data];
        return;
    }

    NSData *data = [ControlCenter controlPillowAirBag:_index pressureValue:value];
    [[BLEManager shareInstance] didSendMessageToDevice:data];
}


- (void)save
{
    NSData *data = [ControlCenter savePillowPressure:_pose pillowArea:0 pressureValue:0];
    [[BLEManager shareInstance] didSendMessageToDevice:data];
    [MJProgressHUD onlyShowMessage:@"Pillow settings saved" afterDelay:1.0 showAddTo:self.view];
}

- (void)showHeightAdvice
{
    [self.heightAdviceOverlay removeFromSuperview];

    UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.backgroundColor = [UIColor colorWithValue:@"#000000" alpha:0.62];
    overlay.alpha = 0;
    self.heightAdviceOverlay = overlay;
    [self.view addSubview:overlay];

    UIButton *dismiss = [UIButton buttonWithType:UIButtonTypeCustom];
    dismiss.frame = overlay.bounds;
    [dismiss addTarget:self action:@selector(dismissHeightAdviceSheet) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:dismiss];

    CGFloat sheetH = MIN(iPhoneHeight - STATUS_BAR_HEIGHT - 24, 690);
    UIView *sheet = [[UIView alloc] initWithFrame:CGRectMake(0, iPhoneHeight, iPhoneWidth, sheetH)];
    sheet.backgroundColor = [UIColor colorWithValue:@"#111111"];
    sheet.layer.cornerRadius = 24.0;
    sheet.layer.masksToBounds = YES;
    self.heightAdviceSheet = sheet;
    [overlay addSubview:sheet];

    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, sheetH)];
    scroll.alwaysBounceVertical = YES;
    [sheet addSubview:scroll];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(24, 22, iPhoneWidth - 80, 24)];
    title.text = @"高度建议";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium];
    [scroll addSubview:title];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    close.frame = CGRectMake(iPhoneWidth - 52, 18, 36, 32);
    [close setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal];
    close.tintColor = [UIColor colorWithValue:@"#6b7280"];
    [close addTarget:self action:@selector(dismissHeightAdviceSheet) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:close];

    CGFloat y = 64;
    CGFloat fieldW = (iPhoneWidth - 60) / 2.0;
    [scroll addSubview:[self adviceInputWithFrame:CGRectMake(24, y, fieldW, 64) label:@"身高 (cm)" placeholder:@"170" tag:6100]];
    [scroll addSubview:[self adviceInputWithFrame:CGRectMake(36 + fieldW, y, fieldW, 64) label:@"体重 (kg)" placeholder:@"65" tag:6101]];

    y += 78;
    [scroll addSubview:[self adviceSegmentWithFrame:CGRectMake(24, y, iPhoneWidth - 48, 70) label:@"性别" options:@[@"男", @"女"] selectedIndex:0 tagBase:6200]];

    y += 86;
    [scroll addSubview:[self adviceInputWithFrame:CGRectMake(24, y, iPhoneWidth - 48, 64) label:@"颈围  标准值约 35cm" placeholder:@"35" tag:6102]];

    y += 78;
    [scroll addSubview:[self adviceInputWithFrame:CGRectMake(24, y, iPhoneWidth - 48, 64) label:@"肩宽" placeholder:@"42" tag:6103]];

    y += 78;
    [scroll addSubview:[self adviceSegmentWithFrame:CGRectMake(24, y, iPhoneWidth - 48, 70) label:@"背型" options:@[@"较薄", @"较厚", @"微驼"] selectedIndex:0 tagBase:6300]];

    y += 86;
    [scroll addSubview:[self adviceSegmentWithFrame:CGRectMake(24, y, iPhoneWidth - 48, 70) label:@"床垫软硬" options:@[@"较软", @"适中", @"较硬"] selectedIndex:1 tagBase:6400]];

    y += 90;
    UIButton *calc = [UIButton buttonWithType:UIButtonTypeCustom];
    calc.frame = CGRectMake(24, y, iPhoneWidth - 48, 48);
    calc.backgroundColor = [UIColor colorWithValue:@"#00d4ff" alpha:0.10];
    calc.layer.cornerRadius = 14.0;
    calc.layer.borderWidth = 1.0;
    calc.layer.borderColor = [UIColor colorWithValue:@"#00d4ff" alpha:0.30].CGColor;
    [calc setTitle:@"查看建议" forState:UIControlStateNormal];
    [calc setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateNormal];
    calc.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    [calc addTarget:self action:@selector(calculateHeightRecommendation) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:calc];

    scroll.contentSize = CGSizeMake(0, CGRectGetMaxY(calc.frame) + 32);

    [UIView animateWithDuration:0.25 animations:^{
        overlay.alpha = 1;
        sheet.frame = CGRectMake(0, iPhoneHeight - sheetH, iPhoneWidth, sheetH);
    }];
}

- (void)showHeightRecommendationSheet
{
    UIScrollView *scroll = (UIScrollView *)self.heightAdviceSheet.subviews.firstObject;
    UIView *old = [scroll viewWithTag:6500];
    [old removeFromSuperview];

    CGFloat y = scroll.contentSize.height - 20;
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(24, y, iPhoneWidth - 48, 252)];
    card.tag = 6500;
    card.backgroundColor = [UIColor colorWithValue:@"#18181b"];
    card.layer.cornerRadius = 16.0;
    card.layer.borderWidth = 1.0;
    card.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    [scroll addSubview:card];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 14, card.bounds.size.width - 32, 18)];
    title.text = @"推荐高度（橙色标记）";
    title.textColor = [UIColor colorWithValue:@"#9ca3af"];
    title.font = [UIFont systemFontOfSize:12.0];
    [card addSubview:title];

    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(16, 36, card.bounds.size.width - 32, 16)];
    desc.text = @"根据睡眠模型分析，适合您的枕头高度如下：";
    desc.textColor = [UIColor colorWithValue:@"#6b7280"];
    desc.font = [UIFont systemFontOfSize:10.0];
    [card addSubview:desc];

    [card addSubview:[self recommendationRowWithFrame:CGRectMake(16, 68, card.bounds.size.width - 32, 54) title:@"侧睡高度" current:self.sideLySlider.value recommended:self.recommendedSideHeight min:6 max:12]];
    [card addSubview:[self recommendationRowWithFrame:CGRectMake(16, 132, card.bounds.size.width - 32, 54) title:@"仰睡高度" current:self.supineSlider.value recommended:self.recommendedBackHeight min:5 max:8]];

    UIButton *apply = [UIButton buttonWithType:UIButtonTypeCustom];
    apply.frame = CGRectMake(16, 202, (card.bounds.size.width - 40) / 2.0, 38);
    apply.backgroundColor = [UIColor whiteColor];
    apply.layer.cornerRadius = 12.0;
    [apply setTitle:@"采用推荐" forState:UIControlStateNormal];
    [apply setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    apply.titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
    [apply addTarget:self action:@selector(applyRecommendationOnly) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:apply];

    UIButton *memory = [UIButton buttonWithType:UIButtonTypeCustom];
    memory.frame = CGRectMake(CGRectGetMaxX(apply.frame) + 8, 202, (card.bounds.size.width - 40) / 2.0, 38);
    memory.backgroundColor = [UIColor colorWithValue:@"#00d4ff" alpha:0.10];
    memory.layer.cornerRadius = 12.0;
    memory.layer.borderWidth = 1.0;
    memory.layer.borderColor = [UIColor colorWithValue:@"#00d4ff" alpha:0.30].CGColor;
    [memory setTitle:@"采用并记忆" forState:UIControlStateNormal];
    [memory setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateNormal];
    memory.titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
    [memory addTarget:self action:@selector(applyRecommendationAndMemory) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:memory];

    scroll.contentSize = CGSizeMake(0, CGRectGetMaxY(card.frame) + 30);
    [scroll setContentOffset:CGPointMake(0, MAX(0, scroll.contentSize.height - scroll.bounds.size.height)) animated:YES];
}

- (void)applyRecommendedHeightsWithMemory:(BOOL)remember
{
    self.sideLySlider.title = [NSString stringWithFormat:@"侧睡高度 · 推荐 %dcm", self.recommendedSideHeight];
    self.supineSlider.title = [NSString stringWithFormat:@"仰睡高度 · 推荐 %dcm", self.recommendedBackHeight];
    self.sideLySlider.value = self.recommendedSideHeight;
    self.supineSlider.value = self.recommendedBackHeight;

    if (remember) {
        NSString *mode = [NSString stringWithFormat:@"推荐模式 %d/%dcm", self.recommendedSideHeight, self.recommendedBackHeight];
        NSMutableArray *modes = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"pillow_memory_modes"] ?: @[]];
        [modes addObject:mode];
        [[NSUserDefaults standardUserDefaults] setObject:modes.copy forKey:@"pillow_memory_modes"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [MJProgressHUD onlyShowMessage:@"已采用推荐并加入记忆" afterDelay:1.0 showAddTo:self.view];
    } else {
        [MJProgressHUD onlyShowMessage:@"已采用推荐高度" afterDelay:1.0 showAddTo:self.view];
    }
}

- (UIView *)adviceInputWithFrame:(CGRect)frame label:(NSString *)label placeholder:(NSString *)placeholder tag:(NSInteger)tag
{
    UIView *wrap = [[UIView alloc] initWithFrame:frame];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 18)];
    labelView.text = label;
    labelView.textColor = [UIColor colorWithValue:@"#9ca3af"];
    labelView.font = [UIFont systemFontOfSize:12.0];
    [wrap addSubview:labelView];

    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 24, frame.size.width, 40)];
    field.tag = tag;
    field.backgroundColor = [UIColor colorWithValue:@"#18181b"];
    field.textColor = [UIColor whiteColor];
    field.font = [UIFont systemFontOfSize:13.0];
    field.layer.cornerRadius = 12.0;
    field.layer.borderWidth = 1.0;
    field.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    field.leftViewMode = UITextFieldViewModeAlways;
    field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:[UIColor colorWithValue:@"#6b7280"]}];
    field.keyboardType = UIKeyboardTypeDecimalPad;
    [wrap addSubview:field];
    return wrap;
}

- (UIView *)adviceSegmentWithFrame:(CGRect)frame label:(NSString *)label options:(NSArray<NSString *> *)options selectedIndex:(NSInteger)selectedIndex tagBase:(NSInteger)tagBase
{
    UIView *wrap = [[UIView alloc] initWithFrame:frame];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 18)];
    labelView.text = label;
    labelView.textColor = [UIColor colorWithValue:@"#9ca3af"];
    labelView.font = [UIFont systemFontOfSize:12.0];
    [wrap addSubview:labelView];

    CGFloat gap = 8.0;
    CGFloat width = (frame.size.width - gap * (options.count - 1)) / options.count;
    for (NSInteger i = 0; i < options.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i * (width + gap), 26, width, 38);
        button.tag = tagBase + i;
        button.layer.cornerRadius = 12.0;
        button.layer.borderWidth = 1.0;
        BOOL selected = i == selectedIndex;
        button.layer.borderColor = [UIColor colorWithValue:(selected ? @"#ffffff" : @"#27272a") alpha:(selected ? 0.24 : 1.0)].CGColor;
        button.backgroundColor = [UIColor colorWithValue:(selected ? @"#ffffff" : @"#18181b") alpha:(selected ? 0.10 : 1.0)];
        [button setTitle:options[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithValue:(selected ? @"#ffffff" : @"#9ca3af")] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [button addTarget:self action:@selector(heightAdviceOptionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [wrap addSubview:button];
    }
    return wrap;
}

- (void)heightAdviceOptionTapped:(UIButton *)sender
{
    NSInteger group = sender.tag / 100;
    for (UIView *subview in sender.superview.subviews) {
        if (![subview isKindOfClass:[UIButton class]]) {
            continue;
        }
        UIButton *button = (UIButton *)subview;
        if (button.tag / 100 != group) {
            continue;
        }
        BOOL selected = button == sender;
        button.backgroundColor = [UIColor colorWithValue:(selected ? @"#ffffff" : @"#18181b") alpha:(selected ? 0.10 : 1.0)];
        button.layer.borderColor = [UIColor colorWithValue:(selected ? @"#ffffff" : @"#27272a") alpha:(selected ? 0.24 : 1.0)].CGColor;
        [button setTitleColor:[UIColor colorWithValue:(selected ? @"#ffffff" : @"#9ca3af")] forState:UIControlStateNormal];
    }
}

- (void)calculateHeightRecommendation
{
    UITextField *heightField = (UITextField *)[self.heightAdviceSheet viewWithTag:6100];
    NSInteger height = heightField.text.integerValue;
    if (height <= 0) {
        height = 170;
    }
    self.recommendedSideHeight = MIN(12, MAX(6, (int)round(height / 20.0 + 1)));
    self.recommendedBackHeight = MIN(8, MAX(5, (int)round(height / 28.0)));
    [self showHeightRecommendationSheet];
}

- (UIView *)recommendationRowWithFrame:(CGRect)frame title:(NSString *)title current:(int)current recommended:(int)recommended min:(int)min max:(int)max
{
    UIView *row = [[UIView alloc] initWithFrame:frame];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 2.0, 18)];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor colorWithValue:@"#9ca3af"];
    titleLabel.font = [UIFont systemFontOfSize:12.0];
    [row addSubview:titleLabel];

    UILabel *value = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 2.0, 0, frame.size.width / 2.0, 18)];
    value.text = [NSString stringWithFormat:@"%d cm  推荐 %d cm", current, recommended];
    value.textColor = [UIColor whiteColor];
    value.textAlignment = NSTextAlignmentRight;
    value.font = [UIFont systemFontOfSize:11.0];
    [row addSubview:value];

    UIView *track = [[UIView alloc] initWithFrame:CGRectMake(0, 30, frame.size.width, 6)];
    track.backgroundColor = [UIColor colorWithValue:@"#27272a"];
    track.layer.cornerRadius = 3.0;
    [row addSubview:track];

    CGFloat currentPercent = (current - min) / (CGFloat)(max - min);
    UIView *fill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * MAX(0, MIN(1, currentPercent)), 6)];
    fill.backgroundColor = [UIColor colorWithValue:@"#00d4ff"];
    fill.layer.cornerRadius = 3.0;
    [track addSubview:fill];

    CGFloat recPercent = (recommended - min) / (CGFloat)(max - min);
    UIView *marker = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width * MAX(0, MIN(1, recPercent)) - 5, 26, 10, 14)];
    marker.backgroundColor = [UIColor colorWithValue:@"#f97316"];
    marker.layer.cornerRadius = 5.0;
    [row addSubview:marker];
    return row;
}

- (void)applyRecommendationOnly
{
    [self applyRecommendedHeightsWithMemory:NO];
    [self dismissHeightAdviceSheet];
}

- (void)applyRecommendationAndMemory
{
    [self applyRecommendedHeightsWithMemory:YES];
    [self dismissHeightAdviceSheet];
}

- (void)dismissHeightAdviceSheet
{
    if (!self.heightAdviceOverlay) {
        return;
    }
    UIView *overlay = self.heightAdviceOverlay;
    UIView *sheet = self.heightAdviceSheet;
    [UIView animateWithDuration:0.22 animations:^{
        overlay.alpha = 0;
        sheet.frame = CGRectMake(0, iPhoneHeight, iPhoneWidth, sheet.frame.size.height);
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
        self.heightAdviceOverlay = nil;
        self.heightAdviceSheet = nil;
    }];
}

- (void)showMemoryModeFlow:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"睡姿记忆模式"
                                                                   message:@"按照网页流程：先命名模式，再分别记录侧睡高度和仰睡高度，最多保存 4 个常用模式。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"例如：午睡模式";
        textField.text = sender.currentTitle;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"保存当前高度" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alert.textFields.firstObject.text.length > 0 ? alert.textFields.firstObject.text : @"睡姿模式";
        [sender setTitle:name forState:UIControlStateNormal];
        [MJProgressHUD onlyShowMessage:@"记忆完成" afterDelay:1.0 showAddTo:self.view];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showPillowHelp
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Pillow Control"
                                                                   message:@"Use posture tabs for back/side sleep, select an airbag or region, then adjust pressure and save."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)rebuildReactManualPanel
{
    [self.manualPanelView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    UILabel *overallTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, self.manualPanelView.bounds.size.width - 40, 18)];
    overallTitle.text = @"整体高度";
    overallTitle.textColor = [UIColor colorWithValue:@"#9ca3af"];
    overallTitle.font = [UIFont systemFontOfSize:12.0];
    [self.manualPanelView addSubview:overallTitle];

    NSArray *heightModes = @[@"低", @"中", @"高"];
    CGFloat modeW = (self.manualPanelView.bounds.size.width - 52) / 3.0;
    for (NSInteger i = 0; i < heightModes.count; i++) {
        UIButton *heightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        heightBtn.frame = CGRectMake(14 + i * (modeW + 6), CGRectGetMaxY(overallTitle.frame) + 8, modeW, 36);
        heightBtn.layer.cornerRadius = 12.0;
        heightBtn.layer.borderWidth = 1.0;
        heightBtn.layer.borderColor = [UIColor colorWithValue:(i == 1 ? @"#00d4ff" : @"#27272a") alpha:(i == 1 ? 0.40 : 1.0)].CGColor;
        heightBtn.backgroundColor = [UIColor colorWithValue:(i == 1 ? @"#00d4ff" : @"#18181b") alpha:(i == 1 ? 0.10 : 1.0)];
        [heightBtn setTitle:heightModes[i] forState:UIControlStateNormal];
        [heightBtn setTitleColor:[UIColor colorWithValue:(i == 1 ? @"#00d4ff" : @"#9ca3af")] forState:UIControlStateNormal];
        heightBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [heightBtn addTarget:self action:@selector(manualHeightModeTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.manualPanelView addSubview:heightBtn];
    }

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(overallTitle.frame) + 56, self.manualPanelView.bounds.size.width - 40, 18)];
    title.text = @"气囊压力";
    title.textColor = [UIColor colorWithValue:@"#6b7280"];
    title.font = [UIFont systemFontOfSize:12.0];
    [self.manualPanelView addSubview:title];

    NSArray *rows = @[@"后枕", @"左边", @"左中", @"右中", @"右边"];
    NSMutableArray *cards = [NSMutableArray array];
    NSMutableArray *valueLabels = [NSMutableArray array];
    CGFloat y = CGRectGetMaxY(title.frame) + 12;
    CGFloat cardGap = 6.0;
    CGFloat cardW = (self.manualPanelView.bounds.size.width - 28 - cardGap * 4) / 5.0;
    for (NSInteger i = 0; i < rows.count; i++) {
        UIButton *card = [UIButton buttonWithType:UIButtonTypeCustom];
        card.frame = CGRectMake(14 + i * (cardW + cardGap), y, cardW, 64);
        card.tag = 3300 + i;
        card.backgroundColor = [UIColor colorWithValue:@"#ffffff" alpha:0.03];
        card.layer.cornerRadius = 14.0;
        card.layer.borderWidth = 1.0;
        card.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.10].CGColor;
        [card addTarget:self action:@selector(manualPressureCardTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.manualPanelView addSubview:card];
        [cards addObject:card];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, card.bounds.size.width, 14)];
        label.text = rows[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithValue:@"#9ca3af"];
        label.font = [UIFont systemFontOfSize:12.0];
        [card addSubview:label];

        UILabel *value = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, card.bounds.size.width, 18)];
        value.tag = 3000 + i;
        value.text = [NSString stringWithFormat:@"%@", self.manualPressureValues[i]];
        value.textColor = [UIColor whiteColor];
        value.textAlignment = NSTextAlignmentCenter;
        value.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
        [card addSubview:value];
        [valueLabels addObject:value];
    }
    y += 70.0;
    self.manualPressureCards = cards.copy;
    self.manualPressureValueLabels = valueLabels.copy;

    self.manualPressureSliderTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y + 8, self.manualPanelView.bounds.size.width - 40, 18)];
    self.manualPressureSliderTitleLabel.textColor = [UIColor colorWithValue:@"#9ca3af"];
    self.manualPressureSliderTitleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.manualPanelView addSubview:self.manualPressureSliderTitleLabel];

    self.manualPressureSlider = [[UISlider alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(self.manualPressureSliderTitleLabel.frame) + 8, self.manualPanelView.bounds.size.width - 48, 28)];
    self.manualPressureSlider.minimumValue = 0;
    self.manualPressureSlider.maximumValue = 60;
    self.manualPressureSlider.value = [self.manualPressureValues[self.selectedManualPressureIndex] floatValue];
    self.manualPressureSlider.minimumTrackTintColor = [self pillowPressureColor:self.manualPressureSlider.value];
    self.manualPressureSlider.maximumTrackTintColor = [UIColor colorWithValue:@"#ffffff" alpha:0.08];
    self.manualPressureSlider.thumbTintColor = [UIColor whiteColor];
    [self.manualPressureSlider addTarget:self action:@selector(pressureSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.manualPanelView addSubview:self.manualPressureSlider];
    y = CGRectGetMaxY(self.manualPressureSlider.frame);
    [self updateManualPressureSelectionUI];

    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(20, y + 2, self.manualPanelView.bounds.size.width - 40, 28)];
    hint.text = @"先选择上方 5 个区域之一，再拖动下方进度条调节该区域压力。";
    hint.textColor = [UIColor colorWithValue:@"#4b5563"];
    hint.font = [UIFont systemFontOfSize:11.0];
    hint.numberOfLines = 0;
    [self.manualPanelView addSubview:hint];

    UIButton *memoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    memoryButton.frame = CGRectMake(20, CGRectGetMaxY(hint.frame) + 12, self.manualPanelView.bounds.size.width - 40, 42);
    memoryButton.backgroundColor = [UIColor colorWithValue:@"#00d4ff" alpha:0.10];
    memoryButton.layer.cornerRadius = 12.0;
    memoryButton.layer.borderWidth = 1.0;
    memoryButton.layer.borderColor = [UIColor colorWithValue:@"#00d4ff" alpha:0.30].CGColor;
    [memoryButton setTitle:@"记忆当前气囊设置" forState:UIControlStateNormal];
    [memoryButton setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateNormal];
    memoryButton.titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
    [memoryButton addTarget:self action:@selector(saveManualPressureValues) forControlEvents:UIControlEventTouchUpInside];
    [self.manualPanelView addSubview:memoryButton];
}

- (UIColor *)pillowPressureColor:(CGFloat)value
{
    if (value >= 45.0) {
        return [UIColor colorWithValue:@"#ef4444"];
    }
    if (value >= 30.0) {
        return [UIColor colorWithValue:@"#00d4ff"];
    }
    return [UIColor colorWithValue:@"#00FF87"];
}

- (void)manualHeightModeTapped:(UIButton *)sender
{
    UIView *parent = sender.superview;
    for (UIView *subview in parent.subviews) {
        if (![subview isKindOfClass:[UIButton class]]) {
            continue;
        }
        UIButton *button = (UIButton *)subview;
        BOOL selected = button == sender;
        if (![button.currentTitle isEqualToString:@"低"] && ![button.currentTitle isEqualToString:@"中"] && ![button.currentTitle isEqualToString:@"高"]) {
            continue;
        }
        button.backgroundColor = [UIColor colorWithValue:(selected ? @"#00d4ff" : @"#18181b") alpha:(selected ? 0.10 : 1.0)];
        button.layer.borderColor = [UIColor colorWithValue:(selected ? @"#00d4ff" : @"#27272a") alpha:(selected ? 0.40 : 1.0)].CGColor;
        [button setTitleColor:[UIColor colorWithValue:(selected ? @"#00d4ff" : @"#9ca3af")] forState:UIControlStateNormal];
    }
    [MJProgressHUD onlyShowMessage:@"整体高度已更新" afterDelay:0.8 showAddTo:self.view];
}

- (void)pressureSliderChanged:(UISlider *)slider
{
    NSInteger index = self.selectedManualPressureIndex;
    if (index < 0 || index >= self.manualPressureValues.count) {
        return;
    }

    int value = (int)roundf(slider.value);
    self.manualPressureValues[index] = @(value);
    slider.minimumTrackTintColor = [self pillowPressureColor:value];
    [self updateManualPressureSelectionUI];

    if (index == 0) {
        NSData *data = [ControlCenter controlPillowArea:1 pressureValue:value];
        [[BLEManager shareInstance] didSendMessageToDevice:data];
        return;
    }

    NSData *data = [ControlCenter controlPillowAirBag:(int)index pressureValue:value];
    [[BLEManager shareInstance] didSendMessageToDevice:data];
}

- (void)saveManualPressureValues
{
    [[NSUserDefaults standardUserDefaults] setObject:self.manualPressureValues.copy forKey:@"pillow_manual_pressure_values"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [MJProgressHUD onlyShowMessage:@"已记忆当前气囊设置" afterDelay:1.0 showAddTo:self.view];
}

- (void)manualPressureCardTapped:(UIButton *)sender
{
    NSInteger index = sender.tag - 3300;
    if (index < 0 || index >= self.manualPressureValues.count) {
        return;
    }

    self.selectedManualPressureIndex = index;
    self.manualPressureSlider.value = [self.manualPressureValues[index] floatValue];
    self.manualPressureSlider.minimumTrackTintColor = [self pillowPressureColor:self.manualPressureSlider.value];
    [self updateManualPressureSelectionUI];
}

- (void)updateManualPressureSelectionUI
{
    NSArray *rows = @[@"后枕", @"左边", @"左中", @"右中", @"右边"];
    for (NSInteger i = 0; i < self.manualPressureCards.count; i++) {
        UIButton *card = self.manualPressureCards[i];
        BOOL selected = i == self.selectedManualPressureIndex;
        CGFloat pressure = [self.manualPressureValues[i] floatValue];

        card.backgroundColor = [UIColor colorWithValue:(selected ? @"#00d4ff" : @"#ffffff") alpha:(selected ? 0.10 : 0.03)];
        card.layer.borderColor = [UIColor colorWithValue:(selected ? @"#00d4ff" : @"#ffffff") alpha:(selected ? 0.45 : 0.10)].CGColor;

        for (UIView *subview in card.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)subview;
                if (label.tag == 3000 + i) {
                    label.text = [NSString stringWithFormat:@"%d", (int)roundf(pressure)];
                    label.textColor = [UIColor colorWithValue:(selected ? @"#ffffff" : @"#d1d5db")];
                    continue;
                }
                label.textColor = [UIColor colorWithValue:(selected ? @"#ffffff" : @"#9ca3af")];
            }
        }
    }

    CGFloat selectedValue = [self.manualPressureValues[self.selectedManualPressureIndex] floatValue];
    if (self.selectedManualPressureIndex >= 0 && self.selectedManualPressureIndex < rows.count) {
        self.manualPressureSliderTitleLabel.text = [NSString stringWithFormat:@"调节%@气囊压力", rows[self.selectedManualPressureIndex]];
    }
    self.manualPressureSlider.value = selectedValue;
    self.manualPressureSlider.minimumTrackTintColor = [self pillowPressureColor:selectedValue];
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
