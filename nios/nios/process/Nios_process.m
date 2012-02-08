//
//  Nios_process.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_process.h"

@implementation Nios_process

+ (id) exit:(NSArray*)params nios:(Nios*)nios {
	exit([[params objectAtIndex:0] intValue]);
}

@end
