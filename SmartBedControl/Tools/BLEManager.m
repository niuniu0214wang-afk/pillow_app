//
//  BLEManager.m
//  SmartHouseYCT
//
//  Created by 刘飞 on 2019/10/26.
//  Copyright © 2019 余长涛. All rights reserved.
//

#import "BLEManager.h"
//#import "BLEDataUpakAndPack.h"

@interface BLEManager ()<CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate>

@property (strong, nonatomic) NSMutableArray *deviceArr;
@property (strong, nonatomic) NSMutableData *holdData;
@property (assign, nonatomic) BOOL isAdd;       //是否为添加设备

//寄存器数组
@property (strong, nonatomic) NSMutableArray *registerArr;
@end

@implementation BLEManager

+ (instancetype)shareInstance
{
    static BLEManager *bleManager;
    static dispatch_once_t oneceToken;
    dispatch_once(&oneceToken, ^{
        bleManager = [[BLEManager alloc] init];
    });
    
    return bleManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.centraManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.deviceArr = [[NSMutableArray alloc] init];
        self.registerArr = [[NSMutableArray alloc] init];
        self.holdData = [[NSMutableData alloc] init];
    }
    return self;
}


#pragma mark - CBCentralManagerDelegate
//确认centraManager的状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:
        {
            NSLog(@">>>>>CBManagerStateUnknown");
        }
            break;
        case CBManagerStateResetting:
        {
            NSLog(@">>>>>CBManagerStateResetting");
        }
            break;
        case CBManagerStateUnsupported:
        {
            NSLog(@">>>>>CBManagerStateUnsupported");
        }
            break;
        case CBManagerStateUnauthorized:
        {
            NSLog(@">>>>>CBManagerStateUnauthorized");
        }
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@">>>>>CBManagerStatePoweredOff");
        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@">>>>>CBManagerStatePoweredOn");
            _isStart = YES;
        }
            break;
            
        default:
            break;
    }
    
    if (self.delegate && [_delegate respondsToSelector:@selector(CBManagerStateChanged:)]) {
        [self.delegate CBManagerStateChanged:central.state];
    }
}


- (void)didStartScanDevice:(BOOL)isAdd
{
    self.isAdd = isAdd;
    NSLog(@"开始搜索");
    if (_deviceArr.count > 0) {
        [_deviceArr removeAllObjects];
    
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didScanResultDevices:)]) {
        [_delegate didScanResultDevices:_deviceArr];
    }
    
    [self.centraManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    //[self.centraManager scanForPeripheralsWithServices:nil options:nil];
}


//搜索设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI
{
    
    NSLog(@"peripheral is %@",peripheral.name);
    
    if ([peripheral.name containsString:self.deviceName]) {
        //先关闭NSLog(@"搜索到的设备id-------%@",peripheral.identifier);
        NSLog(@"Find device:%@ 扫描到的相关数据------%@\n RSSI is %d",peripheral.name,advertisementData,RSSI.intValue);
        
        if (advertisementData[@"kCBAdvDataManufacturerData"]) {
            NSData *data = advertisementData[@"kCBAdvDataManufacturerData"];
            NSString *hexDataStr = [[ToolHexManager sharedManager] convertDataToHexStr:data];
            NSString *mac = [hexDataStr substringFromIndex:4];
            NSLog(@"获取到的设备mac地址是-----%@",mac);
            
            if ([self localHasThisBed:mac] && self.isAdd == YES) {
                
            }else{
                NSDictionary *dict = @{@"device":peripheral,@"mac":mac};
                
                if (![_deviceArr containsObject:dict] || _deviceArr.count == 0) {
                    NSLog(@"当前搜到的设备个数-------%zd",_deviceArr.count);
                    [_deviceArr addObject:dict];
                    if (_delegate && [_delegate respondsToSelector:@selector(didScanResultDevices:)]) {
                        [_delegate didScanResultDevices:_deviceArr];
                    }
                }
            }
        }
    }
}

- (BOOL)localHasThisBed:(NSString *)mac
{
    
    NSArray *array = [DataCenter shareInstance].deviceArr;
    
    //NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceData"];
    BOOL isHase = NO;
    for (int i = 0; i < array.count; i++) {
        BedModel *bed = array[i];
        if ([bed.mac isEqualToString:mac]) {
            isHase = YES;
            break;
        }
    }
    return isHase;
}




//停止搜索
- (void)didStopScanDevice
{
    NSLog(@"停止搜索");
    [self.centraManager stopScan];
}



//连接设备
- (void)didConnectDevice:(CBPeripheral *)currentPeripheral
{
    //连接选中的设备
    self.myPeripheral = currentPeripheral;
    
    [self.centraManager connectPeripheral:currentPeripheral options:nil];
        
    //
}

//重连设备
- (void)reConnectedDevice:(CBPeripheral *)disPeripheral;
{
    NSArray *disArr = [self.centraManager retrievePeripheralsWithIdentifiers:@[disPeripheral.identifier]];
    if (disArr.count > 0) {
        NSLog(@"这里怎么处理呢");
        //CBPeripheral *per = disArr[0];
        [self.centraManager connectPeripheral:disArr[0] options:nil];
    }
}


//断开连接
- (void)didCancelConnect
{
    [self.centraManager cancelPeripheralConnection:self.myPeripheral];
}

//设备连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //连接成功后停止搜索设备
    NSLog(@"连接成功");
    if (self.delegate && [_delegate respondsToSelector:@selector(didConnectedSuccessful:)]) {
        [self.delegate didConnectedSuccessful:peripheral];
    }
    [self.centraManager stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"连接失败");
    if (_delegate && [_delegate respondsToSelector:@selector(didConnectedFaild:)]) {
        [_delegate didConnectedFaild:peripheral];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    int number = RSSI.intValue;
    NSLog(@"number is %d",number);
}

//断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@断开连接",peripheral.name);
    if (_delegate && [_delegate respondsToSelector:@selector(didDisconnected:)]) {
        [_delegate didDisconnected:peripheral];
    }
    //[self didConnectDevice:peripheral];
}

//搜索外设服务和特征
#pragma mark - CBPeripheralDelegate
//服务回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //FFF0   FFE0
//    NSLog(@"peripheral  服务UUID is %@",peripheral.services);
//    NSLog(@"服务个数-------%ld",peripheral.services.count);
   // CBService * __nullable findService = nil;
    // 遍历服务
    
    //CBService *service = peripheral.services.lastObject;
    for (CBService *service in peripheral.services)
    {
        NSLog(@"发现的是服务------%@",service);
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:@"FFF0"]])
        {
            [peripheral discoverCharacteristics:NULL forService:service];
        }
    }

}


//特征回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"外设特征---------%@  个数   %ld",service.characteristics,service.characteristics.count);
    for (CBCharacteristic *characterist in service.characteristics) {
//        if ([[characterist UUID] isEqual:[CBUUID UUIDWithString:@"7FC9000E-5087-4B5E-B3E0-F8AA3DD40EF9"]]) {
//            //[peripheral readValueForCharacteristic:characterist];
//            self.writeCharacteristic = characterist;
//        }
//        if ([[characterist UUID] isEqual:[CBUUID UUIDWithString:@"7FC9000D-5087-4B5E-B3E0-F8AA3DD40EF9"]]) {
//            self.notifCharacteristic = characterist;
//            [peripheral setNotifyValue:YES forCharacteristic:characterist];
//        }
        
        if (characterist.properties & CBCharacteristicPropertyRead) {
            // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
            [peripheral readValueForCharacteristic:characterist];
            NSLog(@"------读取");
        }
        if ((characterist.properties & CBCharacteristicPropertyNotify) || (characterist.properties & CBCharacteristicPropertyIndicate)) {
                    // 订阅通知
            NSLog(@"------监听");
            self.notifCharacteristic = characterist;
            [peripheral setNotifyValue:YES forCharacteristic:characterist];
        }
        if (characterist.properties & CBCharacteristicPropertyWrite) {
            NSLog(@"Properties is Write");
            self.writeCharacteristic = characterist;
        }
        

        //[peripheral discoverDescriptorsForCharacteristic:characterist];
    }
    

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error == nil) {
        if (characteristic.isNotifying) {
            NSLog(@"订阅成功  可以写数据了");
            if (_delegate && [_delegate respondsToSelector:@selector(writeCharacteristicDiscoverdSuccess:)]) {
                [_delegate writeCharacteristicDiscoverdSuccess:peripheral];
            }
//            NSData *writeData = [BLEDataUnpackAndPack deviceOnOrOff:YES];
//            [self didSendMessageToDevice:writeData];
        }
    }
}


#pragma mark - 获取数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (![characteristic isEqual:self.writeCharacteristic]) {
        
    }
    if (![characteristic isEqual:self.notifCharacteristic]) {
        return;
    }
    if (error == nil) {
        NSData *jsonData = characteristic.value;
        NSLog(@"获取到的设备h数据是--------%@",jsonData);
        if (jsonData.length > 0) {
            [[ControlCenter shareInstance] unPackData:jsonData];
        }
        
    }
    
}


//- (void)getValue:(NSData *)data
//{
//    NSLog(@"获取到的初始数据---------%@",data);
////    
//////    NSArray *deviceArr = [self.centraManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"7FC9000C-5087-4B5E-B3E0-F8AA3DD40EF9"]]];
//////    for (int i = 0; i < deviceArr.count; i++) {
//////        CBPeripheral *per = deviceArr[i];
//////        NSLog(@"当前连接着的设备-------%@",per);
//////    }
//    NSDictionary *dataDict = [BLEDataUnpackAndPack uppackDataPack:data];
//    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveDict:)]) {
//        [_delegate didReceiveDict:dataDict];
//    }
//}

//写入数据
- (void)didSendMessageToDevice:(NSData *)data
{
    if (self.writeCharacteristic.properties & CBCharacteristicPropertyWrite) {
        [self.myPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    
    if (self.writeCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
        [self.myPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

//发送数据
- (void)didSendMessageToDevice:(NSData *)data withPeripheral:(CBPeripheral *)per
{
    if (self.writeCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
        [per writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
}


//清空数据
- (void)clearAllDevice
{
    [self.deviceArr removeAllObjects];
}

@end
