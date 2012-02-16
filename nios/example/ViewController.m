//
//  ViewController.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	nios = [[Nios alloc] initWithScriptName:@"index.js" delegate:self];
}

- (void)textViewDidChange:(UITextView *)_textView {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:textView.text], @"parameters", @"setText", @"callback", @"1", @"keepCallback", nil]];
}

- (IBAction)startStop {
	NSDictionary* message;
	if (listening) {
		message = [NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"callback", @"1", @"keepCallback", nil];

		// Stopping is automatic, no callback
		listening = FALSE;
		[startStopButton setTitle:@"Start" forState:UIControlStateNormal];
	} else {
		message = [NSDictionary dictionaryWithObjectsAndKeys:@"start", @"callback", @"1", @"keepCallback", nil];
	}
	[nios sendMessage:message];
}

- (void) nios:(Nios*)nios didSendMessage:(NSDictionary*)dictionary {
	if ([[dictionary valueForKey:@"parameters"] isKindOfClass:[NSArray class]]) {
		NSArray* params = [dictionary valueForKey:@"parameters"];
		if ([params count] > 0) {
			if ([[params objectAtIndex:0] isEqual:@"listening"]) {
				[startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
				listening = TRUE;
			}
		}
	}
}

- (void) dealloc {
	[nios release];
}

@end
