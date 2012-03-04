//
//  Nios_os.m
//  nios
//
//  Created by Sebastian Waisbrot on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_os.h"
#import "Nios.h"
#include <unistd.h>

@implementation Nios_os

+ (id) hostname:(NSArray*)parameters nios:(Nios*)nios {
	char name[255];
	if (gethostname(name, 255) == 0) {
		return [NSArray arrayWithObject:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
	}
	return [NSArray arrayWithObject:@""];
}

@end
