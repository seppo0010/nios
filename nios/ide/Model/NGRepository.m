//
//  NGRepository.m
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NGRepository.h"
#import "NGUser.h"
#import "NSObject+DictionaryInitialization.h"

@implementation NGRepository

@synthesize name;

- (void) setOwner:(id)_owner {
	[[_owner retain] autorelease];
	[owner release];
	if (_owner == nil || [_owner isKindOfClass:[NGUser class]]) {
		owner = _owner;
	} else if ([_owner isKindOfClass:[NSDictionary class]]) {
		owner = [[NGUser alloc] initWithDictionary_n:_owner];
	} else {
		[NSException raise:@"Invalid parameter for setOwner:" format:@"Invalid parameter for setOwner:. Must be a NGUser or an NSDictionary, '%@' received", NSStringFromClass([_owner class])];
	}
}

- (void) dealloc {
	[clone_url release];
	[created_at release];
	[description release];
	[git_url release];
	[homepage release];
	[html_url release];
	[language release];
	[mirror_url release];
	[name release];
	[owner release];
	[pushed_at release];
	[ssh_url release];
	[svn_url release];
	[updated_at release];
	[url release];
	[master_branch release];
	[super dealloc];
}

@end
