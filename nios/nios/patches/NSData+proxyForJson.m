//
//  NSData+NSData_proxyForJson.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData+proxyForJson.h"

@implementation NSData (proxyForJson)

- (NSString*)proxyForJson {
	NSMutableString* str = [NSMutableString stringWithCapacity:[self length] * 4];
	NSUInteger length = [self length];
	const char * bytes = [self bytes];
	for (NSUInteger pos = 0; pos < length; pos++) {
		[str appendFormat:@"\\u%04x", bytes[pos]];
	}
	return [[str copy] autorelease];
}

@end
