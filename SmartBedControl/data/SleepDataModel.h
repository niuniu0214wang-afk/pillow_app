//
//  SleepDataModel.h
//  SmartBedControl
//
//  睡眠数据模型，UI 层只依赖此结构体。
//  后台部署完成后，只需修改 SleepDataController 的 loadSleepData 方法，
//  将 mock 数据替换为 HttpClient 请求，UI 代码无需改动。(2026-05-26)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 单日睡眠数据
@interface SleepDayData : NSObject

@property (assign, nonatomic) NSInteger score;          // 睡眠评分 0-100
@property (assign, nonatomic) CGFloat   qualityPercent; // 睡眠质量百分比 0-100
@property (assign, nonatomic) CGFloat   comparePercent; // 睡眠环比 0-100
@property (strong, nonatomic) NSString *durationText;   // 睡眠时长，如 "8h34m"

@property (assign, nonatomic) NSInteger restingHeartRate; // 静息心率 bpm
@property (assign, nonatomic) NSInteger turnOverCount;    // 翻身次数
@property (assign, nonatomic) NSInteger sitUpCount;       // 坐起次数

/// 睡眠阶段数组（24个元素，每个值 1-4：1=离床 2=浅睡 3=深睡 4=REM）
@property (strong, nonatomic) NSArray<NSNumber *> *sleepStages;

/// AI 自动调节次数
@property (assign, nonatomic) NSInteger autoAdjustCount;

@end


/// 周报数据
@interface SleepWeekData : NSObject

/// 7天评分数组（周一到周日）
@property (strong, nonatomic) NSArray<NSNumber *> *dailyScores;

/// 睡眠质量趋势（7个值）
@property (strong, nonatomic) NSArray<NSNumber *> *qualityTrend;

/// 鼾声变化趋势（7个值）
@property (strong, nonatomic) NSArray<NSNumber *> *snoreTrend;

/// 干预效果趋势（7个值）
@property (strong, nonatomic) NSArray<NSNumber *> *interventionTrend;

@end

NS_ASSUME_NONNULL_END
