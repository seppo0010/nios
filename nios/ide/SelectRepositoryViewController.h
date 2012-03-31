//
//  SelectRepositoryViewController.h
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NGUser;
@interface SelectRepositoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NGUser* user;
	NSArray* repositories;
}

@property (retain) NGUser* user;

@end
