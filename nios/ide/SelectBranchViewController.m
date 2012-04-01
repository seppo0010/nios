//
//  SelectBranchViewController.m
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectBranchViewController.h"
#import "NGUser.h"
#import "NGRepository.h"

@implementation SelectBranchViewController

@synthesize user;
@synthesize repository;

- (void)viewDidLoad {
    [super viewDidLoad];
	if (!branches) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
		[repository getBranches:^(NSArray* _branches){
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
			[branches release];
			branches = [_branches retain];
			[table reloadData];
		} failure:^(NSError* error) {
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
			UIAlertView* alert = [[UIAlertView alloc] init];
			[alert setTitle:@"Ooops..."];
			[alert setMessage:[error localizedDescription]];
			[alert addButtonWithTitle:@"OK"];
			[alert show];
			[alert release];
		}];
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [branches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* identifier = @"branch";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	NSString* branch = [branches objectAtIndex:indexPath.row];
	[[cell textLabel] setText:branch];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* branch = [branches objectAtIndex:indexPath.row];
	[repository downloadBranch:branch success:^void(){
	} failure:^void(NSError* error){
		UIAlertView* alert = [[UIAlertView alloc] init];
		[alert setTitle:@"Ooops..."];
		[alert setMessage:[error localizedDescription]];
		[alert addButtonWithTitle:@"OK"];
		[alert show];
		[alert release];
	}];
}


- (void)viewDidUnload {
    [super viewDidUnload];
	[table release];
	table = nil;
}

- (void) dealloc {
	[branches release];
	[table release];
	[super dealloc];
}

@end
