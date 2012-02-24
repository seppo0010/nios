//
//  Nios_crypto.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_crypto.h"
#import "Nios.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Nios_crypto

+ (id) digest:(NSArray*)params nios:(Nios*)nios {
	NSString* algorithm = [params objectAtIndex:0];
	NSString* data = [params objectAtIndex:1];
	NSString* input_encoding = [params objectAtIndex:2];
	NSString* encoding = [params objectAtIndex:3];

	NSData* input = nil;
	if ([input_encoding isKindOfClass:[NSNull class]] || [input_encoding isEqualToString:@"utf8"]) {
		input = [data dataUsingEncoding:NSUTF8StringEncoding];
	} else {
		[NSException raise:@"Unsupport input encoding" format:@"Unsupport input encoding: '%@'", input_encoding];
	}

	uint8_t* digest = NULL;
	if ([algorithm isEqualToString:@"sha1"]) {
		digest = malloc(sizeof(uint8_t) * CC_SHA1_DIGEST_LENGTH);
		CC_SHA1(input.bytes, input.length, digest);
	} else {
		[NSException raise:@"Unsupport algorithm" format:@"Unsupport algorithm: '%@'", algorithm];
	}

	if ([encoding isEqualToString:@"hex"]) {
		NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
		
		for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
			[output appendFormat:@"%02x", digest[i]];

		free(digest);
		return [NSArray arrayWithObject:output];
	} else if ([encoding isEqualToString:@"base64"]) {
		NSMutableData* output = [NSMutableData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
		free(digest);
		return [NSArray arrayWithObject:[output base64EncodedString]];
	} else {
		free(digest);
		[NSException raise:@"Unsupport encoding" format:@"Unsupport encoding: '%@'", encoding];
	}

	return nil;
}

@end

/*
 
 @implementation SHA1
 
 +(NSString*) digest:(NSString*)input
 {
 const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
 NSData *data = [NSData dataWithBytes:cstr length:input.length];
 
 uint8_t digest[CC_SHA1_DIGEST_LENGTH];
 
 CC_SHA1(data.bytes, data.length, digest);
 
 NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
 
 for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
 [output appendFormat:@"%02x", digest[i]];
 
 return output;
 
 }
 @end  */
