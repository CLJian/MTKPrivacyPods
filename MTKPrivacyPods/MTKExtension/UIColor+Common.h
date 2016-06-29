//
//  UIColor+Common.h
//  MaiTalk
//
//  Created by Joy on 15/4/16.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Common)
+ (UIColor *) colorFromHexRGB:(NSString *) inColorString;
/**
 *  将图片转为UIColor对象
 *
 *  @param imageName 图片名称
 *  @param frame     显示的区域
 *
 *  @return UIColor对象
 */
+ (UIColor *)ImageToColorWithName:(NSString *)imageName frame:(CGRect)frame;

/**
 *  十六进制颜色
 *
 *  @param hexString 十六进制字符串
 *
 *  @return UIColor对象
 */
+ (UIColor *) colorFromHexString:(NSString *)hexString;

/**
 *  十六进制颜色
 *
 *  @param hexColor #号开头的十六进制字符串
 *
 *  @return UIColor对象
 */
+ (UIColor *)colorWithHexStringTwo:(NSString *)hexColor;

/**
 *  颜色渐变
 *
 *  @param c1     开始颜色
 *  @param c2     结束颜色
 *  @param height 高
 *
 *  @return 渐变后的颜色
 */
+ (UIColor*)gradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withHeight:(int)height;

/**
 *  随机颜色
 *
 *  @return 随机颜色
 */
+ (UIColor *)randomColor;
@end
