//
//  SleepScoreProgressView.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/27.
//

#import "SleepScoreProgressView.h"

@interface SleepScoreProgressView ()
@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *label;
@end


@implementation SleepScoreProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setupUI];
    return self;
}

- (void)setupUI {
    self.backgroundColor = UIColor.clearColor;
    _lineWidth = 14;
    _trackColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    _progressColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    // 背景轨道
    _trackLayer = [CAShapeLayer layer];
    _trackLayer.fillColor = UIColor.clearColor.CGColor;
    _trackLayer.strokeColor = _trackColor.CGColor;
    _trackLayer.lineWidth = _lineWidth;
    _trackLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:_trackLayer];
    
    // 进度条
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.fillColor = UIColor.clearColor.CGColor;
    _progressLayer.strokeColor = _progressColor.CGColor;
    _progressLayer.lineWidth = _lineWidth;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.strokeEnd = 0;
    [self.layer addSublayer:_progressLayer];
    
    // 中间分数
    _scoreLabel = [[UILabel alloc] init];
    _scoreLabel.textColor = UIColor.whiteColor;
    _scoreLabel.font = [UIFont systemFontOfSize:80 weight:UIFontWeightLight];
    _scoreLabel.textAlignment = NSTextAlignmentCenter;
    _scoreLabel.text = @"0";
    [self addSubview:_scoreLabel];
    
    _label = [[UILabel alloc] init];
    _label.textColor = [UIColor colorWithValue:@"#6b7280"];
    _label.font = [UIFont systemFontOfSize:10.0];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"睡眠健康评分";
    [self addSubview:_label];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) / 2 - _lineWidth/2;

    // ✅ 核心精准校准：300°圆弧，正下方60°缺口
    // 起始：左侧 150° → 顺时针绘制 → 顶部 → 右侧 -150°
    // 总角度：300°（无任何误差）
    CGFloat startAngle = M_PI - M_PI/3;   // 150°
    CGFloat endAngle   = M_PI/3;  // -150°

    // 强制顺时针绘制，保证300°完整圆弧
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:startAngle
                                                      endAngle:endAngle
                                                     clockwise:YES];
    
    _trackLayer.path = path.CGPath;
    _progressLayer.path = path.CGPath;
    _scoreLabel.frame = self.bounds;
    _label.frame = CGRectMake(self.bounds.size.width/2 - 50, self.bounds.size.height - 80, 100, 20);
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    _progress = MAX(0, MIN(100, progress));
    _scoreLabel.text = [NSString stringWithFormat:@"%.0f", _progress];
    CGFloat rate = _progress / 100.f;
    
    if (animated) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        anim.fromValue = @(_progressLayer.strokeEnd);
        anim.toValue = @(rate);
        anim.duration = 0.6;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        _progressLayer.strokeEnd = rate;
        [_progressLayer addAnimation:anim forKey:@"progress"];
    } else {
        _progressLayer.strokeEnd = rate;
    }
}

@end
