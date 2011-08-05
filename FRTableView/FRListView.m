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

-(void) clearCaches;
-(CGRect) cachedRectForIndexPath:(NSIndexPath*) aPath;
-(void) cacheRect:(CGRect) aRect forIndexPath:(NSIndexPath*) aPath;
-(NSMutableArray*) rectCache;

-(CGRect) visibleRect;

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
	
	[self addObserver:self
		   forKeyPath:@"bounds"
			  options:NSKeyValueObservingOptionNew 
			  context:NULL
	 ];
	
	[self addObserver:self 
		   forKeyPath:@"frame" 
			  options:NSKeyValueObservingOptionNew
			  context:NULL
	 ];
	
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	
	if( [keyPath isEqualToString:@"dataSource"] ){
		[self setNeedsReload];
	}
	else if( [keyPath isEqualToString:@"bounds"]){
		[[self scrollView] setBounds:[object CGRectValue]];
	}
	else if( [keyPath isEqualToString:@"frame"]){
		[[self scrollView] setFrame:[object CGRectValue]];
	}
	
}

-(void) unregisterForNotifications{
	
	[self removeObserver:self 
			  forKeyPath:@"dataSource"
	 ];
	
	[self removeObserver:self
			  forKeyPath:@"bounds"
	 ];
	
	[self removeObserver:self
			  forKeyPath:@"frame"
	 ];
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
	CGRect		cellFrame;
	id			cell;
	NSIndexPath	*indexPath;

	NSLog(@"Reloading");
	
	[self clearCaches];
	
	//Get the context size
	contentSize = [[self scrollView] contentSize];
	
	//Reset the height
	contentSize.height = 0.0f;
	contentSize.width  = [self bounds].size.width; 
	
	yOffset = 0.0f;
	
	//Calculate the total heights && and get the cell rects
	for( int i=0; i < [self numberOfRowsInList]; i++ ){
		
		indexPath = [NSIndexPath indexPathForRow:i
									   inSection:0];
		
		cellHeight = [self heightForRowAtIndexPath:indexPath];		
		
		cellFrame = CGRectMake(0.0f,yOffset,[self bounds].size.width, cellHeight);
		
		[self cacheRect:cellFrame
		   forIndexPath:indexPath
		 ];
	
		yOffset += cellHeight;
		
		contentSize.height += cellHeight;
	}
	
	//Stick to the bottom
	if( [self stickToBottom] ){
		[[self scrollView] setContentOffset:CGPointMake(0.0f, contentSize.height-[[self scrollView] bounds].size.height)];
	}
	
	[[self scrollView] setContentSize:contentSize];
	
	[self loadVisibleCells];
	
	

	
	NSLog(@"Set content size to %@",NSStringFromCGSize(contentSize));
	
		
}

-(void) loadVisibleCells{
	
	CGPoint		offset;
	CGRect		cellRect;
	id			cell;
	NSIndexPath	*indexPath;
	
	//[[self scrollView] contentOffset]

	//Loop over the cells and see if we have any overlap
	for( int i=0; i < [self numberOfRowsInList]; i++ ){
	
		indexPath = [NSIndexPath indexPathForRow:i
									   inSection:0
					 ];
		
		cellRect = [self cachedRectForIndexPath:indexPath];
		
		NSLog(@"Comparing %@ && %@", NSStringFromCGRect(cellRect), NSStringFromCGRect([self visibleRect]));
		
		if( CGRectIntersectsRect(cellRect, [self visibleRect]) ){
			//Load cell
			NSLog(@"Loading cell %d",i);
			
			cell = [self cellForRowAtIndexPath:indexPath];
			
			[cell setFrame:cellRect];
			
			[[self scrollView] addSubview:cell];
		};
	}
	
}

/**
 *	Create the current visible rect
 *	Move this to a category on UIScrollView
 */
-(CGRect) visibleRect{
	
	CGRect	retVal;
	CGSize	size;
	CGPoint origin;
	
	size = [[self scrollView] contentSize];
	origin = [[self scrollView] contentOffset];
	
	retVal = CGRectMake(origin.x, origin.y, size.width, size.height);
	
	return retVal;
}

#pragma mark - Caching
/**
 *	Remove all caches
 */
-(void) clearCaches{
	
	[[self rectCache] removeAllObjects];
}

/**
 *	Get a rect from the cache
 */
-(CGRect) cachedRectForIndexPath:(NSIndexPath*) aPath{
	
	return [[[self rectCache] objectAtIndex:[aPath row]] CGRectValue];
}

/**
 *	Cache a rect
 */
-(void) cacheRect:(CGRect) aRect forIndexPath:(NSIndexPath*) aPath{
	
	[[self rectCache] insertObject:[NSValue valueWithCGRect:aRect]
						   atIndex:[aPath row]
	 ];
}

-(NSMutableArray*) rectCache{
	
	if( !rectCache_ ){
		rectCache_ = [[NSMutableArray alloc] initWithCapacity:[self numberOfRowsInList]];
	}
	
	return rectCache_;
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	NSLog(@"%@",NSStringFromCGPoint([scrollView contentOffset]));
	
	[self loadVisibleCells];
}

@end

