//
//  NSThread+BlockAddition.h
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (BlockAddition)
- (void)performBlock:(void (^)())block;
- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait;
+ (void)performBlockInBackground:(void (^)())block;
@end
