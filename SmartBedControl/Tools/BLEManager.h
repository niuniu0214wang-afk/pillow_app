//
//  BLEManager.h
//  SmartHouseYCT
//
//  Created by 刘飞 on 2019/10/26.
//  Copyright © 2019 余长涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN

@protocol bleManagerDelegate <NSObject>
@optional

//蓝牙状态改变
- (void)CBManagerStateChanged:(CBManagerState)state;

//设备搜索结果
- (void)didScanResultDevices:(NSArray *)deviceArr;

//连接成功
- (void)didConnectedSuccessful:(CBPeripheral *)peripheral;

//连接失败
- (void)didConnectedFaild:(CBPeripheral *)peripheral;

//连接断开
- (void)didDisconnected:(CBPeripheral *)peripheral;

//特征回调成功
- (void)writeCharacteristicDiscoverdSuccess:(CBPeripheral *)peripheral;

//获取到的数据
- (void)didReceiveData:(NSData *)data;
- (void)didReceiveMessage:(NSString *)dataString;
- (void)didReceiveDict:(NSDictionary *)dict;
@end

@interface BLEManager : NSObject
@property (strong, nonatomic) CBCentralManager *centraManager;
@property (strong, nonatomic) CBPeripheral *myPeripheral;
@property (strong, nonatomic) CBCharacteristic *notifCharacteristic;
@property (strong, nonatomic) CBCharacteristic *writeCharacteristic;
@property (strong, nonatomic) NSMutableArray *tempArr;
@property (assign, nonatomic) BOOL isStart;
@property (weak, nonatomic) id<bleManagerDelegate> delegate;


@property (assign, nonatomic) BOOL isFirstBed;  //暂时用
@property (assign, nonatomic) BedMode mode;

@property (copy, nonatomic) NSString *userID;
@property (strong, nonatomic) NSDictionary *parmarDict;


@property (strong, nonatomic) NSString *deviceName; //添加蓝牙时扫描的蓝牙名称

+ (id)shareInstance;

//搜索设备
- (void)didStartScanDevice:(BOOL)isAdd;

//停止搜索
- (void)didStopScanDevice;

//连接设备
- (void)didConnectDevice:(CBPeripheral *)currentPeripheral;

//重连设备
- (void)reConnectedDevice:(CBPeripheral *)disPeripheral;

//断开连接
//- (void)didCancelConnect:(CBPeripheral *)peripheral;
- (void)didCancelConnect;

//发送数据

- (void)didSendMessageToDevice:(NSData *)data;
//- (void)didSendMessageToDevice:(NSData *)data withPeripheral:(CBPeripheral *)per;



//清空设备
- (void)clearAllDevice;

@end

NS_ASSUME_NONNULL_END
