//
//  HttpClient.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/8.
//

#import "HttpClient.h"

@implementation HttpClient

+ (instancetype)sharedClient {
    static HttpClient *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSURLSession *)defaultSession {
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 20; // 超时时间 20 秒
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        session = [NSURLSession sessionWithConfiguration:config];
    });
    return session;
}

- (void)GET:(NSString *)url parameters:(NSDictionary *)params success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSMutableString *urlString = [NSMutableString stringWithString:url];
    
    // 拼接参数
    if (params && params.count > 0) {
        [urlString appendString:@"?"];
        NSMutableArray *parts = [NSMutableArray array];
        for (NSString *key in params) {
            NSString *value = [NSString stringWithFormat:@"%@", params[key]];
            [parts addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
        [urlString appendString:[parts componentsJoinedByString:@"&"]];
    }
    
    NSURL *requestURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *task = [[self defaultSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self handleData:data response:response error:error success:success failure:failure];
    }];
    [task resume];
}

- (void)POST:(NSString *)url parameters:(NSDictionary *)params success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSURL *requestURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.HTTPMethod = @"POST";
    
    // JSON 格式参数
    if (params) {
        NSError *err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        if (!err && jsonData) {
            request.HTTPBody = jsonData;
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
    }
    
    NSURLSessionDataTask *task = [[self defaultSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self handleData:data response:response error:error success:success failure:failure];
    }];
    [task resume];
}

/// 统一处理响应
- (void)handleData:(NSData *)data
          response:(NSURLResponse *)response
             error:(NSError *)error
           success:(HTTPSuccessBlock)success
           failure:(HTTPFailureBlock)failure {
    
    // 网络错误 / 超时
    if (error) {
        if (failure) failure(error);
        return;
    }
    
    // HTTP 状态码判断
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
        NSError *err = [NSError errorWithDomain:@"HTTP_ERROR" code:httpResponse.statusCode userInfo:@{NSLocalizedDescriptionKey: @"服务器异常"}];
        if (failure) failure(err);
        return;
    }
    
    // 解析 JSON
    NSError *jsonError;
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError) {
        if (failure) failure(jsonError);
        return;
    }
    
    // 成功
    if (success) success(result);
}


@end
