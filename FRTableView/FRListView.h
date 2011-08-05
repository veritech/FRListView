//
//  FRTableView.h
//  FRTableView
//
//  Created by Jonathan Dalrymple on 04/08/2011.
//  Copyright 2011 Float:Right Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FRListView : UIView<UIScrollViewDelegate> {

    id		dataSource_;
	id		delegate_;
	
	UIScrollView	*scrollView_;
	
	BOOL	stickToBottom_;
}

@property (nonatomic,assign) id dataSource;
@property (nonatomic,assign) id delegate;
@property (nonatomic,assign) BOOL stickToBottom;

-(void) setNeedsReload;
-(void) reloadData;
-(id) dequeueReusableCellWithIdentifier:(NSString*) aString;

@end

@protocol FRListViewDelegate <NSObject>

@optional

-(void) listView:(FRListView*) aView willDisplayCell:(id) aCell forRowAtIndexPath:(NSIndexPath*) aPath;

-(CGFloat) listView:(FRListView *) aView heightForRowAtIndexPath:(NSIndexPath*) aPath;

-(void) listView:(FRListView*) aView didSelectRowAtIndexPath:(NSIndexPath*) aPath;

-(BOOL) listView:(FRListView*) aView canPerformAction:(SEL) aAction forRowAtIndexPath:(NSIndexPath*) aPath withSender:(id) aObject;

-(void) listView:(FRListView *)aView performAction:(SEL) aAction forRowIndexPath:(NSIndexPath*) aPath withSender:(id) aObject;

@end

@protocol FRListViewDataSource <NSObject>

-(id) listView:(FRListView*) aListView cellForRowAtIndexPath:(NSIndexPath*) aPath;

-(NSUInteger) numberOfRowsInListView:(FRListView*) aView;

@end