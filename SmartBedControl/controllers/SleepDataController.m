//
//  SleepDataController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/22.
//  UI改造：修复布局错位、周选择器间距；抽出 loadSleepData 接口预留云端对接 (2026-05-26)
//  TODO: 后台部署完成后，将 loadDayData/loadWeekData 中的 mock 数据替换为 HttpClient 请求

#import "SleepDataController.h"
#import "../Views/CYCircularSlider.h"
#import "../Views/SleepScoreProgressView.h"
#import "../Views/SleepView.h"
#import "../Views/SleepChartView.h"
#import "../data/SleepDataModel.h"
#import "../Tools/BLEManager.h"
#import "../Tools/DataCenter.h"


@interface SleepDataController ()

@property (strong, nonatomic) UIView *btnBG;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *dayBtn;
@property (strong, nonatomic) UIButton *weekBtn;
@property (strong, nonatomic) UIView *weekView;
@property (strong, nonatomic) SleepScoreProgressView *progressView;
@property (strong, nonatomic) UIScrollView *weekDataView;
@property (strong, nonatomic) SleepChartView *chartOne;
@property (strong, nonatomic) SleepChartView *charTwo;
@property (strong, nonatomic) SleepChartView *chartThree;
@property (strong, nonatomic) UIView *sleepPoseView;
@property (strong, nonatomic) PieChartView *sleepChart;

// 数据模型
@property (strong, nonatomic) SleepDayData  *currentDayData;
@property (strong, nonatomic) SleepWeekData *currentWeekData;

// 生理指标 labels（供数据刷新时更新）
@property (strong, nonatomic) UILabel *heartRateValueLabel;
@property (strong, nonatomic) UILabel *turnOverValueLabel;
@property (strong, nonatomic) UILabel *sitUpValueLabel;
@property (assign, nonatomic) BedMode currentMode;

@end


#define leftLyColor [UIColor colorWithValue:@"#8b5cf6"]
#define lyColor     [UIColor colorWithValue:@"#06b6d4"]
#define rightLyColor [UIColor colorWithValue:@"#f59e0b"]

@implementation SleepDataController

#pragma mark - 数据层（后台部署完成后只改这两个方法）

/// 加载单日数据。当前使用 mock，TODO: 替换为 HttpClient GET 请求
- (void)loadDayData:(void(^)(SleepDayData *data))completion {
    // ── MOCK DATA ──────────────────────────────────────────────
    SleepDayData *mock = [[SleepDayData alloc] init];
    mock.score            = 77;
    mock.qualityPercent   = 56;
    mock.comparePercent   = 86;
    mock.durationText     = @"8h 34m";
    mock.restingHeartRate = 61;
    mock.turnOverCount    = 16;
    mock.sitUpCount       = 3;
    mock.autoAdjustCount  = 22;
    mock.sleepStages      = @[@3,@3,@2,@2,@4,@3,@2,@2,@3,@3,@2,@1,@2,@2,@3,@2,@4,@2,@3,@2];
    // ── END MOCK ───────────────────────────────────────────────
    if (completion) completion(mock);
}

/// 加载周报数据。当前使用 mock，TODO: 替换为 HttpClient GET 请求
- (void)loadWeekData:(void(^)(SleepWeekData *data))completion {
    // ── MOCK DATA ──────────────────────────────────────────────
    SleepWeekData *mock = [[SleepWeekData alloc] init];
    mock.dailyScores        = @[@86,@76,@98,@88,@84,@66,@90];
    mock.qualityTrend       = @[@160,@180,@124,@221,@167,@188,@166];
    mock.snoreTrend         = @[@16,@9,@0,@6,@22,@33,@15];
    mock.interventionTrend  = @[@10,@7,@0,@6,@20,@29,@12];
    // ── END MOCK ───────────────────────────────────────────────
    if (completion) completion(mock);
}

#pragma mark - 视图

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;
    self.currentMode = [DataCenter shareInstance].connectedBed ? [DataCenter shareInstance].connectedBed.mode : [BLEManager shareInstance].mode;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCurrentDeviceDidChange) name:@"CurrentDeviceDidChangeNotification" object:nil];

    // 先加载数据，再构建 UI
    [self loadDayData:^(SleepDayData *data) {
        self.currentDayData = data;
        [self loadWeekData:^(SleepWeekData *wData) {
            self.currentWeekData = wData;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self buildUI];
            });
        }];
    }];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleCurrentDeviceDidChange
{
    BedMode mode = [DataCenter shareInstance].connectedBed ? [DataCenter shareInstance].connectedBed.mode : [BLEManager shareInstance].mode;
    if (mode == self.currentMode) {
        return;
    }
    self.currentMode = mode;
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self buildUI];
}

#pragma mark - UI 构建（只读 self.currentDayData / self.currentWeekData）

- (void)buildUI {
    SleepDayData *day = self.currentDayData;

    // ── 标题栏 ──
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, STATUS_BAR_HEIGHT, 150, 30)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightLight];
    titleLabel.text = self.currentMode == PillowNormal ? @"枕头报告" : @"睡眠报告";
    [self.view addSubview:titleLabel];

    UIButton *bedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bedBtn.frame = CGRectMake(iPhoneWidth - 82, STATUS_BAR_HEIGHT, 62, 28);
    bedBtn.backgroundColor = [UIColor colorWithValue:@"#ffffff" alpha:0.08];
    bedBtn.layer.cornerRadius = 14.0;
    bedBtn.layer.masksToBounds = YES;
    bedBtn.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.1].CGColor;
    bedBtn.layer.borderWidth = 1.0;
    bedBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [bedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bedBtn setTitle:(self.currentMode == PillowNormal ? @"智能枕" : @"左床") forState:UIControlStateNormal];
    [self.view addSubview:bedBtn];

    // ── 日报/周报切换 ──
    _btnBG = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLabel.frame) + 16, iPhoneWidth - 40, 48)];
    _btnBG.backgroundColor = [UIColor colorWithValue:@"#161616"];
    _btnBG.layer.cornerRadius = 14.0;
    _btnBG.layer.masksToBounds = YES;
    [self.view addSubview:_btnBG];

    _dayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _dayBtn.frame = CGRectMake(4, 4, _btnBG.frame.size.width/2 - 8, 40);
    _dayBtn.layer.cornerRadius = 10.0;
    _dayBtn.layer.masksToBounds = YES;
    [_dayBtn setTitle:@"日报" forState:UIControlStateNormal];
    [_dayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_dayBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_dayBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [_dayBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor colorWithValue:@"#222222"]] forState:UIControlStateSelected];
    [_dayBtn addTarget:self action:@selector(dayData) forControlEvents:UIControlEventTouchUpInside];
    _dayBtn.selected = YES;
    [_btnBG addSubview:_dayBtn];

    _weekBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _weekBtn.frame = CGRectMake(CGRectGetMaxX(_dayBtn.frame) + 8, 4, _btnBG.frame.size.width/2 - 8, 40);
    _weekBtn.layer.cornerRadius = 10.0;
    _weekBtn.layer.masksToBounds = YES;
    [_weekBtn setTitle:@"周报" forState:UIControlStateNormal];
    [_weekBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_weekBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_weekBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [_weekBtn setBackgroundImage:[[ToolHexManager sharedManager] imageWithColor:[UIColor colorWithValue:@"#222222"]] forState:UIControlStateSelected];
    [_weekBtn addTarget:self action:@selector(weekData) forControlEvents:UIControlEventTouchUpInside];
    [_btnBG addSubview:_weekBtn];
    
    
    
    
    
    // ── 日报 ScrollView ──
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btnBG.frame) + 10, iPhoneWidth, iPhoneHeight - TAB_BAR_HEIGHT - CGRectGetMaxY(_btnBG.frame) - 10)];
    _scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollView];

    // ── 周选择器（修复：等分布局，小屏不崩溃）──
    _weekView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 32)];
    _weekView.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:_weekView];

    NSArray *weekArr = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    CGFloat weekBtnW = 40.0;
    CGFloat weekTotalW = weekBtnW * 7;
    CGFloat weekSpacing = (iPhoneWidth - weekTotalW) / 8.0;

    UIImage *normalImage = [[ToolHexManager sharedManager] imageWithColor:[UIColor clearColor]];
    UIImage *highImage   = [[ToolHexManager sharedManager] imageWithColor:[UIColor whiteColor]];

    for (int i = 0; i < 7; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(weekSpacing + i * (weekBtnW + weekSpacing), 2, weekBtnW, 28);
        btn.layer.cornerRadius = 14.0;
        btn.layer.masksToBounds = YES;
        btn.titleLabel.font = [UIFont systemFontOfSize:11];
        [btn setTitle:weekArr[i] forState:UIControlStateNormal];
        [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
        [btn setBackgroundImage:highImage forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(daySleepScore:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 100 + i;
        if (i == 3) { btn.selected = YES; }
        [_weekView addSubview:btn];
    }

    // ── 睡眠评分圆环 ──
    _progressView = [[SleepScoreProgressView alloc] initWithFrame:CGRectMake(iPhoneWidth/2 - 125, CGRectGetMaxY(_weekView.frame) + 30, 250, 250)];
    _progressView.lineWidth = 14;
    _progressView.progressColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _progressView.trackColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    [_scrollView addSubview:_progressView];
    [_progressView setProgress:day.score animated:YES];

    // ── 三项统计（质量/环比/时长）──
    CGFloat statY = CGRectGetMaxY(_progressView.frame) + 10;
    NSArray *statTitles  = @[@"睡眠质量", @"睡眠环比", @"睡眠时长"];
    NSArray *statValues  = @[
        [NSString stringWithFormat:@"%.0f%%", day.qualityPercent],
        [NSString stringWithFormat:@"%.0f%%", day.comparePercent],
        day.durationText
    ];
    for (int i = 0; i < 3; i++) {
        CGFloat x = i * (iPhoneWidth / 3.0);
        UILabel *tl = [[UILabel alloc] initWithFrame:CGRectMake(x, statY, iPhoneWidth/3, 15)];
        tl.textColor = [UIColor colorWithValue:@"#6b7280"];
        tl.textAlignment = NSTextAlignmentCenter;
        tl.font = [UIFont systemFontOfSize:10.0];
        tl.text = statTitles[i];
        [_scrollView addSubview:tl];

        UILabel *vl = [[UILabel alloc] initWithFrame:CGRectMake(x, statY + 17, iPhoneWidth/3, 16)];
        vl.textColor = [UIColor whiteColor];
        vl.textAlignment = NSTextAlignmentCenter;
        vl.font = [UIFont systemFontOfSize:13.0];
        vl.text = statValues[i];
        [_scrollView addSubview:vl];
    }

    // ── AI 自动调节回顾卡片 ──
    CGFloat adjustCardY = statY + 50;
    UIView *adjustCard = [[UIView alloc] initWithFrame:CGRectMake(20, adjustCardY, iPhoneWidth - 40, 90)];
    adjustCard.backgroundColor = [UIColor colorWithValue:@"#111111"];
    adjustCard.layer.cornerRadius = 14.0;
    adjustCard.layer.masksToBounds = YES;
    adjustCard.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    adjustCard.layer.borderWidth = 1.0;
    [_scrollView addSubview:adjustCard];

    UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(14, 14, 8, 8)];
    dot.layer.cornerRadius = 4;
    dot.backgroundColor = [UIColor colorWithValue:@"#22c55e"];
    [adjustCard addSubview:dot];

    UILabel *adjustTitle = [[UILabel alloc] initWithFrame:CGRectMake(28, 10, 200, 16)];
    adjustTitle.font = [UIFont systemFontOfSize:11.0];
    adjustTitle.textColor = [UIColor colorWithValue:@"#9ca3af"];
    adjustTitle.text = self.currentMode == PillowNormal ? @"干预回顾" : @"自动调节回顾";
    [adjustCard addSubview:adjustTitle];

    UILabel *adjustContent = [[UILabel alloc] initWithFrame:CGRectMake(14, 32, iPhoneWidth - 68, 50)];
    adjustContent.textColor = [UIColor colorWithValue:@"#9ca3af"];
    adjustContent.numberOfLines = 0;
    adjustContent.font = [UIFont systemFontOfSize:12.0];
    adjustContent.text = self.currentMode == PillowNormal ? [NSString stringWithFormat:@"在您入睡期间，智能枕完成了 %ld 次鼾声与姿态干预，帮助维持更稳定的颈部支撑。", (long)day.autoAdjustCount] : [NSString stringWithFormat:@"在您入睡期间，BOP 悄悄为您进行了 %ld 次自动调节，重点优化了肩背与腰臀支撑。", (long)day.autoAdjustCount];
    [adjustCard addSubview:adjustContent];

    // ── 健康检查（修复：统一用 iPhoneWidth/5 基准，图标与文字对齐）──
    CGFloat healthY = CGRectGetMaxY(adjustCard.frame) + 20;
    UILabel *healthTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, healthY, 100, 16)];
    healthTitle.textColor = [UIColor colorWithValue:@"#6b7280"];
    healthTitle.font = [UIFont systemFontOfSize:10.0];
    healthTitle.text = @"健康检查";
    [_scrollView addSubview:healthTitle];

    NSArray *healthArr = @[@"心率", @"坐起次数", @"翻身次数", @"睡眠阶段", @"呼吸"];
    CGFloat cellW = iPhoneWidth / 5.0;
    for (int i = 0; i < 5; i++) {
        CGFloat cx = i * cellW;
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(cx + (cellW - 32)/2, healthY + 22, 32, 32)];
        icon.image = [UIImage imageNamed:@"right"];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:icon];

        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(cx, healthY + 58, cellW, 16)];
        lbl.textColor = [UIColor colorWithValue:@"#6b7280"];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:10.0];
        lbl.text = healthArr[i];
        [_scrollView addSubview:lbl];
    }

    // ── 生理指标（卡片式，修复：原来用分隔线，改为卡片）──
    CGFloat lifeY = healthY + 82;
    UILabel *lifeTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, lifeY, 100, 16)];
    lifeTitle.textColor = [UIColor colorWithValue:@"#6b7280"];
    lifeTitle.font = [UIFont systemFontOfSize:10.0];
    lifeTitle.text = @"生理指标";
    [_scrollView addSubview:lifeTitle];

    UIView *lifeCard = [[UIView alloc] initWithFrame:CGRectMake(20, lifeY + 22, iPhoneWidth - 40, 110)];
    lifeCard.backgroundColor = [UIColor colorWithValue:@"#111111"];
    lifeCard.layer.cornerRadius = 14.0;
    lifeCard.layer.masksToBounds = YES;
    lifeCard.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    lifeCard.layer.borderWidth = 1.0;
    [_scrollView addSubview:lifeCard];

    NSArray *lifeTitles = @[@"静息心率", @"翻身次数", @"坐起次数"];
    NSArray *lifeVals   = @[
        [NSString stringWithFormat:@"%ld bpm", (long)day.restingHeartRate],
        [NSString stringWithFormat:@"%ld次",   (long)day.turnOverCount],
        [NSString stringWithFormat:@"%ld次",   (long)day.sitUpCount],
    ];
    // 保存 value labels 供后续刷新
    NSMutableArray *lifeValueLabels = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        CGFloat rowY = 10 + i * 32;
        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(16, rowY + 28, lifeCard.bounds.size.width - 32, 0.5)];
        sep.backgroundColor = [UIColor colorWithValue:@"#27272a"];
        if (i < 2) [lifeCard addSubview:sep];

        UILabel *tl = [[UILabel alloc] initWithFrame:CGRectMake(16, rowY + 6, 120, 18)];
        tl.textColor = [UIColor colorWithValue:@"#9ca3af"];
        tl.font = [UIFont systemFontOfSize:12.0];
        tl.text = lifeTitles[i];
        [lifeCard addSubview:tl];

        UILabel *vl = [[UILabel alloc] initWithFrame:CGRectMake(0, rowY + 6, lifeCard.bounds.size.width - 16, 18)];
        vl.textColor = [UIColor whiteColor];
        vl.textAlignment = NSTextAlignmentRight;
        vl.font = [UIFont systemFontOfSize:12.0];
        vl.text = lifeVals[i];
        [lifeCard addSubview:vl];
        [lifeValueLabels addObject:vl];
    }
    self.heartRateValueLabel = lifeValueLabels[0];
    self.turnOverValueLabel  = lifeValueLabels[1];
    self.sitUpValueLabel     = lifeValueLabels[2];

    // ── 睡眠阶段 ──
    CGFloat stageY = CGRectGetMaxY(lifeCard.frame) + 20;
    UILabel *stageTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, stageY, 100, 16)];
    stageTitle.textColor = [UIColor colorWithValue:@"#6b7280"];
    stageTitle.font = [UIFont systemFontOfSize:10.0];
    stageTitle.text = @"睡眠阶段";
    [_scrollView addSubview:stageTitle];

    CGFloat stageBarW = 12.0;
    CGFloat stageTotalW = stageBarW * 24;
    CGFloat stageStartX = (iPhoneWidth - stageTotalW) / 2.0;
    for (int i = 0; i < day.sleepStages.count; i++) {
        SleepView *sleep = [[SleepView alloc] init];
        sleep.frame = CGRectMake(stageStartX + i * stageBarW, stageY + 22, stageBarW - 1, 80);
        sleep.level = [day.sleepStages[i] intValue];
        [_scrollView addSubview:sleep];
    }

    // ── 睡姿时间轴（饼图）──
    CGFloat poseY = stageY + 120;
    _sleepPoseView = [self sleepChartView:CGRectMake(0, poseY, iPhoneWidth, iPhoneWidth)];
    [_scrollView addSubview:_sleepPoseView];

    // ── AI 分析卡片 ──
    UIView *aiCard = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_sleepPoseView.frame) + 10, iPhoneWidth - 40, 130)];
    aiCard.layer.cornerRadius = 16.0;
    aiCard.layer.masksToBounds = YES;
    aiCard.backgroundColor = [UIColor colorWithValue:@"#111111"];
    aiCard.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    aiCard.layer.borderWidth = 1.0;
    [_scrollView addSubview:aiCard];

    UIImageView *aiIcon = [[UIImageView alloc] initWithFrame:CGRectMake(18, 18, 36, 36)];
    aiIcon.image = [UIImage imageNamed:@"boomImage"];
    [aiCard addSubview:aiIcon];

    UILabel *aiLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(62, 16, 100, 18)];
    aiLabel1.textColor = [UIColor colorWithValue:@"#6b7280"];
    aiLabel1.font = [UIFont systemFontOfSize:10.0];
    aiLabel1.text = self.currentMode == PillowNormal ? @"AI干预分析" : @"AI分析";
    [aiCard addSubview:aiLabel1];

    UILabel *aiLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(62, CGRectGetMaxY(aiLabel1.frame), iPhoneWidth - 100, 44)];
    aiLabel2.textColor = [UIColor colorWithValue:@"#9ca3af"];
    aiLabel2.numberOfLines = 0;
    aiLabel2.font = [UIFont systemFontOfSize:12.0];
    aiLabel2.text = self.currentMode == PillowNormal ? @"昨夜鼾声波动较少，侧睡与仰睡切换稳定。智能枕在整夜执行了多次柔性干预，帮助维持呼吸顺畅与颈部支撑。" : @"昨夜翻身次数较少，睡姿整体稳定，深度睡眠提升了 15%。自动调节系统在整夜进行了 20 次睡姿优化。";
    [aiCard addSubview:aiLabel2];

    UILabel *aiLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(62, CGRectGetMaxY(aiLabel2.frame), iPhoneWidth - 100, 18)];
    aiLabel3.textColor = [UIColor colorWithValue:@"#4b5563"];
    aiLabel3.font = [UIFont systemFontOfSize:10.0];
    aiLabel3.text = self.currentMode == PillowNormal ? @"基于枕头压力分布、鼾声干预节奏与姿态切换建立的个性化分析引擎。" : @"基于睡眠健康模型与大规模睡眠数据建立的个性化分析引擎。";
    [aiCard addSubview:aiLabel3];

    _scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(aiCard.frame) + 30);

    [self buildWeekDataView];
}


- (void)daySleepScore:(UIButton *)btn
{
    if (btn.selected) { return; }
    btn.selected = YES;
    for (int i = 0; i < 7; i++) {
        UIButton *button = (UIButton *)[_weekView viewWithTag:100 + i];
        if (button.tag != btn.tag) { button.selected = NO; }
    }
    // 使用 currentWeekData 中的评分，不再依赖旧的 _sleepScoreArr
    NSInteger idx = btn.tag - 100;
    if (idx >= 0 && idx < (NSInteger)self.currentWeekData.dailyScores.count) {
        int score = [self.currentWeekData.dailyScores[idx] intValue];
        [_progressView setProgress:score animated:YES];
    }
}



//睡眠统计圆环
- (UIView *)sleepChartView:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
    titleLabel.font = [UIFont systemFontOfSize:10.0];
    titleLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    titleLabel.text = @"睡姿时间轴";
    [view addSubview:titleLabel];
    
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(iPhoneWidth/2 - 50, 15, 100, 20)];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.font = [UIFont systemFontOfSize:10.0];
    topLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    topLabel.text = @"9:00pm";
    [view addSubview:topLabel];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(iPhoneWidth - 60, iPhoneWidth/2 - 60, 100, 20)];
    rightLabel.textAlignment = NSTextAlignmentLeft;
    rightLabel.font = [UIFont systemFontOfSize:10.0];
    rightLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    rightLabel.text = @"12:00am";
    [view addSubview:rightLabel];
    
    UILabel *boomLabel = [[UILabel alloc] initWithFrame:CGRectMake(iPhoneWidth/2 - 50, iPhoneWidth - 90, 100, 20)];
    boomLabel.textAlignment = NSTextAlignmentCenter;
    boomLabel.font = [UIFont systemFontOfSize:10.0];
    boomLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    boomLabel.text = @"3:00am";
    [view addSubview:boomLabel];
    
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, iPhoneWidth/2 - 60, 60, 20)];
    leftLabel.textAlignment = NSTextAlignmentRight;
    leftLabel.font = [UIFont systemFontOfSize:10.0];
    leftLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    leftLabel.text = @"6:00am";
    [view addSubview:leftLabel];
    
    
    // 1. 创建环形图控件
    self.sleepChart = [[PieChartView alloc] initWithFrame:CGRectMake(60, 30, iPhoneWidth - 120, iPhoneWidth - 120)];
    [view addSubview:self.sleepChart];
    
    // 2. 核心设置：开启空心圆环
    self.sleepChart.drawHoleEnabled = YES;
    self.sleepChart.holeRadiusPercent = 0.8; // 中间空心大小
    self.sleepChart.transparentCircleRadiusPercent = 0.62;
    self.sleepChart.holeColor = [UIColor clearColor]; // 中间背景色
    
    // 3. 构造数据
    NSMutableArray *entries = [NSMutableArray array];
    NSArray *values = @[@10, @8, @5, @15, @9, @10, @11, @5, @7, @6, @4, @7, @3];
    NSArray *colors = @[
        leftLyColor,
        lyColor,
        rightLyColor,
        leftLyColor,
        lyColor,
        rightLyColor,
        leftLyColor,
        lyColor,
        rightLyColor,
        leftLyColor,
        lyColor,
        rightLyColor,
        lyColor
    ];
    
    for (int i = 0; i < values.count; i++) {
        PieChartDataEntry *entry = [[PieChartDataEntry alloc] initWithValue:[values[i] doubleValue] label:nil];
        [entries addObject:entry];
    }
    
    // 4. 设置数据 & 颜色
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithEntries:entries label:nil];
    dataSet.colors = colors;
    dataSet.sliceSpace = 0; // 段间距
    dataSet.drawValuesEnabled = NO; // 显示数值
    
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    self.sleepChart.data = data;
    
    // 5. 关闭旋转、描述文字
    self.sleepChart.rotationEnabled = NO;
    //self.sleepChart.descriptionText = @"";
    self.sleepChart.legend.enabled = NO; // 关闭图例
    return view;
}


#pragma mark - 周报视图

- (void)buildWeekDataView
{
    SleepWeekData *week = self.currentWeekData;

    _weekDataView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btnBG.frame) + 10, iPhoneWidth, iPhoneHeight - TAB_BAR_HEIGHT - CGRectGetMaxY(_btnBG.frame) - 10)];
    _weekDataView.backgroundColor = [UIColor clearColor];
    _weekDataView.contentSize = CGSizeMake(0, 620);
    _weekDataView.hidden = YES;
    [self.view addSubview:_weekDataView];

    CGFloat pad = 20.0;
    CGFloat gap = 12.0;
    CGFloat cardW = (iPhoneWidth - pad * 2 - gap) / 2.0;
    NSArray *metrics = @[
        @[@"周均评分", @"79"],
        @[@"周均睡眠时长", @"8.0h"],
        @[@"周均翻身次数", @"15"],
        @[self.currentMode == PillowNormal ? @"干预总次数" : @"自动调节总次数", @"154"]
    ];
    for (NSInteger i = 0; i < metrics.count; i++) {
        NSArray *metric = metrics[i];
        NSInteger col = i % 2;
        NSInteger row = i / 2;
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(pad + col * (cardW + gap), 10 + row * 82, cardW, 70)];
        card.backgroundColor = [UIColor colorWithValue:@"#111111"];
        card.layer.cornerRadius = 16.0;
        card.layer.masksToBounds = YES;
        card.layer.borderWidth = 1.0;
        card.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
        [_weekDataView addSubview:card];

        UILabel *value = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, cardW - 28, 26)];
        value.text = metric[1];
        value.textColor = [UIColor whiteColor];
        value.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightLight];
        [card addSubview:value];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 42, cardW - 28, 16)];
        label.text = metric[0];
        label.textColor = [UIColor colorWithValue:@"#6b7280"];
        label.font = [UIFont systemFontOfSize:11.0];
        [card addSubview:label];
    }

    CGFloat chartY = 182.0;
    _chartOne = [[SleepChartView alloc] initWithFrame:CGRectMake(0, chartY, iPhoneWidth, 180)];
    _chartOne.title = @"睡眠评分趋势";
    _chartOne.color = [UIColor colorWithValue:@"#f8fafc"];
    _chartOne.dataSource = @[@74,@76,@79,@82,@78,@84,@81];
    [_weekDataView addSubview:_chartOne];

    _charTwo = [[SleepChartView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_chartOne.frame) + 14, iPhoneWidth, 180)];
    _charTwo.title = @"睡眠时长趋势";
    _charTwo.color = [UIColor colorWithValue:@"#22c55e"];
    _charTwo.dataSource = @[@71,@75,@82,@85,@79,@86,@81];
    [_weekDataView addSubview:_charTwo];

    _chartThree = [[SleepChartView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_charTwo.frame) + 14, iPhoneWidth, 180)];
    _chartThree.title = @"翻身次数趋势";
    _chartThree.color = [UIColor colorWithValue:@"#f59e0b"];
    _chartThree.dataSource = @[@19,@17,@16,@14,@15,@12,@13];
    [_weekDataView addSubview:_chartThree];

    SleepChartView *autoChart = [[SleepChartView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_chartThree.frame) + 14, iPhoneWidth, 180)];
    autoChart.title = self.currentMode == PillowNormal ? @"干预趋势" : @"自动调节趋势";
    autoChart.color = [UIColor colorWithValue:@"#38bdf8"];
    autoChart.dataSource = @[@18,@20,@22,@24,@21,@26,@23];
    [_weekDataView addSubview:autoChart];

    UIView *summaryCard = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(autoChart.frame) + 18, iPhoneWidth - 40, 166)];
    summaryCard.backgroundColor = [UIColor colorWithValue:@"#111111"];
    summaryCard.layer.cornerRadius = 16.0;
    summaryCard.layer.masksToBounds = YES;
    summaryCard.layer.borderWidth = 1.0;
    summaryCard.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    [_weekDataView addSubview:summaryCard];

    UILabel *summaryTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, summaryCard.bounds.size.width - 32, 18)];
    summaryTitle.text = @"本周总结";
    summaryTitle.textColor = [UIColor colorWithValue:@"#6b7280"];
    summaryTitle.font = [UIFont systemFontOfSize:12.0];
    [summaryCard addSubview:summaryTitle];

    UILabel *summary = [[UILabel alloc] initWithFrame:CGRectMake(16, 42, summaryCard.bounds.size.width - 32, 108)];
    summary.text = self.currentMode == PillowNormal ? @"• 本周枕头干预主要集中在后半夜，整体节奏较为平稳。\n• 仰卧与侧卧切换后的支撑恢复速度较快，说明高度策略较稳定。\n• 若后续接入真实鼾声与压力数据，可进一步细化干预时段与灵敏度建议。" : @"• 本周睡眠评分在周四和周六达到峰值，自动调节完成度与评分变化呈正相关。\n• 翻身次数整体呈下降趋势，说明床垫支撑逐步稳定。\n• 周末睡眠时长更长，但工作日的入睡效率更好，建议维持固定入睡时段。";
    summary.textColor = [UIColor colorWithValue:@"#9ca3af"];
    summary.font = [UIFont systemFontOfSize:12.0];
    summary.numberOfLines = 0;
    [summaryCard addSubview:summary];

    _weekDataView.contentSize = CGSizeMake(0, CGRectGetMaxY(summaryCard.frame) + 30);
    return;

    UILabel *trendLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 18)];
    trendLabel.font = [UIFont systemFontOfSize:11.0];
    trendLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    trendLabel.text = @"趋势图表";
    [_weekDataView addSubview:trendLabel];

    _chartOne = [[SleepChartView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(trendLabel.frame) + 8, iPhoneWidth - 40, 180)];
    _chartOne.title = @"睡眠质量趋势";
    _chartOne.color = [UIColor colorWithValue:@"#00d4ff"];
    _chartOne.dataSource = week.qualityTrend;
    [_weekDataView addSubview:_chartOne];

    _charTwo = [[SleepChartView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_chartOne.frame) + 14, iPhoneWidth - 40, 180)];
    _charTwo.title = @"鼾声变化趋势";
    _charTwo.color = [UIColor colorWithValue:@"#f97316"];
    _charTwo.dataSource = week.snoreTrend;
    [_weekDataView addSubview:_charTwo];

    _chartThree = [[SleepChartView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_charTwo.frame) + 14, iPhoneWidth - 40, 180)];
    _chartThree.title = @"干预效果趋势";
    _chartThree.color = [UIColor colorWithValue:@"#22c55e"];
    _chartThree.dataSource = week.interventionTrend;
    [_weekDataView addSubview:_chartThree];
}


- (void)dayData
{
    _dayBtn.selected = YES;
    _weekBtn.selected = NO;
    _scrollView.hidden = NO;
    _weekDataView.hidden = YES;
}

- (void)weekData
{
    _weekBtn.selected = YES;
    _dayBtn.selected = NO;
    _scrollView.hidden = YES;
    _weekDataView.hidden = NO;
}

@end
