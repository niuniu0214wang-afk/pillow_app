//
//  ControlCenter.m
//  EonHome
//
//  Created by 刘飞 on 2026/1/5.
//

#import "ControlCenter.h"

@implementation ControlCenter


+ (instancetype)shareInstance
{
    static ControlCenter *dataManager;
    static dispatch_once_t oneceToken;
    dispatch_once(&oneceToken, ^{
        dataManager = [[ControlCenter alloc] init];
    });
    
    return dataManager;
}


//调节头部高度
+ (NSData *)controlHeadHight:(NSString *)direction lyPosture:(NSString *)posture headHight:(int)hight person:(nonnull NSString *)userID;
{
    
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F7 08 %@",userID];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 5);
    pWrite += 5;
    length += 5;
    
    
    NSString *locationStr = [NSString stringWithFormat:@"%@ %@",posture,direction];
    NSData *dataLocationMixed = [self dataWithHexString:locationStr];
    unsigned char *pLocation = (unsigned char *)[dataLocationMixed  bytes];
    memcpy(pWrite, pLocation, 2);
    pWrite += 2;
    length += 2;
    
    NSData *hightData = [NSData dataWithBytes:&hight length:sizeof(hight)];
    unsigned char *pHightData = (unsigned char *)[hightData bytes];
    memcpy(pWrite, pHightData, 1);
    pWrite += 1;
    length += 1;
    
    NSString *otherStr = [NSString stringWithFormat:@"FF FF FF FF"];
    NSData *otherData = [self dataWithHexString:otherStr];
    unsigned char *pOther = (unsigned char *)[otherData  bytes];
    memcpy(pWrite, pOther, 4);
    pWrite += 4;
    length += 4;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"调节头部高度数据帧------%@",dataWrite);
    return dataWrite;
}

//获取身体部位软硬度
+ (NSData *)getBodyHardness:(NSString *)direction person:(nonnull NSString *)userID
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F6 01 %@",direction];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 5);
    pWrite += 5;
    length += 5;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"获取身体部位压力值数据帧------%@",dataWrite);
    return dataWrite;
}

//调节身体部位硬度
+ (NSData *)controlBodyHardness:(NSString *)direction hardnessParmar:(NSDictionary *)parmar person:(nonnull NSString *)userID
{
    
    //_bodyArr = @[@"shoulder",@"back",@"waist",@"hip",@"leg",@"foot"];
    int shoulder = [parmar[@"shoulder"] intValue];    //肩
    int back = [parmar[@"back"] intValue];        //背
    int waist = [parmar[@"waist"] intValue];       //腰
    int hip = [parmar[@"hip"] intValue];         //臀
    int leg = [parmar[@"leg"] intValue];         //腿
    int foot = [parmar[@"foot"] intValue];        //脚
    
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F7 08 %@",userID];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 5);
    pWrite += 5;
    length += 5;
    
//    NSData *userData = [self dataWithHexString:@"01"];
//    unsigned char *pID = (unsigned char *)[userData  bytes];
//    memcpy(pWrite, pID, 1);
//    pWrite += 1;
//    length += 1;
    
    
    NSData *dataDirectionMixed = [self dataWithHexString:direction];
    unsigned char *pDirection = (unsigned char *)[dataDirectionMixed  bytes];
    memcpy(pWrite, pDirection, 1);
    pWrite += 1;
    length += 1;
    
    NSData *shoulderData = [NSData dataWithBytes:&shoulder length:sizeof(shoulder)];
    unsigned char *pShoulderData = (unsigned char *)[shoulderData bytes];
    memcpy(pWrite, pShoulderData, 1);
    pWrite += 1;
    length += 1;
    
    NSData *backData = [NSData dataWithBytes:&back length:sizeof(back)];
    unsigned char *pBackData = (unsigned char *)[backData bytes];
    memcpy(pWrite, pBackData, 1);
    pWrite += 1;
    length += 1;
    
    NSData *waistData = [NSData dataWithBytes:&waist length:sizeof(waist)];
    unsigned char *pWaistData = (unsigned char *)[waistData bytes];
    memcpy(pWrite, pWaistData, 1);
    pWrite += 1;
    length += 1;
    
    NSData *hipData = [NSData dataWithBytes:&hip length:sizeof(hip)];
    unsigned char *pHipData = (unsigned char *)[hipData bytes];
    memcpy(pWrite, pHipData, 1);
    pWrite += 1;
    length += 1;
    
    NSData *legData = [NSData dataWithBytes:&leg length:sizeof(leg)];
    unsigned char *pLegData = (unsigned char *)[legData bytes];
    memcpy(pWrite, pLegData, 1);
    pWrite += 1;
    length += 1;
    
    NSData *footData = [NSData dataWithBytes:&foot length:sizeof(foot)];
    unsigned char *pFootData = (unsigned char *)[footData bytes];
    memcpy(pWrite, pFootData, 1);
    pWrite += 1;
    length += 1;

    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"设置头部高度数据帧------%@",dataWrite);
    return dataWrite;
}

+ (NSData *)controlHardness:(NSString *)side hardnessParmar:(NSDictionary *)parmar person:(NSString *)userID bedModel:(BedMode )model bodyPart:(bodyType)body  leiPose:(NSString *)pose
{
    //头、肩、腰、臀、脚
    int head = [parmar[@"head"] intValue];          //头、枕
    int shoulder = [parmar[@"shoulder"] intValue];  //肩
    int waist = [parmar[@"waist"] intValue];        //腰
    int hip1 = [parmar[@"hip1"] intValue];            //臀
    int hip2 = [parmar[@"hip2"] intValue];            //臀
    int hip3 = [parmar[@"hip3"] intValue];            //臀
    int hip4 = [parmar[@"hip4"] intValue];            //臀
    int foot = [parmar[@"foot"] intValue];          //脚
    
    if (model == BedPro) {
        head = 255;
        foot = 255;
    }
    
    if (body == head) {
        shoulder = 255;
        waist = 255;
        hip1 = 255;
        hip2 = 255;
        hip3 = 255;
        hip4 = 255;
    }
    
    if (body == Body) {
        pose = @"FF";
    }
    
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number 用户id
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F7 0B %@",userID];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 5);
    pWrite += 5;
    length += 5;
    
    //床侧
    NSData *dataSide = [self dataWithHexString:side];
    unsigned char *pSide = (unsigned char *)[dataSide  bytes];
    memcpy(pWrite, pSide, 1);
    pWrite += 1;
    length += 1;
    
    //姿势
    NSData *dataPose = [self dataWithHexString:pose];
    unsigned char *pPose = (unsigned char *)[dataPose  bytes];
    memcpy(pWrite, pPose, 5);
    pWrite += 1;
    length += 1;
    
    //头
    NSData *headData = [NSData dataWithBytes:&head length:sizeof(head)];
    unsigned char *pHead = (unsigned char *)[headData bytes];
    memcpy(pWrite, pHead, 1);
    pWrite += 1;
    length += 1;
    
    //肩
    NSData *shoulderData = [NSData dataWithBytes:&shoulder length:sizeof(shoulder)];
    unsigned char *pShoulderData = (unsigned char *)[shoulderData bytes];
    memcpy(pWrite, pShoulderData, 1);
    pWrite += 1;
    length += 1;
    
    //腰
    NSData *waistData = [NSData dataWithBytes:&waist length:sizeof(waist)];
    unsigned char *pWaistData = (unsigned char *)[waistData bytes];
    memcpy(pWrite, pWaistData, 1);
    pWrite += 1;
    length += 1;
    
    //臀
    NSData *hipData1 = [NSData dataWithBytes:&hip1 length:sizeof(hip1)];
    unsigned char *pHipData1 = (unsigned char *)[hipData1 bytes];
    memcpy(pWrite, pHipData1, 1);
    pWrite += 1;
    length += 1;
    
    //臀
    NSData *hipData2 = [NSData dataWithBytes:&hip2 length:sizeof(hip2)];
    unsigned char *pHipData2 = (unsigned char *)[hipData2 bytes];
    memcpy(pWrite, pHipData2, 1);
    pWrite += 1;
    length += 1;
    
    //臀
    NSData *hipData3 = [NSData dataWithBytes:&hip3 length:sizeof(hip3)];
    unsigned char *pHipData3 = (unsigned char *)[hipData3 bytes];
    memcpy(pWrite, pHipData3, 1);
    pWrite += 1;
    length += 1;
    
    //臀
    NSData *hipData4 = [NSData dataWithBytes:&hip4 length:sizeof(hip4)];
    unsigned char *pHipData4 = (unsigned char *)[hipData4 bytes];
    memcpy(pWrite, pHipData4, 1);
    pWrite += 1;
    length += 1;

    //脚
    NSData *footData = [NSData dataWithBytes:&foot length:sizeof(foot)];
    unsigned char *pFootData = (unsigned char *)[footData bytes];
    memcpy(pWrite, pFootData, 1);
    pWrite += 1;
    length += 1;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"设置身体参数数据帧------%@",dataWrite);
    return dataWrite;
}



//获取AI策略
+ (NSData *)getSmartTactic:(NSString *)direction person:(nonnull NSString *)userID
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F8 02 %@ %@",userID,direction];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 6);
    pWrite += 6;
    length += 6;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"获取AI策略数据帧------%@",dataWrite);
    return dataWrite;
}

//设置AI策略
+ (NSData *)controlSmartTactic:(NSString *)direction bedHardness:(NSString *)hardness smartAntisnoring:(BOOL)isSmart bodyAdaptive:(BOOL)isOpen headAdaptive:(BOOL)isOn person:(nonnull NSString *)userID
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F9 06 %@",userID];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 5);
    pWrite += 5;
    length += 5;
    
    
    NSString *antisnoring = isSmart == YES ? @"01" : @"00";
    NSString *adaptiveBody = isOpen == YES ? @"01" : @"00";
    NSString *adaptiveHead = isOn == YES ? @"01" : @"00";
    
    NSString *controlStr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",adaptiveHead,adaptiveBody,antisnoring,hardness,direction];
    
    NSData *dataControlMixed = [self dataWithHexString:controlStr];
    unsigned char *pControl = (unsigned char *)[dataControlMixed  bytes];
    memcpy(pWrite, pControl, 5);
    pWrite += 5;
    length += 5;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"获取AI策略数据帧------%@",dataWrite);
    return dataWrite;
}

////系统升级
//+ (NSData *)systeamUpload;


//增加用户
+ (NSData *)addUerMessage:(NSString *)name userWeight:(int )weight userHeight:(int)height userAge:(int )age userSex:(NSString *)sex bedSide:(NSString *)side
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F0"];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 3);
    pWrite += 3;
    length += 3;
    
    //数据长度
    int dataLenght = 5 + (int)name.length;
    NSData *lengthData = [NSData dataWithBytes:&dataLenght length:sizeof(dataLenght)];
    unsigned char *pLength = (unsigned char *)[lengthData bytes];
    memcpy(pWrite, pLength, 1);
    pWrite += 1;
    length += 1;
    
    //性别
    NSData *dataSex= [self dataWithHexString:sex];
    unsigned char *pSex = (unsigned char *)[dataSex  bytes];
    memcpy(pWrite, pSex, 1);
    pWrite += 1;
    length += 1;
    
    
    //年龄
    NSData *ageData = [NSData dataWithBytes:&age length:sizeof(age)];
    unsigned char *pAgeData = (unsigned char *)[ageData bytes];
    memcpy(pWrite, pAgeData, 1);
    pWrite += 1;
    length += 1;
    
    //身高
    NSData *hightData = [NSData dataWithBytes:&height length:sizeof(height)];
    unsigned char *pHightData = (unsigned char *)[hightData bytes];
    memcpy(pWrite, pHightData, 1);
    pWrite += 1;
    length += 1;
    
    //体重
    NSData *weightData = [NSData dataWithBytes:&weight length:sizeof(weight)];
    unsigned char *pWeight = (unsigned char *)[weightData bytes];
    memcpy(pWrite, pWeight, 1);
    pWrite += 1;
    length += 1;
    
    //睡侧
    NSData *dataSide= [self dataWithHexString:side];
    unsigned char *pSide = (unsigned char *)[dataSide  bytes];
    memcpy(pWrite, pSide, 1);
    pWrite += 1;
    length += 1;
    
    //昵称
    NSData *dataName = [name dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char *pName = (unsigned char *)[dataName  bytes];
    memcpy(pWrite, pName, name.length);
    pWrite += name.length;
    length += name.length;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    return dataWrite;
}

//获取单个用户
+ (NSData *)getOneUser:(NSString *)userID
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F1 01 %@",userID];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 5);
    pWrite += 5;
    length += 5;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    return dataWrite;
}

//获取用户列表
+ (NSData *)getUserList
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 FB 01 55"];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 5);
    pWrite += 5;
    length += 5;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"获取用户列表数据------%@",dataWrite);
    return dataWrite;
    
}


//修改用户
+ (NSData *)editUerMessage:(NSString *)userID nickName:(NSString *)name userWeight:(int )weight userHeight:(int)height userAge:(int )age userSex:(NSString *)sex bedSide:(NSString *)side
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F0"];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 4);
    pWrite += 4;
    length += 4;
    
    //数据长度
    int dataLenght = 5 + (int)name.length;
    NSData *lengthData = [NSData dataWithBytes:&dataLenght length:sizeof(dataLenght)];
    unsigned char *pLength = (unsigned char *)[lengthData bytes];
    memcpy(pWrite, pLength, 1);
    pWrite += 1;
    length += 1;
    
    //性别
    NSData *dataID= [self dataWithHexString:userID];
    unsigned char *pID = (unsigned char *)[dataID  bytes];
    memcpy(pWrite, pID, 1);
    pWrite += 1;
    length += 1;
    
    //性别
    NSData *dataSex= [self dataWithHexString:sex];
    unsigned char *pSex = (unsigned char *)[dataSex  bytes];
    memcpy(pWrite, pSex, 1);
    pWrite += 1;
    length += 1;
    
    //年龄
    NSData *ageData = [NSData dataWithBytes:&age length:sizeof(age)];
    unsigned char *pAgeData = (unsigned char *)[ageData bytes];
    memcpy(pWrite, pAgeData, 1);
    pWrite += 1;
    length += 1;
    
    //身高
    NSData *hightData = [NSData dataWithBytes:&height length:sizeof(height)];
    unsigned char *pHightData = (unsigned char *)[hightData bytes];
    memcpy(pWrite, pHightData, 1);
    pWrite += 1;
    length += 1;
    
    //体重
    NSData *weightData = [NSData dataWithBytes:&weight length:sizeof(weight)];
    unsigned char *pWeight = (unsigned char *)[weightData bytes];
    memcpy(pWrite, pWeight, 1);
    pWrite += 1;
    length += 1;
    
    //睡侧
    NSData *dataSide= [self dataWithHexString:side];
    unsigned char *pSide = (unsigned char *)[dataSide  bytes];
    memcpy(pWrite, pSide, 1);
    pWrite += 1;
    length += 1;
    
    //昵称
    NSData *dataName = [name dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char *pName = (unsigned char *)[dataName  bytes];
    memcpy(pWrite, pName, name.length);
    pWrite += name.length;
    length += name.length;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    return dataWrite;
}



+ (NSData *)testData
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //a5a5f7080001ff3264010164fb5e
    
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F7 08 00 01 FF 32 64 01 01 64"];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 12);
    pWrite += 12;
    length += 12;
    
        
//    NSString *locationStr = [NSString stringWithFormat:@"01"];
//    NSData *dataLocationMixed = [self dataWithHexString:locationStr];
//    unsigned char *pLocation = (unsigned char *)[dataLocationMixed  bytes];
//    memcpy(pWrite, pLocation, 1);
//    pWrite += 1;
//    length += 1;
//    
//    
//    int age = 22;
//    
//    NSData *ageData = [NSData dataWithBytes:&age length:sizeof(age)];
//    unsigned char *pAgeData = (unsigned char *)[ageData bytes];
//    memcpy(pWrite, pAgeData, 1);
//    pWrite += 1;
//    length += 1;
//    
//    
//    int height = 170;
//    
//    NSData *hightData = [NSData dataWithBytes:&height length:sizeof(height)];
//    unsigned char *pHightData = (unsigned char *)[hightData bytes];
//    memcpy(pWrite, pHightData, 1);
//    pWrite += 1;
//    length += 1;
//    
//    int weight = 60;
//    
//    NSData *weightData = [NSData dataWithBytes:&weight length:sizeof(weight)];
//    unsigned char *pWeight = (unsigned char *)[weightData bytes];
//    memcpy(pWrite, pWeight, 1);
//    pWrite += 1;
//    length += 1;
//    
//    
//    //Tki
//    //NSString *nameStr = [NSString stringWithFormat:@"54 6B 69"];
//    NSString *nameStr = @"Jack";
//    NSData *dataName = [nameStr dataUsingEncoding:NSUTF8StringEncoding];
//    //NSData *dataName = [self dataWithHexString:nameStr];
//    unsigned char *pName = (unsigned char *)[dataName  bytes];
//    memcpy(pWrite, pName, 4);
//    pWrite += 4;
//    length += 4;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"发送的测试信息------%@",dataWrite);
    return dataWrite;
}


//获取调节模式
+ (NSData *)getAdjustModel
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
        
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 E0 01 55"];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 5);
    pWrite += 5;
    length += 5;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"获取调整模式数据帧------%@",dataWrite);
    return dataWrite;
}

//手动自动调节
+ (NSData *)adjustType:(NSString *)type bedSide:(nonnull NSString *)side
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 E1 02 %@ %@",side,type];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 6);
    pWrite += 6;
    length += 6;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"发送手自动---%@",dataWrite);
    return dataWrite;
}

//快速调节
+ (NSData *)controlBedQuick:(NSString *)userID  bedSide:(NSString *)side bodyPose:(NSString *)pose bedHardLevel:(int)level
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F7 09 %@",side];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 5);
    pWrite += 5;
    length += 5;
    
    NSString *controlStr = @"FF 00 FF 00 00 FF FF FF";
    if (level == 1) {
        controlStr = @"FF 00 FF 00 00 FF FF FF";
    }
    if (level == 2) {
        controlStr = @"FF 32 FF 32 32 FF FF FF";
    }
    if (level == 3) {
        controlStr = @"FF 64 FF 64 64 FF FF FF";
    }
    NSData *dataControl = [self dataWithHexString:controlStr];
    unsigned char *pControl = (unsigned char *)[dataControl  bytes];
    memcpy(pWrite, pControl, 8);
    pWrite += 8;
    length += 8;
    
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"发送手自动---%@",dataWrite);
    return dataWrite;
}


//单部位调节
+ (NSData *)controlBodyPart:(NSString *)userID  bodyPart:(int )part bedSide:(NSString *)side bodyPose:(NSString *)pose hardLevel:(int)level
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 F7 09 %@",side];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 5);
    pWrite += 5;
    length += 5;
    
    NSData *levelData = [NSData dataWithBytes:&level length:1];
    NSString *string = [[ToolHexManager sharedManager] convertDataToHexStr:levelData];
    NSString *myStr = [[ToolHexManager sharedManager] doMakeUpperCaseAndAddSpace:string];
    NSString *lastStr = [NSString stringWithFormat:@"%@ ",myStr];
    
    NSString *controlStr = @"FF FF FF FF FF FF FF";
    
    NSString *levelStr = @"";
    
    if (part == 7) {
        levelStr = [NSString stringWithFormat:@"%@ %@",controlStr,myStr];
    }else{
        NSRange range = NSMakeRange(3*part, 0);
        levelStr = [controlStr stringByReplacingCharactersInRange:range withString:lastStr];
    }
    
    NSData *dataControl = [self dataWithHexString:levelStr];
    unsigned char *pControl = (unsigned char *)[dataControl  bytes];
    memcpy(pWrite, pControl, 8);
    pWrite += 8;
    length += 8;
    
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"发送手自动---%@",dataWrite);
    return dataWrite;
}



/*
 char buffer[256];
 char *pWrite = buffer;
 int length = 0;
 
 //帧头 帧长 CmdID Number
 NSString *headerMix = @"2A 22 02 01";
 NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
 unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
 memcpy(pWrite, pHeader, 4);
 pWrite += 4;
 length += 4;
 
 //网关地址
 NSData *dataZigbee = [self doGetGatewayZigbeeMacAddrFromLocal];
 unsigned char *pMacAddress = (unsigned char *)[dataZigbee bytes];
 memcpy(pWrite, pMacAddress, 8);
 pWrite += 8;
 length += 8;
 
 //源节点地址
 NSString *mainDeviceMac = device.strDevice_mac_address;
 NSData *mainMacData = [self dataWithHexString:mainDeviceMac];
 unsigned char *pMainMac = (unsigned char *)[mainMacData bytes];
 memcpy(pWrite, pMainMac, 8);
 pWrite += 8;
 length += 8;
 
 //OD索引、子索引（目前固定01）、数据长度、源端点、目标端点、目标地址、功能码
 NSString *featureMix = @"17 73 01 0C FF FF FF FF FF FF FF FF FF FF FF FF";
 NSData *featureData = [self dataWithHexString:featureMix];
 unsigned char *pFeature = (unsigned char *)[featureData bytes];
 memcpy(pWrite, pFeature, 16);
 pWrite += 16;
 length += 16;
 
 //CS 校验码
 char packageCSData = *(buffer + 2);
 for (int i = 3; i < length; i++) {
     packageCSData = packageCSData + *(buffer + i);
 }
 char packageCS = packageCSData%256;
 memcpy(pWrite, &packageCS, 1);
 pWrite ++;
 length ++;
 
 //结束符 1byte
 char packageEnd = 0x23;
 memcpy(pWrite, &packageEnd, 1);
 pWrite ++;
 length ++;
 
 NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
 return dataWrite;
 */


#pragma mark - 解包

//01546f6dffffffffff024a61636bffffffff
- (void)unPackData:(NSData *)data
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSString *hexDataStr = [[ToolHexManager sharedManager] convertDataToHexStr:data];
    NSString *headerHex = [hexDataStr substringWithRange:NSMakeRange(0, 4)];
    if ([headerHex isEqualToString:@"b5b5"]) {
        NSString *funcationCode = [hexDataStr substringWithRange:NSMakeRange(4, 2)];
        if ([funcationCode isEqualToString:@"01"]) {//实时压力
            [self unPackPillowData:hexDataStr];
        }else if ([funcationCode isEqualToString:@"f3"]) {//获取头部高度
            
            
        }else if ([funcationCode isEqualToString:@"f4"]) {//获取头部高度
            
            
        }else if ([funcationCode isEqualToString:@"f5"]) {//获取头部高度
            
            
        }else if ([funcationCode isEqualToString:@"f0"]) {//新增用户
            NSString *success = [hexDataStr substringWithRange:NSMakeRange(8, 2)];
            NSString *userID = [hexDataStr substringWithRange:NSMakeRange(10, 2)];
            dict[@"message"] = success;
            dict[@"userID"] = userID;
            self.dataDict = dict;
        }else if ([funcationCode isEqualToString:@"f6"]) {//获取身体参数
            NSString *bedSideStr = [hexDataStr substringWithRange:NSMakeRange(8, 2)];
            NSString *headStr = [hexDataStr substringWithRange:NSMakeRange(10, 2)];
            NSString *shoulderStr = [hexDataStr substringWithRange:NSMakeRange(12, 2)];
            NSString *backStr = [hexDataStr substringWithRange:NSMakeRange(14, 2)];
            NSString *waistStr = [hexDataStr substringWithRange:NSMakeRange(16, 2)];
            NSString *hipStr = [hexDataStr substringWithRange:NSMakeRange(18, 2)];
            NSString *thighStr = [hexDataStr substringWithRange:NSMakeRange(20, 2)];
            NSString *calfStr = [hexDataStr substringWithRange:NSMakeRange(22, 2)];
            NSString *footStr = [hexDataStr substringWithRange:NSMakeRange(24, 2)];
            
            int head = (int)[[ToolHexManager sharedManager] numberWithHexString:headStr];
            int shoulder = (int)[[ToolHexManager sharedManager] numberWithHexString:shoulderStr];
            int back = (int)[[ToolHexManager sharedManager] numberWithHexString:backStr];
            int waist = (int)[[ToolHexManager sharedManager] numberWithHexString:waistStr];
            int hip = (int)[[ToolHexManager sharedManager] numberWithHexString:hipStr];
            int thigh = (int)[[ToolHexManager sharedManager] numberWithHexString:thighStr];
            int calf = (int)[[ToolHexManager sharedManager] numberWithHexString:calfStr];
            int foot = (int)[[ToolHexManager sharedManager] numberWithHexString:footStr];
            
            NSLog(@"身体部位硬度：头（%d）\n肩（%d）\n背（%d）\n腰（%d）\n臀（%d）\n大腿（%d）\n小腿（%d）\n脚（%d）",head,shoulder,back,waist,hip,thigh,calf,foot);
            
            dict[@"side"] = bedSideStr;
            dict[@"head"] = @(head);
            dict[@"shoulder"] = @(shoulder);
            dict[@"back"] = @(back);
            dict[@"waist"] = @(waist);
            dict[@"hip"] = @(hip);
            dict[@"thigh"] = @(thigh);
            dict[@"calf"] = @(calf);
            dict[@"foot"] = @(foot);
            self.bodyHardnessData = dict;
                        
        }else if ([funcationCode isEqualToString:@"f7"]) {//调整身体参数
            NSString *message = [hexDataStr substringWithRange:NSMakeRange(8, 2)];
            dict[@"respond"] = message;
            dict[@"code"] = funcationCode;
            self.respondDict = dict;
        }else if ([funcationCode isEqualToString:@"f8"]) {//获取AI策略
            
        }else if ([funcationCode isEqualToString:@"f9"]) {//设置AI策略
            
        }else if ([funcationCode isEqualToString:@"fa"]) {//更新软件
            
        }else if ([funcationCode isEqualToString:@"f1"]) {//获取用户列表
            NSString *lengthStr = [hexDataStr substringWithRange:NSMakeRange(6, 2)];
            int dataLength = (int)[[ToolHexManager sharedManager] numberWithHexString:lengthStr];
            int nameLength = dataLength - 7;    //先计算出昵称的字节长度            
            //id、性别、年龄、身高、体重、睡侧、工作模式、昵称
            NSString *IDStr = [hexDataStr substringWithRange:NSMakeRange(8, 2)];
            NSString *genderStr = [hexDataStr substringWithRange:NSMakeRange(10, 2)];
            NSString *ageStr = [hexDataStr substringWithRange:NSMakeRange(12, 2)];
            NSString *heightStr = [hexDataStr substringWithRange:NSMakeRange(14, 2)];
            NSString *weightStr = [hexDataStr substringWithRange:NSMakeRange(16, 2)];
            NSString *sideStr = [hexDataStr substringWithRange:NSMakeRange(18, 2)];
            NSString *workModeStr = [hexDataStr substringWithRange:NSMakeRange(20, 2)];
            NSString *nickStr = [hexDataStr substringWithRange:NSMakeRange(22, 2*nameLength)];
            
            int age = (int)[[ToolHexManager sharedManager] numberWithHexString:ageStr];
            int height = (int)[[ToolHexManager sharedManager] numberWithHexString:heightStr];
            int weight = (int)[[ToolHexManager sharedManager] numberWithHexString:weightStr];
            NSData *data = [[ToolHexManager sharedManager] convertHexStrToData:nickStr];
            NSString *nick = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"获取到的用户信息\n  id--%@\n  性别--%@\n  年龄--%d\n  身高--%d\n  体重--%d\n  昵称--%@",IDStr,genderStr,age,height,weight,nick);
            
        }else if ([funcationCode isEqualToString:@"e0"]) {//获取调节模式
            NSString *letftMode = [hexDataStr substringWithRange:NSMakeRange(8, 2)];
            NSString *rightMode = [hexDataStr substringWithRange:NSMakeRange(10, 2)];
            dict[@"letfMode"] = letftMode;
            dict[@"rightMode"] = rightMode;
            dict[@"code"] = funcationCode;
            self.respondDict = dict;
        }else if ([funcationCode isEqualToString:@"e1"]) {//设置调节模式返回
            NSString *side = [hexDataStr substringWithRange:NSMakeRange(8, 2)];
            NSString *respons = [hexDataStr substringWithRange:NSMakeRange(10, 2)];
            dict[@"side"] = side;
            dict[@"respond"] = respons;
            dict[@"code"] = funcationCode;
            self.respondDict = dict;
        }else if ([funcationCode isEqualToString:@"e2"]) {//控制盒主动上报调节位置
            NSLog(@"上报数据-------%@",hexDataStr);
            NSString *side = [hexDataStr substringWithRange:NSMakeRange(8, 2)];
            NSString *dataStr = [hexDataStr substringWithRange:NSMakeRange(10, 16)];
            dict[@"dataStr"] = dataStr;
            dict[@"side"] = side;
            dict[@"code"] = funcationCode;
            self.respondDict = dict;
        }else if ([funcationCode isEqualToString:@"a2"]) {
            NSString *sw_ver = [hexDataStr substringWithRange:NSMakeRange(16, 8)];
            NSString *hw_ver = [hexDataStr substringWithRange:NSMakeRange(24, 4)];
            NSLog(@"固件硬件版本------%@    固件软件版本--------%@",hw_ver,sw_ver);
            dict[@"sw_ver"] = sw_ver;
            dict[@"hw_ver"] = hw_ver;
            dict[@"code"] = funcationCode;
            self.versionDict = dict;
        }
    }
}


#pragma mark - 枕头控制指令
//单气囊控制
+ (NSData *)controlPillowAirBag:(int)index pressureValue:(int)value
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 01 F3 02 0%d",index];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 6);
    pWrite += 6;
    length += 6;
    
    NSData *pressureData = [NSData dataWithBytes:&value length:sizeof(value)];
    unsigned char *pPressureData= (unsigned char *)[pressureData bytes];
    memcpy(pWrite, pPressureData, 1);
    pWrite += 1;
    length += 1;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"发送枕头气囊控制---%@",dataWrite);
    return dataWrite;
}

//单区域控制
+ (NSData *)controlPillowArea:(int)area pressureValue:(int)value
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 01 F4 02 0%d",area];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 6);
    pWrite += 6;
    length += 6;
    
    NSData *pressureData = [NSData dataWithBytes:&value length:sizeof(value)];
    unsigned char *pPressureData= (unsigned char *)[pressureData bytes];
    memcpy(pWrite, pPressureData, 1);
    pWrite += 1;
    length += 1;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"发送枕头区域控制---%@",dataWrite);
    return dataWrite;
}

//设置阈值
+ (NSData *)savePillowPressure:(NSString *)pose pillowArea:(int)area pressureValue:(int)value
{
    char buffer[256];
    char *pWrite = buffer;
    int length = 0;
    
    //帧头 帧长 CmdID Number
    NSString *headerMix = [NSString stringWithFormat:@"A5 A5 01 F5 01 00"];
    NSData *dataHeaderMixed = [self dataWithHexString:headerMix];
    unsigned char *pHeader = (unsigned char *)[dataHeaderMixed  bytes];
    memcpy(pWrite, pHeader, 6);
    pWrite += 6;
    length += 6;
    
//    NSData *pressureData = [NSData dataWithBytes:&value length:sizeof(value)];
//    unsigned char *pPressureData= (unsigned char *)[pressureData bytes];
//    memcpy(pWrite, pPressureData, 1);
//    pWrite += 1;
//    length += 1;
    
    //CS 校验码
    char packageCSData = *(buffer + 2);
    for (int i = 3; i < length; i++) {
        packageCSData = packageCSData + *(buffer + i);
    }
    char packageCS = packageCSData%256;
    memcpy(pWrite, &packageCS, 1);
    pWrite ++;
    length ++;
    
    //结束符 1byte
    char packageEnd = 0x5e;
    memcpy(pWrite, &packageEnd, 1);
    pWrite ++;
    length ++;
    
    NSData *dataWrite = [NSData dataWithBytes:buffer length:length];
    NSLog(@"发送设置自动调节阈值---%@",dataWrite);
    return dataWrite;
}



#pragma mark - 枕头数据解析
- (void)unPackPillowData:(NSString *)holdHexDataStr
{
    
}


+ (NSData *)dataWithHexString:(NSString *)str
{
    NSString *strHex = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSData *data = [[ToolHexManager sharedManager] convertHexStrToData:strHex];
    return data;
}


@end
