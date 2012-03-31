//
//  SelectRepositoryViewController.m
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectRepositoryViewController.h"
#import "NGUser.h"

@implementation SelectRepositoryViewController

@synthesize user;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}


- (void) dealloc {
	self.user = nil;
	[super dealloc];
}

@end
