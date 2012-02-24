//
//  Nios_ios.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_ios.h"
#import "Nios.h"
#import <AudioToolbox/AudioToolbox.h>

//static void completionCallback (SystemSoundID  mySSID, void *_info) {
//    NSDictionary* info = (NSDictionary*)_info;
//	NSString* callback = [info valueForKey:@"callback"];
//	Nios* nios = [info valueForKey:@"nios"];
//	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:callback, @"callback", nil]];
//    AudioServicesRemoveSystemSoundCompletion(mySSID);
//	[info release];
//}

@implementation Nios_ios

+ (void) vibrate:(NSArray*)params nios:(Nios*)nios {
//	if ([params count] >= 1) {
//		AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, completionCallback, [[NSDictionary dictionaryWithObjectsAndKeys:nios, @"nois", [params objectAtIndex:0], @"callback", nil] retain]);
//	}
	AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void) alert:(NSArray*)params nios:(Nios*)nios {
	UIAlertView* alert = [[UIAlertView alloc] init];
	alert.title = [params objectAtIndex:0];
	alert.message = [params objectAtIndex:1];
	[alert addButtonWithTitle:@"OK"];
	[alert show];
	[alert release];
}

@end
