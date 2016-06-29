//
//  UIAlertView+Common.m
//  MaiTalk
//
//  Created by Joy on 15/4/22.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import "UIAlertView+Common.h"
#import "UIColor+Common.h"

@interface UIAlertViewDelegateProxy : NSObject<UIAlertViewDelegate>
+(instancetype)sharedDelegateProxy;
@property (nonatomic,strong) NSMutableDictionary *completionMap;
-(void)setCompletion:(UIAlertViewCompletion)completion forAllertView:(UIAlertView*)allertView;
@end

@implementation UIAlertViewDelegateProxy
+(instancetype)sharedDelegateProxy
{
    static UIAlertViewDelegateProxy *proxy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxy = [[UIAlertViewDelegateProxy alloc]init];
    });
    return proxy;
}

-(instancetype)init
{
    if (self = [super init]) {
        _completionMap = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)setCompletion:(UIAlertViewCompletion)completion forAllertView:(UIAlertView *)allertView
{
    allertView.delegate = self;
    [_completionMap setObject:[completion copy] forKey:@(allertView.hash)];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSAssert(alertView, @"alertView Can not be nil");
    if (!alertView) {
        return;
    }
    UIAlertViewCompletion completion = _completionMap[@(alertView.hash)];
    if (completion) {
        completion(alertView, NO, buttonIndex);
    }
    [_completionMap removeObjectForKey:@(alertView.hash)];
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    NSAssert(alertView, @"alertView Can not be nil");
    if (!alertView) {
        return;
    }
    UIAlertViewCompletion completion = _completionMap[@(alertView.hash)];
    if (completion) {
        completion(alertView, YES, -1);
    }
    [_completionMap removeObjectForKey:@(alertView.hash)];
}
@end

@implementation UIAlertView (Common)
- (void)showWithCompletion:(UIAlertViewCompletion)completion
{
    UIAlertViewDelegateProxy *proxy = [UIAlertViewDelegateProxy sharedDelegateProxy];
    if (completion) {
        [proxy setCompletion:completion forAllertView:self];
    }
    [self show];
}
@end
