//
//  ViewController.h
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Nios.h"

@interface ViewController : UIViewController <UITextViewDelegate, NiosDelegate> {
	Nios* nios;
	IBOutlet UITextView* textView;
	IBOutlet UIButton* startStopButton;
	BOOL listening;
}

- (IBAction)startStop;

@end
