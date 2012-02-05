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
		return [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"ENOENT, No such file or directory \'%@\'", [params objectAtIndex:0]], @"message",
										  [NSNumber numberWithInt:34], @"errno",
										  @"ENOENT", @"code",
										  [params objectAtIndex:0], @"path",
										  nil],
				nil];
	}

	return [NSArray arrayWithObjects:[NSNull null], fd, nil];
}

+ (id) readFile:(NSArray*)params {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [paths objectAtIndex:0];
	NSString* path = [documentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@", [params objectAtIndex:0]]];

	BOOL directory;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory]) {
		return [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"ENOENT, No such file or directory \'%@\'", [params objectAtIndex:0]], @"message",
										  [NSNumber numberWithInt:34], @"errno",
										  @"ENOENT", @"code",
										  [params objectAtIndex:0], @"path",
										  nil],
				nil];
	}
	if (directory) {
		return [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
										  @"illegal operation on a directory", @"message",
										  [NSNumber numberWithInt:28], @"errno",
										  @"EISDIR", @"code",
										  [params objectAtIndex:0], @"path",
										  nil],
				nil];
	}

	id ret = [NSData dataWithContentsOfFile:path];
	if ([[params objectAtIndex:1] isKindOfClass:[NSNull class]]) {
	} else if ([[params objectAtIndex:1] isEqualToString:@"utf8"]) {
		ret = [[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease];
	} else if ([[params objectAtIndex:1] isEqualToString:@"ascii"]) {
		ret = [[[NSString alloc] initWithData:ret encoding:NSASCIIStringEncoding] autorelease];
	}
	return [NSArray arrayWithObjects:[NSNull null], ret, nil];
}

@end
