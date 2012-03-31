//
//  ViewController.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "NGUser.h"
#import "SelectRepositoryViewController.h"
#import "SFHFKeychainUtils.h"

@implementation ViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	NSString* _username = [[NSUserDefaults standardUserDefaults] objectForKey:@"github.username"];
	if (_username) {
		username.text = _username;
		NSString* _password = [SFHFKeychainUtils getPasswordForUsername:_username andServiceName:@"github" error:nil];
		if (_password) {
			password.text = _password;
			[self login];
		}
	}
}

- (void) startedLogin {
	[activityIndicator startAnimating];
	username.enabled = NO;
	password.enabled = NO;
	loginButton.enabled = NO;
}

- (void) finishedLogin {
	[activityIndicator stopAnimating];
	username.enabled = YES;
	password.enabled = YES;
	loginButton.enabled = YES;
}

- (IBAction)login {
	[self startedLogin];
	[NGUser loginUsername:username.text andPassword:password.text success:^(NGUser* user) {
		NSError* error;
		if (![SFHFKeychainUtils storeUsername:username.text andPassword:password.text forServiceName:@"github" updateExisting:YES error:&error]) {
			UIAlertView* alert = [[UIAlertView alloc] init];
			[alert setTitle:@"Ooops..."];
			[alert setMessage:[error localizedDescription]];
			[alert addButtonWithTitle:@"OK"];
			[alert show];
			return;
		}
		[[NSUserDefaults standardUserDefaults] setObject:username.text forKey:@"github.username"];

		[self finishedLogin];
		SelectRepositoryViewController* controller = [[SelectRepositoryViewController alloc] init];
		controller.user = user;
		[self presentModalViewController:controller animated:YES];
		[controller release];
	} failure:^(NSError* error) {
		[self finishedLogin];
		UIAlertView* alert = [[UIAlertView alloc] init];
		[alert setTitle:@"Ooops..."];
		[alert setMessage:[error localizedDescription]];
		[alert addButtonWithTitle:@"OK"];
		[alert show];
	}];
}

- (void) viewDidUnload {
	[super viewDidUnload];
	[username release];
	[password release];
	[activityIndicator release];
	[loginButton release];
	username = password = nil;
	activityIndicator = nil;
	loginButton = nil;
}

- (void) dealloc {
	[loginButton release];
	[activityIndicator release];
	[username release];
	[password release];
	[super dealloc];
}

@end