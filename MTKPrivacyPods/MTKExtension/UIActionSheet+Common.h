//
//  UIActionSheet+Common.h
//  MaiTalk
//
//  Created by Joy on 15/5/8.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIActionSheetCompletion)(UIActionSheet *actionSheet, NSInteger buttonIdx);

@interface UIActionSheet (Common)
- (void)showInView:(UIView*)view WithCompletion:(UIActionSheetCompletion)completion;
@end
