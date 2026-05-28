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
@end

@implementation PillowController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;
    _index = 1;
    _pose = @"01";


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


    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(controlLabel.frame) + 20, iPhoneWidth - 40, 350)];
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






    UIView *controlBgView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(controlLabel.frame) + 20, iPhoneWidth - 40, 380)];
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


    _sideLySlider = [[PillowSlider alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_highBtn.frame) + 15, iPhoneWidth - 40, 130)];
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

    saveBtn.frame = CGRectMake(iPhoneWidth/2 - 171, CGRectGetMaxY(controlBgView.frame) + 18, 342, 56);

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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"高度建议"
                                                                   message:@"根据网页原型，此处用于录入身高、体重、颈围、肩宽、背型和床垫软硬，计算侧睡/仰睡推荐高度。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"采用推荐 侧睡 9cm / 仰睡 6.5cm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.sideLySlider.title = @"侧睡高度 · 推荐 9cm";
        self.supineSlider.title = @"仰睡高度 · 推荐 6.5cm";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
