//
//  fs.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_fs.h"

@implementation Nios_fs

+ (id) open:(NSArray*)params {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [paths objectAtIndex:0];
	NSString* path = [NSString stringWithFormat:@"/%@", [params objectAtIndex:0]];
	NSDictionary* fd = [[NSDictionary alloc] initWithObjectsAndKeys:
						[documentsPath stringByAppendingString:path], @"path",
						[params objectAtIndex:1], @"flags",
						[params objectAtIndex:2], @"mode",
						nil];

	BOOL directory;
	if ([[fd valueForKey:@"flags"] isEqualToString:@"r"] && ![[NSFileManager defaultManager] fileExistsAtPath:[fd valueForKey:@"path"] isDirectory:&directory]) {
		// XXX: Use exception?
		return [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSNumber numberWithInt:34], @"errno",
										  @"ENOENT", @"code",
										  [params objectAtIndex:0], @"path",
										  nil],
				nil];
	}

	return [NSArray arrayWithObjects:[NSNull null], fd, nil];
}

@end
