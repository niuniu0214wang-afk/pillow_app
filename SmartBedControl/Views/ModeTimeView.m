//
//  ModeTimeView.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/7.
//  UI改造：修复循环次数从0开始的bug、修复transform叠加bug，改用frame动画 (2026-05-26)

#import "ModeTimeView.h"


#define kViewHeight 310
#define kMianColor @"#a78bfa"
#define kLaColor @"#00d4ff"
#define kAnColor @"#f97316"
#define kBoColor @"#00ff87"
#define btnScal ((iPhoneWidth - 40) - 290)/4

@interface ModeTimeView ()

@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) NSArray *titleArr;
@property (strong, nonatomic) NSArray *wordArr;
@property (strong, nonatomic) NSArray *colorArr;
@property (strong, nonatomic) UILabel *messageLabel;
@property (assign, nonatomic) int level;    //执行等级，一级大约15分钟
@end


@implementation ModeTimeView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.wordArr = @[@"眠",@"拉",@"按",@"波"];
        self.titleArr = @[@"助眠模式",@"拉伸模式",@"按摩模式",@"海浪波动"];
        self.colorArr = @[kMianColor,kLaColor,kAnColor,kBoColor];
        self.level = 1;
    }
    return self;
}


- (void)show:(NSInteger)tag
{
    self.backgroundColor = [UIColor colorWithValue:@"#000000" alpha:0.6];
    [[QuickTools mainWindow] addSubview:self];
    [self doInitContentView:tag];

    // 用 frame 动画替代 transform，避免多次调用时 transform 叠加错位
    CGRect startFrame = CGRectMake(0, iPhoneHeight, iPhoneWidth, kViewHeight);
    CGRect endFrame   = CGRectMake(0, iPhoneHeight - kViewHeight, iPhoneWidth, kViewHeight);
    self.bgView.frame = startFrame;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.bgView.frame = endFrame;
    } completion:nil];
}


- (void)doInitContentView:(NSInteger)tag
{
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, iPhoneHeight, iPhoneWidth, kViewHeight)];
    [[QuickTools mainWindow] addSubview:self.bgView];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, iPhoneWidth - 40, 280)];
    contentView.backgroundColor = [UIColor colorWithValue:@"#1a1a1a"];
    contentView.layer.cornerRadius = 24.0;
    contentView.layer.masksToBounds = YES;
    contentView.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:.08].CGColor;
    contentView.layer.borderWidth = 1.0;
    [self.bgView addSubview:contentView];
    
    UILabel *wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 28, 28)];
    wordLabel.textAlignment = NSTextAlignmentCenter;
    wordLabel.font = [UIFont systemFontOfSize:10.0];
    wordLabel.text = self.wordArr[tag];
    wordLabel.layer.cornerRadius = 14;
    wordLabel.layer.masksToBounds = YES;
    wordLabel.textColor = [UIColor colorWithValue:self.colorArr[tag]];
    wordLabel.backgroundColor = [UIColor colorWithValue:self.colorArr[tag] alpha:.12];
    wordLabel.layer.borderColor = [UIColor colorWithValue:self.colorArr[tag] alpha:.24].CGColor;
    wordLabel.layer.borderWidth = 1.0;
    [contentView addSubview:wordLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 8, 160, 25)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:18.0];
    titleLabel.text = self.titleArr[tag];
    titleLabel.textColor = [UIColor whiteColor];
    [contentView addSubview:titleLabel];
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 33, 160, 18)];
    detailLabel.textAlignment = NSTextAlignmentLeft;
    detailLabel.font = [UIFont systemFontOfSize:12.0];
    detailLabel.text = self.titleArr[tag];
    detailLabel.text = @"每次循环约15分钟";
    detailLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    [contentView addSubview:detailLabel];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 160, 18)];
    countLabel.textAlignment = NSTextAlignmentLeft;
    countLabel.font = [UIFont systemFontOfSize:12.0];
    countLabel.text = self.titleArr[tag];
    countLabel.text = @"选择循环次数";
    countLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    [contentView addSubview:countLabel];
    
    UIImage *highImage = [[ToolHexManager sharedManager] imageWithColor:[UIColor colorWithValue:self.colorArr[tag] alpha:0.08]];
    UIImage *normalImage = [[ToolHexManager sharedManager] imageWithColor:[UIColor colorWithValue:@"#ffffff" alpha:0.04]];
    
    for (int i = 0; i < 5; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
        [btn setBackgroundImage:highImage forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
        [btn setTitleColor:self.colorArr[tag] forState:UIControlStateSelected];
        btn.frame = CGRectMake(20 + i%5*(btnScal + 50), CGRectGetMaxY(countLabel.frame) + 5, 50, 44);
        btn.layer.cornerRadius = 12.0;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 1.0;
        btn.tag = 360 + i + 1;  // tag 从 361 开始，对应循环次数 1-5
        if (i == 0) {
            btn.layer.borderColor = [UIColor colorWithValue:self.colorArr[tag] alpha:.24].CGColor;
            btn.selected = YES;
        } else {
            btn.layer.borderColor = [UIColor colorWithValue:@"#ffffff" alpha:0.06].CGColor;
        }
        // 按钮显示 1/2/3/4/5 次
        [btn setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(levelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:btn];
    }
    
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(countLabel.frame) + 59, iPhoneWidth - 80, 38)];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.text = @"共15分钟·1个循环";
    _messageLabel.textColor = [UIColor colorWithValue:self.colorArr[tag]];
    _messageLabel.font = [UIFont systemFontOfSize:12.0];
    _messageLabel.layer.cornerRadius = 12.0;
    _messageLabel.layer.masksToBounds = YES;
    _messageLabel.layer.borderColor = [UIColor colorWithValue:self.colorArr[tag] alpha:0.2].CGColor;
    _messageLabel.layer.borderWidth = 1.0;
    _messageLabel.backgroundColor = [UIColor colorWithValue:self.colorArr[tag] alpha:0.08];
    [contentView addSubview:_messageLabel];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(20, CGRectGetMaxY(_messageLabel.frame) + 10, iPhoneWidth/2 - 45, 44);
    cancelBtn.layer.cornerRadius = 12.0;
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.backgroundColor = [UIColor colorWithValue:@"#ffffff" alpha:0.04];
    cancelBtn.layer.borderColor = [UIColor colorWithValue:@"ffffff" alpha:0.08].CGColor;
    cancelBtn.layer.borderWidth = 1.0;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:cancelBtn];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(CGRectGetMaxX(cancelBtn.frame) + 10, CGRectGetMaxY(_messageLabel.frame) + 10, iPhoneWidth/2 - 45, 44);
    okBtn.layer.cornerRadius = 12.0;
    okBtn.layer.masksToBounds = YES;
    okBtn.backgroundColor = [UIColor colorWithValue:self.colorArr[tag]];
    okBtn.layer.borderWidth = 1.0;
    [okBtn setTitle:@"开始" forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor colorWithValue:@"#050814"] forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(modeRun) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:okBtn];
}

- (void)levelBtnClicked:(UIButton *)btn
{
    // tag = 361~365，对应循环次数 1~5
    _level = (int)(btn.tag - 360);
    _messageLabel.text = [NSString stringWithFormat:@"共%d分钟·%d个循环", _level * 15, _level];
}


- (void)modeRun
{
    if ([_delegate respondsToSelector:@selector(modeTimeView:doTimeLevel:)]) {
        [_delegate modeTimeView:self doTimeLevel:_level];
    }
    [self dismiss];
}


- (void)dismiss
{
    CGRect endFrame = CGRectMake(0, iPhoneHeight, iPhoneWidth, kViewHeight);
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.bgView.frame = endFrame;
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
        [self removeFromSuperview];
    }];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
