//
//  FRTableView.h
//  FRTableView
//
//  Created by Jonathan Dalrymple on 04/08/2011.
//  Copyright 2011 Float:Right Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FRListViewCountDirty -1
#define kFRListViewCacheSize 12
#define kFRListViewSetNeedsReloadNotification @"FRListViewSetNeedsReloadNotification"
#define DEBUGMODE YES

@protocol FRListViewDataSource;
@protocol FRListViewDelegate;

@interface FRListView : UIView<UIScrollViewDelegate> {

    id						dataSource_;
	id						delegate_;
	
	UIScrollView			*scrollView_;
	
	BOOL					stickToBottom_;
	
	NSInteger				cachedRowCount_;
	
	NSMutableArray			*rectCache_;	
	NSCache					*cellCache_;

}

@property (nonatomic,assign) id<FRListViewDataSource> dataSource;
@property (nonatomic,assign) id<FRListViewDelegate> delegate;
@property (nonatomic,assign) BOOL stickToBottom;

-(void) setNeedsReload;
-(void) reloadData;
-(id) dequeueReusableCellWithIdentifier:(NSString*) aString;

@end

@protocol FRListViewDelegate <NSObject>

@optional

-(void) listView:(FRListView*) aView willDisplayCell:(id) aCell forRowAtIndex:(NSUInteger) aRow;

-(CGFloat) listView:(FRListView *) aView heightForRowAtIndex:(NSUInteger) aRow;

-(void) listView:(FRListView*) aView didSelectRowAtIndex:(NSUInteger) aRow;

//TODO:
//Implement
//-(BOOL) listView:(FRListView*) aView canPerformAction:(SEL) aAction forRowAtIndex:(NSUInteger) aRow withSender:(id) aObject;

//-(void) listView:(FRListView *)aView performAction:(SEL) aAction forRowAtIndex:(NSUInteger*) aRow withSender:(id) aObject;

@end

@protocol FRListViewDataSource <NSObject>

-(id) listView:(FRListView*) aListView cellForRowAtIndex:(NSUInteger) aRow;

-(NSUInteger) numberOfRowsInListView:(FRListView*) aView;

@end