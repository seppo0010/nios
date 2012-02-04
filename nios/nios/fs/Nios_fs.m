//
//  fs.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_fs.h"

@implementation Nios_fs_fd

@synthesize path;
@synthesize flags;
@synthesize mode;

- (void) dealloc {
	[path release];
	[flags release];
	[mode release];
	[super dealloc];
}
@end

@implementation Nios_fs

+ (id) open:(NSArray*)params {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [paths objectAtIndex:0];
	;

	Nios_fs_fd* fd = [[Nios_fs_fd alloc] init];
	fd.path = [documentsPath stringByAppendingString:[params objectAtIndex:0]];
	fd.flags = [params objectAtIndex:1];
	fd.mode = [params objectAtIndex:2];
	[[NSFileManager defaultManager] createFileAtPath:fd.path contents:nil attributes:nil];
	return fd;
}

@end
