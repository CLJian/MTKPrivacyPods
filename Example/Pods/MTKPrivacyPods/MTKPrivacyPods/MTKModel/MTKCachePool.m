//
//  MTKCachePool.m
//  MaiTalk
//
//  Created by Joy on 15/9/17.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import "MTKCachePool.h"

#define kExpirationTimeHour 48

#define kCachePoolPathName @"MTKCaiZhuCachePoolFolder"

@interface MTKCachePool ()
@property (nonatomic,readonly)NSCache *cache;
@end

@implementation MTKCachePool

+(instancetype)sharedCachePool
{
    static MTKCachePool* pool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [[MTKCachePool alloc] init];
    });
    return pool;
}

-(id)init
{
    if (self=[super init]) {
        _cache=[[NSCache alloc]init];
    }
    return self;
}

-(void)clearMemoryContent
{
    [_cache removeAllObjects];
}

-(void)clearAllCachedContent
{
    [self clearMemoryContent];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString *folderDir = [cacheDirectory stringByAppendingPathComponent: kCachePoolPathName];
        NSString *pastFolderDir = [cacheDirectory stringByAppendingPathComponent: @"MTKCachePoolFolder"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:folderDir error:nil];
        [fileManager removeItemAtPath:pastFolderDir error:nil];
    });
}

#pragma mark 保存
-(void)saveObjectJustToMemory:(id)object WithKey:(NSString *)key
{
//    if (![MTKLoginModel sharedInstance].hasLoggedIn) {
//        return;
//    }
    key = [self getKeyFromKeyName:key];
    if (object==nil) {
        [_cache removeObjectForKey:key];
        return;
    }
    [_cache setObject:object forKey:key];
}

-(void)saveObjectJustToDisk:(id)object WithKey:(NSString *)key
{
//    if (![MTKLoginModel sharedInstance].hasLoggedIn) {
//        return;
//    }
    key = [self getKeyFromKeyName:key];
    if ([object conformsToProtocol:@protocol(NSCopying)]) {
        object = [object copy];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSKeyedArchiver archiveRootObject:object toFile:[self filePathWithName:key]];
    });
}

-(void)saveObject:(id)object WithKey:(NSString *)key
{
//    if (![MTKLoginModel sharedInstance].hasLoggedIn) {
//        return;
//    }
    key = [self getKeyFromKeyName:key];
    if (object==nil) {
        [_cache removeObjectForKey:key];
        NSFileManager *manager=[NSFileManager defaultManager];
        [manager removeItemAtPath:[self filePathWithName:key] error:nil];
        return;
    }
    [_cache setObject:object forKey:key];
    if ([object conformsToProtocol:@protocol(NSCopying)]) {
        object = [object copy];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSKeyedArchiver archiveRootObject:object toFile:[self filePathWithName:key]];
    });
}

#pragma mark 读取
-(id)readObjectWithKey:(NSString *)key
{
    NSString *usedKey = [self getKeyFromKeyName:key];
    if(key==nil){
        return nil;
    }
    NSData *cacheData = [_cache objectForKey:usedKey];
    if(cacheData){
        return cacheData;
    }else{
        id object=[self readObjectJustFromDiskWithKey:key];
        if (object) {
            [_cache setObject:object forKey:usedKey];
        }
        return object;
    }
}

-(id)readObjectJustFromDiskWithKey:(NSString *)key
{
    key = [self getKeyFromKeyName:key];
    
    NSString *filepath =[self filePathWithName:key];
    id object;
    BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:filepath];
    if(isDirExist){
        
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    }
    return object;
}

//分段存储

-(id)loadAsynReadObjectPartWithKey:(NSString*)key
{
    NSString *keyPart = [NSString stringWithFormat:@"%@_Part",key];
    id objPart = [self readObjectWithKey:keyPart];
    return objPart;
}

-(void)asynReadObjectWithKey:(NSString *)key andCompletion:(void (^)(id))completion
{
    NSString *keyAll = [NSString stringWithFormat:@"%@_all",key];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        id objAll = [self readObjectJustFromDiskWithKey:keyAll];
        completion(objAll);
    });
}

-(void)saveObjectWithPartObject:(id)objectPart andAllObject:(id)objectAll WithKey:(NSString *)key
{
//    if (![MTKLoginModel sharedInstance].hasLoggedIn) {
//        return;
//    }
    NSString *keyAll = [NSString stringWithFormat:@"%@_all",key];
    NSString *keyPart = [NSString stringWithFormat:@"%@_Part",key];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self saveObject:objectPart WithKey:keyPart];
        [self saveObjectJustToDisk:objectAll WithKey:keyAll];
    });
}

-(BOOL)checkAsynLoadDataNeedToRefreshWithKey:(NSString*)key
{
    NSString *keyPart = [self getKeyFromKeyName:[NSString stringWithFormat:@"%@_Part",key]];
    NSString *keyPath = [self filePathWithName:keyPart];
    BOOL expire = [self judgeFileIsExpireWithFilePath:keyPath];
    return expire;
}


//存储公共数据
-(id)readObjectWithOutMemberId:(NSString *)key
{
    if(key==nil){
        return nil;
    }
    NSData *cacheData = [_cache objectForKey:key];
    if(cacheData){
        return cacheData;
    }else{
        NSString *filepath =[self filePathWithName:key];
        id object;
        BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:filepath];
        if(isDirExist){
            object=[NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
        }
        return object;
    }
}

-(void)saveObjectWithOutMemberid:(id)object WithKey:(NSString *)key
{
    if (object==nil) {
        [_cache removeObjectForKey:key];
        NSFileManager *manager=[NSFileManager defaultManager];
        [manager removeItemAtPath:[self filePathWithName:key] error:nil];
        return;
    }
    [_cache setObject:object forKey:key];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSKeyedArchiver archiveRootObject:object toFile:[self filePathWithName:key]];
    });
}

#pragma mark

-(NSString*)getKeyFromKeyName:(NSString *)name
{
    NSString *key = [NSString stringWithFormat:@"%@-%@",_cachePoolName,name];
    return key;
}

-(NSString*)filePathWithName:(NSString* )fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *folderDir = [cacheDirectory stringByAppendingPathComponent: kCachePoolPathName];
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

-(BOOL)checkDataNeedToRefreshWithKey:(NSString*)key
{
    key = [self getKeyFromKeyName:key];
    NSString *keyPath = [self filePathWithName:key];
    BOOL expire = [self judgeFileIsExpireWithFilePath:keyPath];
    return expire;
}

-(BOOL)judgeFileIsExpireWithFilePath:(NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
    if (fileAttributes != nil) {
        NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
//        NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
        NSDate *nowDate = [NSDate date];
        NSTimeInterval timeInterval = [nowDate timeIntervalSinceDate:fileModDate];
        double timeHour = timeInterval / 3600;
        if (timeHour < kExpirationTimeHour) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

@end
