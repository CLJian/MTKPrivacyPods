//
//  NSObject+MTKProperties.h
//  NBJSONModelDemo
//
//  Created by Joy on 15/11/30.
//  Copyright © 2015年 XiaoMai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MTKFetchModelPropertyValueType) {
    MTKClassPropertyValueTypeNone = 0,
    MTKClassPropertyTypeChar,
    MTKClassPropertyTypeInt,
    MTKClassPropertyTypeShort,
    MTKClassPropertyTypeLong,
    MTKClassPropertyTypeLongLong,
    MTKClassPropertyTypeUnsignedChar,
    MTKClassPropertyTypeUnsignedInt,
    MTKClassPropertyTypeUnsignedShort,
    MTKClassPropertyTypeUnsignedLong,
    MTKClassPropertyTypeUnsignedLongLong,
    MTKClassPropertyTypeBool,
    MTKClassPropertyTypeFloat,
    MTKClassPropertyTypeDouble,
    MTKClassPropertyTypeVoid,
    MTKClassPropertyTypeCharString,
    MTKClassPropertyTypeObject,
    MTKClassPropertyTypeClassObject,
    MTKClassPropertyTypeSelector,
    MTKClassPropertyTypeArray,
    MTKClassPropertyTypeStruct,
    MTKClassPropertyTypeUnion,
    MTKClassPropertyTypeBitField,
    MTKClassPropertyTypePointer,
    MTKClassPropertyTypeUnknow
};

@interface MTKModelPropertyType : NSObject
@property (nonatomic, copy) NSString *propertyName;
//数组内部使用 以协议标识
@property (nonatomic, assign) Class objClass;
//正常的类型 当属性类型为对象的时候使用
@property (nonatomic, assign) Class arrUsedClass;
//属性类型 上述情况并未完全处理
@property (nonatomic, assign)MTKFetchModelPropertyValueType propertyType;

@end

@interface NSObject (MTKProperties)
//存储的属性表 字典键为小写 只有基本数据类型 支持NSCoding协议的对象支持自动解析
+(NSDictionary*)mtkCachedProperties;
//存储数据库的主键名 不可随意更新 主键的更新需要优化 现在属性减少会重建表 小写
+(NSString*)mtkPrimaryKeyPropertyName;
//不进行持久化保存和自动化解析的键 都要小写...
+(NSArray*)mtkNoManagePropertyNames;

@end
