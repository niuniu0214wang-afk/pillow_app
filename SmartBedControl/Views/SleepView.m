//
//  SleepView.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/27.
//

#import "SleepView.h"

@interface SleepView ()
@property (strong, nonatomic) UIView *slider;
@end

@implementation SleepView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    _slider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
    [self addSubview:_slider];
}


//
- (void)setLevel:(int)level
{
    UIColor *color = [UIColor clearColor];
    int y = 100;
    if (level == 1) {//离床
        y = 70;
        color = [UIColor colorWithValue:@"#f59e0b"];
    }
    if (level == 2) {//睡眠中断
        y = 60;
        color = [UIColor colorWithValue:@"#1e3a5f"];
    }
    if (level == 3) {//浅睡
        y = 40;
        color = [UIColor colorWithValue:@"#93c5fd"];
    }
    
    if (level == 4) {//深睡
        y = 0;
        color = [UIColor colorWithValue:@"#3b82f6"];
    }
    _slider.frame = CGRectMake(0, y, self.frame.size.width, 100 - y);
    _slider.backgroundColor = color;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
