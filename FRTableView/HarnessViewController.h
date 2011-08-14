//
//  HarnessViewController.h
//  FRTableView
//
//  Created by Jonathan Dalrymple on 04/08/2011.
//  Copyright 2011 Float:Right Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRListView.h"

@interface HarnessViewController : UIViewController<FRListViewDelegate,FRListViewDataSource>{
    
	FRListView *listView;
	NSUInteger	count_;
}
@property (nonatomic, retain) IBOutlet FRListView *listView;

@end
