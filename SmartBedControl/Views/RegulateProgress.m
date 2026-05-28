//
//  RegulateProgress.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/24.
//

#import "RegulateProgress.h"
#import "UIImageView+GIF.h"

@interface RegulateProgress ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *animationView;
@property (strong, nonatomic) UIView *stopLyingImage;
@property (strong, nonatomic) UILabel *stateLabel;
@end

@implementation RegulateProgress

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 66, 20)];
        self.titleLabel.font = [UIFont systemFontOfSize:13.0];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
        [self addSubview:self.titleLabel];
        
        _animationView = [[UIImageView alloc] initWithFrame:CGRectMake(95, 10, iPhoneWidth - 180, 20)];
        [_animationView playGifWithName:@"wave_animation"];
        _animationView.hidden = YES;
        [self addSubview:_animationView];
        
        _stopLyingImage = [[UIView alloc] initWithFrame:CGRectMake(95, 18, iPhoneWidth - 180, 4)];
        _stopLyingImage.backgroundColor = [UIColor colorWithValue:@"#00ff87"];
        [self addSubview:_stopLyingImage];
        
        
        self.stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_animationView.frame) + 10, 10, 50, 20)];
        self.stateLabel.font = [UIFont systemFontOfSize:13.0];
        self.stateLabel.textAlignment = NSTextAlignmentLeft;
        self.stateLabel.textColor = [UIColor colorWithValue:@"#00ff87"];
        self.stateLabel.text = @"";
        [self addSubview:self.stateLabel];

    }
    return self;
}


- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}


- (void)start
{
    self.animationView.hidden = NO;
    self.stopLyingImage.hidden = YES;
    self.stateLabel.text = @"调节中...";
    self.stateLabel.textColor = [UIColor colorWithValue:@"#eab305"];
}

- (void)stop
{
    NSLog(@"结束动画");
    self.animationView.hidden = YES;
    self.stopLyingImage.hidden = NO;
    self.stateLabel.text = @"调节完成";
    self.stateLabel.textColor = [UIColor colorWithValue:@"#00ff87"];
}






/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
