//
//  UITabBar+MTKTabbar.m
//  MaiTalk
//
//  Created by Duke on 15/7/13.
//  Copyright (c) 2015年 duomai. All rights reserved.
//


#import "UITabBar+MTKTabbar.h"
#import "MTKExtension.h"

#define kBaseTag 1000

@interface UITabBar (Catagory)

@end

@implementation UITabBar (MTKTabbar)

-(BOOL)isBadgeShowWithIndex:(NSInteger)badgeIndex
{
    NSInteger tag = kBaseTag+badgeIndex;
    UIView *badge = [self viewWithTag:tag];
    if (!badge || badge.hidden == YES) {
        return NO;
    }
    return YES;
}

-(void)showBadgeWithIndex:(NSInteger)badgeIndex
{
    NSInteger tag = kBaseTag+badgeIndex;
    UIView *badge = [self viewWithTag:tag];
    if (!badge) {
        badge = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        badge.backgroundColor = [UIColor redColor];
        badge.layer.cornerRadius = 5;
        badge.clipsToBounds = YES;
        CGPoint center = CGPointMake((self.width/4)*(badgeIndex+1) -25 , 10);
        badge.center = center;
        badge.tag = tag;
        [self addSubview:badge];
    }
    badge.hidden = NO;
}

-(void)hideBadgeWithIndex:(NSInteger)badgeIndex
{
    NSInteger tag = kBaseTag+badgeIndex;
    UIView *badge = [self viewWithTag:tag];
    badge.hidden = YES;
}

-(void)hideAllBadge
{
    for (UIView *view in self.subviews) {
        if (view.tag >= kBaseTag) {
            view.hidden = YES;
        }
    }
}


@end
