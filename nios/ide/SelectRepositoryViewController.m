;//
//  SelectRepositoryViewController.m
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectRepositoryViewController.h"
#import "NGUser.h"
#import "NGRepository.h"

@implementation SelectRepositoryViewController

@synthesize user;

- (void) viewDidLoad {
	[super viewDidLoad];
	if (repositories == nil) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
		[user getRepositories:^(NSArray* _repositories) {
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
			[repositories release];
			repositories = [_repositories retain];
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
	return [repositories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* identifier = @"repository";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	NGRepository* repository = [repositories objectAtIndex:indexPath.row];
	[[cell textLabel] setText:repository.name];
	return cell;
}

- (void) viewDidUnload {
	[super viewDidUnload];
	[table release];
	table = nil;
}

- (void) dealloc {
	self.user = nil;
	[table release];
	[super dealloc];
}

@end
