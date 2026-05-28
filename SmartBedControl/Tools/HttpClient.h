//
//  HttpClient.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HTTPSuccessBlock)(id responseObject);
typedef void(^HTTPFailureBlock)(NSError *error);


@interface HttpClient : NSObject

/// 单例
+ (instancetype)sharedClient;

/// GET 请求
- (void)GET:(NSString *)url
 parameters:(nullable NSDictionary *)params
    success:(HTTPSuccessBlock)success
    failure:(HTTPFailureBlock)failure;

/// POST 请求
- (void)POST:(NSString *)url
  parameters:(nullable NSDictionary *)params
     success:(HTTPSuccessBlock)success
     failure:(HTTPFailureBlock)failure;


@end

NS_ASSUME_NONNULL_END
