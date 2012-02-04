//
//  ViewController.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	nios = [[Nios alloc] initWithScriptName:@"index.js"];
}

- (void) dealloc {
	[nios release];
}

@end
