//
//  MainController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/3.
//

#import "MainController.h"
#import "../pages/SetViewController.h"
#import "../pages/PersonController.h"
#import "SearchController.h"
#import "../Views/RegulateProgress.h"
#import "../Views/ModeButton.h"
#import "../Views/RegulateSlider.h"
#import "../Views/UIImageView+GIF.h"
#import "../Views/ModeTimeView.h"
#import "../Views/HandAnimationView.h"

@interface MainController ()<bleManagerDelegate,controlSliderDelegate,modeTimeDelegate>

@property (strong, nonatomic) UILabel *titleLabel;

//选择左右床
@property (strong, nonatomic) UIImageView *sideView;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UIButton *rightBtn;

@property (strong, nonatomic) UILabel *stateLabel;


@property (strong, nonatomic) UIButton *leftUser;
@property (strong, nonatomic) UIButton *rightUser;


//调节模式
@property (strong, nonatomic) UIImageView *btnView;
@property (strong, nonatomic) UIView *midView;
@property (strong, nonatomic) UIButton *autoBtn;
@property (strong, nonatomic) UIButton *handBtn;
@property (strong, nonatomic) UIButton *seamlessBtn;

@property (strong, nonatomic) UIView *autoModeView;         //自动页面
@property (strong, nonatomic) RegulateProgress *headProgress;         //头
@property (strong, nonatomic) RegulateProgress *shoulderProgress;     //肩
@property (strong, nonatomic) RegulateProgress *backProgress;         //背
@property (strong, nonatomic) RegulateProgress *waistProgress;        //腰
@property (strong, nonatomic) RegulateProgress *hipProgress;          //臀
@property (strong, nonatomic) RegulateProgress *thighProgress;        //大腿
@property (strong, nonatomic) RegulateProgress *calfProgress;         //小腿
@property (strong, nonatomic) RegulateProgress *footProgress;         //脚

@property (strong, nonatomic) NSString *leftMode;
@property (strong, nonatomic) NSString *rightMode;



@property (strong, nonatomic) UIScrollView *handModeView;   //手动页面

@property (strong, nonatomic) UIImageView *bedImageView2;

@property (strong, nonatomic) UIView *sliderView;
@property (strong, nonatomic) UIView *alphaView;
@property (strong, nonatomic) RegulateSlider *headSlider;         //头
@property (strong, nonatomic) RegulateSlider *shoulderSlider;     //肩
@property (strong, nonatomic) RegulateSlider *backSlider;         //背
@property (strong, nonatomic) RegulateSlider *waistSlider;        //腰
@property (strong, nonatomic) RegulateSlider *hipSlider;          //臀
@property (strong, nonatomic) RegulateSlider *thighSlider;        //大腿
@property (strong, nonatomic) RegulateSlider *calfSlider;         //小腿
@property (strong, nonatomic) RegulateSlider *footSlider;         //脚

@property (strong, nonatomic) UILabel *headLabel;           //头
@property (strong, nonatomic) UILabel *shoulderLabel;       //肩
@property (strong, nonatomic) UILabel *backLabel;           //背
@property (strong, nonatomic) UILabel *waistLabel;          //腰
@property (strong, nonatomic) UILabel *hipLabel;            //臀
@property (strong, nonatomic) UILabel *thighLabel;          //大腿
@property (strong, nonatomic) UILabel *calfLabel;           //小腿
@property (strong, nonatomic) UILabel *footLabel;           //脚


//快速调节
@property (strong, nonatomic) UIView *faterView;
@property (strong, nonatomic) UIImageView *boomView;
@property (strong, nonatomic) UIView *quickView;
@property (strong, nonatomic) UIButton *softBtn;
@property (strong, nonatomic) UIButton *mediumBtn;
@property (strong, nonatomic) UIButton *hardBtn;

@property (strong, nonatomic) NSArray *labelArr;
@property (strong, nonatomic) NSArray *sliderArr;
@property (assign, nonatomic) BOOL isAuto;  //是否自动调节
@property (strong, nonatomic) BLEManager *bleManager;
@property (strong, nonatomic) ControlCenter *controlCenter;
@property (strong, nonatomic) CBPeripheral *connectPer;

//@property (assign, nonatomic) CBPeripheralState state;   //连接状态
@property (strong, nonatomic) NSString *side;
@property (assign, nonatomic) BOOL isQuick;     //是否执行了快速调节

@property (assign, nonatomic) int count;        //计次


@property (strong, nonatomic) NSArray *partArr;
@property (strong, nonatomic) NSArray *progressArr; //进度条数组


@property (assign, nonatomic) BedMode connectedMode;    //连接设备的型号


@property (strong, nonatomic) HandAnimationView *animationView;
@property (strong, nonatomic) UIView *manualCardView;
@property (strong, nonatomic) UIView *manualControlPanel;
@property (strong, nonatomic) UIView *manualAdjustingOverlay;
@property (strong, nonatomic) NSTimer *manualAdjustingTimer;

@end

@implementation MainController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;
    
    _side = @"01";
    _bleManager = [BLEManager shareInstance];
    _controlCenter = [ControlCenter shareInstance];
    _bleManager.delegate = self;
    if (_bleManager.isFirstBed) {
        NSData *data = [ControlCenter getAdjustModel];
        [_bleManager didSendMessageToDevice:data];
    }
    self.connectedMode = _bleManager.mode;
    
    UIColor *color = [UIColor colorWithValue:@"ffffff" alpha:0.1];
    UIImage *colorImage = [[ToolHexManager sharedManager] imageWithColor:color];
    

    _shoulderProgress = [[RegulateProgress alloc] init];
    NSLog(@"触发0--------%@",_shoulderProgress);
    _backProgress = [[RegulateProgress alloc] init];
    _waistProgress = [[RegulateProgress alloc] init];
    _hipProgress = [[RegulateProgress alloc] init];
    _thighProgress = [[RegulateProgress alloc] init];
    _calfProgress = [[RegulateProgress alloc] init];
    
    
    _shoulderSlider = [[RegulateSlider alloc] init];
    _backSlider = [[RegulateSlider alloc] init];
    _waistSlider = [[RegulateSlider alloc] init];
    _hipSlider = [[RegulateSlider alloc] init];
    _thighSlider = [[RegulateSlider alloc] init];
    _calfSlider = [[RegulateSlider alloc] init];

    if (self.connectedMode == BedNormal) {
        _partArr = @[@"肩部",@"腰部",@"臀部"];
        _sliderArr = @[_shoulderSlider,_waistSlider,_hipSlider];
        _progressArr = @[_shoulderProgress,_waistProgress,_hipProgress];
    }
    
    if (self.connectedMode == BedPro) {
        _partArr = @[@"肩1",@"肩2",@"腰1",@"腰2",@"臀部",@"腿部"];
        _sliderArr = @[_shoulderSlider,_backSlider,_waistSlider,_hipSlider,_thighSlider,_calfSlider];
        _progressArr = @[_shoulderProgress,_backProgress,_waistProgress,_hipProgress,_thighProgress,_calfProgress];
    }
    
    
    UILabel *brandLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCALE(20), STATUS_BAR_HEIGHT + 7, SCALE(80), 30)];
    brandLabel.text = @"BOP";
    brandLabel.textColor = [UIColor whiteColor];
    brandLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightLight];
    brandLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:brandLabel];

    UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    helpBtn.frame = CGRectMake(iPhoneWidth - SCALE(20) - 28, STATUS_BAR_HEIGHT + 8, 28, 28);
    helpBtn.layer.cornerRadius = 14.0;
    helpBtn.layer.masksToBounds = YES;
    helpBtn.layer.borderWidth = 1.0;
    helpBtn.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.1].CGColor;
    helpBtn.backgroundColor = [UIColor colorWithValue:@"#ffffff" alpha:0.05];
    [helpBtn setTitle:@"?" forState:UIControlStateNormal];
    [helpBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    helpBtn.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    [helpBtn addTarget:self action:@selector(showManualHelpSheet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:helpBtn];

    // ── 左右床切换：导航栏右侧胶囊容器 ──
    CGFloat capsuleW = SCALE(108.0);
    UIView *bedSideCapsule = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(helpBtn.frame) - SCALE(8) - capsuleW, STATUS_BAR_HEIGHT + 7, capsuleW, 30)];
    bedSideCapsule.backgroundColor = [UIColor colorWithValue:@"#161616"];
    bedSideCapsule.layer.cornerRadius = 10.0;
    bedSideCapsule.layer.masksToBounds = YES;
    [self.view addSubview:bedSideCapsule];

    UIColor *selectedBg = [UIColor colorWithValue:@"ffffff" alpha:0.15];
    UIImage *selectedImg = [[ToolHexManager sharedManager] imageWithColor:selectedBg];
    UIImage *normalImg   = [[ToolHexManager sharedManager] imageWithColor:[UIColor clearColor]];

    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(4, 3, capsuleW/2 - 6, 24);
    [_leftBtn setTitle:@"左床" forState:UIControlStateNormal];
    [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_leftBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_leftBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [_leftBtn setBackgroundImage:selectedImg forState:UIControlStateSelected];
    _leftBtn.layer.cornerRadius = 8.0;
    _leftBtn.layer.masksToBounds = YES;
    _leftBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _leftBtn.selected = YES;
    [_leftBtn addTarget:self action:@selector(changeBedSide:) forControlEvents:UIControlEventTouchUpInside];
    [bedSideCapsule addSubview:_leftBtn];

    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(capsuleW/2 + 2, 3, capsuleW/2 - 6, 24);
    [_rightBtn setTitle:@"右床" forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_rightBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_rightBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [_rightBtn setBackgroundImage:selectedImg forState:UIControlStateSelected];
    _rightBtn.layer.cornerRadius = 8.0;
    _rightBtn.layer.masksToBounds = YES;
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_rightBtn addTarget:self action:@selector(changeBedSide:) forControlEvents:UIControlEventTouchUpInside];
    [bedSideCapsule addSubview:_rightBtn];
    
    
    UIView *btnBG = [[UIView alloc] initWithFrame:CGRectMake(SCALE(20), STATUS_BAR_HEIGHT + 48, iPhoneWidth - SCALE(40), 48)];
    btnBG.backgroundColor = [UIColor colorWithValue:@"#161616"];
    btnBG.layer.cornerRadius = 14.0;
    btnBG.layer.masksToBounds = YES;
    [self.view addSubview:btnBG];
    
    
    _autoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _autoBtn.frame = CGRectMake(4, 4, btnBG.frame.size.width/2 - 8, 40);
    _autoBtn.layer.cornerRadius = 10.0;
    _autoBtn.layer.masksToBounds = YES;
    [_autoBtn setTitle:@"自动模式" forState:UIControlStateNormal];
    //[_autoBtn setTitle:@"自动模式" forState:UIControlStateNormal];
    [_autoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_autoBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_autoBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor clearColor]]  forState:UIControlStateNormal];
    [_autoBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor colorWithValue:@"#222222"]]  forState:UIControlStateSelected];
    [_autoBtn addTarget:self action:@selector(controlModeByAuto) forControlEvents:UIControlEventTouchUpInside];
    _autoBtn.selected = YES;
    [btnBG addSubview:_autoBtn];
    
    _handBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _handBtn.frame = CGRectMake(CGRectGetMaxX(_autoBtn.frame) + 8, 4, btnBG.frame.size.width/2 - 8, 40);
    _handBtn.layer.cornerRadius = 10.0;
    _handBtn.layer.masksToBounds = YES;
    [_handBtn setTitle:@"手动调节" forState:UIControlStateNormal];
    [_handBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_handBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_handBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor clearColor]]  forState:UIControlStateNormal];
    [_handBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor colorWithValue:@"#222222"]]  forState:UIControlStateSelected];
    [_handBtn addTarget:self action:@selector(controlModeByHand) forControlEvents:UIControlEventTouchUpInside];
    [btnBG addSubview:_handBtn];
    
    
    NSLog(@"看一看  安全区----%f",safeBottom);
    UIScrollView *autoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btnBG.frame) + 10, iPhoneWidth, iPhoneHeight - TAB_BAR_HEIGHT - CGRectGetMaxY(btnBG.frame) - 60)];
    autoScrollView.showsVerticalScrollIndicator = NO;
    self.autoModeView = autoScrollView;
    self.autoModeView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.autoModeView];
    
    // ── 心率卡片（渐变背景 + 红色图标）──
    CGFloat cardPad = SCALE(20);
    CGFloat cardGap = SCALE(12);
    CGFloat cardW   = (iPhoneWidth - cardPad * 2 - cardGap) / 2.0;

    UIView *heartRateView = [[UIView alloc] initWithFrame:CGRectMake(cardPad, 0, cardW, 88)];
    heartRateView.layer.cornerRadius = 16.0;
    heartRateView.layer.masksToBounds = YES;
    heartRateView.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.06].CGColor;
    heartRateView.layer.borderWidth = 1.0;
    CAGradientLayer *heartGrad = [CAGradientLayer layer];
    heartGrad.colors = @[(id)[UIColor colorWithValue:@"#ffffff" alpha:0.04].CGColor,
                         (id)[UIColor colorWithValue:@"#ffffff" alpha:0.01].CGColor];
    heartGrad.startPoint = CGPointMake(0, 0);
    heartGrad.endPoint   = CGPointMake(1, 1);
    heartGrad.frame = CGRectMake(0, 0, cardW, 88);
    [heartRateView.layer insertSublayer:heartGrad atIndex:0];
    [self.autoModeView addSubview:heartRateView];

    UIImageView *heartImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 14, 14)];
    heartImage.image = [[UIImage imageNamed:@"heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    heartImage.tintColor = [UIColor colorWithValue:@"#f87171"];
    [heartRateView addSubview:heartImage];

    UILabel *heartLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(34, 14, cardW - 40, 16)];
    heartLabel1.font = [UIFont systemFontOfSize:11.0];
    heartLabel1.textColor = [UIColor colorWithValue:@"#6b7280"];
    heartLabel1.text = @"心率";
    [heartRateView addSubview:heartLabel1];

    UILabel *heartNumberLabel = [[UILabel alloc] init];
    heartNumberLabel.text = @"68";
    heartNumberLabel.font = [UIFont systemFontOfSize:28.0 weight:UIFontWeightUltraLight];
    heartNumberLabel.textColor = [UIColor whiteColor];
    [heartNumberLabel sizeToFit];
    heartNumberLabel.frame = CGRectMake(16, 36, heartNumberLabel.bounds.size.width, heartNumberLabel.bounds.size.height);
    [heartRateView addSubview:heartNumberLabel];

    UILabel *heartLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(heartNumberLabel.frame) + 4, 50, 40, 16)];
    heartLabel2.font = [UIFont systemFontOfSize:11.0];
    heartLabel2.textColor = [UIColor colorWithValue:@"#6b7280"];
    heartLabel2.text = @"BPM";
    [heartRateView addSubview:heartLabel2];

    // ── 呼吸卡片（渐变背景 + 蓝色图标）──
    UIView *breatheView = [[UIView alloc] initWithFrame:CGRectMake(cardPad + cardW + cardGap, 0, cardW, 88)];
    breatheView.layer.cornerRadius = 16.0;
    breatheView.layer.masksToBounds = YES;
    breatheView.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.06].CGColor;
    breatheView.layer.borderWidth = 1.0;
    CAGradientLayer *breathGrad = [CAGradientLayer layer];
    breathGrad.colors = @[(id)[UIColor colorWithValue:@"#ffffff" alpha:0.04].CGColor,
                          (id)[UIColor colorWithValue:@"#ffffff" alpha:0.01].CGColor];
    breathGrad.startPoint = CGPointMake(0, 0);
    breathGrad.endPoint   = CGPointMake(1, 1);
    breathGrad.frame = CGRectMake(0, 0, cardW, 88);
    [breatheView.layer insertSublayer:breathGrad atIndex:0];
    [self.autoModeView addSubview:breatheView];

    UIImageView *breathImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 14, 14)];
    breathImage.image = [[UIImage imageNamed:@"breath"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    breathImage.tintColor = [UIColor colorWithValue:@"#60a5fa"];
    [breatheView addSubview:breathImage];

    UILabel *breathLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(34, 14, cardW - 40, 16)];
    breathLabel1.font = [UIFont systemFontOfSize:11.0];
    breathLabel1.textColor = [UIColor colorWithValue:@"#6b7280"];
    breathLabel1.text = @"呼吸频率";
    [breatheView addSubview:breathLabel1];

    UILabel *breathNumberLabel = [[UILabel alloc] init];
    breathNumberLabel.text = @"16";
    breathNumberLabel.font = [UIFont systemFontOfSize:28.0 weight:UIFontWeightUltraLight];
    breathNumberLabel.textColor = [UIColor whiteColor];
    [breathNumberLabel sizeToFit];
    breathNumberLabel.frame = CGRectMake(16, 36, breathNumberLabel.bounds.size.width, breathNumberLabel.bounds.size.height);
    [breatheView addSubview:breathNumberLabel];

    UILabel *breathLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(breathNumberLabel.frame) + 4, 50, 40, 16)];
    breathLabel2.font = [UIFont systemFontOfSize:11.0];
    breathLabel2.textColor = [UIColor colorWithValue:@"#6b7280"];
    breathLabel2.text = @"次/分";
    [breatheView addSubview:breathLabel2];
    
    UIImageView *bedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(iPhoneWidth/2 - 170, CGRectGetMaxY(heartRateView.frame) + 20, 340, 180)];
    [bedImageView playGifWithName:@"bodyAnimation"];
    [self.autoModeView addSubview:bedImageView];
    
    
    CGFloat progressBottom = CGRectGetMaxY(bedImageView.frame);
    for (int i = 0 ; i < _partArr.count; i++) {
        RegulateProgress *porssess = _progressArr[i];
        porssess.frame = CGRectMake(0, CGRectGetMaxY(bedImageView.frame) + i%_partArr.count * 40, iPhoneWidth, 40);
        porssess.title = _partArr[i];
        [self.autoModeView addSubview:porssess];
        progressBottom = CGRectGetMaxY(porssess.frame);
    }

    UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(cardPad, progressBottom + 12, iPhoneWidth - cardPad * 2, 42)];
    statusView.backgroundColor = [UIColor colorWithValue:@"#eab308" alpha:0.10];
    statusView.layer.cornerRadius = 14.0;
    statusView.layer.masksToBounds = YES;
    statusView.layer.borderWidth = 1.0;
    statusView.layer.borderColor = [UIColor colorWithValue:@"#eab308" alpha:0.22].CGColor;
    [self.autoModeView addSubview:statusView];

    UIView *adjustDot = [[UIView alloc] initWithFrame:CGRectMake(18, 17, 8, 8)];
    adjustDot.backgroundColor = [UIColor colorWithValue:@"#eab308"];
    adjustDot.layer.cornerRadius = 4.0;
    [statusView addSubview:adjustDot];

    UILabel *statusText = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, statusView.frame.size.width - 50, 42)];
    statusText.text = @"调节中";
    statusText.textColor = [UIColor colorWithValue:@"#fde68a"];
    statusText.textAlignment = NSTextAlignmentCenter;
    statusText.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
    [statusView addSubview:statusText];

    UILabel *modeTitle = [[UILabel alloc] initWithFrame:CGRectMake(cardPad, CGRectGetMaxY(statusView.frame) + 16, iPhoneWidth - cardPad * 2, 18)];
    modeTitle.text = @"自动功能";
    modeTitle.textColor = [UIColor colorWithValue:@"#6b7280"];
    modeTitle.font = [UIFont systemFontOfSize:12.0];
    [self.autoModeView addSubview:modeTitle];

    NSArray *autoModes = @[
        @{@"title":@"牵引模式", @"desc":@"分区拉伸支撑", @"icon":@"lashen", @"color":@"#00d4ff"},
        @{@"title":@"悬浮模式", @"desc":@"降低局部压迫", @"icon":@"zhumian", @"color":@"#a78bfa"},
        @{@"title":@"怀抱模式", @"desc":@"柔和包裹承托", @"icon":@"anmo", @"color":@"#f97316"},
        @{@"title":@"海浪模式", @"desc":@"循环起伏放松", @"icon":@"hailang", @"color":@"#00FF87"}
    ];

    CGFloat autoGridTop = CGRectGetMaxY(modeTitle.frame) + 10;
    CGFloat autoCardW = (iPhoneWidth - cardPad * 2 - cardGap) / 2.0;
    CGFloat autoCardH = 86.0;
    for (int i = 0; i < autoModes.count; i++) {
        NSDictionary *dict = autoModes[i];
        NSInteger col = i % 2;
        NSInteger row = i / 2;
        UIButton *modeCard = [UIButton buttonWithType:UIButtonTypeCustom];
        modeCard.frame = CGRectMake(cardPad + col * (autoCardW + cardGap), autoGridTop + row * (autoCardH + cardGap), autoCardW, autoCardH);
        modeCard.backgroundColor = [UIColor colorWithValue:@"#ffffff" alpha:0.03];
        modeCard.layer.cornerRadius = 16.0;
        modeCard.layer.masksToBounds = YES;
        modeCard.layer.borderWidth = 1.0;
        modeCard.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.06].CGColor;
        modeCard.tag = 260 + i;
        [modeCard addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self.autoModeView addSubview:modeCard];

        UIView *iconBg = [[UIView alloc] initWithFrame:CGRectMake(14, 14, 32, 32)];
        iconBg.backgroundColor = [UIColor colorWithValue:dict[@"color"] alpha:0.12];
        iconBg.layer.cornerRadius = 10.0;
        iconBg.layer.masksToBounds = YES;
        [modeCard addSubview:iconBg];

        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 16, 16)];
        icon.image = [[UIImage imageNamed:dict[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        icon.tintColor = [UIColor colorWithValue:dict[@"color"]];
        [iconBg addSubview:icon];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(56, 14, autoCardW - 68, 20)];
        title.text = dict[@"title"];
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
        [modeCard addSubview:title];

        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(56, 36, autoCardW - 68, 18)];
        desc.text = dict[@"desc"];
        desc.textColor = [UIColor colorWithValue:@"#6b7280"];
        desc.font = [UIFont systemFontOfSize:10.0];
        [modeCard addSubview:desc];

        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 58, autoCardW - 28, 18)];
        timeLabel.text = @"15 min";
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.textColor = [UIColor colorWithValue:@"#9ca3af"];
        timeLabel.font = [UIFont systemFontOfSize:11.0];
        [modeCard addSubview:timeLabel];
    }

    autoScrollView.contentSize = CGSizeMake(0, autoGridTop + autoCardH * 2 + cardGap + 24);
    self.autoModeView.hidden = YES;
    
  //**********************************手动调节******************************
    self.handModeView = [[UIScrollView alloc] initWithFrame:self.autoModeView.frame];
    self.handModeView.backgroundColor = [UIColor clearColor];
    self.handModeView.contentSize = CGSizeMake(0, 700);
    [self.view addSubview:self.handModeView];
    
    if (self.connectedMode == BedPro) {
        self.handModeView.contentSize = CGSizeMake(0, 760);
    }

    CGFloat manualPad = SCALE(20);
    CGFloat manualCardH = 252.0;
    _manualCardView = [[UIView alloc] initWithFrame:CGRectMake(manualPad, 0, iPhoneWidth - manualPad * 2, manualCardH)];
    _manualCardView.layer.cornerRadius = 18.0;
    _manualCardView.layer.masksToBounds = YES;
    _manualCardView.layer.borderWidth = 1.0;
    _manualCardView.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.04].CGColor;
    CAGradientLayer *manualCardGradient = [CAGradientLayer layer];
    manualCardGradient.colors = @[(id)[UIColor colorWithValue:@"#050814"].CGColor,
                                  (id)[UIColor colorWithValue:@"#080c18"].CGColor];
    manualCardGradient.startPoint = CGPointMake(0, 0);
    manualCardGradient.endPoint = CGPointMake(0, 1);
    manualCardGradient.frame = _manualCardView.bounds;
    [_manualCardView.layer insertSublayer:manualCardGradient atIndex:0];
    [self.handModeView addSubview:_manualCardView];

    UIView *manualStatusDot = [[UIView alloc] initWithFrame:CGRectMake(SCALE(18), 18, 8, 8)];
    manualStatusDot.backgroundColor = [UIColor colorWithValue:@"#3b82f6"];
    manualStatusDot.layer.cornerRadius = 4.0;
    manualStatusDot.layer.masksToBounds = YES;
    [_manualCardView addSubview:manualStatusDot];

    UILabel *manualTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(manualStatusDot.frame) + SCALE(8), 10, _manualCardView.frame.size.width - SCALE(155), 24)];
    manualTitle.text = @"手动气压调节";
    manualTitle.textColor = [UIColor colorWithValue:@"#9ca3af"];
    manualTitle.font = [UIFont systemFontOfSize:12.0];
    [_manualCardView addSubview:manualTitle];

    UILabel *manualHint = [[UILabel alloc] initWithFrame:CGRectMake(_manualCardView.frame.size.width - SCALE(115), 10, SCALE(95), 24)];
    manualHint.text = @"拖动滑块调整";
    manualHint.textAlignment = NSTextAlignmentRight;
    manualHint.textColor = [UIColor colorWithValue:@"#4b5563"];
    manualHint.font = [UIFont systemFontOfSize:11.0];
    [_manualCardView addSubview:manualHint];
    
    _bedImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake((_manualCardView.frame.size.width - 340) / 2.0, 44, 340, 180)];
    _bedImageView2.image = [UIImage imageNamed:@"tou"];
    [_manualCardView addSubview:_bedImageView2];

    _manualAdjustingOverlay = [[UIView alloc] initWithFrame:_manualCardView.bounds];
    _manualAdjustingOverlay.backgroundColor = [UIColor colorWithValue:@"#050814" alpha:0.72];
    _manualAdjustingOverlay.hidden = YES;
    [_manualCardView addSubview:_manualAdjustingOverlay];

    UILabel *adjustingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, manualCardH/2.0 - 16, _manualCardView.frame.size.width, 32)];
    adjustingLabel.text = @"调节中";
    adjustingLabel.textAlignment = NSTextAlignmentCenter;
    adjustingLabel.textColor = [UIColor colorWithValue:@"#00d4ff"];
    adjustingLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];
    [_manualAdjustingOverlay addSubview:adjustingLabel];
    
    // ── 快速调节按钮（Step 6：加边框，提升背景 alpha）──
    CGFloat quickPad  = SCALE(40);
    CGFloat quickGap  = SCALE(10);
    CGFloat quickBtnW = (iPhoneWidth - quickPad * 2 - quickGap * 2) / 3.0;
    CGFloat panelY = CGRectGetMaxY(_manualCardView.frame) + 4;
    CGFloat panelH = self.connectedMode == BedPro ? 815.0 : 605.0;
    _manualControlPanel = [[UIView alloc] initWithFrame:CGRectMake(manualPad, panelY, iPhoneWidth - manualPad * 2, panelH)];
    _manualControlPanel.layer.cornerRadius = 16.0;
    _manualControlPanel.layer.masksToBounds = YES;
    _manualControlPanel.layer.borderWidth = 1.0;
    _manualControlPanel.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.06].CGColor;
    CAGradientLayer *panelGradient = [CAGradientLayer layer];
    panelGradient.colors = @[(id)[UIColor colorWithValue:@"#ffffff" alpha:0.04].CGColor,
                             (id)[UIColor colorWithValue:@"#ffffff" alpha:0.01].CGColor];
    panelGradient.startPoint = CGPointMake(0, 0);
    panelGradient.endPoint = CGPointMake(1, 1);
    panelGradient.frame = _manualControlPanel.bounds;
    [_manualControlPanel.layer insertSublayer:panelGradient atIndex:0];
    [self.handModeView addSubview:_manualControlPanel];

    CGFloat panelW = _manualControlPanel.bounds.size.width;
    quickPad = SCALE(16);
    quickGap = SCALE(8);
    quickBtnW = (panelW - quickPad * 2 - quickGap * 2) / 3.0;

    _hardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _hardBtn.backgroundColor = [UIColor colorWithValue:@"#ef4444" alpha:0.08];
    _hardBtn.frame = CGRectMake(quickPad, 16, quickBtnW, 36);
    [_hardBtn setTitle:@"一键变硬" forState:UIControlStateNormal];
    _hardBtn.titleLabel.font = [UIFont systemFontOfSize:SCALE(12.0)];
    _hardBtn.layer.cornerRadius = 18.0;
    _hardBtn.layer.masksToBounds = YES;
    _hardBtn.layer.borderColor = [UIColor colorWithValue:@"#ef4444" alpha:0.25].CGColor;
    _hardBtn.layer.borderWidth = 1.0;
    [_hardBtn setTitleColor:[UIColor colorWithValue:@"#ef4444"] forState:UIControlStateNormal];
    [_hardBtn addTarget:self action:@selector(controlQuickAdjust:) forControlEvents:UIControlEventTouchUpInside];
    [_manualControlPanel addSubview:_hardBtn];

    _mediumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _mediumBtn.backgroundColor = [UIColor colorWithValue:@"#00d4ff" alpha:0.08];
    _mediumBtn.frame = CGRectMake(CGRectGetMaxX(_hardBtn.frame) + quickGap, 16, quickBtnW, 36);
    _mediumBtn.titleLabel.font = [UIFont systemFontOfSize:SCALE(12.0)];
    _mediumBtn.layer.cornerRadius = 18.0;
    _mediumBtn.layer.masksToBounds = YES;
    _mediumBtn.layer.borderColor = [UIColor colorWithValue:@"#00d4ff" alpha:0.25].CGColor;
    _mediumBtn.layer.borderWidth = 1.0;
    [_mediumBtn setTitle:@"一键适中" forState:UIControlStateNormal];
    [_mediumBtn setTitleColor:[UIColor colorWithValue:@"#00d4ff"] forState:UIControlStateNormal];
    [_mediumBtn addTarget:self action:@selector(controlQuickAdjust:) forControlEvents:UIControlEventTouchUpInside];
    [_manualControlPanel addSubview:_mediumBtn];

    _softBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _softBtn.backgroundColor = [UIColor colorWithValue:@"#00FF87" alpha:0.08];
    _softBtn.frame = CGRectMake(CGRectGetMaxX(_mediumBtn.frame) + quickGap, 16, quickBtnW, 36);
    _softBtn.titleLabel.font = [UIFont systemFontOfSize:SCALE(12.0)];
    _softBtn.layer.cornerRadius = 18.0;
    _softBtn.layer.masksToBounds = YES;
    _softBtn.layer.borderColor = [UIColor colorWithValue:@"#00FF87" alpha:0.25].CGColor;
    _softBtn.layer.borderWidth = 1.0;
    [_softBtn setTitle:@"一键变软" forState:UIControlStateNormal];
    [_softBtn setTitleColor:[UIColor colorWithValue:@"#00FF87"] forState:UIControlStateNormal];
    [_softBtn addTarget:self action:@selector(controlQuickAdjust:) forControlEvents:UIControlEventTouchUpInside];
    [_manualControlPanel addSubview:_softBtn];
    
    
    
    CGFloat modePad  = SCALE(16);
    CGFloat sliderStartY = CGRectGetMaxY(_softBtn.frame) + 22;
    for (int i= 0; i < _sliderArr.count; i++) {
        RegulateSlider *slider = _sliderArr[i];
        slider.frame = CGRectMake(0, sliderStartY + (i%_sliderArr.count)*70, panelW, 70);
        slider.delegate = self;
        slider.title = _partArr[i];
        [_manualControlPanel addSubview:slider];
    }

    CGFloat actionY = sliderStartY + _sliderArr.count * 70 + 8;
    CGFloat actionGap = SCALE(12);
    CGFloat actionW = (panelW - modePad * 2 - actionGap) / 2.0;

    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resetBtn.frame = CGRectMake(modePad, actionY, actionW, 44);
    resetBtn.backgroundColor = [UIColor colorWithValue:@"#ffffff" alpha:0.03];
    resetBtn.layer.cornerRadius = 12.0;
    resetBtn.layer.masksToBounds = YES;
    resetBtn.layer.borderWidth = 1.0;
    resetBtn.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.06].CGColor;
    resetBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [resetBtn setTitle:@"重置" forState:UIControlStateNormal];
    [resetBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetManualPressure) forControlEvents:UIControlEventTouchUpInside];
    [_manualControlPanel addSubview:resetBtn];

    UIButton *memoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    memoryBtn.frame = CGRectMake(CGRectGetMaxX(resetBtn.frame) + actionGap, actionY, actionW, 44);
    memoryBtn.backgroundColor = [UIColor whiteColor];
    memoryBtn.layer.cornerRadius = 12.0;
    memoryBtn.layer.masksToBounds = YES;
    memoryBtn.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    [memoryBtn setTitle:@"记忆" forState:UIControlStateNormal];
    [memoryBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [memoryBtn addTarget:self action:@selector(saveManualPressurePreset) forControlEvents:UIControlEventTouchUpInside];
    [_manualControlPanel addSubview:memoryBtn];

    CGFloat contentH = CGRectGetMaxY(_manualControlPanel.frame) + 28;
    self.handModeView.contentSize = CGSizeMake(0, MAX(contentH, self.handModeView.frame.size.height + 1));
    
    
    
    
    
//    
//    for (int i = 0; i < modeArr.count; i++) {
//        NSDictionary *dict = modeArr[i];
//        ModeButton *button = [[ModeButton alloc] initWithIcon:[UIImage imageNamed:dict[@"icon"]] title:dict[@"title"]];
//        button.frame = CGRectMake(i%4, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
//    }
    
    
    
    
    /*
    _count = 0;
    _isAuto = YES;
    
    _seamlessBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_seamlessBtn setBackgroundColor:[UIColor clearColor]];
    _seamlessBtn.frame = CGRectMake(CGRectGetMaxX(_handBtn.frame), _btnView.frame.origin.y, _btnView.frame.size.width/3, 36);
    [_seamlessBtn setTitle:@"无感调节" forState:UIControlStateNormal];
    [_seamlessBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_seamlessBtn addTarget:self action:@selector(controlModeSeamless) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_seamlessBtn];
    
    
    
    _sliderView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, iPhoneWidth - 30, 380)];
    _sliderView.layer.cornerRadius = 15.0;
    _sliderView.layer.masksToBounds = YES;
    //_sliderView.alpha = 0.7;
    // 1. 创建渐变图层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];

    // 2. 设置渐变的起止颜色
    gradientLayer.colors = @[
        (id)[UIColor colorWithValue:@"#1A246C"].CGColor,
        (id)[UIColor colorWithValue:@"#091242"].CGColor
    ];
    // 3. 设置渐变方向（可选）
    gradientLayer.startPoint = CGPointMake(0, 0);   // 左上角
    gradientLayer.endPoint = CGPointMake(1, 1);     // 右下角
    // 4. 设置颜色分布位置（可选，0~1之间）
    gradientLayer.locations = @[@0.2, @0.8];
    gradientLayer.opacity = 0.7;
    // 5. 设置图层大小
    gradientLayer.frame = _sliderView.bounds;
    // 6. 添加到视图
    [_sliderView.layer insertSublayer:gradientLayer atIndex:0];
    [_handModeView addSubview:_sliderView];
    
    
    
    
    _headLabel = [self levelLabel];
    _shoulderLabel = [self levelLabel];
    _backLabel = [self levelLabel];
    _waistLabel = [self levelLabel];
    _hipLabel = [self levelLabel];
    _thighLabel = [self levelLabel];
    _calfLabel = [self levelLabel];
    _footLabel = [self levelLabel];
    
    
    _labelArr = @[_headLabel,_shoulderLabel,_backLabel,_waistLabel,_hipLabel,_thighLabel,_calfLabel,_footLabel];
    
    
    
    
    
    _faterView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_sliderView.frame) + 20, iPhoneWidth - 40, 36)];
    _faterView.backgroundColor = [UIColor clearColor];
    [_handModeView addSubview:_faterView];
    
    _boomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth - 40, 36)];
    _boomView.image = [UIImage imageNamed:@"btn"];
    _boomView.layer.cornerRadius = 18.0;
    _boomView.layer.borderWidth = 1.0;
    _boomView.layer.masksToBounds = YES;
    _boomView.layer.borderColor = [UIColor colorWithValue:@"#1482ff"].CGColor;
    [_faterView addSubview:_boomView];

    
    _quickView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_faterView.frame)/3, 36)];
    _quickView.backgroundColor = [UIColor colorWithValue:@"#1482ff"];
    _quickView.layer.cornerRadius = 18.0;
    _quickView.layer.masksToBounds = YES;
    [_faterView addSubview:_quickView];
    
    _softBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_softBtn setBackgroundColor:[UIColor clearColor]];
    _softBtn.frame = CGRectMake(0, 0, _faterView.frame.size.width/3, 36);
    [_softBtn setTitle:@"软" forState:UIControlStateNormal];
    [_softBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_softBtn addTarget:self action:@selector(controlQuickAdjust:) forControlEvents:UIControlEventTouchUpInside];
    [_faterView addSubview:_softBtn];
    
    _mediumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_mediumBtn setBackgroundColor:[UIColor clearColor]];
    _mediumBtn.frame = CGRectMake(CGRectGetMaxX(_softBtn.frame), 0, _faterView.frame.size.width/3, 36);
    [_mediumBtn setTitle:@"适中" forState:UIControlStateNormal];
    [_mediumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_mediumBtn addTarget:self action:@selector(controlQuickAdjust:) forControlEvents:UIControlEventTouchUpInside];
    [_faterView addSubview:_mediumBtn];
    
    _hardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_hardBtn setBackgroundColor:[UIColor clearColor]];
    _hardBtn.frame = CGRectMake(CGRectGetMaxX(_mediumBtn.frame), 0, _faterView.frame.size.width/3, 36);
    [_hardBtn setTitle:@"硬" forState:UIControlStateNormal];
    [_hardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_hardBtn addTarget:self action:@selector(controlQuickAdjust:) forControlEvents:UIControlEventTouchUpInside];
    [_faterView addSubview:_hardBtn];
    
    [self creatNavgationBar];
    
    
    
    if (self.bed.state == 2) {
        _stateLabel.text = @"已连接";
        _stateLabel.textColor = [UIColor greenColor];
        NSData *data = [ControlCenter getAdjustModel];
        self.connectPer = self.bed.myPer;
        [_bleManager didSendMessageToDevice:data withPeripheral:self.connectPer];
    }else{
        [_bleManager didStartScanDevice:NO];
        _stateLabel.text = @"正在连接...";
        _stateLabel.textColor = [UIColor whiteColor];
    }
    
    */
    
    [_controlCenter addObserver:self forKeyPath:@"respondDict" options:NSKeyValueObservingOptionNew context:nil];
    
    [_controlCenter addObserver:self forKeyPath:@"bodyHardnessData" options:NSKeyValueObservingOptionNew context:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedBed:) name:@"connectedBed" object:nil];
    
    
}

- (void)connectedBed:(NSNotification *)notif
{
    NSLog(@"代理------%@",_bleManager.delegate);
    id object = notif.object;
    NSDictionary *dic = (NSDictionary *)object;
    CBPeripheral *per = dic[@"device"];
    [_bleManager didConnectDevice:per];
}



#pragma mark -KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([keyPath isEqualToString:@"respondDict"]) {
        NSDictionary *dict = change[@"new"];
        NSString *code = dict[@"code"];
        if ([code isEqualToString:@"e0"]) {
            self.leftMode = dict[@"letfMode"];
            self.rightMode = dict[@"rightMode"];
            if ([self.leftMode isEqualToString:@"01"]) {
                _isAuto = NO;
                NSData *data = [ControlCenter getBodyHardness:_side person:@"01"];
                [_bleManager didSendMessageToDevice:data];
                _handBtn.selected = YES;
                _autoBtn.selected = NO;
                [self switchContentToAuto:NO];
            } else if ([self.leftMode isEqualToString:@"02"] || [self.leftMode isEqualToString:@"05"]) {
                _isAuto = YES;
                _handBtn.selected = NO;
                _autoBtn.selected = YES;
                [self switchContentToAuto:YES];
            } else {
                _isAuto = YES;
                [self switchContentToAuto:YES];
            }
        } else if ([code isEqualToString:@"e1"]) {
            NSString *respond = dict[@"respond"];
            NSString *side = dict[@"side"];
            if ([side isEqualToString:@"01"]) {
                self.leftMode = respond;
            }else{
                self.rightMode = respond;
            }
            if ([respond isEqualToString:@"01"]) {//切换手动成功
                self.isAuto = NO;
                NSData *data = [ControlCenter getBodyHardness:self.side person:@"01"];
                [self.bleManager didSendMessageToDevice:data];
            }
        }else if ([code isEqualToString:@"e2"]) {
            NSString *side = dict[@"side"];
            NSString *dataStr = dict[@"dataStr"];
            for (int i = 0; i < 9; i++) {
                if (i == 8) {
                    [self showAirbagAnimation:i bedSide:side];
                }else{
                    NSString *part = [dataStr substringWithRange:NSMakeRange(i*2, 2)];
                    if ([part isEqualToString:@"01"]) {
                        [self showAirbagAnimation:i bedSide:side];
                        break;
                    }
                }
            }
        }else if ([code isEqualToString:@"f7"]){
            NSString *respond = dict[@"respond"];
            if ([respond isEqualToString:@"00"]) {
                if (_animationView) {
                    [_animationView  removeFromSuperview];
                    _animationView = nil;
                }
            }
        }
    }
    
    if ([keyPath isEqualToString:@"bodyHardnessData"]) {
        NSDictionary *dict = change[@"new"];
        [self uploadBodySlider:dict];
    }
}


- (void)creatNavgationBar
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, STATUS_BAR_HEIGHT + 14, 10, 16);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iPhoneWidth/2 - 75, STATUS_BAR_HEIGHT + 7, 150, 30)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:17.0];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = self.bed.bedName;
    [self.view addSubview:_titleLabel];
    
    UIButton *btn  = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(iPhoneWidth - 50, STATUS_BAR_HEIGHT + 7, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
    [btn setTintColor:[UIColor whiteColor]];
    [btn addTarget:self action:@selector(deviceSetPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)backToViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}


// 切换内容区域，带 0.2s fade 动画
- (void)switchContentToAuto:(BOOL)isAuto
{
    UIView *showView = isAuto ? self.autoModeView : self.handModeView;
    UIView *hideView = isAuto ? self.handModeView : self.autoModeView;
    showView.alpha = 0;
    showView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        showView.alpha = 1.0;
        hideView.alpha = 0;
    } completion:^(BOOL finished) {
        hideView.hidden = YES;
        hideView.alpha = 1.0;
    }];
}

#pragma mark -左右床切换

//切换左右床
- (void)changeBedSide:(UIButton *)btn
{
//    if (self.bed.state != 2) {
//        NSLog(@"设备未连接");
//        [MJProgressHUD onlyShowMessage:@"设备未连接" afterDelay:1.0 showAddTo:self.view];
//        return;
//    }
    
    
    
    if (btn == _leftBtn) {
        if ([_side isEqualToString:@"01"]) { return; }
        _side = @"01";
        _leftBtn.selected = YES;
        _rightBtn.selected = NO;
        if ([_leftMode isEqualToString:@"01"]) {
            _isAuto = NO;
            NSData *data = [ControlCenter getBodyHardness:@"01" person:@"01"];
            [_bleManager didSendMessageToDevice:data];
            _handBtn.selected = YES;
            _autoBtn.selected = NO;
            [self switchContentToAuto:NO];
        } else {
            _isAuto = YES;
            _handBtn.selected = NO;
            _autoBtn.selected = [_leftMode isEqualToString:@"02"];
            [self switchContentToAuto:YES];
        }
    }
    if (btn == _rightBtn) {
        if ([_side isEqualToString:@"02"]) { return; }
        _side = @"02";
        _rightBtn.selected = YES;
        _leftBtn.selected = NO;
        if ([_rightMode isEqualToString:@"01"]) {
            _isAuto = NO;
            NSData *data = [ControlCenter getBodyHardness:@"02" person:@"01"];
            [_bleManager didSendMessageToDevice:data];
            _handBtn.selected = YES;
            _autoBtn.selected = NO;
            [self switchContentToAuto:NO];
        } else {
            _isAuto = YES;
            _handBtn.selected = NO;
            _autoBtn.selected = [_rightMode isEqualToString:@"02"];
            [self switchContentToAuto:YES];
        }
    }
}


#pragma mark -调节模式切换
//自动调节
- (void)controlModeByAuto
{
    _autoBtn.selected = YES;
    _handBtn.selected = NO;
    _isAuto = YES;
    [self switchContentToAuto:YES];
    NSData *data = [ControlCenter adjustType:@"02" bedSide:_side];
    [_bleManager didSendMessageToDevice:data];
}

//手动调节
- (void)controlModeByHand
{
    _isAuto = NO;
    _autoBtn.selected = NO;
    _handBtn.selected = YES;
    [self switchContentToAuto:NO];
    NSData *data = [ControlCenter adjustType:@"01" bedSide:_side];
    [_bleManager didSendMessageToDevice:data];
}

//无感调节
- (void)controlModeSeamless
{
    if (self.bed.state != 2) {
        NSLog(@"设备未连接");
        [MJProgressHUD onlyShowMessage:@"设备未连接" afterDelay:1.0 showAddTo:self.view];
        return;
    }
    
    NSLog(@"无感调节");
    [UIView animateWithDuration:0.2 animations:^{
        //self.midView.frame = CGRectMake(20 + CGRectGetWidth(self.btnView.frame)/2, CGRectGetMinY(self.btnView.frame), CGRectGetWidth(self.btnView.frame)/2, 36);
        self.midView.frame = self.seamlessBtn.frame;
    }];
    _isAuto = YES;
    _handModeView.hidden = YES;
    
//    NSData *data = [ControlCenter adjustType:@"03"];
//    [_bleManager didSendMessageToDevice:data];
}

//助眠、拉伸、按摩、拉伸
- (void)modeChanged:(UIButton *)btn
{
    NSInteger tag = btn.tag - 260;
    ModeTimeView *modeView = [[ModeTimeView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    modeView.delegate = self;
    [modeView show:tag];
}

- (void)modeTimeView:(ModeTimeView *)view doTimeLevel:(int)level
{
    
}




- (void)uploadBodySlider:(NSDictionary *)dict
{
    int head = [dict[@"head"] intValue];
    int shoulder = [dict[@"shoulder"] intValue];
    int back = [dict[@"back"] intValue];
    int waist = [dict[@"waist"] intValue];
    int hip = [dict[@"hip"] intValue];
    int thigh = [dict[@"thigh"] intValue];
    int calf = [dict[@"calf"] intValue];
    int foot = [dict[@"foot"] intValue];
        
    if (head > 100) {
        head = 100;
    }
    if (shoulder > 100) {
        shoulder = 100;
    }
    if (back > 100) {
        back = 100;
    }
    if (waist > 100) {
        waist = 100;
    }
    if (hip > 100) {
        hip = 100;
    }
    if (thigh > 100) {
        thigh = 100;
    }
    if (calf > 100) {
        calf = 100;
    }
    if (foot > 100) {
        foot = 100;
    }
    
    _shoulderSlider.value = shoulder;
    _backSlider.value = back;
    _waistSlider.value = waist;
    _hipSlider.value = hip;
    _thighSlider.value = thigh;
    _calfSlider.value = calf;

    
}


//调节各部位软硬度
- (void)showManualAdjustingOverlay
{
    if (!self.manualAdjustingOverlay) {
        return;
    }
    [self.manualAdjustingTimer invalidate];
    self.manualAdjustingOverlay.alpha = 0;
    self.manualAdjustingOverlay.hidden = NO;
    [UIView animateWithDuration:0.15 animations:^{
        self.manualAdjustingOverlay.alpha = 1.0;
    }];
    self.manualAdjustingTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(hideManualAdjustingOverlay) userInfo:nil repeats:NO];
}

- (void)hideManualAdjustingOverlay
{
    [UIView animateWithDuration:0.18 animations:^{
        self.manualAdjustingOverlay.alpha = 0;
    } completion:^(BOOL finished) {
        self.manualAdjustingOverlay.hidden = YES;
        self.manualAdjustingOverlay.alpha = 1.0;
    }];
}

- (void)showManualHelpSheet
{
    CGFloat sheetH = 260.0;
    UIView *mask = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mask.backgroundColor = [UIColor colorWithValue:@"#000000" alpha:0.6];
    mask.tag = 9801;
    [[QuickTools mainWindow] addSubview:mask];

    UIView *sheet = [[UIView alloc] initWithFrame:CGRectMake(0, iPhoneHeight, iPhoneWidth, sheetH)];
    sheet.backgroundColor = [UIColor colorWithValue:@"#1a1a1a"];
    sheet.layer.cornerRadius = 24.0;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    sheet.layer.masksToBounds = YES;
    sheet.layer.borderWidth = 1.0;
    sheet.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.08].CGColor;
    sheet.tag = 9802;
    [[QuickTools mainWindow] addSubview:sheet];

    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake(iPhoneWidth/2 - 20, 10, 40, 4)];
    handle.backgroundColor = [UIColor colorWithValue:@"#ffffff" alpha:0.2];
    handle.layer.cornerRadius = 2.0;
    [sheet addSubview:handle];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(24, 34, iPhoneWidth - 48, 24)];
    title.text = @"手动调节说明";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium];
    [sheet addSubview:title];

    NSArray *items = @[@"拖动滑块可单独调节肩、腰、臀、腿等区域支撑。",
                       @"一键变硬、适中、变软会同步全部区域的目标压力。",
                       @"调节过程中请保持设备连接，完成后可点击记忆保存当前配置。"];
    for (int i = 0; i < items.count; i++) {
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(24, 76 + i * 42, 6, 6)];
        dot.backgroundColor = [UIColor colorWithValue:@"#00d4ff"];
        dot.layer.cornerRadius = 3.0;
        [sheet addSubview:dot];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 68 + i * 42, iPhoneWidth - 64, 28)];
        label.text = items[i];
        label.textColor = [UIColor colorWithValue:@"#9ca3af"];
        label.font = [UIFont systemFontOfSize:13.0];
        label.numberOfLines = 2;
        [sheet addSubview:label];
    }

    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(24, sheetH - 70, iPhoneWidth - 48, 48);
    okBtn.backgroundColor = [UIColor whiteColor];
    okBtn.layer.cornerRadius = 14.0;
    okBtn.layer.masksToBounds = YES;
    [okBtn setTitle:@"知道了" forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
    [okBtn addTarget:self action:@selector(dismissManualHelpSheet) forControlEvents:UIControlEventTouchUpInside];
    [sheet addSubview:okBtn];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissManualHelpSheet)];
    [mask addGestureRecognizer:tap];

    [UIView animateWithDuration:0.28 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        sheet.frame = CGRectMake(0, iPhoneHeight - sheetH, iPhoneWidth, sheetH);
    } completion:nil];
}

- (void)dismissManualHelpSheet
{
    UIView *mask = [[QuickTools mainWindow] viewWithTag:9801];
    UIView *sheet = [[QuickTools mainWindow] viewWithTag:9802];
    [UIView animateWithDuration:0.2 animations:^{
        sheet.frame = CGRectMake(0, iPhoneHeight, iPhoneWidth, sheet.bounds.size.height);
        mask.alpha = 0;
    } completion:^(BOOL finished) {
        [sheet removeFromSuperview];
        [mask removeFromSuperview];
    }];
}

- (void)resetManualPressure
{
    for (RegulateSlider *slider in _sliderArr) {
        slider.value = 50;
    }
    [self showManualAdjustingOverlay];
    NSData *data = [ControlCenter controlBedQuick:@"FF" bedSide:_side bodyPose:@"01" bedHardLevel:2];
    [self sendControlData:data];
}

- (void)saveManualPressurePreset
{
    NSMutableArray *values = [NSMutableArray array];
    for (RegulateSlider *slider in _sliderArr) {
        [values addObject:@(slider.value)];
    }
    [[NSUserDefaults standardUserDefaults] setObject:values forKey:[NSString stringWithFormat:@"manualPressurePreset_%@", _side ?: @"01"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [MJProgressHUD onlyShowMessage:@"已记忆当前配置" afterDelay:1.0 showAddTo:self.view];
}

#pragma mark- controlSliderDelegate
- (void)controlsliderValue:(RegulateSlider *)slider controlEndValue:(int)value valueIsUp:(BOOL)isUp
{
    [self showManualAdjustingOverlay];
    
    if (!_animationView) {
        _animationView = [[HandAnimationView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_bedImageView2.frame) - 70, CGRectGetWidth(_manualCardView.bounds), 24) withBedMode:self.connectedMode];
        [_manualCardView addSubview:_animationView];
    }
    
    //_level = 0;
    if (slider == _headSlider) {
        NSLog(@"头部调节------%d",value);
        NSData *data = [ControlCenter controlBodyPart:@"01" bodyPart:0 bedSide:_side bodyPose:@"FF" hardLevel:value];
        [self sendControlData:data];
        [_animationView didAnimationUp:isUp bodyPart:0];
    }
    
    if (slider == _shoulderSlider) {
        NSLog(@"肩部调节------%d",value);
        NSData *data = [ControlCenter controlBodyPart:@"01" bodyPart:1 bedSide:_side bodyPose:@"FF" hardLevel:value];
        [self sendControlData:data];
        [_animationView didAnimationUp:isUp bodyPart:0];
    }
    
    if (slider == _backSlider) {
        NSLog(@"背部调节------%d",value);
        NSData *data = [ControlCenter controlBodyPart:@"01" bodyPart:2 bedSide:_side bodyPose:@"FF" hardLevel:value];
        [self sendControlData:data];
        [_animationView didAnimationUp:isUp bodyPart:1];
    }
    
    if (slider == _waistSlider) {
        NSLog(@"腰部调节------%d",value);
        NSData *data = [ControlCenter controlBodyPart:@"01" bodyPart:3 bedSide:_side bodyPose:@"FF" hardLevel:value];
        [self sendControlData:data];
        [_animationView didAnimationUp:isUp bodyPart:2];
    }
    if (slider == _hipSlider) {
        NSLog(@"臀部调节------%d",value);
        NSData *data = [ControlCenter controlBodyPart:@"01" bodyPart:4 bedSide:_side bodyPose:@"FF" hardLevel:value];
        [self sendControlData:data];
        [_animationView didAnimationUp:isUp bodyPart:3];
    }
    if (slider == _thighSlider) {
        NSLog(@"腿部调节------%d",value);
        NSData *data = [ControlCenter controlBodyPart:@"01" bodyPart:5 bedSide:_side bodyPose:@"FF" hardLevel:value];
        [self sendControlData:data];
        [_animationView didAnimationUp:isUp bodyPart:4];
    }
    if (slider == _calfSlider) {
        NSLog(@"小腿部调节------%d",value);
        NSData *data = [ControlCenter controlBodyPart:@"01" bodyPart:6 bedSide:_side bodyPose:@"FF" hardLevel:value];
        [self sendControlData:data];
        //[_animationView didAnimationUp:isUp bodyPart:5];
    }
    
    if (slider == _footSlider) {
        NSLog(@"脚部调节------%d",value);
        NSData *data = [ControlCenter controlBodyPart:@"01" bodyPart:7 bedSide:_side bodyPose:@"FF" hardLevel:value];
        [self sendControlData:data];
    }
}



//快速调节
- (void)controlQuickAdjust:(UIButton *)btn
{
 
//    if (self.bed.state != 2) {
//        NSLog(@"设备未连接");
//        [MJProgressHUD onlyShowMessage:@"设备未连接" afterDelay:1.0 showAddTo:self.view];
//        return;
//    }
    
    _isQuick = YES;
    [self showManualAdjustingOverlay];
    int level = 0;
    
    if (btn == _softBtn) {
//        [UIView animateWithDuration:0.2 animations:^{
//            self.quickView.frame = CGRectMake(0, 0, CGRectGetWidth(self.faterView.frame)/3, 36);
//        }];
        
        level = 1;
        for (RegulateSlider *slider in _sliderArr) {
            slider.value = 85;
        }
    }
    
    if (btn == _mediumBtn) {
//        [UIView animateWithDuration:0.2 animations:^{
//            self.quickView.frame = CGRectMake(CGRectGetMaxX(self.softBtn.frame), 0, CGRectGetWidth(self.faterView.frame)/3, 36);
//        }];
        level = 2;
        for (RegulateSlider *slider in _sliderArr) {
            slider.value = 50;
        }
    }
    
    if (btn == _hardBtn) {
//        [UIView animateWithDuration:0.2 animations:^{
//            self.quickView.frame = CGRectMake(CGRectGetMaxX(self.mediumBtn.frame), 0, CGRectGetWidth(self.faterView.frame)/3, 36);
//        }];
        level = 3;
        for (RegulateSlider *slider in _sliderArr) {
            slider.value = 0;
        }
    }
    
    NSData *data = [ControlCenter controlBedQuick:@"FF" bedSide:_side bodyPose:@"01" bedHardLevel:level];
    //[_bleManager didSendMessageToDevice:data];
    
    [self sendControlData:data];
}



- (void)deviceSetPage
{
    SetViewController *setVC = [[SetViewController alloc] init];
    setVC.bed = self.bed;
    [self.navigationController pushViewController:setVC animated:YES];
}



//共用label模版
- (UILabel *)levelLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}


#pragma mark - BLEManagerDelegate
//搜索到到的设备
- (void)didScanResultDevices:(NSArray *)deviceArr
{
    if (deviceArr.count > 0) {
        for (NSDictionary *dic in deviceArr) {
            NSString *mac = dic[@"mac"];
            if ([mac isEqualToString:self.bed.mac]) {
                CBPeripheral *per = dic[@"device"];
                [_bleManager didConnectDevice:per];
                [_bleManager didStopScanDevice];
                NSLog(@"开始连接--------------------------");
                break;
            }
        }
    }
    
    
}

- (void)didConnectedSuccessful:(CBPeripheral *)peripheral
{
    NSLog(@"连接成功");
    
}

- (void)writeCharacteristicDiscoverdSuccess:(CBPeripheral *)peripheral
{
    NSLog(@"可以通讯了");
    self.connectPer = peripheral;
    _stateLabel.text = @"已连接";
    _stateLabel.textColor = [UIColor colorWithValue:@"#26D08C"];
    
    //[DataCenter shareInstance].state = CBPeripheralStateConnected;
    self.bed.state = CBPeripheralStateConnected;
    self.bed.myPer = peripheral;
    NSMutableArray *array = [DataCenter shareInstance].deviceArr.mutableCopy;
    for (BedModel *bed in array) {
        if ([bed.mac isEqualToString:self.bed.mac]) {
            NSInteger index = [array indexOfObject:bed];
            [array replaceObjectAtIndex:index withObject:self.bed];
            break;
        }
    }
    [DataCenter shareInstance].deviceArr = array.copy;
    
    //先获取工作模式
    NSData *data = [ControlCenter getAdjustModel];
    [_bleManager didSendMessageToDevice:data];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadBedList" object:nil];
    
}


- (void)didDisconnected:(CBPeripheral *)peripheral
{
    NSLog(@"主界面断开连接");
    self.bed.state = CBPeripheralStateDisconnected;
    self.bed.myPer = peripheral;
    NSMutableArray *array = [DataCenter shareInstance].deviceArr.mutableCopy;
    for (BedModel *bed in array) {
        if ([bed.mac isEqualToString:self.bed.mac]) {
            NSInteger index = [array indexOfObject:bed];
            [array replaceObjectAtIndex:index withObject:self.bed];
            break;
        }
    }
    [DataCenter shareInstance].deviceArr = array.copy;

    _stateLabel.text = @"连接断开";
    _stateLabel.textColor = [UIColor redColor];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadBedList" object:nil];

    // 自定义底部 Sheet，替换系统 UIAlertController (2026-05-26)
    [self showDisconnectSheet];
}

// 自定义断线重连底部弹窗，与 ModeTimeView 风格一致
- (void)showDisconnectSheet
{
    CGFloat sheetH = 200.0;

    // 半透明遮罩
    UIView *mask = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mask.backgroundColor = [UIColor colorWithValue:@"#000000" alpha:0.6];
    mask.tag = 9901;
    [[QuickTools mainWindow] addSubview:mask];

    // 底部卡片
    UIView *sheet = [[UIView alloc] initWithFrame:CGRectMake(0, iPhoneHeight, iPhoneWidth, sheetH)];
    sheet.backgroundColor = [UIColor colorWithValue:@"#1a1a1a"];
    sheet.layer.cornerRadius = 24.0;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    sheet.layer.masksToBounds = YES;
    sheet.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.08].CGColor;
    sheet.layer.borderWidth = 1.0;
    sheet.tag = 9902;
    [[QuickTools mainWindow] addSubview:sheet];

    // 顶部拖拽指示条
    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake(iPhoneWidth/2 - 20, 10, 40, 4)];
    handle.backgroundColor = [UIColor colorWithValue:@"#ffffff" alpha:0.2];
    handle.layer.cornerRadius = 2.0;
    [sheet addSubview:handle];

    // 标题
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(24, 28, iPhoneWidth - 48, 22)];
    titleLbl.text = @"连接已断开";
    titleLbl.textColor = [UIColor whiteColor];
    titleLbl.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium];
    [sheet addSubview:titleLbl];

    // 副标题
    UILabel *subLbl = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(titleLbl.frame) + 4, iPhoneWidth - 48, 18)];
    subLbl.text = [NSString stringWithFormat:@"与 %@ 的连接已中断", self.bed.bedName ?: @"设备"];
    subLbl.textColor = [UIColor colorWithValue:@"#6b7280"];
    subLbl.font = [UIFont systemFontOfSize:13.0];
    [sheet addSubview:subLbl];

    // 按钮行
    CGFloat btnY = CGRectGetMaxY(subLbl.frame) + 24;
    CGFloat btnW = (iPhoneWidth - 56) / 2.0;

    // 取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(20, btnY, btnW, 50);
    cancelBtn.backgroundColor = [UIColor colorWithValue:@"#ffffff" alpha:0.04];
    cancelBtn.layer.cornerRadius = 14.0;
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.08].CGColor;
    cancelBtn.layer.borderWidth = 1.0;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [cancelBtn addTarget:self action:@selector(dismissDisconnectSheet) forControlEvents:UIControlEventTouchUpInside];
    [sheet addSubview:cancelBtn];

    // 重新连接按钮（白底黑字）
    UIButton *reconnectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reconnectBtn.frame = CGRectMake(CGRectGetMaxX(cancelBtn.frame) + 16, btnY, btnW, 50);
    reconnectBtn.backgroundColor = [UIColor whiteColor];
    reconnectBtn.layer.cornerRadius = 14.0;
    reconnectBtn.layer.masksToBounds = YES;
    [reconnectBtn setTitle:@"重新连接" forState:UIControlStateNormal];
    [reconnectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    reconnectBtn.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
    [reconnectBtn addTarget:self action:@selector(reconnectFromSheet) forControlEvents:UIControlEventTouchUpInside];
    [sheet addSubview:reconnectBtn];

    // 点击遮罩关闭
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDisconnectSheet)];
    [mask addGestureRecognizer:tap];

    // 弹出动画
    CGRect endFrame = CGRectMake(0, iPhoneHeight - sheetH, iPhoneWidth, sheetH);
    [UIView animateWithDuration:0.28 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        sheet.frame = endFrame;
    } completion:nil];
}

- (void)dismissDisconnectSheet
{
    UIView *mask  = [[QuickTools mainWindow] viewWithTag:9901];
    UIView *sheet = [[QuickTools mainWindow] viewWithTag:9902];
    CGRect hideFrame = CGRectMake(0, iPhoneHeight, iPhoneWidth, sheet.bounds.size.height);
    [UIView animateWithDuration:0.22 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        sheet.frame = hideFrame;
        mask.alpha  = 0;
    } completion:^(BOOL finished) {
        [sheet removeFromSuperview];
        [mask removeFromSuperview];
    }];
}

- (void)reconnectFromSheet
{
    [self dismissDisconnectSheet];
    [self reConnected];
}


//数据发送中心，带进度
- (void)sendControlData:(NSData *)data
{
    [_bleManager didSendMessageToDevice:data];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.contentColor = [UIColor whiteColor];
    // 设置主要文字（显示在转轮下方）
    hud.label.text = @"设置中...";
    // 可选：设置文字颜色
    hud.label.textColor = [UIColor whiteColor];

    // 可选：设置背景样式
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [hud hideAnimated:YES afterDelay:3.0];
}


//气囊动画  0头 1肩 2背 3腰 4臀 5大腿 6小腿 7脚
- (void)showAirbagAnimation:(int)part bedSide:(NSString *)side
{
    
    NSLog(@"调整的位置是--------%d",part);
    for (int i = 0; i < _progressArr.count; i++) {
        RegulateProgress *prossess = _progressArr[i];
        [prossess stop];
    }
    
    
    if (self.connectedMode == BedNormal) {
        if (part == 1) {
            [_shoulderProgress start];
        }
        if (part == 3) {
            [_waistProgress start];
        }
        if (part == 4) {
            [_hipProgress start];
        }
    }else{
        
        
        if (part == 1) {
            [_shoulderProgress start];
        }
        if (part == 2) {
            [_backProgress start];
        }
        if (part == 3) {
            [_waistProgress start];
        }
        if (part == 4) {
            [_hipProgress start];
        }
        if (part == 5) {
            [_thighProgress start];
        }
        if (part == 6) {
            [_calfProgress start];
        }
    }
    
}


#pragma mark- 重连
- (void)reConnected
{
    _stateLabel.text = @"正在连接...";
    _stateLabel.textColor = [UIColor whiteColor];
    [_bleManager didStartScanDevice:NO];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.manualAdjustingTimer invalidate];
    self.manualAdjustingTimer = nil;
    _bleManager.delegate = nil;
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
