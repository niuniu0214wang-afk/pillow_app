//
//  RegisterController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/16.
//

#import "RegisterController.h"

@interface RegisterController ()
@property (strong, nonatomic) UITextField *phoneField;
@property (strong, nonatomic) UITextField *codeField;
@property (strong, nonatomic) UITextField *psdField;
@property (strong, nonatomic) UITextField *rePsdField;
@property (strong, nonatomic) UIButton *codeBtn;
@property (strong, nonatomic) NSTimer *codeTimer;
@property (assign, nonatomic) int time;
@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.backgroundColor = [UIColor clearColor];
    backBtn.frame = CGRectMake(20, STATUS_BAR_HEIGHT + 20, 180, 30);
    [backBtn setTitleColor:[UIColor colorWithValue:@"#6b7280"] forState:UIControlStateNormal];
    [backBtn setTitle:@"← 已有账户？返回登录" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToLastPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(backBtn.frame) + 10, 180, 50)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:36.0 weight:UIFontWeightUltraLight];
    titleLabel.text = @"创建账户";
    [self.view addSubview:titleLabel];
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLabel.frame) + 10, 200, 20)];
    detailLabel.textAlignment = NSTextAlignmentLeft;
    detailLabel.font = [UIFont systemFontOfSize:16.0];
    detailLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    detailLabel.text = @"开始您的智能睡眠之旅";
    [self.view addSubview:detailLabel];
    
    
    
    UIView *phoneView = [self textFieldBgView:CGRectMake(20, CGRectGetMaxY(detailLabel.frame) + 15, iPhoneWidth - 40, 56) withImage:@"rePhone"];
    [self.view addSubview:phoneView];
    
    _phoneField = [self creatField:CGRectMake(40, 15, CGRectGetWidth(phoneView.frame) - 60, 26) withTitle:@"手机号"];
    _phoneField.keyboardType = UIKeyboardTypePhonePad;
    [phoneView addSubview:_phoneField];
    
    
    UIView *codeView = [self textFieldBgView:CGRectMake(20, CGRectGetMaxY(phoneView.frame) + 15, iPhoneWidth - 160, 56) withImage:@"reCode"];
    [self.view addSubview:codeView];
    
    _codeField = [self creatField:CGRectMake(40, 15, CGRectGetWidth(codeView.frame) - 60, 26) withTitle:@"验证码"];
    _codeField.keyboardType = UIKeyboardTypeNumberPad;
    [codeView addSubview:_codeField];
    
    _codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _codeBtn.frame = CGRectMake(iPhoneWidth - 120, CGRectGetMaxY(phoneView.frame) + 15, 100, 56);
    _codeBtn.backgroundColor = [UIColor colorWithValue:@"#111111"];
    _codeBtn.layer.cornerRadius = 12.0;
    _codeBtn.layer.borderColor = [UIColor colorWithValue:@"#18181b"].CGColor;
    _codeBtn.layer.borderWidth = 1.0;
    _codeBtn.layer.masksToBounds = YES;
    _codeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_codeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [_codeBtn setTitleColor:[UIColor colorWithValue:@"#9ca3af"] forState:UIControlStateNormal];
    [_codeBtn addTarget:self action:@selector(phoneCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_codeBtn];
    
    
    UIView *psdView = [self textFieldBgView:CGRectMake(20, CGRectGetMaxY(codeView.frame) + 15, iPhoneWidth - 40, 56) withImage:@"relock"];
    [self.view addSubview:psdView];
    
    _psdField = [self creatField:CGRectMake(40, 15, CGRectGetWidth(psdView.frame) - 60, 26) withTitle:@"设置密码"];
    _psdField.secureTextEntry = YES;
    [psdView addSubview:_psdField];
    
    UIView *rePsdView = [self textFieldBgView:CGRectMake(20, CGRectGetMaxY(psdView.frame) + 15, iPhoneWidth - 40, 56) withImage:@"relock"];
    [self.view addSubview:rePsdView];
    
    _rePsdField = [self creatField:CGRectMake(40, 15, CGRectGetWidth(rePsdView.frame) - 60, 26) withTitle:@"确认密码"];
    _rePsdField.secureTextEntry = YES;
    [rePsdView addSubview:_rePsdField];
    
    
    UIButton *registBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registBtn.backgroundColor = [UIColor whiteColor];
    registBtn.layer.cornerRadius = 10.0;
    registBtn.layer.masksToBounds = YES;
    registBtn.frame = CGRectMake(iPhoneWidth/2 - 171, CGRectGetMaxY(rePsdView.frame) + 20, 342, 56);
    [registBtn setTitle:@"立即注册" forState:UIControlStateNormal];
    registBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [registBtn setTitleColor:mainColor forState:UIControlStateNormal];
    [registBtn addTarget:self action:@selector(registAcc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registBtn];
    
    
}

- (void)backToLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

//获取验证码
- (void)phoneCode
{
    if (![self isPhoneNumber:_phoneField.text]) {
        return;
    }
    if (!_codeTimer) {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",httpIP,getPhoneCode];
        NSDictionary *dict = @{@"channel": @"PHONE",
                               @"account": _phoneField.text ?: @"",
                               @"purpose": @"REGISTER"};

        [[HttpClient sharedClient] POST:urlStr parameters:dict success:^(id  _Nonnull responseObject) {
            NSLog(@"responseObject is %@",responseObject);
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"网络请求错误信息:%@",error);
        }];

        _codeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeGOGO) userInfo:nil repeats:YES];
        _time = 60;
        _codeBtn.enabled = NO;
    }
}

- (void)timeGOGO
{
    _time --;
    NSLog(@"输出结果------%d",_time);
    if (_time > 0) {
        [_codeBtn setTitle:[NSString stringWithFormat:@"%ds 后重发",_time] forState:UIControlStateNormal];
    }else{
        [_codeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        _codeBtn.enabled = YES;
        [_codeTimer invalidate];
        _codeTimer = nil;
        _time = 0;
    }
}

//注册账号
- (void)registAcc
{
    if (![self isPhoneNumber:_phoneField.text]) {
        return;
    }
    if (_codeField.text.length == 0) {
        [MJProgressHUD onlyShowMessage:@"请输入验证码" afterDelay:1.0 showAddTo:self.view];
        return;
    }
    if (_psdField.text.length < 6) {
        [MJProgressHUD onlyShowMessage:@"密码至少 6 位" afterDelay:1.0 showAddTo:self.view];
        return;
    }
    if (![_psdField.text isEqualToString:_rePsdField.text]) {
        [MJProgressHUD onlyShowMessage:@"两次密码不一致" afterDelay:1.0 showAddTo:self.view];
        return;
    }
        
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",httpIP,userRegister];
    NSDictionary *dict = @{@"account": _phoneField.text ?: @"",
                           @"password": _psdField.text ?: @"",
                           @"verificationCode": _codeField.text ?: @""};

    [[HttpClient sharedClient] POST:urlStr parameters:dict success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject is %@",responseObject);
        [MJProgressHUD onlyShowMessage:@"注册成功" afterDelay:1.0 showAddTo:self.view];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"网络请求错误信息:%@",error);
    }];
}


//正则校验是否是手机号码

- (BOOL)isPhoneNumber:(NSString *)phoneNumber
{
    if (!phoneNumber || phoneNumber.length != 11) {
        [MJProgressHUD onlyShowMessage:@"手机号码不正确" afterDelay:1.5 showAddTo:self.view];
            return NO;
        }
        
        // 中国大陆手机号正则（最常用、最稳定）
        NSString *regex = @"^1[3-9]\\d{9}$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        return [predicate evaluateWithObject:phoneNumber];
}








- (UIView *)textFieldBgView:(CGRect)frame withImage:(NSString *)imageName
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithValue:@"#111111"];
    view.layer.cornerRadius = 12.0;
    view.layer.borderColor = [UIColor colorWithValue:@"#18181b"].CGColor;
    view.layer.borderWidth = 1.0;
    view.layer.masksToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 16, 16)];
    imageView.image = [UIImage imageNamed:imageName];
    [view addSubview:imageView];
    
    
    return view;
}

- (UITextField *)creatField:(CGRect)frame withTitle:(NSString *)text
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.borderStyle = UITextBorderStyleNone;
    textField.textColor = [UIColor whiteColor];
    textField.font = [UIFont systemFontOfSize:15.0];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:[UIColor colorWithValue:@"#4b5563"]}];
    return textField;
}

- (void)dealloc
{
    [_codeTimer invalidate];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
