//
//  SleepChartView.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/17.
//

#import "SleepChartView.h"


@interface SleepChartView ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) LineChartView *lineChart;
@end

@implementation SleepChartView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setUpViews];
    }
    return self;
}


- (void)setUpViews
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, iPhoneWidth - 40, self.frame.size.height)];
    view.backgroundColor = [UIColor clearColor];
    view.layer.cornerRadius = 16.0;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [UIColor colorWithValue:@"#18181b"].CGColor;
    view.layer.borderWidth = 1.0;
    view.backgroundColor = [UIColor colorWithValue:@"#111111"];
    [self addSubview:view];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 20)];
    _titleLabel.textColor = [UIColor colorWithValue:@"#9ca3af"];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = [UIFont systemFontOfSize:12];
    [view addSubview:_titleLabel];
    
    _lineChart = [[LineChartView alloc] initWithFrame:CGRectMake(20, 30, iPhoneWidth - 80, 130)];
    _lineChart.backgroundColor = [UIColor clearColor];
    [view addSubview:_lineChart];

    // 基础全局配置
    _lineChart.chartDescription.enabled = NO; // 关闭底部描述文字
    _lineChart.legend.enabled = NO; // 显示图例
    _lineChart.dragEnabled = NO; // 可拖拽
    _lineChart.pinchZoomEnabled = NO;
    _lineChart.scaleYEnabled = NO;
    
    
     
    ChartXAxis *xAxis = _lineChart.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom; // 文字放下面
    xAxis.drawAxisLineEnabled = NO;    // 隐藏X轴线
    xAxis.drawGridLinesEnabled = NO;  // 隐藏竖网格
    xAxis.drawLabelsEnabled = YES;    // 显示X轴文字
    xAxis.labelTextColor = [UIColor colorWithValue:@"#4b5563"];

    // ========== Y轴配置：隐藏刻度、隐藏网格、隐藏轴线 ==========
    ChartYAxis *leftAxis = _lineChart.leftAxis;
    leftAxis.drawAxisLineEnabled = NO;    // 隐藏Y轴线
    leftAxis.drawGridLinesEnabled = NO;   // 隐藏横网格
    leftAxis.drawLabelsEnabled = NO;      // 隐藏Y轴刻度数字

    _lineChart.rightAxis.enabled = NO; // 关闭右侧Y轴
    _lineChart.leftAxis.enabled = NO;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;   
}

- (void)setColor:(UIColor *)color
{
    _color = color;
}


- (void)setDataSource:(NSArray *)dataSource
{
    NSArray *XText = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    _dataSource = dataSource;
    
    NSMutableArray *entries = [NSMutableArray array];
    
    for (int i = 0; i < dataSource.count; i++) {
        ChartDataEntry *entry = [[ChartDataEntry alloc] initWithX:i y:[dataSource[i] doubleValue]];
        [entries addObject:entry];
    }
    
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithEntries:entries label:@"数据趋势"];
    // 折线颜色、宽度
    set.colors = @[_color];
    set.lineWidth = 2;
    // 数据圆点
    set.circleColors = @[_color];
    set.circleRadius = 4;
    // 显示数值
    set.drawValuesEnabled = NO;
    //set.valueFont = [UIFont systemFontOfSize:9];
    // 平滑曲线
    set.mode = LineChartModeLinear;
    
    LineChartData *data = [[LineChartData alloc] initWithDataSet:set];
    _lineChart.data = data;

    // X轴显示自定义文字
    _lineChart.xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] initWithValues:XText];

    // 动画
    [_lineChart animateWithYAxisDuration:0.8];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
