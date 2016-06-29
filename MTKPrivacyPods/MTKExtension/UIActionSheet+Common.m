//
//  UIActionSheet+Common.m
//  MaiTalk
//
//  Created by Joy on 15/5/8.
//  Copyright (c) 2015年 duomai. All rights reserved.
//

#import "UIActionSheet+Common.h"
#import "UIColor+Common.h"

@interface UIActionSheetDelegateProxy : NSObject<UIActionSheetDelegate>
+(instancetype)sharedDelegateProxy;
@property (nonatomic,strong) NSMutableDictionary *completionMap;
-(void)setCompletion:(UIActionSheetCompletion)completion forActionSheet:(UIActionSheet*)actionSheet;
@end

@implementation UIActionSheetDelegateProxy
+(instancetype)sharedDelegateProxy
{
    static UIActionSheetDelegateProxy *proxy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxy = [[UIActionSheetDelegateProxy alloc]init];
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

-(void)setCompletion:(UIActionSheetCompletion)completion forActionSheet:(UIActionSheet*)actionSheet;
{
    actionSheet.delegate = self;
    [_completionMap setObject:completion forKey:@(actionSheet.hash)];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIActionSheetCompletion completion = _completionMap[@(actionSheet.hash)];
    if (completion) {
        completion(actionSheet,buttonIndex);
    }
    [_completionMap removeObjectForKey:@(actionSheet.hash)];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [_completionMap removeObjectForKey:@(actionSheet.hash)];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subViwe in actionSheet.subviews) {
        if ([subViwe isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subViwe;
            [button setTitleColor:[UIColor colorFromHexRGB:@"#000000"] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:18];
        }
    }
}

@end

@implementation UIActionSheet (Common)
- (void)showInView:(UIView*)view WithCompletion:(UIActionSheetCompletion)completion;
{
    UIActionSheetDelegateProxy *proxy = [UIActionSheetDelegateProxy sharedDelegateProxy];
    if (completion) {
        [proxy setCompletion:completion forActionSheet:self];
    }
    
    [self showInView:view];
}

@end
