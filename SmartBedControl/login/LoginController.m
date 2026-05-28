//
//  LoginController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/16.
//  UI改造：对标 React 原型 Login.tsx，系统图标输入框、ultraLight字重、验证码切换、忘记密码内嵌 (2026-05-26)

#import "LoginController.h"
#import "ForgetPasswordController.h"
#import "RegisterController.h"
#import "../SceneDelegate.h"
#import "../Tools/BLEManager.h"
#import "../Tools/DataCenter.h"

typedef NS_ENUM(NSInteger, LoginMode) {
    LoginModePassword,
    LoginModeCode
};

@interface LoginBedSelectController : UIViewController
@end

@interface LoginController ()

@property (strong, nonatomic) UIView      *welcomeView;
@property (strong, nonatomic) UIView      *accountView;
@property (strong, nonatomic) UITextField *accountField;

// 密码登录
@property (strong, nonatomic) UIView      *passwordContainer;
@property (strong, nonatomic) UITextField *passwordField;

// 验证码登录
@property (strong, nonatomic) UIView      *codeContainer;
@property (strong, nonatomic) UITextField *codeField;
@property (strong, nonatomic) UIButton    *sendCodeBtn;
@property (strong, nonatomic) NSTimer     *codeTimer;
@property (assign, nonatomic) NSInteger    codeCountdown;

// 辅助按钮
@property (strong, nonatomic) UIButton *forgetBtn;
@property (strong, nonatomic) UIButton *switchModeBtn;
@property (strong, nonatomic) UIButton *loginBtn;

@property (assign, nonatomic) LoginMode loginMode;

@end

@implementation LoginBedSelectController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self buildUI];
}

- (void)buildUI
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(18, STATUS_BAR_HEIGHT + 8, 36, 32);
    [backBtn setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    backBtn.tintColor = [UIColor colorWithValue:@"#6b7280"];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(80, STATUS_BAR_HEIGHT + 10, iPhoneWidth - 160, 26)];
    title.text = @"智能床垫";
    title.textColor = [UIColor colorWithValue:@"#9ca3af"];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightLight];
    [self.view addSubview:title];

    UILabel *connected = [[UILabel alloc] initWithFrame:CGRectMake(iPhoneWidth - 94, STATUS_BAR_HEIGHT + 12, 74, 22)];
    connected.text = @"已连接";
    connected.textColor = [UIColor colorWithValue:@"#22c55e"];
    connected.textAlignment = NSTextAlignmentRight;
    connected.font = [UIFont systemFontOfSize:11.0];
    [self.view addSubview:connected];

    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(20, STATUS_BAR_HEIGHT + 86, iPhoneWidth - 40, 20)];
    hint.text = @"选择床位查看详情";
    hint.textColor = [UIColor colorWithValue:@"#4b5563"];
    hint.textAlignment = NSTextAlignmentCenter;
    hint.font = [UIFont systemFontOfSize:12.0];
    [self.view addSubview:hint];

    CGFloat bedW = iPhoneWidth - 48;
    CGFloat bedH = 245;
    UIView *bed = [[UIView alloc] initWithFrame:CGRectMake(24, STATUS_BAR_HEIGHT + 128, bedW, bedH)];
    bed.backgroundColor = [UIColor colorWithValue:@"#111116"];
    bed.layer.cornerRadius = 14.0;
    bed.layer.borderWidth = 1.0;
    bed.layer.borderColor = [UIColor colorWithValue:@"#2a2a34"].CGColor;
    [self.view addSubview:bed];

    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake((bedW - 1) / 2.0, 12, 1, bedH - 24)];
    divider.backgroundColor = [UIColor colorWithValue:@"#333333"];
    [bed addSubview:divider];

    UIButton *left = [self sideButtonWithFrame:CGRectMake(10, 12, bedW / 2.0 - 16, bedH - 24)
                                         title:@"左床"
                                          name:@"小明"
                                         color:@"#00ccff"
                                           tag:1001];
    [bed addSubview:left];

    UIButton *right = [self sideButtonWithFrame:CGRectMake(bedW / 2.0 + 6, 12, bedW / 2.0 - 16, bedH - 24)
                                          title:@"右床"
                                           name:@"小丽"
                                          color:@"#00FF87"
                                            tag:1002];
    [bed addSubview:right];

    CGFloat cardY = CGRectGetMaxY(bed.frame) + 28;
    [self.view addSubview:[self sleeperCard:CGRectMake(24, cardY, (iPhoneWidth - 60) / 2.0, 92) title:@"左床" name:@"小明" color:@"#00ccff" tag:1001]];
    [self.view addSubview:[self sleeperCard:CGRectMake(36 + (iPhoneWidth - 60) / 2.0, cardY, (iPhoneWidth - 60) / 2.0, 92) title:@"右床" name:@"小丽" color:@"#00FF87" tag:1002]];

    UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(bed.frame) + 150, iPhoneWidth - 40, 20)];
    footer.text = @"SMARTREST BOP · 12 AIR CHAMBERS · DUAL ZONE";
    footer.textColor = [UIColor colorWithValue:@"#4b5563"];
    footer.textAlignment = NSTextAlignmentCenter;
    footer.font = [UIFont systemFontOfSize:10.0];
    [self.view addSubview:footer];
}

- (UIButton *)sideButtonWithFrame:(CGRect)frame title:(NSString *)title name:(NSString *)name color:(NSString *)color tag:(NSInteger)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.tag = tag;
    button.layer.cornerRadius = 10.0;
    button.layer.borderWidth = 0.8;
    button.layer.borderColor = [UIColor colorWithValue:color alpha:0.25].CGColor;
    [button addTarget:self action:@selector(selectSide:) forControlEvents:UIControlEventTouchUpInside];

    UIView *glow = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - 88) / 2.0, 52, 88, 120)];
    glow.backgroundColor = [UIColor colorWithValue:color alpha:0.08];
    glow.layer.cornerRadius = 44.0;
    glow.userInteractionEnabled = NO;
    [button addSubview:glow];

    UILabel *person = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, frame.size.width, 24)];
    person.text = name;
    person.textColor = [UIColor colorWithValue:color alpha:0.85];
    person.textAlignment = NSTextAlignmentCenter;
    person.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium];
    [button addSubview:person];

    UILabel *side = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 44, frame.size.width, 20)];
    side.text = title;
    side.textColor = [UIColor whiteColor];
    side.textAlignment = NSTextAlignmentCenter;
    side.font = [UIFont systemFontOfSize:14.0];
    [button addSubview:side];
    return button;
}

- (UIButton *)sleeperCard:(CGRect)frame title:(NSString *)title name:(NSString *)name color:(NSString *)color tag:(NSInteger)tag
{
    UIButton *card = [UIButton buttonWithType:UIButtonTypeCustom];
    card.frame = frame;
    card.tag = tag;
    card.backgroundColor = [UIColor colorWithValue:@"#0a0a0f"];
    card.layer.cornerRadius = 16.0;
    card.layer.borderWidth = 1.0;
    card.layer.borderColor = [UIColor colorWithValue:@"#1a1a22"].CGColor;
    [card addTarget:self action:@selector(selectSide:) forControlEvents:UIControlEventTouchUpInside];

    UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(16, 18, 8, 8)];
    dot.backgroundColor = [UIColor colorWithValue:color];
    dot.layer.cornerRadius = 4.0;
    [card addSubview:dot];

    UILabel *side = [[UILabel alloc] initWithFrame:CGRectMake(32, 12, frame.size.width - 48, 20)];
    side.text = title;
    side.textColor = [UIColor whiteColor];
    side.font = [UIFont systemFontOfSize:14.0];
    [card addSubview:side];

    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(16, 48, frame.size.width - 32, 18)];
    status.text = [NSString stringWithFormat:@"%@ · 睡眠中", name];
    status.textColor = [UIColor colorWithValue:@"#6b7280"];
    status.font = [UIFont systemFontOfSize:12.0];
    [card addSubview:status];
    return card;
}

- (void)selectSide:(UIButton *)sender
{
    NSString *side = sender.tag == 1001 ? @"left" : @"right";
    NSString *bedSide = sender.tag == 1001 ? @"01" : @"02";
    [[NSUserDefaults standardUserDefaults] setObject:side forKey:@"selected_bed_side"];
    [[NSUserDefaults standardUserDefaults] setObject:bedSide forKey:@"selected_bed_side_code"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    SceneDelegate *app = [QuickTools currentSceneDelegate];
    [app changeYellowController];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@implementation LoginController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;
    self.loginMode = LoginModePassword;

    // ── 标题区 ──
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCALE(24), 160, iPhoneWidth - SCALE(48), 56)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:SCALE(40.0) weight:UIFontWeightUltraLight];
    titleLabel.text = @"欢迎";
    [self.view addSubview:titleLabel];

    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCALE(24), CGRectGetMaxY(titleLabel.frame) - 4, iPhoneWidth - SCALE(48), 28)];
    detailLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.font = [UIFont systemFontOfSize:SCALE(14.0)];
    detailLabel.text = @"登录您的睡眠账号";
    [self.view addSubview:detailLabel];

    // ── 账号输入框 ──
    CGFloat hPad = SCALE(24);
    CGFloat fieldW = iPhoneWidth - hPad * 2;

    _accountView = [[UIView alloc] initWithFrame:CGRectMake(hPad, CGRectGetMaxY(detailLabel.frame) + 40, fieldW, 56)];
    _accountView.backgroundColor = [UIColor colorWithValue:@"#111111"];
    _accountView.layer.cornerRadius = 14.0;
    _accountView.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    _accountView.layer.borderWidth = 1.0;
    _accountView.layer.masksToBounds = YES;
    [self.view addSubview:_accountView];

    UIImageView *phoneIcon = [[UIImageView alloc] initWithFrame:CGRectMake(18, 20, 16, 16)];
    phoneIcon.image = [UIImage systemImageNamed:@"phone"];
    phoneIcon.tintColor = [UIColor colorWithValue:@"#6b7280"];
    [_accountView addSubview:phoneIcon];

    _accountField = [[UITextField alloc] initWithFrame:CGRectMake(44, 15, fieldW - 60, 26)];
    _accountField.borderStyle = UITextBorderStyleNone;
    _accountField.keyboardType = UIKeyboardTypePhonePad;
    _accountField.textColor = [UIColor whiteColor];
    _accountField.font = [UIFont systemFontOfSize:15.0];
    _accountField.attributedPlaceholder = [[NSAttributedString alloc]
        initWithString:@"手机号 / 邮箱"
            attributes:@{NSForegroundColorAttributeName: [UIColor colorWithValue:@"#4b5563"]}];
    [_accountView addSubview:_accountField];

    // ── 密码输入框 ──
    _passwordContainer = [[UIView alloc] initWithFrame:CGRectMake(hPad, CGRectGetMaxY(_accountView.frame) + 16, fieldW, 56)];
    _passwordContainer.backgroundColor = [UIColor colorWithValue:@"#111111"];
    _passwordContainer.layer.cornerRadius = 14.0;
    _passwordContainer.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    _passwordContainer.layer.borderWidth = 1.0;
    _passwordContainer.layer.masksToBounds = YES;
    [self.view addSubview:_passwordContainer];

    UIImageView *lockIcon = [[UIImageView alloc] initWithFrame:CGRectMake(18, 19, 16, 18)];
    lockIcon.image = [UIImage systemImageNamed:@"lock"];
    lockIcon.tintColor = [UIColor colorWithValue:@"#6b7280"];
    [_passwordContainer addSubview:lockIcon];

    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(44, 15, fieldW - 60, 26)];
    _passwordField.borderStyle = UITextBorderStyleNone;
    _passwordField.secureTextEntry = YES;
    _passwordField.textColor = [UIColor whiteColor];
    _passwordField.font = [UIFont systemFontOfSize:15.0];
    _passwordField.attributedPlaceholder = [[NSAttributedString alloc]
        initWithString:@"密码"
            attributes:@{NSForegroundColorAttributeName: [UIColor colorWithValue:@"#4b5563"]}];
    [_passwordContainer addSubview:_passwordField];

    // ── 验证码输入框（默认隐藏）──
    _codeContainer = [[UIView alloc] initWithFrame:_passwordContainer.frame];
    _codeContainer.backgroundColor = [UIColor clearColor];
    _codeContainer.hidden = YES;
    _codeContainer.alpha = 0;
    [self.view addSubview:_codeContainer];

    CGFloat sendBtnW = SCALE(100);
    CGFloat codeInputW = fieldW - sendBtnW - 10;
    UIView *codeInputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, codeInputW, 56)];
    codeInputView.backgroundColor = [UIColor colorWithValue:@"#111111"];
    codeInputView.layer.cornerRadius = 14.0;
    codeInputView.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    codeInputView.layer.borderWidth = 1.0;
    codeInputView.layer.masksToBounds = YES;
    [_codeContainer addSubview:codeInputView];

    UIImageView *hashIcon = [[UIImageView alloc] initWithFrame:CGRectMake(18, 19, 16, 18)];
    hashIcon.image = [UIImage systemImageNamed:@"number"];
    hashIcon.tintColor = [UIColor colorWithValue:@"#6b7280"];
    [codeInputView addSubview:hashIcon];

    _codeField = [[UITextField alloc] initWithFrame:CGRectMake(44, 15, codeInputW - 56, 26)];
    _codeField.borderStyle = UITextBorderStyleNone;
    _codeField.keyboardType = UIKeyboardTypeNumberPad;
    _codeField.textColor = [UIColor whiteColor];
    _codeField.font = [UIFont systemFontOfSize:15.0];
    _codeField.attributedPlaceholder = [[NSAttributedString alloc]
        initWithString:@"验证码"
            attributes:@{NSForegroundColorAttributeName: [UIColor colorWithValue:@"#4b5563"]}];
    [codeInputView addSubview:_codeField];

    _sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendCodeBtn.frame = CGRectMake(codeInputW + 10, 0, sendBtnW, 56);
    _sendCodeBtn.backgroundColor = [UIColor colorWithValue:@"#111111"];
    _sendCodeBtn.layer.cornerRadius = 14.0;
    _sendCodeBtn.layer.borderColor = [UIColor colorWithValue:@"#27272a"].CGColor;
    _sendCodeBtn.layer.borderWidth = 1.0;
    _sendCodeBtn.layer.masksToBounds = YES;
    [_sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [_sendCodeBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    [_sendCodeBtn setTitleColor:[UIColor colorWithValue:@"#4b5563"] forState:UIControlStateDisabled];
    _sendCodeBtn.titleLabel.font = [UIFont systemFontOfSize:SCALE(12.0)];
    [_sendCodeBtn addTarget:self action:@selector(sendCode) forControlEvents:UIControlEventTouchUpInside];
    [_codeContainer addSubview:_sendCodeBtn];

    // ── 辅助链接行 ──
    CGFloat linkY = CGRectGetMaxY(_passwordContainer.frame) + 10;

    _forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _forgetBtn.frame = CGRectMake(hPad, linkY, SCALE(80), 24);
    [_forgetBtn setTitle:@"忘记密码？" forState:UIControlStateNormal];
    _forgetBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_forgetBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_forgetBtn addTarget:self action:@selector(forgetPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_forgetBtn];

    _switchModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _switchModeBtn.frame = CGRectMake(iPhoneWidth - hPad - SCALE(110), linkY, SCALE(110), 24);
    [_switchModeBtn setTitle:@"使用验证码登录" forState:UIControlStateNormal];
    _switchModeBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_switchModeBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [_switchModeBtn addTarget:self action:@selector(switchLoginMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_switchModeBtn];

    // ── 登录按钮 ──
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.backgroundColor = [UIColor whiteColor];
    _loginBtn.layer.cornerRadius = 14.0;
    _loginBtn.layer.masksToBounds = YES;
    _loginBtn.frame = CGRectMake(hPad, linkY + 40, fieldW, 56);
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium];
    [_loginBtn setTitleColor:mainColor forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];

    // ── 注册链接 ──
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(hPad, CGRectGetMaxY(_loginBtn.frame) + 24, fieldW, 24);
    [registerBtn setTitle:@"还没有账户？立即注册" forState:UIControlStateNormal];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [registerBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(registerAccount) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];

    [self creatWelcomView];
    [self performSelector:@selector(hiddleWelcomView) withObject:nil afterDelay:1.5];
}

#pragma mark - 登录方式切换

- (void)switchLoginMode
{
    BOOL toCode = (self.loginMode == LoginModePassword);
    self.loginMode = toCode ? LoginModeCode : LoginModePassword;

    if (toCode) {
        _codeContainer.hidden = NO;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.passwordContainer.alpha = toCode ? 0 : 1;
        self.codeContainer.alpha     = toCode ? 1 : 0;
        self.forgetBtn.alpha         = toCode ? 0 : 1;
    } completion:^(BOOL finished) {
        self.passwordContainer.hidden = toCode;
        self.codeContainer.hidden     = !toCode;
    }];

    NSString *title = toCode ? @"使用密码登录" : @"使用验证码登录";
    [_switchModeBtn setTitle:title forState:UIControlStateNormal];
}

#pragma mark - 发送验证码

- (void)sendCode
{
    if (_accountField.text.length == 0) {
        [MJProgressHUD onlyShowMessage:@"请先输入手机号" afterDelay:1.5 showAddTo:self.view];
        return;
    }
    // TODO: 调用发送验证码接口
    _codeCountdown = 60;
    _sendCodeBtn.enabled = NO;
    _codeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tickCountdown) userInfo:nil repeats:YES];
}

- (void)tickCountdown
{
    _codeCountdown--;
    if (_codeCountdown <= 0) {
        [_codeTimer invalidate];
        _codeTimer = nil;
        _sendCodeBtn.enabled = YES;
        [_sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    } else {
        [_sendCodeBtn setTitle:[NSString stringWithFormat:@"%lds 后重发", (long)_codeCountdown] forState:UIControlStateNormal];
    }
}

#pragma mark - 登录

- (void)login
{
    [MJProgressHUD onlyShowMessage:@"登录成功" afterDelay:1.0 showAddTo:self.view];
    BedMode mode = [DataCenter shareInstance].connectedBed ? [DataCenter shareInstance].connectedBed.mode : [BLEManager shareInstance].mode;
    if (mode == PillowNormal) {
        SceneDelegate *app = [QuickTools currentSceneDelegate];
        [app changeYellowController];
        return;
    }
    LoginBedSelectController *bedVC = [[LoginBedSelectController alloc] init];
    [self.navigationController pushViewController:bedVC animated:YES];
}

#pragma mark - 注册 / 找回密码

- (void)registerAccount
{
    RegisterController *registerVC = [[RegisterController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)forgetPassword
{
    ForgetPasswordController *forgetVC = [[ForgetPasswordController alloc] init];
    [self.navigationController pushViewController:forgetVC animated:YES];
}

#pragma mark - 开场动画

- (void)creatWelcomView
{
    self.welcomeView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.welcomeView.backgroundColor = mainColor;
    [self.view addSubview:self.welcomeView];

    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(iPhoneWidth/2 - 170, iPhoneHeight/2 - 340, 340, 340)];
    logo.image = [UIImage imageNamed:@"welcomLogo"];
    [self.welcomeView addSubview:logo];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(logo.frame) - 70, iPhoneWidth - 60, 70)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:48.0 weight:UIFontWeightUltraLight];
    titleLabel.text = @"SMARTREST";
    [self.welcomeView addSubview:titleLabel];

    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(titleLabel.frame), iPhoneWidth - 60, 20)];
    subLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    subLabel.textAlignment = NSTextAlignmentCenter;
    subLabel.font = [UIFont systemFontOfSize:12.0];
    subLabel.text = @"ADAPTIVE SLEEP SYSTEM";
    [self.welcomeView addSubview:subLabel];
}

- (void)hiddleWelcomView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.welcomeView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.welcomeView removeFromSuperview];
            self.welcomeView = nil;
        }
    }];
}

- (void)dealloc
{
    [_codeTimer invalidate];
}

@end
