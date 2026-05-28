//
//  ModeButton.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/24.
//

#import "ModeButton.h"

@interface ModeButton ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *textLabel;
@end


@implementation ModeButton

- (instancetype)initWithIcon:(UIImage *)icon title:(NSString *)title {
    self = [super init];
    if (self) {
        [self setupUIWithIcon:icon title:title];
    }
    return self;
}

- (void)setupUIWithIcon:(UIImage *)icon title:(NSString *)title {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1]; // 深色背景
    self.layer.cornerRadius = 16;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1].CGColor;
    self.clipsToBounds = YES;
    
    // 图标
    self.iconView = [[UIImageView alloc] initWithImage:icon];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.iconView];
    
    // 文字
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.text = title;
    self.textLabel.textColor = [UIColor lightGrayColor];
    self.textLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.textLabel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
