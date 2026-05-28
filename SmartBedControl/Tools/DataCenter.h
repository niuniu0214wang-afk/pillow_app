//
//  DataCenter.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/7.
//

#import <Foundation/Foundation.h>
#import "../data/BedModel.h"
#import "../data/PersonModel.h"

NS_ASSUME_NONNULL_BEGIN




@interface DataCenter : NSObject

//@property (assign, nonatomic) CBPeripheralState state;  //记录设备的连接状态
@property (strong, nonatomic) BedModel *connectedBed;   //记录当前连接的设备
@property (strong, nonatomic) CBPeripheral *connectPer; //记录当前连接的设备


@property (strong, nonatomic) NSArray *deviceArr;       //本次打开app获取到的设备列表

+ (instancetype)shareInstance;


//打开数据库
- (BOOL)openDB;

//创建床垫列表
- (BOOL)creatBedTable;

//创建用户列表
- (BOOL)creatPersonTable;

//增加床垫信息
- (BOOL)addBed:(BedModel *)bed;

//修改床垫名称
- (BOOL)editBedName:(BedModel *)bed withName:(NSString *)newName;

//修改床垫使用人
- (BOOL)editBedPerson:(BedModel *)bed withUserID:(int)userID withBedSide:(NSString *)side;

//删除床信息
- (BOOL)deleteBed:(BedModel *)bed;

//获取床列表
- (NSArray<BedModel *> *)getAllBeds;


//增加用户信息
- (void)addPerson:(PersonModel *)person;

//修改用户信息
- (void)editPerson:(PersonModel *)person;

//删除用户信息
- (void)deletePerson:(PersonModel *)person;

//获取用户列表
- (NSArray<PersonModel *> *)getAllPersons;

//关闭数据库
- (void)closeDB;



@end

NS_ASSUME_NONNULL_END
