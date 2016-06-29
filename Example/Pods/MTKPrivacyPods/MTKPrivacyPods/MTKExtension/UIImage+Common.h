//
//  UIImage+Common.h
//  MaiTalk
//
//  Created by Joy on 15/4/21.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum  {
    topToBottom = 0,//从上到下
    leftToRight = 1,//从左到右
    upleftTolowRight = 2,//左上到右下
    uprightTolowLeft = 3,//右上到左下
}GradientType;
@interface UIImage (Common)
+ (UIImage *)imageFromView:(UIView*)view;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)imageWithBlurLevel:(CGFloat)blurLevel;
- (CGSize)sizeThatFits:(CGSize)size;
- (instancetype)circleWithRadius:(CGFloat)radius;

+ (instancetype)imageFromColors:(NSArray*)colors ByGradientType:(GradientType)gradientType size:(CGSize)size;
@end
