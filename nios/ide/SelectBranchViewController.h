//
//  SelectBranchViewController.h
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NGUser;
@class NGRepository;
@interface SelectBranchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NGUser* user;
	NGRepository* repository;
	NSArray* branches;
	IBOutlet UITableView* table;
}

@property (retain) NGUser* user;
@property (retain) NGRepository* repository;

@end
