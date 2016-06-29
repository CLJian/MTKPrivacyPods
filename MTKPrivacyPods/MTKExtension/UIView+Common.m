//
//  UIView+Common.m
//  MaiTalk
//
//  Created by Joy on 15/4/10.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import "UIView+Common.h"

@implementation UIView (Common)

-(void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}
-(CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

-(void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = [borderColor CGColor];
}

-(UIColor *)borderColor
{
    CGColorRef ref = self.layer.borderColor;
    if (ref) {
        return [UIColor colorWithCGColor:ref];
    }else{
        return nil;
    }
}

-(void)setBorderWidth:(CGFloat)borderWidth
{
    CGFloat scale = [UIScreen mainScreen].scale;
    NSInteger pixelNum = borderWidth / (1 / scale);
    CGFloat usedWith = pixelNum ? (CGFloat)pixelNum/scale : borderWidth;
    self.layer.borderWidth = usedWith;
}

-(CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

-(void)setTop:(CGFloat)top
{
    CGRect rect = self.frame;
    rect.origin.y = top;
    self.frame = rect;
}

-(CGFloat)top
{
    return self.frame.origin.y;
}

-(void)setBottom:(CGFloat)bottom
{
    CGRect rect = self.frame;
    rect.origin.y = bottom - self.frame.size.height;
    self.frame = rect;
}

-(CGFloat)bottom
{
    return self.frame.size.height + self.frame.origin.y;
}

-(void)setLeft:(CGFloat)left
{
    CGRect rect = self.frame;
    rect.origin.x = left;
    self.frame = rect;
}

-(CGFloat)left
{
    return self.frame.origin.x;
}


-(void)setRight:(CGFloat)right
{
    CGRect rect = self.frame;
    rect.origin.x = right - self.frame.size.width;
    self.frame = rect;
}

-(CGFloat)right
{
    return self.frame.size.width + self.frame.origin.x;
}

-(void)setWidth:(CGFloat)width
{
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

-(CGFloat)width
{
    return self.frame.size.width;
}

-(void)setHeight:(CGFloat)height
{
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame =rect;
}

-(CGFloat)height
{
    return  self.frame.size.height;
}


-(id)copyWithZone:(NSZone *)zone
{
    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:self];
    id view = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
    return view;
}

+ (instancetype)getViewFromNib {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    for (UIView *view in views) {
        if ([view isKindOfClass:[self class]]) {
            return view;
        }
    }
    return nil;
}


- (UIView *)findFirstResponder{
    
    UIView *firstResponder = nil;
    if (self.isFirstResponder) {
        firstResponder = self;
    }else{
        
        for (UIView *view in self.subviews) {
            
            if (view.isFirstResponder) {
                firstResponder = view;
                break;
            }else{
                
                firstResponder = [view findFirstResponder];
                if (firstResponder) {
                    break;
                }
            }
        }
    }
    return firstResponder;
}


@end
