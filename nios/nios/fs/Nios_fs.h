//
//  fs.h
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Nios_fs_fd : NSObject {
	NSString* path;
	NSString* flags;
	NSString* mode;
}

@property (retain) NSString* path;
@property (retain) NSString* flags;
@property (retain) NSString* mode;

@end

@interface Nios_fs : NSObject

@end
