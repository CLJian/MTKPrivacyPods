//
//  MTKBDHandle.m
//  NBJSONModelDemo
//
//  Created by Joy on 15/11/27.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import "MTKDBHandle.h"
#import <sqlite3.h>
#import "NSObject+MTKProperties.h"

#define DBText  @"text"
#define DBInt   @"integer"
#define DBFloat @"real"
#define DBData  @"blob"
#define DBNoManage @"DBNoManage"

@interface MTKModelPropertyType (MTKDBRelated)
//将属性转化为简单的可存储的数据
-(id)mtkPropertyValueForDBValue:(id)singeValue;
//将简单的数据转化为可使用的属性数据
-(id)mtkDBValueForPropertyValue:(id)propertyValue;
//数据库中存储类型
@property (nonatomic,readonly) NSString* mtkDBType;

@end


@implementation MTKModelPropertyType (MTKDBRelated)

-(id)mtkPropertyValueForDBValue:(id)singeValue
{
    if (self.propertyType > MTKClassPropertyValueTypeNone && self.propertyType < MTKClassPropertyTypeVoid ) {
        return @([singeValue doubleValue]);
    }
    if (self.propertyType == MTKClassPropertyTypeObject) {
        if ([singeValue isKindOfClass:[NSData class]]) {
            if ([self.objClass isSubclassOfClass:[NSData class]]) {
                return singeValue;
            }else if([self.objClass conformsToProtocol:@protocol(NSCoding)]) {
                id object = [NSKeyedUnarchiver unarchiveObjectWithData:singeValue];
                if ([object isKindOfClass:self.objClass]) {
                    //是该类型
                    return object;
                }else{
                    return object;
                }
            }
        }
        if ([self.objClass isSubclassOfClass:[NSString class]]) {
            return [NSString  stringWithFormat:@"%@", singeValue ? singeValue : @""];
        }
        if ([self.objClass isSubclassOfClass:[NSNumber class]]) {
            return [NSNumber numberWithDouble:[singeValue doubleValue]];
        }
    }
    return nil;
}

-(id)mtkDBValueForPropertyValue:(id)propertyValue
{
    NSString *dbTypeString = self.mtkDBType;
    if ([dbTypeString isEqualToString:DBText]) {
        return [NSString stringWithFormat:@"%@",propertyValue ? propertyValue : @""];
    }
    if ([dbTypeString isEqualToString:DBData]) {
        if ([propertyValue isKindOfClass:[NSData class]]) {
            return propertyValue;
        }
        if ([self.objClass conformsToProtocol:@protocol(NSCoding)] && [[propertyValue class]conformsToProtocol:@protocol(NSCoding)]) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:propertyValue];
            return data;
        }
    }
    if ([dbTypeString isEqualToString:DBInt]) {
        return @([propertyValue longValue]);
    }
    if ([dbTypeString isEqualToString:DBFloat]) {
        return @([propertyValue doubleValue]);
    }
    if (propertyValue) {
        NSString *string = [NSString stringWithFormat:@"%@",propertyValue ? propertyValue : @""];
        return string;
    }
    return nil;
}

-(NSString *)mtkDBType
{
    if (self.propertyType > MTKClassPropertyValueTypeNone && self.propertyType < MTKClassPropertyTypeFloat) {
        return DBInt;
    }else if(self.propertyType == MTKClassPropertyTypeFloat || self.propertyType == MTKClassPropertyTypeDouble){
        return DBFloat;
    }else if(self.propertyType == MTKClassPropertyTypeObject){
        if ([self.objClass isSubclassOfClass:[NSString class]] || [self.objClass isSubclassOfClass:[NSNumber class]]) {
            return DBText;
        }else{
            return DBData;
        }
    }
    return DBNoManage;
}

@end




@interface MTKDBHandle ()

@property (nonatomic) sqlite3 *sqlite3DB;

@property (nonatomic,assign) BOOL isDBOpen;

@property (nonatomic,strong) NSMutableArray *checkedClassNameArray;

@property (atomic,assign) dispatch_queue_t dbHandleQueue;

@property (nonatomic,copy) NSString *DBPath;

@end

@implementation MTKDBHandle

#pragma mark

+(instancetype)sharedDBHandle
{
    static MTKDBHandle *dbHandle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbHandle = [[MTKDBHandle alloc]init];
    });
    return dbHandle;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(instancetype)init
{
    if (self = [super init]) {
        _checkedClassNameArray = [NSMutableArray array];
        _dbHandleQueue = dispatch_queue_create("com.mtkdbhandle.queue", DISPATCH_QUEUE_SERIAL);
#ifdef DEBUG
        NSLog(@"DB%@",self.DBPath);
#endif
    }
    return self;
}

#pragma mark DB

-(void)setDBName:(NSString *)DBName
{
    dispatch_async(_dbHandleQueue, ^{
        _DBName = DBName;
        if (DBName.length) {
            _DBPath = [self filePathWithName:[NSString stringWithFormat:@"DB-%@",DBName]];
        }else{
            _DBPath = nil;
        }
    });
}

-(NSString*)filePathWithName:(NSString* )fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *folderDir = [cacheDirectory stringByAppendingPathComponent: @"DBFolder"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:folderDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:folderDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path = [folderDir stringByAppendingPathComponent:fileName];
    return path;
}

-(NSString *)DBPath
{
    if (!_DBPath.length) {
        _DBPath = [self filePathWithName:@"MainDB"];
    }
    return _DBPath;
}

-(BOOL)openDB
{
    NSString *dbPath = self.DBPath ;

    int flags = SQLITE_OPEN_READWRITE;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        flags = SQLITE_OPEN_READWRITE;
    } else {
        flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
    }
    if (self.isDBOpen) {
        return YES;
    }
    int rc = sqlite3_open_v2([dbPath UTF8String], &_sqlite3DB, flags, NULL);
    if (rc == SQLITE_OK) {
//        NSLog(@"打开数据库%@成功!", dbPath);
        self.isDBOpen = YES;
        return YES;
    } else {
//        NSLog(@"打开数据库%@失败!", dbPath);
        return NO;
    }
    return NO;
}

-(BOOL)closeDB
{
    if (!self.isDBOpen) {
        //数据库已关闭
        return YES;
    }
    int rc = sqlite3_close(_sqlite3DB);
    if (rc == SQLITE_OK) {
        //关闭数据库成功
        self.isDBOpen = NO;
        self.sqlite3DB = NULL;
        return YES;
    } else {
        //关闭数据库失败
        return NO;
    }
    return YES;
}

#pragma mark Table

-(NSString*)tableNameWithClass:(Class)aClass andtableKey:(NSString*)key
{
    NSMutableString *tableName = [[NSMutableString alloc]initWithString:NSStringFromClass(aClass)];
    if (key.length) {
        [tableName appendFormat:@"_%@",key];
    }
    return tableName;
}
//所有表名
-(NSArray *)sqlite_tablename {
//    if (!self.isDBOpen) {
//        [self openDB];
//    }
    sqlite3_stmt *stmt = NULL;
    NSMutableArray *tablenameArray = [[NSMutableArray alloc] init];
    NSString *str = [NSString stringWithFormat:@"select name from sqlite_master where type='table'"];
    sqlite3 *sqlite3DB = self.sqlite3DB;
    if (sqlite3_prepare_v2(sqlite3DB, [str UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
        while (SQLITE_ROW == sqlite3_step(stmt)) {
            const unsigned char *text = sqlite3_column_text(stmt, 0);
            [tablenameArray addObject:[NSString stringWithUTF8String:(const char *)text]];
        }
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
//    [self closeDB];
    return tablenameArray;
}
//单表列名
-(NSArray *)sqlite_columnNamesArrayWithTableName:(NSString*)tableName
{
//    if (!self.isDBOpen) {
//        [self openDB];
//    }
    sqlite3_stmt *stmt = NULL;
    NSMutableArray *columnNamesArray = [[NSMutableArray alloc] init];
    NSString *str = [NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName];
    sqlite3 *sqlite3DB = self.sqlite3DB;
    BOOL result = sqlite3_prepare_v2(sqlite3DB, [str UTF8String], -1, &stmt, NULL) == SQLITE_OK;
    if (result) {
        while (SQLITE_ROW == sqlite3_step(stmt)) {
            const unsigned char *text = sqlite3_column_text(stmt,1);
            [columnNamesArray addObject:[NSString stringWithUTF8String:(const char *)text]];
        }
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
//    [self closeDB];
    return columnNamesArray;
}
//表是否存在
- (BOOL)sqlite_tableExistWithTableName:(NSString*)tableName {
    NSArray *tableArray = [self sqlite_tablename];
    for (NSString *tablename in tableArray) {
        if ([tablename isEqualToString:tableName]) {
            return YES;
        }
    }
    return NO;
}
//创建表
- (void)createDbTable:(Class)aClass andTableKey:(NSString*)key;
{
//    if (!self.isDBOpen) {
//        [self openDB];
//    }
    
    NSString *tableName = [self tableNameWithClass:aClass andtableKey:key];
    
    if ([self sqlite_tableExistWithTableName:tableName]) {
        //数据库表已存在
        return;
    }
//    if (!self.isDBOpen) {
//        [self openDB];
//    }
    NSMutableString *sql = [NSMutableString stringWithCapacity:0];
    [sql appendString:@"create table "];
    [sql appendString:tableName];
    [sql appendString:@"("];
    
    NSDictionary *propertyDic = [aClass mtkCachedProperties];

    NSArray *allValues = [propertyDic allValues];
    NSString *primaryKey = [[aClass mtkPrimaryKeyPropertyName]lowercaseString] ;
    NSMutableArray *DBPropertyValue = [NSMutableArray arrayWithCapacity:allValues.count];

    for (int i = 0; i < allValues.count; i++) {
        MTKModelPropertyType *propertyType = allValues[i];
        NSString *type = propertyType.mtkDBType;
        NSString *key = [propertyType.propertyName lowercaseString];
        NSString *proStr;
        if ([key isEqualToString:primaryKey]) {
            proStr = [NSString stringWithFormat:@"%@ %@ primary key", key, type];
        } else {
            proStr = [NSString stringWithFormat:@"%@ %@", key, type];
        }
        [DBPropertyValue addObject:proStr];
    }
    NSString *propertyStr = [DBPropertyValue componentsJoinedByString:@","];
    [sql appendString:propertyStr];
    [sql appendString:@");"];
    
    char *errmsg = 0;
    sqlite3 *sqlite3DB = self.sqlite3DB;
    int ret = sqlite3_exec(sqlite3DB,[sql UTF8String],NULL,NULL,&errmsg);
    if(ret != SQLITE_OK){
        //建表失败
        fprintf(stderr,"create table fail: %s\n",errmsg);
    }
    sqlite3_free(errmsg);
//    [self closeDB];
}
//更新表内容
-(void)updateTableContentWithClass:(Class)aClass andTableKey:(NSString*)tableKey
{
    //每次运行程序对于表执行一遍更新表
    NSString *tableName = [self tableNameWithClass:aClass andtableKey:tableKey];
    if ([_checkedClassNameArray containsObject:tableName]) {
        return;
    }else{
        [_checkedClassNameArray addObject:tableName];
    }
    if (![self sqlite_tableExistWithTableName:tableName]) {
        return;
    }

    NSArray *columnArr = [self sqlite_columnNamesArrayWithTableName:tableName];
    //冗余的列
    NSMutableArray *redundantColumnArr = [NSMutableArray arrayWithArray:columnArr];
    //缺少的列
    NSMutableArray *absentColumnArr = [NSMutableArray array];
    NSDictionary *propertyDic = [aClass mtkCachedProperties];
    NSMutableArray *jsonNameArr = [NSMutableArray arrayWithArray:[propertyDic allKeys]];
//    [jsonNameArr removeObjectsInArray:[aClass mtkNoManageJsonNames]];
    for (NSString *jsonName in jsonNameArr) {
        if ([columnArr containsObject:jsonName]) {
            [redundantColumnArr removeObject:jsonName];
        }else{
            [absentColumnArr addObject:jsonName];
        }
    }
    if (!absentColumnArr.count && !redundantColumnArr.count) {
        //表不需要更新
        return;
    }
    NSString *primaryKey = [[aClass mtkPrimaryKeyPropertyName]lowercaseString];
    NSMutableArray *sameNameArr = [NSMutableArray arrayWithArray:columnArr];
    [sameNameArr removeObjectsInArray:redundantColumnArr];
    //相同项不包含主键直接重新建表
    if (primaryKey.length && ![sameNameArr containsObject:primaryKey]) {
        [self removeTableWithName:tableName];
        [self createDbTable:aClass andTableKey:tableKey];
        return;
    }
    NSMutableString *sqlString = [NSMutableString string];
    //有冗余项或者主键改变 需要重新建表
    if (redundantColumnArr.count || (primaryKey.length && ![sameNameArr containsObject:primaryKey])) {
        NSString *tempTableKey = @"_temp";
        NSString *tempTableName = [self tableNameWithClass:aClass andtableKey:tempTableKey];
        [self createDbTable:aClass andTableKey:tempTableKey];
        NSMutableString *valueString = [NSMutableString stringWithFormat:@"%@",[sameNameArr componentsJoinedByString:@"',"]];
        if (valueString.length) {
            [valueString insertString:@"'" atIndex:0];
            [valueString appendString:@"'"];
        }
        NSMutableString *copyStr = [NSMutableString stringWithFormat:@"insert into %@ select %@ from %@;",tempTableName,[sameNameArr componentsJoinedByString:@","],tableName];
        NSString *dropStr = [NSString stringWithFormat:@"drop table %@;",tableName];
        NSString *renameStr = [NSString stringWithFormat:@"alter table %@ rename to %@;",tempTableName,tableName];
        [sqlString appendFormat:@"%@ %@ %@",copyStr,dropStr,renameStr];
    }else{
        //不然加上缺少的列就好了
        if (absentColumnArr.count) {
            for (NSInteger i = 0 ; i < absentColumnArr.count; i++) {
                NSString *jsonName = absentColumnArr[i];
                MTKModelPropertyType *type = propertyDic[jsonName];
                if (!type) {
                    continue;
                }
                NSString *addStr =[NSString stringWithFormat:@"alter table %@ add %@ %@;",tableName,jsonName,type.mtkDBType];
                [sqlString appendFormat:@" %@",addStr];
            }
        }
    }
    if (sqlString.length) {
//        if (![self isDBOpen]) {
//            [self openDB];
//        }
        sqlite3 *sqlite3DB = self.sqlite3DB;
        char *errmsg = 0;
        int ret = sqlite3_exec(sqlite3DB, [sqlString UTF8String], NULL, NULL, &errmsg);
        if(ret != SQLITE_OK){
            fprintf(stderr,"set primary key fail: %s\n", errmsg);
        }
        sqlite3_free(errmsg);
    }
//    [self closeDB];
}

//删除表
-(BOOL)removeTableWithName:(NSString*)tableName
{
//    if (![self isDBOpen]) {
//        [self openDB];
//    }
    NSMutableString *sql = [NSMutableString stringWithCapacity:0];
    [sql appendString:@"drop table "];
    [sql appendString:tableName];
    char *errmsg = 0;
    sqlite3 *sqlite3DB = self.sqlite3DB;
    int ret = sqlite3_exec(sqlite3DB,[sql UTF8String], NULL, NULL, &errmsg);
    if(ret != SQLITE_OK){
        fprintf(stderr,"drop table fail: %s\n",errmsg);
    }
    sqlite3_free(errmsg);
//    [self closeDB];
    return YES;
}

-(BOOL)removeDbTableWithClassName:(NSString *)className andTableKey:(NSString *)tableKey
{
    NSMutableString *tableName = [[NSMutableString alloc]initWithString:className];
    if (tableKey.length) {
        [tableName appendFormat:@"_%@",tableKey];
    }
    return [self removeTableWithName:tableName];
}

-(BOOL)removeAllTableWithClassName:(NSString *)className
{
    if (!className.length) {
        return NO;
    }
    NSArray *tableNameArray = [self sqlite_tablename];
    BOOL isSuccess = YES;
    NSString *tempStr = [NSString stringWithFormat:@"%@_",className];
    for (NSString *tableName in tableNameArray) {
        if ([tableName hasPrefix:tempStr] || [className isEqualToString:tableName]) {
            BOOL tempSuccess = [self removeTableWithName:tableName];
            if (!tempSuccess) {
                isSuccess = NO;
            }
        }
    }
    return isSuccess;
}

#pragma mark 数据读写

-(BOOL)saveRowWithObject:(id)object withTableKey:(NSString *)tableKey
{
    if (!object || [object isKindOfClass:[NSNull class]]) {
        //空对象
        return NO;
    }
    NSString *tableName = [self tableNameWithClass:[object class] andtableKey:tableKey];
    if (![self sqlite_tableExistWithTableName:tableName]) {
        [self createDbTable:[object class] andTableKey:tableKey];
    }else{
        [self updateTableContentWithClass:[object class] andTableKey:tableKey];
    }
    NSArray *culumns = [self sqlite_columnNamesArrayWithTableName:tableName];
//    if (!self.isDBOpen) {
//        [self openDB];
//    }
    NSDictionary *propertyDic = [[object class]mtkCachedProperties];
    
    NSMutableString *sql_NSString = [[NSMutableString alloc] initWithFormat:@"insert or replace into %@ values(?)", tableName];
    
    NSRange range = [sql_NSString rangeOfString:@"?"];
//    NSArray *allJsonKeys = [propertyDic allKeys];
    for (int i = 0; i < culumns.count - 1; i++) {
        [sql_NSString insertString:@",?" atIndex:range.location + 1];
    }
    sqlite3_stmt *stmt = NULL;
    sqlite3 *sqlite3DB = self.sqlite3DB;
    const char *errmsg = NULL;
    
    BOOL result = sqlite3_prepare_v2(sqlite3DB, [sql_NSString UTF8String], -1, &stmt, &errmsg) == SQLITE_OK;
    if (result) {
        for (int i = 1; i <= culumns.count; i++) {
            NSString *jsonKey = culumns[i-1];
            MTKModelPropertyType *propertyType = propertyDic[jsonKey];
            if (!propertyType) {
                continue;
            }
            NSString *propertyDBTypeStr = propertyType.mtkDBType;
            id propertyValue = [object valueForKey:propertyType.propertyName];
            id dbValue = [propertyType mtkDBValueForPropertyValue:propertyValue];
            if ([propertyDBTypeStr isEqualToString:DBData]) {
                if (!dbValue || dbValue == [NSNull null] || ![dbValue isKindOfClass:[NSData class]]) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    NSData *data = dbValue;
                    int len = (int)[data length];
                    const void *bytes = [data bytes];
                    sqlite3_bind_blob(stmt, i, bytes, len, NULL);
                }
            } else if ([propertyDBTypeStr isEqualToString:DBText]) {
                if (!dbValue || dbValue == [NSNull null] || ![dbValue isKindOfClass:[NSString class]] || [dbValue length]==0 ) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    sqlite3_bind_text(stmt, i, [dbValue UTF8String], -1, SQLITE_STATIC);
                }
            } else if ([propertyDBTypeStr isEqualToString:DBFloat]) {
                if (!dbValue || dbValue == [NSNull null] || [dbValue isEqual:@""] || ![dbValue respondsToSelector:@selector(doubleValue)]) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    sqlite3_bind_double(stmt, i, [dbValue doubleValue]);
                }
            }
            else if ([propertyDBTypeStr isEqualToString:DBInt]) {
                if (!dbValue || dbValue == [NSNull null] || [dbValue isEqual:@""] || ![dbValue respondsToSelector:@selector(intValue)]) {
                    sqlite3_bind_null(stmt, i);
                } else {
                    sqlite3_bind_int64(stmt, i, [dbValue longValue]);
                }
            }
        }
        int rc = sqlite3_step(stmt);
        if ((rc != SQLITE_DONE) && (rc != SQLITE_ROW)) {
            fprintf(stderr,"save object fail: %s\n",errmsg);
            sqlite3_finalize(stmt);
            stmt = NULL;
//            [self closeDB];
            return NO;
        }
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
//    [self closeDB];
    return YES;
}

-(BOOL)saveObjects:(NSArray *)objectsArray withTableKey:(NSString *)tableKey
{
    if (!objectsArray.count) {
        return NO;
    }
    BOOL success = YES;
    Class aClass = [objectsArray[0] class];
    for (id obj in objectsArray) {
        if ([obj isKindOfClass:aClass]) {
            BOOL suc = [self saveRowWithObject:obj withTableKey:tableKey];
            if (!suc) {
                success = suc;
            }
        }
    }
    return success;
}

-(NSArray *)selectDbObjects:(Class)aClass condition:(NSString *)condition orderby:(NSString *)orderby withTableKey:(NSString *)tableKey
{
    if (!aClass) {
        return nil;
    }
//    if (![self isDBOpen]) {
//        [self openDB];
//    }
    sqlite3_stmt *stmt = NULL;
    NSMutableArray *array = [NSMutableArray array];
    NSMutableString *selectstring = nil;
    NSString *tableName = [self tableNameWithClass:aClass andtableKey:tableKey];
    
    selectstring = [[NSMutableString alloc] initWithFormat:@"select %@ from %@", @"*", tableName];
    if (condition != nil || [condition length] != 0) {
        if (![[condition lowercaseString] isEqualToString:@"all"]) {
            [selectstring appendFormat:@" where %@", condition];
        }
    }
    if (orderby != nil || [orderby length] != 0) {
        if (![[orderby lowercaseString] isEqualToString:@"no"]) {
            [selectstring appendFormat:@" order by %@", orderby];
        }
    }
    
    sqlite3 *sqlite3DB = self.sqlite3DB;
    
    NSDictionary *propertyDic = [aClass mtkCachedProperties];
    
    if (sqlite3_prepare_v2(sqlite3DB, [selectstring UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
        int column_count = sqlite3_column_count(stmt);
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            id obj = [[aClass alloc] init];
            for (int i = 0; i < column_count; i++) {
                const char *column_name = sqlite3_column_name(stmt, i);
                NSString *jsonKey = [NSString stringWithUTF8String:column_name];
                MTKModelPropertyType *propertyType = propertyDic[jsonKey];
                if (!propertyType) {
                    continue;
                }
                const char * column_decltype = sqlite3_column_decltype(stmt, i);
                id column_value = nil;

                NSString *obj_column_decltype = [[NSString stringWithUTF8String:column_decltype]lowercaseString];
                if ([obj_column_decltype isEqualToString:DBText]) {
                    const unsigned char *value = sqlite3_column_text(stmt, i);
                    if (value != NULL) {
                        column_value = [NSString stringWithUTF8String: (const char *)value];
                        id objValue = [propertyType mtkPropertyValueForDBValue:column_value];
                        [obj setValue:objValue forKey:propertyType.propertyName];
                    }
                } else if ([obj_column_decltype isEqualToString:DBInt]) {
                    int value = sqlite3_column_int(stmt, i);
                    column_value = [NSNumber numberWithInt: value];
                    id objValue = [propertyType mtkPropertyValueForDBValue:column_value];
                    [obj setValue:objValue forKey:propertyType.propertyName];
                } else if ([obj_column_decltype isEqualToString:DBFloat]) {
                    double value = sqlite3_column_double(stmt, i);
              
                    column_value = [NSNumber numberWithDouble:value];
                    id objValue = [propertyType mtkPropertyValueForDBValue:column_value];
                    [obj setValue:objValue forKey:propertyType.propertyName];
                
                } else if ([obj_column_decltype isEqualToString:DBData]) {
                    const void *databyte = sqlite3_column_blob(stmt, i);
                    if (databyte != NULL) {
                        int dataLenth = sqlite3_column_bytes(stmt, i);
                        column_value = [NSData dataWithBytes:databyte length:dataLenth];
                        id objValue = [propertyType mtkPropertyValueForDBValue:column_value];
                        [obj setValue:objValue forKey:propertyType.propertyName];
                    }
                } else {
                    const unsigned char *value = sqlite3_column_text(stmt, i);
                    if (value != NULL) {
                        column_value = [NSString stringWithUTF8String: (const char *)value];
                        id objValue = [propertyType mtkPropertyValueForDBValue:column_value];
                        [obj setValue:objValue forKey:propertyType.propertyName];
                    }
                }
            }
            if (obj) {
                if (array == nil) {
                    array = [[NSMutableArray alloc] initWithObjects:obj, nil];
                } else {
                    [array addObject:obj];
                }
            }

        }
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
//    [self closeDB];
    return array;
}

-(BOOL)removeObjectWithClass:(Class)aClass andTableKey:(NSString *)tableKey withCondition:(NSString *)condition
{
    if (!condition.length) {
        return NO;
    }
    NSString *tableName = [self tableNameWithClass:aClass andtableKey:tableKey];
    if (![self sqlite_tableExistWithTableName:tableName]) {
        return YES;
    }
    if ([[condition lowercaseString]isEqualToString:@"all"]) {
        [self removeTableWithName:tableName];
        return YES;
    }
    NSString *sqlString = [NSString stringWithFormat:@"delete from %@ where %@",tableName,condition];
//    if (![self isDBOpen]) {
//        [self openDB];
//    }
    const char *errmsg = 0;
    sqlite3 *sqlite3DB = self.sqlite3DB;
    sqlite3_stmt *stmt = NULL;
    int rc = -1;
    if (sqlite3_prepare_v2(sqlite3DB, [sqlString UTF8String], -1, &stmt, &errmsg) == SQLITE_OK) {
        rc = sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
    if ((rc != SQLITE_DONE) && (rc != SQLITE_ROW)) {
        fprintf(stderr,"remove object fail: %s\n",errmsg);
        return NO;
    }
    return YES;
}

/*
异步方法
*/
//删除类对应的tableKey的表
-(void)removeDbTableWithClassName:(NSString*)className andTableKey:(NSString*)tableKey andCompletion:(MTKOperationResult)completion
{
    dispatch_async(_dbHandleQueue, ^{
        if (![self isDBOpen]) {
            [self openDB];
        }
        BOOL success = [self removeDbTableWithClassName:className andTableKey:tableKey];
        [self closeDB];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
        });
    });
}
//删除类对应的所有表
-(void)removeAllTableWithClassName:(NSString*)className andCompletion:(MTKOperationResult)completion
{
    dispatch_async(_dbHandleQueue, ^{
        if (![self isDBOpen]) {
            [self openDB];
        }
        BOOL success = [self removeAllTableWithClassName:className];
        [self closeDB];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
        });
    });
}
//删除类相关条件的数据 条件为all的时候删除表 为空不处理 condition例 all删除所有 id=930删除id为930的对象
-(void)removeObjectWithClass:(Class)aClass andTableKey:(NSString*)tableKey withCondition:(NSString*)condition andCompletion:(MTKOperationResult)completion
{
    dispatch_async(_dbHandleQueue, ^{
        if (![self isDBOpen]) {
            [self openDB];
        }
        BOOL success = [self removeObjectWithClass:aClass andTableKey:tableKey withCondition:condition];
        [self closeDB];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
        });
    });
}
//存储对象 以类名和tableKey作为表名
-(void)saveRowWithObject:(id)object withTableKey:(NSString*)tableKey andCompletion:(MTKOperationResult)completion
{
    dispatch_async(_dbHandleQueue, ^{
        if (![self isDBOpen]) {
            [self openDB];
        }
        BOOL success = [self saveRowWithObject:object withTableKey:tableKey];
        [self closeDB];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
        });
    });
}
//现在只支持单类型的存储，以首个对象的类型为准
-(void)saveObjects:(NSArray*)objectsArray withTableKey:(NSString*)tableKey andCompletion:(MTKOperationResult)completion
{
    dispatch_async(_dbHandleQueue, ^{
        if (![self isDBOpen]) {
            [self openDB];
        }
        BOOL success = [self saveObjects:objectsArray withTableKey:tableKey];
        [self closeDB];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
        });
    });
}

-(void)selectDbObjects:(Class)aClass condition:(NSString *)condition orderby:(NSString *)orderby withTableKey:(NSString*)tableKey andCompletion:(MTKOperationCompletion)completion
{
    dispatch_async(_dbHandleQueue, ^{
        if (![self isDBOpen]) {
            [self openDB];
        }
        NSArray* resultsArr = [self selectDbObjects:aClass condition:condition orderby:orderby withTableKey:tableKey];
        [self closeDB];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(!!resultsArr,resultsArr);
            }
        });
    });
}

@end
