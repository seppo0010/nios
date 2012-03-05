//
//  ViewController.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation ViewController

// Get IP Address
- (NSString *)getIPAddress {    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];               
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
	
}

- (void) viewDidLoad {
	[super viewDidLoad];
	nios = [[Nios alloc] initWithScriptName:@"index.js" delegate:self];
}

- (void) niosDidFinishLoading:(Nios*)nios {
	[self textViewDidChange:textView];
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
				[[[[UIAlertView alloc] initWithTitle:@"Now listening..." message:[NSString stringWithFormat:@"Open a browser pointing to http://%@:8080/", [self getIPAddress]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
			}
		}
	}
}

- (void) dealloc {
	[nios release];
	[super dealloc];
}

@end
