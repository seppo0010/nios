//
//  NGRepository.h
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NGUser;
@interface NGRepository : NSObject {
	NSString* clone_url;
	NSString* created_at;
	NSString* description;
	BOOL fork;
	int forks;
	NSString* git_url;
	BOOL has_downloads;
	BOOL has_issues;
	BOOL has_wiki;
	NSString* homepage;
	NSString* html_url;
	int id;
	NSString* language;
	NSString* mirror_url;
	NSString* name;
	int open_issues;
	NGUser* owner;
	int private;
	NSString* pushed_at;
	int size;
	NSString* ssh_url;
	NSString* svn_url;
	NSString* updated_at;
	NSString* url;
	NSString* master_branch;
	int watchers;
}

@property (retain) NSString* name;

@end
