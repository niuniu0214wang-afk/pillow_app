//
//  DataCenter.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/7.
//

#import "DataCenter.h"
#import <sqlite3.h>


#define BEDKEY @"bed"
#define PERSONKEY @"person"

@interface DataCenter ()
@property (assign, nonatomic) sqlite3 *db;
@end



@implementation DataCenter


+ (instancetype)shareInstance
{
    static DataCenter *dataManager = nil;
    static dispatch_once_t oneceToken;
    dispatch_once(&oneceToken, ^{
        dataManager = [[self alloc] init];
    });
    return dataManager;
}


//打开数据库
- (BOOL)openDB
{
    // 1. 获取沙盒Document目录路径
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        // 2. 拼接数据库文件路径（test.db，不存在则自动创建）
        NSString *dbPath = [docPath stringByAppendingPathComponent:@"smartBed.db"];
        NSLog(@"数据库路径：%@", dbPath);
        
        // 3. 打开数据库（SQLITE_OK 表示成功）
        int result = sqlite3_open([dbPath UTF8String], &_db);
        if (result != SQLITE_OK) {
            NSLog(@"打开数据库失败，错误码：%d", result);
            sqlite3_close(_db); // 失败时关闭空指针
            _db = NULL;
            return NO;
        }
        NSLog(@"打开数据库成功");
        [self creatBedTable];
//        [self createOrderTable];
        return YES;
}

//创建床垫表
- (BOOL)creatBedTable
{
        const char *createSQL = "CREATE TABLE IF NOT EXISTS Bed ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name TEXT NOT NULL,"
        "mac TEXT NOT NULL,"
        "mode INTEGER,"
        "leftUser INTEGER,"
        "rightUser INTEGER);";
        
        // 执行无返回值的SQL（sqlite3_exec）
        char *errMsg = NULL;
        int result = sqlite3_exec(_db, createSQL, NULL, NULL, &errMsg);
        if (result != SQLITE_OK) {
            NSLog(@"创建bed表失败：%s", errMsg);
            sqlite3_free(errMsg); // 释放错误信息内存
            return NO;
        }
        NSLog(@"创建bed表成功");
        return YES;
}


//增加床信息
- (BOOL)addBed:(BedModel *)bed
{
    const char *insertSQL = "INSERT INTO Bed (name, mac, mode, leftUser, rightUser) VALUES (?, ?, ?, ?, ?);";
    sqlite3_stmt *stmt = NULL;
    
    int result = sqlite3_prepare_v2(_db, insertSQL, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"编译插入User SQL失败：%d", result);
        sqlite3_finalize(stmt);
        return NO;
    }
        
    sqlite3_bind_text(stmt, 1, [bed.bedName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, [bed.mac UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt, 3, (int)bed.mode);
    sqlite3_bind_int(stmt, 4, (int)bed.letfUser);
    sqlite3_bind_int(stmt, 5, (int)bed.rightUser);
        
    result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        NSLog(@"插入bed数据失败：%d", result);
        sqlite3_finalize(stmt);
        return NO;
    }
    
    sqlite3_finalize(stmt);
    NSLog(@"插入bed数据成功");
    return YES;
}

//修改床垫名称
- (BOOL)editBedName:(BedModel *)bed withName:(NSString *)newName
{
    const char *updateSQL = "UPDATE Bed SET name = ? WHERE mac = ?;";
    sqlite3_stmt *stmt = NULL;
    
    int result = sqlite3_prepare_v2(_db, updateSQL, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"编译更新Bed SQL失败：%d", result);
        sqlite3_finalize(stmt);
        return NO;
    }
        
    sqlite3_bind_text(stmt, 1, [newName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, [bed.mac UTF8String], -1, SQLITE_TRANSIENT);
        
    result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        NSLog(@"更新Bed数据失败：%d", result);
        sqlite3_finalize(stmt);
        return NO;
    }
    
    sqlite3_finalize(stmt);
    NSLog(@"更新用户成功");
    return YES;
}
////删除床信息
//- (void)deleteBed:(BedModel *)bed;
//
//
//获取床列表
- (NSArray<BedModel *> *)getAllBeds
{
    NSMutableArray *users = [NSMutableArray array];
    const char *querySQL = "SELECT id, name, mac, mode, leftUser, rightUser FROM Bed;";
    sqlite3_stmt *stmt = NULL;
    
    int result = sqlite3_prepare_v2(_db, querySQL, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"编译查询User SQL失败：%d", result);
        sqlite3_finalize(stmt);
        return users;
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSInteger bedID = sqlite3_column_int(stmt, 0);
        NSString *name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
        NSString *mac = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
        NSInteger mode = sqlite3_column_int(stmt, 3);
        NSInteger letfUser = sqlite3_column_int(stmt, 4);
        NSInteger rightUser = sqlite3_column_int(stmt, 5);
        
        BedModel *bed = [[BedModel alloc] init];
        bed.bedID = bedID;
        bed.bedName = name;
        bed.mac = mac;
        bed.mode = mode;
        bed.letfUser = (int)letfUser;
        bed.rightUser = (int)rightUser;
        [users addObject:bed];
    }
    
    sqlite3_finalize(stmt);
    NSLog(@"查询到 %ld 条Bed数据", users.count);
    return users.copy;
}
////增加用户信息
//- (void)addPerson:(PersonModel *)person;
//
////修改用户信息
//- (void)editPerson:(PersonModel *)person;
//
////删除用户信息
//- (void)deletePerson:(PersonModel *)person;



@end
