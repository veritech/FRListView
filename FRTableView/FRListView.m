//
//  FRTableView.m
//  FRTableView
//
//  Created by Jonathan Dalrymple on 04/08/2011.
//  Copyright 2011 Float:Right Ltd. All rights reserved.
//

#import "FRListView.h"
#import "NSMutableArray+queue.h"


@interface FRListView()

-(UIScrollView*) scrollView;
-(void) setupView;

-(void) registerForNotifications;
-(void) unregisterForNotifications;

-(CGRect) visibleRect;

//Caching
-(void) clearCaches;

-(NSCache*) cellCache;
-(NSMutableArray*) cellCacheForIdentifier:(NSString*) aName;

-(CGRect) cachedRectForRowAtIndex:(NSUInteger) aRow;
-(void) cacheRect:(CGRect)aRect forRowAtIndex:(NSUInteger)aRow;

-(NSMutableArray*) rectCache;

//Delegate
-(CGFloat) heightForRowAtIndex:(NSUInteger) aRow;
-(void) didSelectRowAtIndex:(NSUInteger) aRow;
-(void) willDisplayCell:(id) aCell forRowAtIndex:(NSUInteger) aRow;

//Datasource
-(id) cellForRowAtIndex:(NSUInteger) aRow;
-(NSInteger) numberOfRowsInList;

@end

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
	
	[cellCache_ release];
	cellCache_ = nil;
	
	[rectCache_ release];
	rectCache_ = nil;
	
	dataSource_ = nil;
	delegate_ = nil;

	[super dealloc];
}

-(void) awakeFromNib{
	
	[super awakeFromNib];
	
	[self setupView];
}

/**
 *	Create the sub view heirarchy
 */
-(void) setupView{
	//Add the scroll view
	[self addSubview:[self scrollView]];
	
	stickToBottom_ = NO;
	
	cachedRowCount_ = 0;
	
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadData)
												 name:kFRListViewSetNeedsReloadNotification
											   object:self
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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
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

#pragma mark - Private accessors
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

#pragma mark - Reload management
/**
 *	Queue requests to have the view reloaded
 *
 */
-(void) setNeedsReload{
	
	NSNotification *notification;
	
	notification = [NSNotification notificationWithName:kFRListViewSetNeedsReloadNotification
												 object:self
					];
	
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification
											   postingStyle:NSPostASAP
											   coalesceMask:(NSNotificationCoalescingOnName|NSNotificationCoalescingOnSender)
												   forModes:nil
	 ];
	
}

/**
 *	Reload the data immediately
 *
 */
-(void) reloadData{
	
	CGSize		contentSize;
	CGFloat		cellHeight;
	CGFloat		yOffset;
	CGRect		cellFrame;

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
		
		cellHeight = [self heightForRowAtIndex:i];		
		
		cellFrame = CGRectMake(0.0f,yOffset,[self bounds].size.width, cellHeight);
		
		[self cacheRect:cellFrame
		  forRowAtIndex:i
		 ];
	
		yOffset += cellHeight;
		
		contentSize.height += cellHeight;
	}
	
	//Stick to the bottom
	if( [self stickToBottom] ){
		[[self scrollView] setContentOffset:CGPointMake(0.0f, contentSize.height-[[self scrollView] bounds].size.height)];
	}
	
	[[self scrollView] setContentSize:contentSize];
	
	//NSLog(@"Set content size to %@",NSStringFromCGSize(contentSize));
			
}

/**
 *
 *
 */
-(void)loadCellsForRect:(CGRect) visibleRect{
	
	id			cell;
	CGRect		cellRect;
	
	//Loop over the cells and see if we have any overlap
	for( int i=0; i < [self numberOfRowsInList]; i++ ){

			
		cellRect = [self cachedRectForRowAtIndex:i];
		
		//NSLog(@"Comparing %@ && %@", NSStringFromCGRect(cellRect), NSStringFromCGRect(visibleRect));
		
		if( CGRectIntersectsRect(cellRect, visibleRect) ){
			//Load cell
			//NSLog(@"Loading cell At index %d",i);
		
			
			cell = [self cellForRowAtIndex:i];
			
			[cell setFrame:cellRect];
			
			[self willDisplayCell:cell
					forRowAtIndex:i
			 ];
			
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
	
	size = [[self scrollView] bounds].size;
	origin = [[self scrollView] contentOffset];
	
	retVal = CGRectMake(origin.x, origin.y, size.width, size.height);
	
	return retVal;
}

#pragma mark - Caching
/**
 *	Remove all caches
 */
-(void) clearCaches{
	
	cachedRowCount_ = FRListViewCountDirty;
	
	[[self rectCache] removeAllObjects];
	[[self cellCache] removeAllObjects];
}

/**
 *	Get a rect from the cache
 */
-(CGRect) cachedRectForRowAtIndex:(NSUInteger) aRow{
	return [[[self rectCache] objectAtIndex:aRow] CGRectValue];
}

/**
 *	Cache a rect
 */
-(void) cacheRect:(CGRect)aRect forRowAtIndex:(NSUInteger)aRow{
	
	[[self rectCache] insertObject:[NSValue valueWithCGRect:aRect]
						   atIndex:aRow
	 ];	
	
}

/**
 *	A cache for all the rects in the view
 *
 */
-(NSMutableArray*) rectCache{
	
	if( !rectCache_ ){
		rectCache_ = [[NSMutableArray alloc] initWithCapacity:[self numberOfRowsInList]];
	}
	
	return rectCache_;
}

/**
 *	Create the cell cache
 */
-(NSCache*) cellCache{
	
	if( !cellCache_ ){
		cellCache_ = [[NSCache alloc] init];
		
		[cellCache_ setName:@"com.FRListView.cellCache"];
	}
	return cellCache_;
}

/**
 *	Create cell cache's for a given id
 *	@param aName The name of the cache
 *	
 *	@return aCache
 */
-(NSMutableArray*) cellCacheForIdentifier:(NSString*) aName{
	
	NSMutableArray *cache = nil;
	
	if( !(cache = (NSMutableArray*)[[self cellCache] objectForKey:aName]) ){
		
		cache = [[NSMutableArray alloc] initWithCapacity:kFRListViewCacheSize];
		
		[[self cellCache] setObject:cache
							 forKey:aName];
		
		[cache release];
	}
	
	return cache;
}

#pragma mark - Cell reuse
/**
 *	Get the cell from the internal cell cache
 *	@param the id
 */
-(id) dequeueReusableCellWithIdentifier:(NSString*) aString{

	id				cell = nil;
	NSMutableArray *cache = nil;
	
	if( aString ){

		cache = [self cellCacheForIdentifier:aString];
		
		//If the cache full
		if( [cache count] >= kFRListViewCacheSize ){
			
			//NSLog(@"Cache Hit!");
			//Dequeue a cell
			cell = [cache dequeue];
			
			//Prepare it for reuse
			[cell prepareForReuse]; 		
		}
	}
	
	//return it
	return cell;
}

#pragma mark - FRListViewDelegate wrapper methods
/**
 *	
 */
-(void) willDisplayCell:(id) aCell forRowAtIndex:(NSUInteger) aRow{
	
	if( [[self delegate] respondsToSelector:@selector(listView:willDisplayCell:forRowAtIndex:)]){
		
		[[self delegate] listView:self
				  willDisplayCell:aCell
					forRowAtIndex:aRow
		 ];
	}
}

/**
 *
 */
-(void) didSelectRowAtIndex:(NSUInteger) aRow{
		
	if( [[self delegate] respondsToSelector:@selector(listView:didSelectRowAtIndex:)] ){
		[[self delegate] listView:self
			  didSelectRowAtIndex:aRow
		 ];
	}
}

/**
 *
 */
-(CGFloat) heightForRowAtIndex:(NSUInteger) aRow{
	
	if( [[self delegate] respondsToSelector:@selector(listView:heightForRowAtIndex:)] ){
		return [[self delegate] listView:self
					 heightForRowAtIndex:aRow
				];
	}
	
	return 40.0f;
}

#pragma mark - FRListViewDataSource wrapper methods
/**
 *	Get the total numbers of the cells
 */
-(NSInteger) numberOfRowsInList{
	
	if( [[self dataSource] respondsToSelector:@selector(numberOfRowsInListView:)] && cachedRowCount_ == FRListViewCountDirty ){
		cachedRowCount_ =  [[self dataSource] numberOfRowsInListView:self];
	}
	
	return cachedRowCount_;
}

/**
 *	Internal Cell for row at index path method
 *	@param aPath NSIndexPath of the cell 
 *	
 *	@return a Newly configured cell
 */
-(id) cellForRowAtIndex:(NSUInteger) aRow{
	
	UITableViewCell	*cell = nil;
	NSString *cellIdentifier = nil;
	
	//Create a cache for the cell
	if( [[self dataSource] respondsToSelector:@selector(listView:cellForRowAtIndex:)] ){
		
		cell = [[self dataSource] listView:self
						 cellForRowAtIndex:aRow
				];
		
		//Add the cell to the cache
		if( (cellIdentifier = [cell reuseIdentifier]) ){
			[[self cellCacheForIdentifier:cellIdentifier] enqueue:cell];		
		}	
	}
	
	return cell;
}

#pragma mark - UIScrollViewDelegate
/**
 *	Reload the cells as we scroll
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[self loadCellsForRect:[self visibleRect]];
	
}

@end

