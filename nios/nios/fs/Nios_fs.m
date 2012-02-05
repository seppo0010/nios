//
//  fs.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_fs.h"
#include <fcntl.h>
#include <sys/stat.h>

@implementation Nios_fs

+ (NSString*) fullPathforPath:(NSString*)path {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [paths objectAtIndex:0];
	return [NSString stringWithFormat:@"%@/%@", documentsPath, path];
}

+ (id) errorForCode:(int)code forFile:(NSString*)file {
	switch (code) {
		case ENOENT:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"ENOENT, No such file or directory \'%@\'", file], @"message",
					[NSNumber numberWithInt:34], @"errno",
					@"ENOENT", @"code",
					file, @"path",
					nil];
		case EACCES:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"EACCES, permission denied '%@'", file], @"message",
					[NSNumber numberWithInt:3], @"errno",
					@"EACCES", @"code",
					file, @"path",
					nil];
		case EFAULT:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"EFAULT, '%@'", file], @"message",
					[NSNumber numberWithInt:-1], @"errno",
					@"EFAULT", @"code",
					file, @"path",
					nil];
		case EISDIR:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"EISDIR, illegal operation on a directory '%@'", file], @"message",
					[NSNumber numberWithInt:28], @"errno",
					@"EISDIR", @"code",
					file, @"path",
					nil];
		case ELOOP:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"ELOOP, too many symbolic links are encountered '%@'", file], @"message",
					[NSNumber numberWithInt:-1], @"errno",
					@"ELOOP", @"code",
					file, @"path",
					nil];
		case ENAMETOOLONG:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"ELOOP, name too long '%@'", file], @"message",
					[NSNumber numberWithInt:-1], @"errno",
					@"ENAMETOOLONG", @"code",
					file, @"path",
					nil];
		case ENOTDIR:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"ELOOP, not a directory '%@'", file], @"message",
					[NSNumber numberWithInt:27], @"errno",
					@"ENOTDIR", @"code",
					file, @"path",
					nil];
		case EROFS:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"ELOOP, file resides on a read-only file system '%@'", file], @"message",
					[NSNumber numberWithInt:-1], @"errno",
					@"EROFS", @"code",
					file, @"path",
					nil];
		case ETXTBSY:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"ETXTBSY, file is a pure procedure (shared text) file that is being executed '%@'", file], @"message",
					[NSNumber numberWithInt:-1], @"errno",
					@"ETXTBSY", @"code",
					file, @"path",
					nil];
		case EFBIG:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"EFBIG, length argument was greater than the maximum file size '%@'", file], @"message",
					[NSNumber numberWithInt:-1], @"errno",
					@"EFBIG", @"code",
					file, @"path",
					nil];
		case EINTR:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"EINTR, signal is caught during execution '%@'", file], @"message",
					[NSNumber numberWithInt:-1], @"errno",
					@"EINTR", @"code",
					file, @"path",
					nil];
		case EINVAL:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"EINVAL, length argument is less than 0 '%@'", file], @"message",
					[NSNumber numberWithInt:-1], @"errno",
					@"EINVAL", @"code",
					file, @"path",
					nil];
		case EIO:
			return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"EIO, I/O error occurred while reading from or writing to a file system '%@'", file], @"message",
					[NSNumber numberWithInt:-1], @"errno",
					@"EIO", @"code",
					file, @"path",
					nil];
	}
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSString stringWithFormat:@"UNKNOWN, unknown error '%@'", file], @"message",
			[NSNumber numberWithInt:-1], @"errno",
			@"UNKNOWN", @"code",
			file, @"path",
			nil];
}

+ (id) open:(NSArray*)params {
	NSString* path = [self fullPathforPath:[params objectAtIndex:0]];
	BOOL directory;
	if ([[[params objectAtIndex:2] valueForKey:@"flags"] isEqualToString:@"r"] && ![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory]) {
		return [NSArray arrayWithObject:[self errorForCode:ENOENT forFile:[params objectAtIndex:0]]];
	}

	int fp = open([path UTF8String], [[params objectAtIndex:1] intValue], [[params objectAtIndex:2] intValue]);
	return [NSNumber numberWithInt:fp];
}

+ (id) readFile:(NSArray*)params {
	NSString* path = [self fullPathforPath:[params objectAtIndex:0]];

	BOOL directory;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory]) {
		return [NSArray arrayWithObject:[self errorForCode:ENOENT forFile:[params objectAtIndex:0]]];
	}
	if (directory) {
		return [NSArray arrayWithObject:[self errorForCode:EISDIR forFile:[params objectAtIndex:0]]];
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

+ (id) rename:(NSArray*)params {
	NSString* path = [self fullPathforPath:[params objectAtIndex:0]];
	NSString* targetPath = [self fullPathforPath:[params objectAtIndex:1]];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		return [NSArray arrayWithObject:[self errorForCode:ENOENT forFile:[params objectAtIndex:0]]];
	}
	
	NSError* error;
	BOOL success = [[NSFileManager defaultManager] moveItemAtPath:path toPath:targetPath error:&error];
	if (!success) {
		return [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
										  [error description], @"message",
										  [NSNumber numberWithInt:error.code], @"errno",
										  [params objectAtIndex:0], @"path",
										  nil],
				nil];
	}
	return [NSArray arrayWithObject:[NSNull null]];
}

+ (id) truncate:(NSArray*)params {
	NSString* path = [self fullPathforPath:[params objectAtIndex:0]];
	int result = truncate([path UTF8String], [[params objectAtIndex:1] intValue]);
	if (result != 0) {
		return [NSArray arrayWithObjects:[self errorForCode:result forFile:[params objectAtIndex:0]],nil];
	}
	return [NSArray arrayWithObject:[NSNull null]];
}

+ (id) chown:(NSArray*)params {
	NSString* path = [self fullPathforPath:[params objectAtIndex:0]];
	
	int result = chown([path UTF8String], (unsigned int)[[params objectAtIndex:1] unsignedIntValue], (unsigned int)[[params objectAtIndex:2] unsignedIntValue]);
	if (result != 0) {
		return [NSArray arrayWithObject:[self errorForCode:result forFile:[params objectAtIndex:0]]];
	}
	return [NSArray arrayWithObject:[NSNull null]];
}

+ (id) lchown:(NSArray*)params {
	NSString* path = [self fullPathforPath:[params objectAtIndex:0]];
	
	int result = lchown([path UTF8String], (unsigned int)[[params objectAtIndex:1] unsignedIntValue], (unsigned int)[[params objectAtIndex:2] unsignedIntValue]);
	if (result != 0) {
		return [NSArray arrayWithObject:[self errorForCode:result forFile:[params objectAtIndex:0]]];
	}
	return [NSArray arrayWithObject:[NSNull null]];
}

+ (id) fchown:(NSArray*)params {
	int fd = [[params objectAtIndex:0] intValue];
	
	int result = fchown(fd, (unsigned int)[[params objectAtIndex:1] unsignedIntValue], (unsigned int)[[params objectAtIndex:2] unsignedIntValue]);
	if (result != 0) {
		return [NSArray arrayWithObject:[self errorForCode:result forFile:[params objectAtIndex:0]]];
	}
	return [NSArray arrayWithObject:[NSNull null]];
}

+ (id) chmod:(NSArray*)params {
	NSString* path = [self fullPathforPath:[params objectAtIndex:0]];
	
	int result = chmod([path UTF8String], (unsigned int)[[params objectAtIndex:1] unsignedIntValue]);
	if (result != 0) {
		return [NSArray arrayWithObject:[self errorForCode:result forFile:[params objectAtIndex:0]]];
	}
	return [NSArray arrayWithObject:[NSNull null]];
}

+ (id) lchmod:(NSArray*)params {
	NSString* path = [self fullPathforPath:[params objectAtIndex:0]];
	
	int result = lchmod([path UTF8String], (unsigned int)[[params objectAtIndex:1] unsignedIntValue]);
	if (result != 0) {
		return [NSArray arrayWithObject:[self errorForCode:result forFile:[params objectAtIndex:0]]];
	}
	return [NSArray arrayWithObject:[NSNull null]];
}

+ (id) fchmod:(NSArray*)params {
	int fd = [[params objectAtIndex:0] intValue];
	
	int result = fchmod(fd, (unsigned int)[[params objectAtIndex:1] unsignedIntValue]);
	if (result != 0) {
		return [NSArray arrayWithObject:[self errorForCode:result forFile:[params objectAtIndex:0]]];
	}
	return [NSArray arrayWithObject:[NSNull null]];
}

+ (id) statFromStruct:(struct stat*)st {
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[dateFormatter setDateFormat:@"E', 'd' 'MMM' 'yyyy' 'HH':'mm':'ss' 'zzz"];
	NSString* atime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:st->st_atimespec.tv_sec]];
	NSString* mtime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:st->st_mtimespec.tv_sec]];
	NSString* ctime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:st->st_ctimespec.tv_sec]];
	[dateFormatter release];
	return [NSArray arrayWithObjects:[NSNull null], [NSDictionary dictionaryWithObjectsAndKeys:
													 [NSNumber numberWithUnsignedInt:st->st_dev], @"dev",
													 [NSNumber numberWithUnsignedLong:st->st_ino], @"ino",
													 [NSNumber numberWithUnsignedInt:st->st_mode], @"mode",
													 [NSNumber numberWithUnsignedInt:st->st_nlink], @"nlink",
													 [NSNumber numberWithUnsignedInt:st->st_uid], @"uid",
													 [NSNumber numberWithUnsignedInt:st->st_gid], @"gid",
													 [NSNumber numberWithUnsignedInt:st->st_rdev], @"rdev",
													 [NSNumber numberWithUnsignedLong:st->st_size], @"size",
													 [NSNumber numberWithUnsignedInt:st->st_blksize], @"blksize",
													 [NSNumber numberWithUnsignedLong:st->st_blocks], @"blocks",
													 atime, @"atime",
													 mtime, @"mtime",
													 ctime, @"ctime",
													 nil],
			nil];
}

+ (id) stat:(NSArray*)params {
	NSString* path = [self fullPathforPath:[params objectAtIndex:0]];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		return [NSArray arrayWithObject:[self errorForCode:ENOENT forFile:[params objectAtIndex:0]]];
	}
	
	struct stat st;
	stat([path UTF8String], &st);
	return [NSArray arrayWithObjects:[NSNull null], [self statFromStruct:&st], nil];
}

+ (id) lstat:(NSArray*)params {
	NSString* path = [self fullPathforPath:[params objectAtIndex:0]];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		return [NSArray arrayWithObject:[self errorForCode:ENOENT forFile:[params objectAtIndex:0]]];
	}
	
	struct stat st;
	lstat([path UTF8String], &st);
	return [NSArray arrayWithObjects:[NSNull null], [self statFromStruct:&st], nil];
}

+ (id) fstat:(NSArray*)params {
	int fd = [[params objectAtIndex:0] intValue];
	
	struct stat st;
	fstat(fd, &st);
	return [NSArray arrayWithObjects:[NSNull null], [self statFromStruct:&st], nil];
}

@end
