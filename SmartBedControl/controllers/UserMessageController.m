//
//  UserMessageController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/12.
//

#import "UserMessageController.h"
#import "../Views/PillowSlider.h"

#define secondTextColor [UIColor colorWithValue:@"#6b7280"]
#define labelBGColor [UIColor colorWithValue:@"#1a1a1a"]
#define bordorColor [UIColor colorWithValue:@"#27272a"]
#define highColor [UIColor colorWithValue:@"#00d4ef"]
#define highBgColor [UIColor colorWithValue:@"#00d4ef" alpha:0.1]
#define highBorderColor [UIColor colorWithValue:@"#00d4ef" alpha:0.4]

@interface UserMessageController ()

@property (strong, nonatomic) UIScrollView *messageScrollView;


@property (strong, nonatomic) UITextField *heightField; //身高
@property (strong, nonatomic) UITextField *weightField; //体重
@property (strong, nonatomic) UITextField *ageField;    //年龄
@property (strong, nonatomic) UITextField *neckField;   //颈围

@property (strong, nonatomic) UIButton *boyBtn;
@property (strong, nonatomic) UIButton *girlBtn;

@property (strong, nonatomic) PillowSlider *supineSlider;
@property (strong, nonatomic) PillowSlider *sideLySlider;
@end

@implementation UserMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = mainColor;
    
    _messageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + 65, iPhoneWidth, iPhoneHeight - STATUS_BAR_HEIGHT - 65 - TAB_BAR_HEIGHT)];
    _messageScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_messageScrollView];
    _messageScrollView.contentSize = CGSizeMake(iPhoneWidth, iPhoneHeight + 200);
    
    //身高
    UILabel *heightLabel = [self secondTextLabel:CGRectMake(20, 0, 100, 20) labelText:@"身高(cm)" textAlignment:NSTextAlignmentLeft];
    [_messageScrollView addSubview:heightLabel];

    UIView *heighView = [self bgView:CGRectMake(20, CGRectGetMaxY(heightLabel.frame) + 3, iPhoneWidth/2 - 30, 52)];
    [_messageScrollView addSubview:heighView];
    _heightField = [self inputField:CGRectMake(14, 13, heighView.frame.size.width - 28, 26) placeholder:@"175"];
    _heightField.keyboardType = UIKeyboardTypeNumberPad;
    [heighView addSubview:_heightField];
    
    //体重
    UILabel *weightLabel = [self secondTextLabel:CGRectMake(iPhoneWidth/2 + 10, 0, 100, 20) labelText:@"体重(kg)" textAlignment:NSTextAlignmentLeft];
    [_messageScrollView addSubview:weightLabel];

    UIView *weightView = [self bgView:CGRectMake(iPhoneWidth/2 + 10, CGRectGetMaxY(weightLabel.frame) + 3, iPhoneWidth/2 - 30, 52)];
    [_messageScrollView addSubview:weightView];
    _weightField = [self inputField:CGRectMake(14, 13, weightView.frame.size.width - 28, 26) placeholder:@"65"];
    _weightField.keyboardType = UIKeyboardTypeDecimalPad;
    [weightView addSubview:_weightField];
    
    //年龄
    UILabel *ageLabel = [self secondTextLabel:CGRectMake(20, CGRectGetMaxY(heighView.frame) + 10 , 100, 20) labelText:@"年龄" textAlignment:NSTextAlignmentLeft];
    [_messageScrollView addSubview:ageLabel];

    UIView *ageView = [self bgView:CGRectMake(20, CGRectGetMaxY(ageLabel.frame) + 3, iPhoneWidth - 40, 52)];
    [_messageScrollView addSubview:ageView];
    _ageField = [self inputField:CGRectMake(14, 13, ageView.frame.size.width - 28, 26) placeholder:@"25"];
    _ageField.keyboardType = UIKeyboardTypeNumberPad;
    [ageView addSubview:_ageField];
    
    //性别
    UILabel *sexLabel = [self secondTextLabel:CGRectMake(20, CGRectGetMaxY(ageView.frame) + 10 , 100, 20) labelText:@"性别" textAlignment:NSTextAlignmentLeft];
    [_messageScrollView addSubview:sexLabel];
    
    _boyBtn = [self messageBtn:CGRectMake(20, CGRectGetMaxY(sexLabel.frame) + 3, iPhoneWidth/2 - 30, 52) withTitle:@"男"];
    _boyBtn.layer.borderColor = highBorderColor.CGColor;
    _boyBtn.selected = YES;
    _boyBtn.tag = 100;
    [_boyBtn addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
    [_messageScrollView addSubview:_boyBtn];
    
    _girlBtn = [self messageBtn:CGRectMake(iPhoneWidth/2 + 10, CGRectGetMaxY(sexLabel.frame) + 3, iPhoneWidth/2 - 30, 52) withTitle:@"女"];
    _girlBtn.layer.borderColor = bordorColor.CGColor;
    _girlBtn.tag = 101;
    [_girlBtn addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
    [_messageScrollView addSubview:_girlBtn];
    
    
    float btnWidth = (iPhoneWidth - 60)/3;
    
    //睡眠偏好
    UILabel *sleepLabel = [self secondTextLabel:CGRectMake(20, CGRectGetMaxY(_boyBtn.frame) + 10 , 100, 20) labelText:@"睡眠偏好" textAlignment:NSTextAlignmentLeft];
    [_messageScrollView addSubview:sleepLabel];
    
    NSArray *pianHaoArr = @[@"侧睡",@"仰睡",@"混合"];
    for (int i = 0 ; i < 3; i++) {
        UIButton *btn = [self messageBtn:CGRectMake(20 + i%3*(btnWidth + 10), CGRectGetMaxY(sleepLabel.frame) + 3, btnWidth, 52) withTitle:pianHaoArr[i]];
        btn.layer.borderColor = bordorColor.CGColor;
        btn.tag = 200 + i;
        [btn addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_messageScrollView addSubview:btn];
        if (i == 0) {
            btn.selected = YES;
            btn.layer.borderColor = highBorderColor.CGColor;
        }
    }
    
    //年龄
    UILabel *neckLabel = [self secondTextLabel:CGRectMake(20, CGRectGetMaxY(sleepLabel.frame) + 65 , 100, 20) labelText:@"颈围" textAlignment:NSTextAlignmentLeft];
    [_messageScrollView addSubview:neckLabel];

    UIView *neckView = [self bgView:CGRectMake(20, CGRectGetMaxY(neckLabel.frame) + 3, iPhoneWidth - 40, 52)];
    [_messageScrollView addSubview:neckView];
    _neckField = [self inputField:CGRectMake(14, 13, neckView.frame.size.width - 28, 26) placeholder:@"请输入颈围"];
    _neckField.keyboardType = UIKeyboardTypeDecimalPad;
    [neckView addSubview:_neckField];
    
    //肩宽
    UILabel *shoulderLabel = [self secondTextLabel:CGRectMake(20, CGRectGetMaxY(neckView.frame) + 10 , 100, 20) labelText:@"肩宽" textAlignment:NSTextAlignmentLeft];
    [_messageScrollView addSubview:shoulderLabel];
    
    NSArray *shoulderArr = @[@"较窄",@"适中",@"较宽"];
    for (int i = 0 ; i < 3; i++) {
        UIButton *btn = [self messageBtn:CGRectMake(20 + i%3*(btnWidth + 10), CGRectGetMaxY(shoulderLabel.frame) + 3, btnWidth, 52) withTitle:shoulderArr[i]];
        btn.layer.borderColor = bordorColor.CGColor;
        btn.tag = 300 + i;
        [btn addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_messageScrollView addSubview:btn];
        if (i == 1) {
            btn.selected = YES;
            btn.layer.borderColor = highBorderColor.CGColor;
        }
    }
    
    //背部
    UILabel *backLabel = [self secondTextLabel:CGRectMake(20, CGRectGetMaxY(shoulderLabel.frame) + 65 , 100, 20) labelText:@"背部" textAlignment:NSTextAlignmentLeft];
    [_messageScrollView addSubview:backLabel];
    
    NSArray *backArr = @[@"较薄",@"适中",@"微驼"];
    for (int i = 0 ; i < 3; i++) {
        UIButton *btn = [self messageBtn:CGRectMake(20 + i%3*(btnWidth + 10), CGRectGetMaxY(backLabel.frame) + 3, btnWidth, 52) withTitle:backArr[i]];
        btn.layer.borderColor = bordorColor.CGColor;
        btn.tag = 400 + i;
        [btn addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_messageScrollView addSubview:btn];
        if (i == 1) {
            btn.selected = YES;
            btn.layer.borderColor = highBorderColor.CGColor;
        }
    }
    
    //床垫
    UILabel *bedLabel = [self secondTextLabel:CGRectMake(20, CGRectGetMaxY(backLabel.frame) + 65 , 100, 20) labelText:@"床垫" textAlignment:NSTextAlignmentLeft];
    [_messageScrollView addSubview:bedLabel];
    
    NSArray *bedArr = @[@"较软",@"适中",@"较硬"];
    for (int i = 0 ; i < 3; i++) {
        UIButton *btn = [self messageBtn:CGRectMake(20 + i%3*(btnWidth + 10), CGRectGetMaxY(bedLabel.frame) + 3, btnWidth, 52) withTitle:bedArr[i]];
        btn.layer.borderColor = bordorColor.CGColor;
        btn.tag = 500 + i;
        [btn addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_messageScrollView addSubview:btn];
        if (i == 1) {
            btn.selected = YES;
            btn.layer.borderColor = highBorderColor.CGColor;
        }
    }

    
    UIButton *adviceBtn = [self messageBtn:CGRectMake(20, CGRectGetMaxY(bedLabel.frame) + 65, iPhoneWidth - 40, 52) withTitle:@"查看建议"];
    adviceBtn.layer.borderColor = highBorderColor.CGColor;
    adviceBtn.selected = YES;
    [adviceBtn addTarget:self action:@selector(showAdviceView) forControlEvents:UIControlEventTouchUpInside];
    [_messageScrollView addSubview:adviceBtn];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.backgroundColor = [UIColor whiteColor];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    okBtn.layer.cornerRadius = 12.0;
    okBtn.layer.masksToBounds = YES;
    [okBtn addTarget:self action:@selector(saveUserMessage) forControlEvents:UIControlEventTouchUpInside];
    [_messageScrollView addSubview:okBtn];
    
    BLEManager *manager = [BLEManager shareInstance];
    if (manager.mode == PillowNormal) {
        
        _messageScrollView.contentSize = CGSizeMake(iPhoneWidth, iPhoneHeight + 260);
        
        UIView *pillowAdviceView = [self adviceView:CGRectMake(20, CGRectGetMaxY(adviceBtn.frame) + 10, iPhoneWidth - 40, 264)];
        [_messageScrollView addSubview:pillowAdviceView];
        
        okBtn.frame = CGRectMake(20, CGRectGetMaxY(pillowAdviceView.frame) + 20, iPhoneWidth - 40, 56);
    }else{
        _messageScrollView.contentSize = CGSizeMake(iPhoneWidth, iPhoneHeight);
        okBtn.frame = CGRectMake(20, CGRectGetMaxY(adviceBtn.frame) + 20, iPhoneWidth - 40, 56);
    }
        
    
    [self creatNavigatiocnBar];
}

- (void)creatNavigatiocnBar
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:[UIImage systemImageNamed:@"chevron.backward"] forState:UIControlStateNormal];
    backBtn.tintColor = secondTextColor;
    backBtn.frame = CGRectMake(30, STATUS_BAR_HEIGHT + 30, 9, 18);
    [backBtn addTarget:self action:@selector(backToLastPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(iPhoneWidth/2 - 100, STATUS_BAR_HEIGHT + 28, 200, 22);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"编辑个人信息";
    [self.view addSubview:titleLabel];
    
    
    
}

- (void)backToLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)optionSelected:(UIButton *)sender
{
    NSInteger group = sender.tag / 100;
    for (UIView *subview in self.messageScrollView.subviews) {
        if (![subview isKindOfClass:[UIButton class]]) {
            continue;
        }
        UIButton *button = (UIButton *)subview;
        if (button.tag / 100 == group) {
            button.selected = (button == sender);
            button.layer.borderColor = button.selected ? highBorderColor.CGColor : bordorColor.CGColor;
        }
    }
}

- (void)showAdviceView
{
    CGFloat targetY = MAX(0, self.messageScrollView.contentSize.height - self.messageScrollView.bounds.size.height);
    [self.messageScrollView setContentOffset:CGPointMake(0, targetY) animated:YES];
}

- (void)saveUserMessage
{
    if (self.heightField.text.length == 0 || self.weightField.text.length == 0 || self.ageField.text.length == 0) {
        [MJProgressHUD onlyShowMessage:@"请完善身高、体重和年龄" afterDelay:1.0 showAddTo:self.view];
        return;
    }
    [MJProgressHUD onlyShowMessage:@"已保存个人信息" afterDelay:1.0 showAddTo:self.view];
}




#pragma mark - 二级标题Label
- (UILabel *)secondTextLabel:(CGRect )frame labelText:(NSString *)text textAlignment:(NSTextAlignment )alignment
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = secondTextColor;
    label.textAlignment = alignment;
    label.font = [UIFont systemFontOfSize:12.0];
    label.text = text;
    return label;
}


- (UIView *)bgView:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = labelBGColor;
    view.layer.borderColor = bordorColor.CGColor;
    view.layer.cornerRadius  = 12.0;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = 1.0;
    return view;
}

- (UITextField *)inputField:(CGRect)frame placeholder:(NSString *)placeholder
{
    UITextField *field = [[UITextField alloc] initWithFrame:frame];
    field.borderStyle = UITextBorderStyleNone;
    field.textColor = [UIColor whiteColor];
    field.font = [UIFont systemFontOfSize:15.0];
    field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: secondTextColor}];
    return field;
}

- (UIButton *)messageBtn:(CGRect)frame withTitle:(NSString *)title
{
    UIImage *normalImage = [[ToolHexManager sharedManager] imageWithColor:[UIColor colorWithValue:@"#1a1a1a"]];
    UIImage *highImage = [[ToolHexManager sharedManager] imageWithColor:highBgColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.layer.cornerRadius = 12.0;
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = 1.0;
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [btn setBackgroundImage:highImage forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:highColor forState:UIControlStateSelected];
    return btn;
}


//查看建议
- (UIView *)adviceView:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithValue:@"#27272a"];
    view.layer.cornerRadius = 16.0;
    view.layer.masksToBounds = YES;
    
    _sideLySlider = [[PillowSlider alloc] initWithFrame:CGRectMake(0, 10, iPhoneWidth - 40, 80)];
    _sideLySlider.title = @"侧睡高度";
    [view addSubview:_sideLySlider];
    
    _supineSlider = [[PillowSlider alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_sideLySlider.frame), iPhoneWidth - 40, 80)];
    _supineSlider.title = @"仰睡高度";
    [view addSubview:_supineSlider];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(20, CGRectGetMaxY(_supineSlider.frame) + 5, iPhoneWidth - 80, 48);
    okBtn.backgroundColor = [UIColor whiteColor];
    [okBtn setTitle:@"遵从推荐" forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    okBtn.layer.cornerRadius = 12.0;
    okBtn.layer.masksToBounds = YES;
    [view addSubview:okBtn];
    
    return view;
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
