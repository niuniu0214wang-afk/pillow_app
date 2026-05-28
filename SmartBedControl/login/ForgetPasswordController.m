//
//  ForgetPasswordController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/16.
//

#import "ForgetPasswordController.h"

@interface ForgetPasswordController ()
@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UITextField *codeField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *sendCodeBtn;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger countdown;

@end

@implementation ForgetPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;
    [self buildUI];
}

- (void)buildUI
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(16, STATUS_BAR_HEIGHT + 4, 40, 36);
    [backBtn setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    backBtn.tintColor = [UIColor colorWithValue:@"#6b7280"];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(24, 160, iPhoneWidth - 48, 50)];
    title.text = @"重置密码";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:36.0 weight:UIFontWeightUltraLight];
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];

    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(title.frame), iPhoneWidth - 48, 24)];
    sub.text = @"验证身份后设置新密码";
    sub.textColor = [UIColor colorWithValue:@"#6b7280"];
    sub.font = [UIFont systemFontOfSize:14.0];
    sub.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:sub];

    CGFloat pad = 24.0;
    CGFloat width = iPhoneWidth - pad * 2;
    CGFloat y = CGRectGetMaxY(sub.frame) + 42;
    self.accountField = [self addInputAtY:y width:width placeholder:@"手机号 / 邮箱" icon:@"phone" secure:NO];

    y += 72;
    UIView *codeWrap = [[UIView alloc] initWithFrame:CGRectMake(pad, y, width, 56)];
    [self.view addSubview:codeWrap];
    self.codeField = [self inputFieldInContainer:codeWrap frame:CGRectMake(0, 0, width - 112, 56) placeholder:@"验证码" icon:@"number" secure:NO];

    self.sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendCodeBtn.frame = CGRectMake(width - 102, 0, 102, 56);
    self.sendCodeBtn.backgroundColor = [UIColor colorWithValue:@"#111111"];
    self.sendCodeBtn.layer.cornerRadius = 14.0;
    self.sendCodeBtn.layer.borderWidth = 1.0;
    self.sendCodeBtn.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    [self.sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    self.sendCodeBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.sendCodeBtn addTarget:self action:@selector(sendCode) forControlEvents:UIControlEventTouchUpInside];
    [codeWrap addSubview:self.sendCodeBtn];

    y += 72;
    self.passwordField = [self addInputAtY:y width:width placeholder:@"新密码" icon:@"lock" secure:YES];

    y += 84;
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resetBtn.frame = CGRectMake(pad, y, width, 56);
    resetBtn.backgroundColor = [UIColor whiteColor];
    resetBtn.layer.cornerRadius = 14.0;
    resetBtn.layer.masksToBounds = YES;
    [resetBtn setTitle:@"确认重置" forState:UIControlStateNormal];
    [resetBtn setTitleColor:mainColor forState:UIControlStateNormal];
    resetBtn.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium];
    [resetBtn addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetBtn];
}

- (UITextField *)addInputAtY:(CGFloat)y width:(CGFloat)width placeholder:(NSString *)placeholder icon:(NSString *)icon secure:(BOOL)secure
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(24, y, width, 56)];
    [self.view addSubview:container];
    return [self inputFieldInContainer:container frame:container.bounds placeholder:placeholder icon:icon secure:secure];
}

- (UITextField *)inputFieldInContainer:(UIView *)parent frame:(CGRect)frame placeholder:(NSString *)placeholder icon:(NSString *)icon secure:(BOOL)secure
{
    UIView *container = [[UIView alloc] initWithFrame:frame];
    container.backgroundColor = [UIColor colorWithValue:@"#111111"];
    container.layer.cornerRadius = 14.0;
    container.layer.borderWidth = 1.0;
    container.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    [parent addSubview:container];

    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 19, 16, 18)];
    iconView.image = [UIImage systemImageNamed:icon];
    iconView.tintColor = [UIColor colorWithValue:@"#6b7280"];
    [container addSubview:iconView];

    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(44, 15, frame.size.width - 58, 26)];
    field.textColor = [UIColor whiteColor];
    field.secureTextEntry = secure;
    field.font = [UIFont systemFontOfSize:15.0];
    field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:[UIColor colorWithValue:@"#4b5563"]}];
    [container addSubview:field];
    return field;
}

- (void)sendCode
{
    if (self.accountField.text.length == 0) {
        [MJProgressHUD onlyShowMessage:@"请先输入手机号或邮箱" afterDelay:1.0 showAddTo:self.view];
        return;
    }
    self.countdown = 60;
    self.sendCodeBtn.enabled = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

- (void)tick
{
    self.countdown--;
    if (self.countdown <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        self.sendCodeBtn.enabled = YES;
        [self.sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    } else {
        [self.sendCodeBtn setTitle:[NSString stringWithFormat:@"%lds", (long)self.countdown] forState:UIControlStateNormal];
    }
}

- (void)resetPassword
{
    if (self.accountField.text.length == 0 || self.codeField.text.length == 0 || self.passwordField.text.length < 6) {
        [MJProgressHUD onlyShowMessage:@"请完整填写信息，新密码至少 6 位" afterDelay:1.0 showAddTo:self.view];
        return;
    }
    [MJProgressHUD onlyShowMessage:@"密码已重置，请重新登录" afterDelay:1.0 showAddTo:self.view];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [self.timer invalidate];
}


@end
