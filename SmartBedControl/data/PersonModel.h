//
//  PersonModel.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonModel : NSObject

@property (assign, nonatomic) int userID;         //id
@property (strong, nonatomic) NSString *nickName;       //昵称
@property (strong, nonatomic) NSString *gender;         //性别
@property (assign, nonatomic) int age;                  //年龄
@property (assign, nonatomic) int weight;               //体重
@property (assign, nonatomic) int height;               //身高
@property (strong, nonatomic) NSString *bedSide;        //睡侧
@property (assign, nonatomic) int isAdmin;              //是否管理员

@end

NS_ASSUME_NONNULL_END
