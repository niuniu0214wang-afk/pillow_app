//
//  RegulateSlider.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/24.
//  UI改造：对标 React 原型 ManualModeViz.tsx，添加实时数值显示、颜色反馈、触感反馈 (2026-05-26)

#import "RegulateSlider.h"


@interface RegulateSlider ()

@property (strong, nonatomic) UILabel *partLabel;
@property (strong, nonatomic) UILabel *valueLabel;   // 右侧实时数值
@property (strong, nonatomic) UIView  *dotView;      // 部位名称左侧彩色圆点
@property (strong, nonatomic) UISlider *slider;

@end



@implementation RegulateSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSliderView];
    }
    return self;
}


- (void)setupSliderView
{
    // 左侧彩色圆点
    _dotView = [[UIView alloc] initWithFrame:CGRectMake(SCALE(20), 7, 8, 8)];
    _dotView.layer.cornerRadius = 4.0;
    _dotView.layer.masksToBounds = YES;
    _dotView.backgroundColor = [UIColor colorWithValue:@"#6b7280"];
    [self addSubview:_dotView];

    // 部位名称
    self.partLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCALE(35), 0, SCALE(100), 25)];
    self.partLabel.font = [UIFont systemFontOfSize:14.0];
    self.partLabel.textColor = [UIColor colorWithValue:@"#9ca3af"];
    self.partLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.partLabel];

    // 右侧实时数值标签
    CGFloat viewW = MAX(CGRectGetWidth(self.bounds), iPhoneWidth);
    _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW - SCALE(55), 0, SCALE(40), 25)];
    _valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:13.0 weight:UIFontWeightRegular];
    _valueLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    _valueLabel.textAlignment = NSTextAlignmentRight;
    _valueLabel.text = @"0";
    [self addSubview:_valueLabel];

    // 滑块：左边距 SCALE(35)，右边距 SCALE(55)，两端留出标签空间
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(SCALE(35), CGRectGetMaxY(self.partLabel.frame) + 8, viewW - SCALE(90), 16)];
    self.slider.maximumTrackTintColor = [UIColor colorWithValue:@"#ffffff" alpha:0.06];
    self.slider.minimumTrackTintColor = [UIColor colorWithValue:@"#00d4ff"];
    [self.slider setThumbImage:[UIImage imageNamed:@"sliderPoint"] forState:UIControlStateNormal];
    [self.slider addTarget:self action:@selector(levelChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(levelChangeEnd:) forControlEvents:UIControlEventTouchUpInside];
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 100;
    self.value = 50;
    [self addSubview:self.slider];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat viewW = CGRectGetWidth(self.bounds);
    _valueLabel.frame = CGRectMake(viewW - SCALE(55), 0, SCALE(40), 25);
    self.slider.frame = CGRectMake(SCALE(35), CGRectGetMaxY(self.partLabel.frame) + 8, viewW - SCALE(90), 16);
}

- (UIImage *)sliderTrackImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 12, 8);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:4.0];
    [color setFill];
    [path fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
}

// 硬度颜色从低到高依次过渡：绿 -> 黄 -> 红
- (UIColor *)colorForValue:(int)v
{
    CGFloat progress = MAX(0.0, MIN(1.0, v / 100.0));
    UIColor *startColor = [UIColor colorWithValue:@"#22c55e"];
    UIColor *midColor = [UIColor colorWithValue:@"#facc15"];
    UIColor *endColor = [UIColor colorWithValue:@"#ef4444"];
    UIColor *fromColor = progress <= 0.5 ? startColor : midColor;
    UIColor *toColor = progress <= 0.5 ? midColor : endColor;
    CGFloat localProgress = progress <= 0.5 ? progress / 0.5 : (progress - 0.5) / 0.5;

    CGFloat fr = 0, fg = 0, fb = 0, fa = 0;
    CGFloat tr = 0, tg = 0, tb = 0, ta = 0;
    [fromColor getRed:&fr green:&fg blue:&fb alpha:&fa];
    [toColor getRed:&tr green:&tg blue:&tb alpha:&ta];

    return [UIColor colorWithRed:(fr + (tr - fr) * localProgress)
                           green:(fg + (tg - fg) * localProgress)
                            blue:(fb + (tb - fb) * localProgress)
                           alpha:(fa + (ta - fa) * localProgress)];
}

- (void)setValue:(int)value
{
    value = MAX(0, MIN(100, value));
    _value = value;
    self.slider.value = value;
    _valueLabel.text = [NSString stringWithFormat:@"%d", value];
    UIColor *color = [self colorForValue:value];
    _valueLabel.textColor = color;
    _dotView.backgroundColor = color;
    self.slider.minimumTrackTintColor = color;
}

- (void)setTitle:(NSString *)title
{
    self.partLabel.text = title;
}


// 滑动中：实时更新数值显示和颜色
- (void)levelChanged:(UISlider *)slider
{
    int current = (int)slider.value;
    UIColor *color = [self colorForValue:current];
    _valueLabel.text = [NSString stringWithFormat:@"%d", current];
    _valueLabel.textColor = color;
    _dotView.backgroundColor = color;
    self.slider.minimumTrackTintColor = color;
}

// 滑动结束：触感反馈 + 通知代理
- (void)levelChangeEnd:(UISlider *)slider
{
    int number = (int)slider.value;
    BOOL isUp = number > _value ? YES : NO;

    // 轻触感反馈
    UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [feedback prepare];
    [feedback impactOccurred];

    if ([_delegate respondsToSelector:@selector(controlsliderValue:controlEndValue:valueIsUp:)]) {
        [_delegate controlsliderValue:self controlEndValue:number valueIsUp:isUp];
    }
}

@end
