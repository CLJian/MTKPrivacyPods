//
//  MTKViewController.m
//  MTKPrivacyPods
//
//  Created by Joy on 06/17/2016.
//  Copyright (c) 2016 Joy. All rights reserved.
//

#import "MTKViewController.h"
#import <MTKExtension.h>
#import "MTKJsonModel.h"
#import "MTKDBHandle.h"

#import "MTKTestModel.h"

@interface MTKViewController ()

@end

@implementation MTKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MTKTestModel *model = [MTKTestModel new];
    model.tttttt = @"dsdasda";
    
    //    NSDictionary *dic = @{@"tttttt":@"ddddd" , @"rrrrr":@"vvvv"};
    //
    //    [model injectJSONData:dic];
    //
    //    NSLog(@"%@",model);

    
    [[MTKDBHandle sharedDBHandle]saveRowWithObject:model withTableKey:@"2222" andCompletion:^(BOOL success) {
        
    }];
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
