//
//  UIImage+Common.m
//  MaiTalk
//
//  Created by Joy on 15/4/21.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import "UIImage+Common.h"

@implementation UIImage (Common)

+(UIImage *)imageFromView:(UIView *)view
{
//    UIGraphicsBeginImageContextWithOptions(view.bounds.size, 0, [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    //Create a context of the appropriate size
    UIGraphicsBeginImageContext(size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //Build a rect of appropriate size at origin 0,0
    CGRect fillRect = CGRectMake(0, 0, size.width, size.height);
    
    //Set the fill color
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    
    //Fill the color
    CGContextFillRect(currentContext, fillRect);
    
    //Snap the picture and close the context
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorImage;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imageSize = CGSizeMake(self.size.width / self.scale,
                                  self.size.height / self.scale);
    
    CGFloat widthRatio = imageSize.width / size.width;
    CGFloat heightRatio = imageSize.height / size.height;
    
    if (widthRatio > heightRatio) {
        imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio);
    } else {
        imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio);
    }
    
    return imageSize;
}

-(UIImage *)imageWithBlurLevel:(CGFloat)blurLevel
{
    //创建CIContext对象
    CIImage *image = [CIImage imageWithCGImage:self.CGImage];
    
    CIContext * context = [CIContext contextWithOptions:nil];
    //创建CIFilter
    CIFilter * gaussianBlur = [CIFilter filterWithName:@"CIGaussianBlur"];
    //设置滤镜输入参数
    [gaussianBlur setValue:image forKey:kCIInputImageKey];
    //设置模糊参数
    [gaussianBlur setValue:@(blurLevel) forKey:@"inputRadius"];
    
    //得到处理后的图片
    CIImage* resultImage = gaussianBlur.outputImage;
    CGImageRef imageRef = [context createCGImage:resultImage fromRect:CGRectMake(3, 0, resultImage.extent.size.width + resultImage.extent.origin.x * 2 - 6, resultImage.extent.size.height + resultImage.extent.origin.y * 2)];
    UIImage * imge = [[UIImage alloc]initWithCGImage:imageRef];

    CFRelease(imageRef);
    return imge;
}
- (instancetype)circleWithRadius:(CGFloat)radius {
    //2.开启上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2, radius * 2), NO, 0.0);
    //3.取得当前的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //4.画圆
    CGRect circleRect = CGRectMake(0, 0, radius * 2, radius * 2);
    CGContextAddEllipseInRect(ctx, circleRect);
    //5.裁剪(按照当前的路径形状裁剪)
    CGContextClip(ctx);
    //6.画图
    [self drawInRect:circleRect];
    //7.取图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //8.结束
    UIGraphicsEndImageContext();
    return newImage;
}

+ (instancetype)imageFromColors:(NSArray*)colors ByGradientType:(GradientType)gradientType size:(CGSize)size{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case 0:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        case 1:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, 0.0);
            break;
        case 2:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, size.height);
            break;
        case 3:
            start = CGPointMake(size.width, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;

}
@end
