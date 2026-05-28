//
//  DeviceManager.m
//  EonHome
//
//  Created by 刘飞 on 2026/1/20.
//

#import "DeviceManager.h"
#import <UIKit/UIKit.h>
#import <Security/Security.h>

@implementation DeviceManager


+ (instancetype)sharedManager {
    static DeviceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSString *)getDeviceID {
    NSString *deviceID = [self loadDeviceIDFromKeychain];
    
    if (!deviceID || deviceID.length == 0) {
        deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [self saveDeviceIDToKeychain:deviceID];
    }
    
    return deviceID;
}

- (void)resetDeviceID {
    [self deleteDeviceIDFromKeychain];
}


#pragma mark - Keychain 操作

- (NSString *)loadDeviceIDFromKeychain {
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    NSString *account = @"device_unique_id";
    
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: service,
        (__bridge id)kSecAttrAccount: account,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
    };
    
    CFTypeRef dataRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataRef);
    
    if (status == errSecSuccess) {
        NSData *data = (__bridge_transfer NSData *)dataRef;
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}


- (void)saveDeviceIDToKeychain:(NSString *)deviceID {
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    NSString *account = @"device_unique_id";
    
    NSData *data = [deviceID dataUsingEncoding:NSUTF8StringEncoding];
    
    // 先删除旧的
    [self deleteDeviceIDFromKeychain];
    
    // 添加新的
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: service,
        (__bridge id)kSecAttrAccount: account,
        (__bridge id)kSecValueData: data,
        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlock
    };
    
    SecItemAdd((__bridge CFDictionaryRef)query, NULL);
}

- (void)deleteDeviceIDFromKeychain {
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    NSString *account = @"device_unique_id";
    
    NSDictionary *query = @{(__bridge  id)kSecClass : (__bridge  id)kSecClassGenericPassword,(__bridge  id)kSecAttrService : service,(__bridge  id)kSecAttrAccount : account};
    
    SecItemDelete((__bridge CFDictionaryRef)query);
}

@end
