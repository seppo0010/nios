//
//  ViewController.h
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextViewDelegate> {
	IBOutlet UITextField* username;
	IBOutlet UITextField* password;
	IBOutlet UIActivityIndicatorView* activityIndicator;
	IBOutlet UIButton* loginButton;
}

- (IBAction)login;

@end