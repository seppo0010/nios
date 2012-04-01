//
//  NGUser.m
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NGUser.h"
#import "NSThread+BlockAddition.h"
#import "UAGithubEngine.h"
#import "NSObject+DictionaryInitialization.h"
#import "NGRepository.h"

@implementation NGUser

@synthesize engine;

+ (void)loginUsername:(NSString*)username andPassword:(NSString*)password success:(void(^)(NGUser *))successBlock_ failure:(void(^)(NSError *))failureBlock_  {
	[NSThread performBlockInBackground:^() {
		UAGithubEngine* engine = [[UAGithubEngine alloc] initWithUsername:username password:password withReachability:YES];
		[engine user:username completion:^id(id response) {
			if ([response isKindOfClass:[NSError class]]) {
				[[NSThread mainThread] performBlock:^() { failureBlock_(response); }];
			} else {
				NGUser* user = [[[NGUser alloc] initWithDictionary_n:[response objectAtIndex:0]] autorelease];
				user.engine = engine;
				[[NSThread mainThread] performBlock:^() { successBlock_(user); }];
			}
			return nil;
		}];
		[engine release];
	}];
}

- (void) getRepositories:(void(^)(NSArray *))successBlock_ failure:(void(^)(NSError *))failureBlock_  {
	[NSThread performBlockInBackground:^() {
		[engine repositoriesForUser:login includeWatched:NO completion:^id(id response) {
			if ([response isKindOfClass:[NSError class]]) {
				[[NSThread mainThread] performBlock:^() { failureBlock_(response); }];
			} else if ([response isKindOfClass:[NSArray class]]) {
				NSMutableArray* _repositories = [NSMutableArray arrayWithCapacity:[response count]];
				for (NSDictionary* repository in response) {
					[_repositories addObject:[[[NGRepository alloc] initWithDictionary_n:repository] autorelease]];
				}
				NSArray* repositories = [_repositories copy];
				[[NSThread mainThread] performBlock:^() { successBlock_(repositories); }];
			} else {
				[[NSThread mainThread] performBlock:^() { failureBlock_(nil); }];
			}
			return nil;
		}];
	}];
}

- (void) dealloc {
	[avatar_url release];
	[bio release];
	[blog release];
	[company release];
	[created_at release];
	[email release];
	[gravatar_id release];
	[html_url release];
	[location release];
	[login release];
	[name release];
	[user release];
	[url release];
	[type release];
	[plan release];
	[engine release];
	[super dealloc];
}

@end
