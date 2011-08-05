//
//  HarnessViewController.m
//  FRTableView
//
//  Created by Jonathan Dalrymple on 04/08/2011.
//  Copyright 2011 Float:Right Ltd. All rights reserved.
//

#import "HarnessViewController.h"


@implementation HarnessViewController
@synthesize listView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [listView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	NSLog(@"List View %@",listView);
	
	[[self listView] setStickToBottom:YES];
	
	[[self listView] setDataSource:self];
}

-(id) listView:(FRListView*) aListView cellForRowAtIndexPath:(NSIndexPath*) aPath{
	
	id view;
	
	view = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	
	[view setText:[NSString stringWithFormat:@"Cell %d",[aPath row]]];
	
	if( [aPath row] % 2 ){
		[view setBackgroundColor:[UIColor greenColor]];		
	}
	else{
		[view setBackgroundColor:[UIColor blueColor]];
	}
	
	return view;
}

-(NSUInteger) numberOfRowsInListView:(FRListView*) aView{
	
	return 50;
}

- (void)viewDidUnload
{

    [self setListView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
