//
//  UIAlertView+Common.h
//  MaiTalk
//
//  Created by Joy on 15/4/22.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIAlertViewCompletion)(UIAlertView *alertView, BOOL canceled, NSInteger buttonIdx);

@interface UIAlertView (Common)
- (void)showWithCompletion:(UIAlertViewCompletion)completion;
@end
