//
//  Nios_console.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_console.h"
#import "Nios.h"

@implementation Nios_console

+ (id) log:(NSArray*)parameters nios:(Nios*)nios {
	NSLog(@"%@", [parameters objectAtIndex:0]);
	return nil;
}

@end
