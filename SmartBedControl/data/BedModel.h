//
//  BedModel.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BedModel : NSObject


@property (strong, nonatomic) CBPeripheral *myPer;      //蓝牙设备
@property (strong, nonatomic) CBCharacteristic *myCharacteristic;   //通讯服务
@property (assign, nonatomic) NSInteger bedID;          //床垫id
@property (strong, nonatomic) NSString *mac;            //mac地址
@property (assign, nonatomic) BedMode mode;             //型号
@property (strong, nonatomic) NSString *bedName;        //床的名字
@property (assign, nonatomic) CBPeripheralState state;  //床的连接状态
@property (assign, nonatomic) int letfUser;             //左床使用人
@property (assign, nonatomic) int rightUser;            //右床使用人
@end

NS_ASSUME_NONNULL_END
