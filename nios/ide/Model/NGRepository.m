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
#import "UAGithubEngine.h"
#import "NSThread+BlockAddition.h"
#import "NSData+Base64.h"

@implementation NGRepository

@synthesize user;
@synthesize name;

- (void) getBranches:(void(^)(NSArray*))successBlock_ failure:(void(^)(NSError *))failureBlock_ {
	[NSThread performBlockInBackground:^() {
		[user.engine branchesForRepository:[NSString stringWithFormat:@"%@/%@", user.login, name] completion:^id(id response) {
			if ([response isKindOfClass:[NSError class]]) {
				[[NSThread mainThread] performBlock:^() { failureBlock_(response); }];
			} else if ([response isKindOfClass:[NSArray class]]) {
				NSMutableArray* _branches = [NSMutableArray arrayWithCapacity:[response count]];
				for (NSDictionary* branch in response) {
					[_branches addObject:[branch valueForKey:@"name"]];
				}
				NSArray* branches = [_branches copy];
				[[NSThread mainThread] performBlock:^() { successBlock_(branches); }];
			} else {
				[[NSThread mainThread] performBlock:^() { failureBlock_(nil); }];
			}
			return nil;
		}];
	}];
}

- (BOOL) isDownloaded {
	return FALSE;
}

- (void) downloadBranch:(NSString*)branchName success:(void(^)())successBlock_ failure:(void(^)(NSError *))failureBlock_ {
//	[NSThread performBlockInBackground:^() {
	NSString* repo = [NSString stringWithFormat:@"%@/%@", user.login, name];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [paths objectAtIndex:0];
	NSString* path = [[documentsPath stringByAppendingPathComponent:repo] stringByAppendingPathComponent:branchName];
	
	NSError* error;
	if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
		failureBlock_(error);
		return;
	}
	[user.engine reference:[NSString stringWithFormat:@"heads/%@", branchName] inRepository:repo completion:^id(id response) {
		if ([response isKindOfClass:[NSError class]]) {
			failureBlock_(error);
			return nil;
		} else if (response != nil && [response isKindOfClass:[NSArray class]] == FALSE) {
			failureBlock_(nil);
			return nil;
		}
		NSString* treeSha = [[[response objectAtIndex:0] valueForKey:@"object"] valueForKey:@"sha"];
		[user.engine tree:treeSha inRepository:repo recursive:YES completion:^id(id response) {
			NSArray* tree = [[response objectAtIndex:0] valueForKey:@"tree"];
			for (NSDictionary* file in tree) {
				[user.engine blobForSHA:[file valueForKey:@"sha"] inRepository:repo completion:^id(id blobs) {
					if ([blobs isKindOfClass:[NSError class]]) {
						failureBlock_(error);
						return nil;
					} else if (blobs != nil && [blobs isKindOfClass:[NSArray class]] == FALSE) {
						failureBlock_(nil);
						return nil;
					}

					NSError* error;
					NSDictionary* blob = [blobs objectAtIndex:0];
					NSString* encodedContent = [blob valueForKey:@"content"];
					NSData* content;
					if ([[blob valueForKey:@"encoding"] isEqual:@"base64"]) {
						content = [NSData dataFromBase64String:encodedContent];
					} else if ([[blob valueForKey:@"encoding"] isEqual:@"utf-8"]) {
						content = [encodedContent dataUsingEncoding:NSUTF8StringEncoding];
					}
					if (![content writeToFile:[path stringByAppendingPathComponent:[file valueForKey:@"path"]] options:NSDataWritingAtomic error:&error]) {
						failureBlock_(error);
						return nil;
					}
					return nil;
				}];
			}
			return nil;
		}];
		return nil;
	}];
//	}];
	
}
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
