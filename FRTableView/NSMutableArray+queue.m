//
//  NSMutableArray+queue.m
//  FRTableView
//
//  Created by Jonathan Dalrymple on 11/08/2011.
//  Copyright 2011 Float:Right Ltd. All rights reserved.
//

#import "NSMutableArray+queue.h"


@implementation NSMutableArray (queue)

/**
 *	Enqueue an an object
 *	@param aObject an object to be added to the end of the queue
 */
-(void) enqueue:(id) aObject{

	[self addObject:aObject];
}

/**
 *	Return the object at the head of the queue
 *
 *	@return aObject the object at the top of the enqueue
 */
-(id) dequeue{
	
	id element = nil;
	
	if( [self count] > 0 ){
		
		element = [self objectAtIndex:0];
		
		[self removeObjectAtIndex:0];
		
	}
		 
	return element;
	
}

@end
