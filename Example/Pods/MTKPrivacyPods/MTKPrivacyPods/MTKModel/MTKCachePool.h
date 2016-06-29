//
//  MTKCachePool.h
//  MaiTalk
//
//  Created by Joy on 15/9/17.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
缓存池！
可以存储可序列化的文件
MTKFetchModel及其子类支持存储
*/

@interface MTKCachePool : NSObject

+(instancetype)sharedCachePool;

@property (atomic,copy) NSString *cachePoolName;

-(void)clearMemoryContent;

-(void)clearAllCachedContent;

-(void)saveObject:(id)object WithKey:(NSString *)key;

//支持两步的缓存
-(BOOL)checkAsynLoadDataNeedToRefreshWithKey:(NSString*)key;

-(id)loadAsynReadObjectPartWithKey:(NSString*)key;

-(void)asynReadObjectWithKey:(NSString *)key andCompletion:(void (^)(id Object))completion;

-(void)saveObjectWithPartObject:(id)objectPart andAllObject:(id)objectAll WithKey:(NSString *)key;

//尝试从内存和文件系统中获取对象
-(id)readObjectWithKey:(NSString *)key;
//只保存在内存中
-(void)saveObjectJustToMemory:(id)object WithKey:(NSString *)key;
//判断是否过期
-(BOOL)checkDataNeedToRefreshWithKey:(NSString*)key;

//只操作文件系统的内容
-(void)saveObjectJustToDisk:(id)object WithKey:(NSString *)key;

-(id)readObjectJustFromDiskWithKey:(NSString *)key;

//存储公共数据
-(id)readObjectWithOutMemberId:(NSString *)key;

-(void)saveObjectWithOutMemberid:(id)object WithKey:(NSString *)key;

@end
