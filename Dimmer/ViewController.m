//
//  ViewController.m
//  Dimmer
//
//  Created by xuwf on 13-9-12.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "ViewController.h"
#import "DimmerSwitch.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    DimmerSwitch* swi = [[DimmerSwitch alloc] init];
    
    [swi addTarget:self action:@selector(onDimmerSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    CGSize size = self.view.frame.size;
    swi.center = CGPointMake(size.width/2, size.height/2);
    [self.view addSubview:swi];
}

//- (void)onDimmerSwitchPressed:(DimmerSwitch* )swi {
//    NSLog(@"onDimmerSwitchPressed:on = %d", swi.on);
//}

- (void)onDimmerSwitchValueChanged:(DimmerSwitch* )swi{
    NSLog(@"onDimmerSwitchValueChanged:progress = %f", swi.progress);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
