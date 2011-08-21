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
	
	count_ = 100;
	
	[[self listView] setStickToBottom:YES];
	
	[[self listView] setDataSource:self];
	
	[[self listView] setDelegate:self];
	
//	[NSTimer scheduledTimerWithTimeInterval:5.0f
//									 target:self 
//								   selector:@selector(update) 
//								   userInfo:nil 
//									repeats:YES
//	 ];
}

-(void) update{
	
	count_++;
	
	[[self listView] setNeedsReload];
}

#pragma mark - DataSource
-(id) listView:(FRListView*) aListView cellForRowAtIndex:(NSUInteger) aRow{
	
	UITableViewCell *cell;
	
	if( !(cell = [aListView dequeueReusableCellWithIdentifier:@"cell"]) ){
		NSLog(@"Created cell");
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:@"cell"] autorelease];
	}
	
	[[cell textLabel] setText:[NSString stringWithFormat:@"Cell %d",aRow]];
	
	if( aRow % 2 ){
		[[cell textLabel] setBackgroundColor:[UIColor greenColor]];		
	}
	else{
		[[cell textLabel] setBackgroundColor:[UIColor blueColor]];
	}
	
	return cell;
}

-(NSUInteger) numberOfRowsInListView:(FRListView*) aView{
	
	return count_;
}

-(CGFloat) listView:(FRListView *) aView heightForRowAtIndex:(NSUInteger) aRow{
	
	if( aRow % 2 ){
		return 100.0f;		
	}
	else{
		return 50.0f;
	}

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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
