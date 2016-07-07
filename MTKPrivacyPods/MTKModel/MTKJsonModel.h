//
//  MTKJsonModel.h
//  NBJSONModelDemo
//
//  Created by Joy on 15/11/30.
//  Copyright © 2015年 XiaoMai. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
所有属性大小写不敏感
*/

@interface MTKJsonModel : NSObject<NSCoding,NSCopying>

- (instancetype)initWithJSONDict:(NSDictionary *)dict;
//替换模型数据 只能处理字典
- (void)injectJSONData:(NSDictionary*)jsonData;
//替换模型数据
- (void)injectDataWithModel:(MTKJsonModel*)model;

- (NSDictionary *)jsonDict;

- (NSString *)jsonString;

//键的map @{Json字段名称:属性名称} 都使用小写
+(NSDictionary *)mtkJsonModelKeyMapper;

@end
