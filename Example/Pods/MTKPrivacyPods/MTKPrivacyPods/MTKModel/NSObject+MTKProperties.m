//
//  NSObject+MTKProperties.m
//  NBJSONModelDemo
//
//  Created by Joy on 15/11/30.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import "NSObject+MTKProperties.h"
#import <objc/runtime.h>

#define MTKTypeIndicator @"T"
#define MTKReadonlyIndicator @"R"

@interface MTKModelPropertyType()
@property (nonatomic,assign) BOOL notManage;
- (instancetype)initWithAttributes:(NSString *)attributes;
@end

@implementation MTKModelPropertyType
+ (NSDictionary *)encodedTypesMap{
    static NSDictionary *encodedTypesMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        encodedTypesMap = @{@"c":@1, @"i":@2, @"s":@3, @"l":@4, @"q":@5,
                            @"C":@6, @"I":@7, @"S":@8, @"L":@9, @"Q":@10,
                            @"B":@11,@"f":@12,@"d":@13,@"v":@14,@"*":@15,
                            @"@":@16,@"#":@17,@":":@18,@"[":@19,@"{":@20,
                            @"(":@21,@"b":@22,@"^":@23,@"?":@24};
    });
    return encodedTypesMap;
}

- (instancetype)initWithAttributes:(NSString *)attributes {
    self = [super init];
    if (self) {
        if (self != nil) {
            NSArray *typeStringComponents = [attributes componentsSeparatedByString:@","];
            //解析类型信息
            if ([typeStringComponents count] > 0) {
                //检查是否包含只读属性
                if ([typeStringComponents containsObject:MTKReadonlyIndicator]) {
                    _notManage = YES;
                    return self;
                }
                //类型信息肯定是放在最前面的且以“T”打头
                NSString *typeInfo = [typeStringComponents objectAtIndex:0];
                NSScanner *scanner = [NSScanner scannerWithString:typeInfo];
                [scanner scanUpToString:MTKTypeIndicator intoString:NULL];
                [scanner scanString:MTKTypeIndicator intoString:NULL];
                NSUInteger scanLocation = scanner.scanLocation;
                if ([typeInfo length] > scanLocation) {
                    NSString *typeCode = [typeInfo substringWithRange:NSMakeRange(scanLocation, 1)];
                    NSNumber *indexNumber = [[self.class encodedTypesMap] objectForKey:typeCode];
                    self.propertyType = (MTKFetchModelPropertyValueType)[indexNumber integerValue];
                    //当当前的类型为对象的时候，解析出对象对应的类型的相关信息
                    //T@"NSArray<MTKMyModel>"
                    if (self.propertyType == MTKClassPropertyTypeObject) {
                        scanner.scanLocation += 1;
                        if ([scanner scanString:@"\"" intoString:NULL]) {
                            NSString *objectClassName = nil;
                            [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                                                intoString:&objectClassName];
                            self.objClass = NSClassFromString(objectClassName);
                            if(![self.objClass conformsToProtocol:@protocol(NSCoding)]){
                                _notManage = YES;
                                return self;
                            }
                            if ([self.objClass isSubclassOfClass:[NSArray class]]) {
                                while ([scanner scanString:@"<" intoString:NULL]) {
                                    NSString* protocolName = nil;
                                    [scanner scanUpToString:@">" intoString: &protocolName];
                                    if (protocolName != nil) {
                                        Class protocalClass = NSClassFromString(protocolName);
                                        if (protocalClass) {
                                            _arrUsedClass = protocalClass;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return self;
}

@end

static const char *MTKPropertiesMapDictionaryKey;

@implementation NSObject (MTKProperties)

+ (NSDictionary*)mtkCachedProperties {
    NSMutableDictionary*propertyMap = objc_getAssociatedObject(self, &MTKPropertiesMapDictionaryKey);
    if (!propertyMap) {
        Class class = self;
        propertyMap = [NSMutableDictionary dictionary];
        while (class != [NSObject class]) {
            unsigned int count;
            objc_property_t *properties = class_copyPropertyList(class, &count);
            NSArray *noManagerArr = [self mtkNoManagePropertyNames];
            for (int i = 0; i < count; i++) {
                objc_property_t property = properties[i];
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
                if ([noManagerArr containsObject:propertyName]) {
                    continue;
                }
                NSString *propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
                MTKModelPropertyType *propertyType = [[MTKModelPropertyType alloc] initWithAttributes:propertyAttributes];
                if (!propertyType.notManage) {
                    propertyType.propertyName = propertyName;
                    propertyMap[[propertyName lowercaseString]] = propertyType;
                }
            }
            free(properties);
            class = [class superclass];
        }
        objc_setAssociatedObject(self, &MTKPropertiesMapDictionaryKey, propertyMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return propertyMap;
}

+(NSString *)mtkPrimaryKeyPropertyName
{
    return @"";
}

+(NSArray*)mtkNoManagePropertyNames
{
    return @[];
}

@end
