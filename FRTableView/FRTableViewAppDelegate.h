//
//  FRTableViewAppDelegate.h
//  FRTableView
//
//  Created by Jonathan Dalrymple on 04/08/2011.
//  Copyright 2011 Float:Right Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRTableViewViewController;

@interface FRTableViewAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet FRTableViewViewController *viewController;

@end
