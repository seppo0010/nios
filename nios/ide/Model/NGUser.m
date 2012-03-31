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

@end
