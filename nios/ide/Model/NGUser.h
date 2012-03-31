//
//  NGUser.h
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UAGithubEngine;
@interface NGUser : NSObject {
	NSString* avatar_url;
	NSString* bio;
	NSString* blog;
	int collaborators;
	NSString* company;
	NSString* created_at;
	int disk_usage;
	int space;
	NSString* email;
	int followers;
	int following;
	NSString* gravatar_id;
	BOOL hireable;
	NSString* html_url;
	int id;
	NSString* location;
	NSString* login;
	NSString* name;
	int owned_private_repos;
	int private_gists;
	int public_gists;
	int public_repos;
	int total_private_repos;
	NSString* user;
	NSString* url;
	NSString* type;
	id plan;

	UAGithubEngine* engine;
}

@property (retain) UAGithubEngine* engine;

+ (void)loginUsername:(NSString*)username andPassword:(NSString*)password success:(void(^)(NGUser *))successBlock_ failure:(void(^)(NSError *))failureBlock_ ;

@end
