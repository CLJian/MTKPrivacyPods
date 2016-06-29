//
//  UITabBar+MTKTabbar.h
//  MaiTalk
//
//  Created by Duke on 15/7/13.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (MTKTabbar)

-(void)showBadgeWithIndex:(NSInteger)badgeIndex;
-(void)hideBadgeWithIndex:(NSInteger)badgeIndex;
-(void)hideAllBadge;
-(BOOL)isBadgeShowWithIndex:(NSInteger)badgeIndex;

@end
