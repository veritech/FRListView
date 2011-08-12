//
//  NSMutableArray+queue.h
//  FRTableView
//
//  Created by Jonathan Dalrymple on 11/08/2011.
//  Copyright 2011 Float:Right Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableArray (queue)

-(void) enqueue:(id) aObject;
-(id) dequeue;

@end
