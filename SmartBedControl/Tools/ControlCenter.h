//
//  ControlCenter.h
//  EonHome
//
//  Created by 刘飞 on 2026/1/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ControlCenter : NSObject


@property (strong, nonatomic) NSDictionary *personDict;
@property (strong, nonatomic) NSDictionary *headHightData;
@property (strong, nonatomic) NSDictionary *bodyHardnessData;
@property (strong, nonatomic) NSDictionary *dataDict;
@property (strong, nonatomic) NSArray *nicknames;
@property (strong, nonatomic) NSDictionary *messageDict;
@property (strong, nonatomic) NSString *respondMessage;
@property (strong, nonatomic) NSDictionary *respondDict;
@property (strong, nonatomic) NSDictionary *versionDict;



+ (id)shareInstance;

//+ (NSData *)testData:(NSString *)name userWeight:(int )weight;
+ (NSData *)testData;;

//增加用户
+ (NSData *)addUerMessage:(NSString *)name userWeight:(int )weight userHeight:(int)height userAge:(int )age userSex:(NSString *)sex bedSide:(NSString *)side;

//获取单个用户
+ (NSData *)getOneUser:(NSString *)userID;

//获取用户列表
+ (NSData *)getUserList;

//修改用户
+ (NSData *)editUerMessage:(NSString *)userID nickName:(NSString *)name userWeight:(int )weight userHeight:(int)height userAge:(int )age userSex:(NSString *)sex bedSide:(NSString *)side;




//调节头部高度
+ (NSData *)controlHeadHight:(NSString *)direction lyPosture:(NSString *)posture headHight:(int)hight person:(NSString *)userID;

//获取身体部位软硬度
+ (NSData *)getBodyHardness:(NSString *)direction person:(NSString *)userID;

//调节身体部位硬度
+ (NSData *)controlBodyHardness:(NSString *)direction hardnessParmar:(NSDictionary *)parmar person:(NSString *)userID;


//+ (NSData *)controlHardness:(NSString *)side hardnessParmar:(NSDictionary *)parmar person:(NSString *)userID bedModel:(BedMode)model bodyPart:(bodyType)body leiPose:(NSString *)pose;

//获取AI策略
+ (NSData *)getSmartTactic:(NSString *)direction person:(NSString *)userID;

//设置AI策略
+ (NSData *)controlSmartTactic:(NSString *)direction bedHardness:(NSString *)hardness smartAntisnoring:(BOOL)isSmart bodyAdaptive:(BOOL)isOpen headAdaptive:(BOOL)isOn person:(NSString *)userID;

//系统升级
+ (NSData *)systeamUpload;

//获取调节模式
+ (NSData *)getAdjustModel;

//手动自动调节
+ (NSData *)adjustType:(NSString *)type bedSide:(nonnull NSString *)side;




//单部位调节
+ (NSData *)controlBodyPart:(NSString *)userID  bodyPart:(int )part bedSide:(NSString *)side bodyPose:(NSString *)pose hardLevel:(int)level;

//快速调节
+ (NSData *)controlBedQuick:(NSString *)userID  bedSide:(NSString *)side bodyPose:(NSString *)pose bedHardLevel:(int)level;



#pragma mark - 枕头控制指令
//单气囊控制
+ (NSData *)controlPillowAirBag:(int)index pressureValue:(int)value;

//单区域控制
+ (NSData *)controlPillowArea:(int)area pressureValue:(int)value;

//设置阈值
+ (NSData *)savePillowPressure:(NSString *)pose pillowArea:(int)area pressureValue:(int)value;


//数据解包
- (void)unPackData:(NSData *)data;
//- (void)unPackData:(NSString *)data;

@end

NS_ASSUME_NONNULL_END
