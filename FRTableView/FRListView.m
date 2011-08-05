//
//  FRTableView.m
//  FRTableView
//
//  Created by Jonathan Dalrymple on 04/08/2011.
//  Copyright 2011 Float:Right Ltd. All rights reserved.
//

#import "FRListView.h"

@interface FRListView()

-(UIScrollView*) scrollView;
-(void) setupView;
-(CGFloat) heightForRowAtIndexPath:(NSIndexPath*) aPath;
-(NSInteger) numberOfRowsInList;
-(id) cellForRowAtIndexPath:(NSIndexPath*) aPath;

-(void) registerForNotifications;
-(void) unregisterForNotifications;

@end

#define DEBUGMODE YES

@implementation FRListView

@synthesize delegate = delegate_;
@synthesize dataSource = dataSource_;
@synthesize stickToBottom = stickToBottom_;

#pragma mark - Object Lifecycle
-(id) initWithFrame:(CGRect)frame{
	
	if( !(self = [super initWithFrame:frame]) ) return nil;
	
	[self setupView];
	
	return self;
}

-(void) dealloc{

	[self unregisterForNotifications];
	
	[scrollView_ release];
	scrollView_ = nil;
	
	dataSource_ = nil;
	delegate_ = nil;

	[super dealloc];
}

-(void) awakeFromNib{
	
	[super awakeFromNib];
	
	[self setupView];
}

-(void) setupView{
	//Add the scroll view
	[self addSubview:[self scrollView]];
	
	[self registerForNotifications];
	
}

#pragma mark - KVO & Notifications
-(void) registerForNotifications{
	
	[self addObserver:self 
		   forKeyPath:@"dataSource" 
			  options:NSKeyValueObservingOptionNew
			  context:NULL
	 ];
	
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	
	if( [keyPath isEqualToString:@"dataSource"] ){
		[self setNeedsReload];
	}
	else if( [keyPath isEqualToString:@"bounds"]){
	
	}
	else if( [keyPath isEqualToString:@"frame"]){
		
	}
	
}

-(void) unregisterForNotifications{
	
	[self removeObserver:self 
			  forKeyPath:@"dataSource"];
}

/**
 *	Internal view to get the scroll view
 */
-(UIScrollView*) scrollView{
	
	if( !scrollView_ ){
		scrollView_ = [[UIScrollView alloc] initWithFrame:[self frame]];
		
		[scrollView_ setAutoresizingMask:[self autoresizingMask]];
		
		[scrollView_ setDelegate:self];
		
		if( DEBUGMODE ){
			[scrollView_ setBackgroundColor:[UIColor purpleColor]];
		}
	}
	
	return scrollView_;
}

//	Data management
-(void) setNeedsReload{
	[self reloadData];
}

-(void) reloadData{
	
	CGSize		contentSize;
	CGFloat		cellHeight;
	CGFloat		yOffset;
	NSUInteger	numberOfRows;
	CGRect		cellFrame;
	id			cell;
	NSIndexPath	*indexPath;

	
	numberOfRows = [self numberOfRowsInList];
	
	//Get the context size
	contentSize = [[self scrollView] contentSize];
	
	//Reset the height
	contentSize.height = 0.0f;
	
	yOffset = 0.0f;
	
	//Calculate the total height
	for( int i=0; i < numberOfRows; i++ ){
				
		indexPath = [NSIndexPath indexPathForRow:i
									   inSection:0];
		
		cellHeight = [self heightForRowAtIndexPath:indexPath];		
				
		cellFrame = CGRectMake(0.0f,yOffset,[self bounds].size.width, cellHeight);
		
		cell = [self cellForRowAtIndexPath:indexPath];
		
		[cell setFrame:cellFrame];
		
		NSLog(@"Cell %@",cell);
		
		[[self scrollView] addSubview:cell];
		
		contentSize.height += cellHeight;
		yOffset += cellHeight;
	}
	
	[[self scrollView] setContentSize:contentSize];
	
	NSLog(@"Set content size to %@",NSStringFromCGSize(contentSize));
	
	//Add the views
	if( [self stickToBottom] ){
		[[self scrollView] setContentOffset:CGPointMake(0.0f, contentSize.height-[[self scrollView] bounds].size.height)];
	}
		
}

//	Cells
-(id) dequeueReusableCellWithIdentifier:(NSString*) aString{
	
}

//	Delegate wrappers
-(void) willDisplayCell:(id) aCell forRowAtIndexPath:(NSIndexPath*) aPath{
	
}

-(void) didSelectRowAtIndexPath:(NSIndexPath*) aPath{
	
}

-(CGFloat) heightForRowAtIndexPath:(NSIndexPath*) aPath{
	
	if( [[self delegate] respondsToSelector:@selector(listView:heightForRowAtIndexPath::)] ){
		return [[self delegate] listView:self
				 heightForRowAtIndexPath:aPath
				];
	}
	
	return 40.0f;
}

//	Datasource wrappers
-(NSInteger) numberOfRowsInList{
	
	if( [[self dataSource] respondsToSelector:@selector(numberOfRowsInListView:)] ){
		return [[self dataSource] numberOfRowsInListView:self];
	}
	
	return 0;
}

-(id) cellForRowAtIndexPath:(NSIndexPath*) aPath{
	
	if( [[self dataSource] respondsToSelector:@selector(listView:cellForRowAtIndexPath:)]){
		return [[self dataSource] listView:self
					 cellForRowAtIndexPath:aPath
		 ];
	}
	
	return nil;
}

@end

