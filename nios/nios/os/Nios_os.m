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
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <net/if.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>
#include <mach/mach_init.h>
#include <mach/vm_map.h>

#define NS_IN6ADDRSZ    16
#define NS_INT16SZ      2

// This two functions are extracted from libuv
static const char *
inet_ntop4(const unsigned char *src, char *dst, size_t size)
{
    static const char fmt[] = "%u.%u.%u.%u";
    char tmp[sizeof("255.255.255.255")];
	
    if ((size_t)sprintf(tmp, fmt, src[0], src[1], src[2], src[3]) >= size) {
		return (NULL);
    }
    strcpy(dst, tmp);
    return (dst);
}

static const char *
inet_ntop6(const unsigned char *src, char *dst, size_t size)
{
    /*
     * Note that int32_t and int16_t need only be "at least" large enough
     * to contain a value of the specified size.  On some systems, like
     * Crays, there is no such thing as an integer variable with 16 bits.
     * Keep this in mind if you think this function should have been coded
     * to use pointer overlays.  All the world's not a VAX.
     */
    char tmp[sizeof("ffff:ffff:ffff:ffff:ffff:ffff:255.255.255.255")];
    char *tp;
    struct { int base, len; } best, cur;
    unsigned int words[NS_IN6ADDRSZ / NS_INT16SZ];
    int i;
	
    /*
     * Preprocess:
     *  Copy the input (bytewise) array into a wordwise array.
     *  Find the longest run of 0x00's in src[] for :: shorthanding.
     */
    memset(words, '\0', sizeof(words));
    for (i = 0; i < NS_IN6ADDRSZ; i++)
		words[i / 2] |= (src[i] << ((1 - (i % 2)) << 3));
    best.base = -1;
    best.len = 0;
    cur.base = -1;
	cur.len = 0;
    for (i = 0; i < (NS_IN6ADDRSZ / NS_INT16SZ); i++) {
		if (words[i] == 0) {
			if (cur.base == -1)
				cur.base = i, cur.len = 1;
			else
				cur.len++;
		} else {
			if (cur.base != -1) {
				if (best.base == -1 || cur.len > best.len)
					best = cur;
				cur.base = -1;
			}
		}
    }
    if (cur.base != -1) {
		if (best.base == -1 || cur.len > best.len)
			best = cur;
    }
    if (best.base != -1 && best.len < 2)
		best.base = -1;
	
    /*
     * Format the result.
     */
    tp = tmp;
    for (i = 0; i < (NS_IN6ADDRSZ / NS_INT16SZ); i++) {
		/* Are we inside the best run of 0x00's? */
		if (best.base != -1 && i >= best.base &&
			i < (best.base + best.len)) {
			if (i == best.base)
				*tp++ = ':';
			continue;
		}
		/* Are we following an initial run of 0x00s or any real hex? */
		if (i != 0)
			*tp++ = ':';
		/* Is this address an encapsulated IPv4? */
		if (i == 6 && best.base == 0 && (best.len == 6 ||
										 (best.len == 7 && words[7] != 0x0001) ||
										 (best.len == 5 && words[5] == 0xffff))) {
			if (!inet_ntop4(src+12, tp, sizeof(tmp) - (tp - tmp)))
				return (NULL);
			tp += strlen(tp);
			break;
		}
		tp += sprintf(tp, "%x", words[i]);
    }
    /* Was it a trailing run of 0x00's? */
    if (best.base != -1 && (best.base + best.len) ==
        (NS_IN6ADDRSZ / NS_INT16SZ))
		*tp++ = ':';
    *tp++ = '\0';
	
    /*
     * Check for overflow, copy, and we're done.
     */
    if ((size_t)(tp - tmp) > size) {
		return (NULL);
    }
    strcpy(dst, tmp);
    return (dst);
}

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
    unsigned int ticks = (unsigned int)sysconf(_SC_CLK_TCK),
	multiplier = ((uint64_t)1000L / ticks);
    char model[512];
    uint64_t cpuspeed;
    size_t size;
    unsigned int i;
    natural_t numcpus;
    mach_msg_type_number_t msg_type;
    processor_cpu_load_info_data_t *info;
	
    size = sizeof(model);
    if (sysctlbyname("hw.model", &model, &size, NULL, 0) < 0) {
		return nil;
    }
    size = sizeof(cpuspeed);
    if (sysctlbyname("hw.cpufrequency", &cpuspeed, &size, NULL, 0) < 0) {
		return nil;
    }
	
    if (host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numcpus,
                            (processor_info_array_t*)&info,
                            &msg_type) != KERN_SUCCESS) {
		return nil;
    }
	
	NSMutableArray* cpu_info = [NSMutableArray arrayWithCapacity:numcpus];

    for (i = 0; i < numcpus; i++) {
		[cpu_info addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 [NSString stringWithFormat:@"%s", model], @"model",
							 [NSNumber numberWithUnsignedLongLong:cpuspeed/1000000], @"speed",
							 [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithUnsignedLongLong:(uint64_t)(info[i].cpu_ticks[0]) * multiplier], @"user",
							  [NSNumber numberWithUnsignedLongLong:(uint64_t)(info[i].cpu_ticks[3]) * multiplier], @"nice",
							  [NSNumber numberWithUnsignedLongLong:(uint64_t)(info[i].cpu_ticks[1]) * multiplier], @"sys",
							  [NSNumber numberWithUnsignedLongLong:(uint64_t)(info[i].cpu_ticks[2]) * multiplier], @"idle",
							  [NSNumber numberWithUnsignedLongLong:0], @"irq",
							  nil], @"times",
							 nil]];		
    }
    vm_deallocate(mach_task_self(), (vm_address_t)info, msg_type);
	
	return [NSArray arrayWithObject:cpu_info];
}

+ (id) networkInterfaces:(NSArray*)parameters nios:(Nios*)nios {
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
	NSMutableDictionary* returnInterfaces = [NSMutableDictionary dictionaryWithCapacity:1];
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
			NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
			NSMutableArray* addresses = [returnInterfaces valueForKey:name];
			if (!addresses) {
				addresses = [NSMutableArray arrayWithCapacity:3];
				[returnInterfaces setValue:addresses forKey:name];
			}
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
				NSString *address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				[addresses addObject:[NSDictionary dictionaryWithObjectsAndKeys:address, @"address", @"IPv4", @"family", [NSNumber numberWithBool:temp_addr->ifa_flags & IFF_LOOPBACK ? TRUE : FALSE], @"internal", nil]];
            } else if (temp_addr->ifa_addr->sa_family == AF_INET6) {
				char dst[255]; size_t size = 255;
				inet_ntop6((const void*)&((struct sockaddr_in6 *)temp_addr->ifa_addr)->sin6_addr, dst, size);
				NSString *address = [NSString stringWithUTF8String:dst];
				[addresses addObject:[NSDictionary dictionaryWithObjectsAndKeys:address, @"address", @"IPv6", @"family", [NSNumber numberWithBool:temp_addr->ifa_flags & IFF_LOOPBACK ? TRUE : FALSE], @"internal", nil]];
			}
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return [NSArray arrayWithObject:returnInterfaces];

}

@end
