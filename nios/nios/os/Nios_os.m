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
#include <sys/sysctl.h>

@implementation Nios_os

+ (id) hostname:(NSArray*)parameters nios:(Nios*)nios {
	char name[255];
	if (gethostname(name, 255) == 0) {
		return [NSArray arrayWithObject:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
	}
	return [NSArray arrayWithObject:@""];
}

+ (id) type:(NSArray*)parameters nios:(Nios*)nios {
	return [NSArray arrayWithObject:[[UIDevice currentDevice] systemName]];
}

+ (id) release:(NSArray*)parameters nios:(Nios*)nios {
	return [NSArray arrayWithObject:[[UIDevice currentDevice] systemVersion]];
}

+ (id) uptime:(NSArray*)parameters nios:(Nios*)nios {
	struct timeval value;
	size_t size = sizeof(value);
	if (sysctlbyname("kern.boottime", &value, &size, NULL, 0) == 0) {
		struct timeval current_time = {0,0};
		
		if (gettimeofday(&current_time,NULL) == 0) {
			return [NSArray arrayWithObject:[NSNumber numberWithLong:current_time.tv_sec - value.tv_sec]];
		}
	}
	
	return [NSArray arrayWithObject:[NSNumber numberWithLong:0]];
}

+ (id) cpus:(NSArray*)parameters nios:(Nios*)nios {
	int value;
	size_t size = sizeof(value);
	if (sysctlbyname("hw.physicalcpu", &value, &size, NULL, 0) == 0) {
		return [NSArray arrayWithObject:[NSNumber numberWithInt:value]];
	}
	
	return [NSArray arrayWithObject:[NSNumber numberWithInt:0]];
}

@end
