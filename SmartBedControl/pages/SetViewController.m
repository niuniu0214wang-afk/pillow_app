//
//  SetViewController.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/4.
//

#import "SetViewController.h"
#import "../Views/SetCell.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "../test/TestViewController.h"
#import <CommonCrypto/CommonDigest.h>
@interface SetViewController ()<UITableViewDelegate,UITableViewDataSource,UIDocumentPickerDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSDictionary *cell_dict;
@property (strong, nonatomic) NSArray *cell_arr;
@end

@implementation SetViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    
    _cell_arr = @[@{@"name":@"设备名称",@"image":@"name"},@{@"name":@"房间",@"image":@"room"},@{@"name":@"意见与反馈",@"image":@"feed"},@{@"name":@"设备号",@"image":@"number"},@{@"name":@"版本号",@"image":@"version"}];
    
    
    self.view.backgroundColor = [UIColor colorWithValue:@"#070F25"];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, iPhoneWidth, SCALE(455));
    imageView.image = [UIImage imageNamed:@"jianbian"];
    [self.view addSubview:imageView];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_HEIGHT + 15, iPhoneWidth, iPhoneHeight)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"SetCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"setCell"];
    [self creatNavgationBar];
    
}


- (void)creatNavgationBar
{
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, STATUS_BAR_HEIGHT + 14, 15, 24);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

- (void)backToViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cell_arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = _cell_arr[indexPath.row];
    SetCell *cell = (SetCell *)[tableView dequeueReusableCellWithIdentifier:@"setCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cell_icon.image = [UIImage imageNamed:dict[@"image"]];
    cell.cell_title.text = dict[@"name"];
    if (indexPath.row == 0) {
        cell.cell_label.text = self.bed.bedName;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UIAlertController *aler = [UIAlertController alertControllerWithTitle:nil message:@"请输入床垫名称" preferredStyle:UIAlertControllerStyleAlert];
        [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"名称";
        }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *field = aler.textFields.firstObject;
            if (field.text.length < 1 || [field.text isEqualToString:@""]) {
                [MJProgressHUD onlyShowMessage:@"请输入床垫名称" afterDelay:1.0 showAddTo:self.view];
                return;
            }
            
            if (field.text.length > 14) {
                [MJProgressHUD onlyShowMessage:@"名称太长了" afterDelay:1.0 showAddTo:self.view];
                return;
            }
            
            
            if ([[DataCenter shareInstance] editBedName:self.bed withName:field.text]) {
                NSLog(@"修改名称成功");
                self.bed.bedName = field.text;
                SetCell *cell = (SetCell *)[tableView cellForRowAtIndexPath:indexPath];
                cell.cell_label.text = field.text;
                
                NSMutableArray *array = [DataCenter shareInstance].deviceArr.mutableCopy;
                for (BedModel *bed in array) {
                    if ([bed.mac isEqualToString:self.bed.mac]) {
                        NSInteger index = [array indexOfObject:bed];
                        [array replaceObjectAtIndex:index withObject:self.bed];
                        break;
                    }
                }
                [DataCenter shareInstance].deviceArr = array.copy;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadBedName" object:field.text];
            }else{
                NSLog(@"修改名称失败");
            }            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [aler addAction:okAction];
        [aler addAction:cancelAction];
        [self presentViewController:aler animated:YES completion:nil];
    }
    
    if (indexPath.row == 1) {
        
    }
    
    
//    if (indexPath.row == 4) {
//        NSArray *allowedTypes = @[UTTypeData, UTTypeItem, UTTypeImage]; // 可根据需要限定具体类型
//            UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
//                                                      initForOpeningContentTypes:allowedTypes
//                                                      asCopy:YES]; // 使用asCopy:YES获取副本
//            
//            picker.delegate = self;
//            picker.allowsMultipleSelection = NO;
//            [self presentViewController:picker animated:YES completion:nil];
//    }
    
//    if (indexPath.row == 1) {
//        TestViewController *testVC = [[TestViewController alloc] init];
//        [self.navigationController pushViewController:testVC animated:YES];
//    }
}


// 处理文件选择结果
- (void)documentPicker:(UIDocumentPickerViewController *)controller
  didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    
    NSURL *fileURL = urls.firstObject;
    if (!fileURL) return;
    
    // 开始访问安全作用域（关键！）
    BOOL success = [fileURL startAccessingSecurityScopedResource];
    NSFileManager *fm = [NSFileManager defaultManager];
    // 检查文件是否存在
        if (![fm fileExistsAtPath:fileURL.path]) {
            NSLog(@"文件不存在: %@", fileURL.path);
           
        }else{
            NSLog(@"文件存在: %@", fileURL.path);
        }
        
        // 检查文件是否可读
        if (![fm isReadableFileAtPath:fileURL.path]) {
            NSLog(@"文件不可读: %@", fileURL.path);
            
        }else{
            NSLog(@"文件可读: %@", fileURL.path);
        }
        
        // 获取文件属性
        NSError *error = nil;
        NSDictionary *attributes = [fm attributesOfItemAtPath:fileURL.path error:&error];
        if (error) {
            NSLog(@"无法获取文件属性: %@", error);
           
        }else{
            NSLog(@"获取到文件属性");
        }
    
    if (success) {
        NSError *error = nil;
        NSData *firmwareData = [NSData dataWithContentsOfURL:fileURL
                                                      options:NSDataReadingMappedIfSafe
                                                        error:&error];
        if (firmwareData) {
            NSString *fileName = fileURL.lastPathComponent;
            NSLog(@"成功读取升级文件: %@，大小: %lu 字节", fileName, (unsigned long)firmwareData.length);
            NSLog(@"读取到的数据是-----%@",firmwareData);
            
            for (int i = 0; i < 20; i++) {
                NSRange range = NSMakeRange(i*30, 30);
                NSData *data = [firmwareData subdataWithRange:range];
                NSLog(@"截取到的数据是------%@",data);
            }
            
            // 保存文件数据，准备升级
//            self.firmwareData = firmwareData;
//            self.firmwareFileName = fileName;
//            
//            // 可以校验文件完整性（如MD5、CRC等）
//            [self verifyFirmwareIntegrity:firmwareData];
//            
//            // 开始蓝牙升级流程
//            [self startOTAUpdate];
        } else {
            NSLog(@"读取文件失败: %@", error.localizedDescription);
        }
        
        // 重要：停止访问安全作用域
        [fileURL stopAccessingSecurityScopedResource];
    }
}

- (NSString *)md5OfFileAtPath:(NSString *)filePath {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (!fileHandle) {
        NSLog(@"无法打开文件: %@", filePath);
        return nil;
    }
    
    // 初始化 MD5 上下文
    CC_MD5_CTX md5Context;
    CC_MD5_Init(&md5Context);
    
    // 分块读取文件，避免内存溢出
    NSData *data;
    while ((data = [fileHandle readDataOfLength:4096]).length > 0) {
        CC_MD5_Update(&md5Context, data.bytes, (CC_LONG)data.length);
    }
    
    [fileHandle closeFile];
    
    // 计算最终 MD5 值
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5Context);
    
    // 转换为十六进制字符串
    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", digest[i]];
    }
    
    return [md5String copy];
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
