//
//  PersonController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/7.
//

#import "PersonController.h"
#import "../Views/SetCell.h"

@interface PersonController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *userTableView;
@property (strong, nonatomic) NSArray *tableData;
@end

@implementation PersonController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableData = @[@{@"title":@"使用人",@"icon":@"user"},@{@"title":@"性别",@"icon":@"sex"},@{@"title":@"更换使用人",@"icon":@"changeUser"}];
    
    self.view.backgroundColor = [UIColor colorWithValue:@"#070F25"];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, iPhoneWidth, SCALE(455));
    imageView.image = [UIImage imageNamed:@"jianbian"];
    [self.view addSubview:imageView];
    
    _userTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_HEIGHT + 30, iPhoneWidth, iPhoneHeight - NAVIGATION_HEIGHT - safeBottom)];
    _userTableView.backgroundColor = [UIColor clearColor];
    _userTableView.delegate = self;
    _userTableView.dataSource = self;
    [self.view addSubview:_userTableView];
    
    [_userTableView registerNib:[UINib nibWithNibName:@"SetCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userCell"];
    
    
    [self creatNavgationBar];
    
}


- (void)creatNavgationBar
{
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, STATUS_BAR_HEIGHT + 14, 10, 16);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iPhoneWidth/2 - 75, STATUS_BAR_HEIGHT + 7, 150, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:17.0];
    label.textColor = [UIColor whiteColor];
    label.text = @"用户信息";
    [self.view addSubview:label];
    
//    UIButton *btn  = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(iPhoneWidth - 50, STATUS_BAR_HEIGHT + 7, 25, 25);
//    [btn setBackgroundImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
//    [btn setTintColor:[UIColor whiteColor]];
//    [btn addTarget:self action:@selector(deviceSetPage) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    
}

- (void)backToViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 76;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 76)];
    view.backgroundColor = [UIColor clearColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 8, iPhoneWidth - 40, 46);
    btn.backgroundColor = [UIColor redColor];
    btn.layer.cornerRadius = 10;
    btn.layer.masksToBounds = YES;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"解除使用权" forState:UIControlStateNormal];
    [view addSubview:btn];
    
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SetCell *cell = (SetCell *)[tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dic = _tableData[indexPath.row];
    
    cell.cell_icon.image = [UIImage imageNamed:dic[@"icon"]];
    cell.cell_title.text = dic[@"title"];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
