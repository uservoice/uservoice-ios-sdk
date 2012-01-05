//
//  UVStreamPoller.m
//  UserVoice
//
//  Created by Scott Rutherford on 12/08/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVStreamPoller.h"
#import "UVStreamEvent.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVSuggestion.h"

@implementation UVStreamPoller
static UVStreamPoller* _instance;

@synthesize repeatingTimer, lastPollTime;

+ (UVStreamPoller *)instance 
{
	@synchronized([UVStreamPoller class]) 
    {
		if (!_instance)
			_instance = [[self alloc] init];
		
		return _instance;
	}
	
	return nil;
}

+ (id)alloc {
	@synchronized([UVStreamPoller class]) {
		NSAssert(_instance == nil, @"Attempted to allocate a second instance of a singleton.");
		_instance = [super alloc];
		return _instance;
	}
	
	return nil;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		// initialize stuff here

	}
	return self;
}

- (void)pollServer:(NSTimer*)theTimer {
	NSLog(@"Polling the UserVoice server");
	if (!lastPollTime) {
		self.lastPollTime = [UVSession currentSession].startTime;
	}		
	
//	[UVStreamEvent publicForForum:[UVSession currentSession].clientConfig.forum 
//					  andDelegate:self
//							since:lastPollTime];	
	self.lastPollTime = [NSDate date];
}

- (void)didRetrievePublicStream:(NSArray *)theStream {
	NSLog(@"Got public stream");
	
	NSMutableDictionary *suggestionIds = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
	for (int i=0; i<[[UVSession currentSession].clientConfig.forum.currentTopic.suggestions count]; i++) {
		UVSuggestion *theSuggestion = [[UVSession currentSession].clientConfig.forum.currentTopic.suggestions objectAtIndex:i];
				
		NSNumber *index = [NSNumber numberWithInt:i];		
		NSString *key = [NSString stringWithFormat:@"%d", theSuggestion.suggestionId];
		[suggestionIds setObject:index forKey:key];
	}

	for (int i=0; i<[theStream count]; i++) {
		UVStreamEvent *event = (UVStreamEvent *)[theStream objectAtIndex:i];				
		
		if ([event.type isEqualToString:@"suggestion"]) {
			NSLog(@"New suggestion");
			// just invalidate the forum, can't order this anyway
			[UVSession currentSession].clientConfig.forum.currentTopic.suggestionsNeedReload = YES;
			
		} else {
			NSDictionary *suggestionDict = [event.object valueForKey:@"suggestion"]; 
			UVSuggestion *theSuggestion = [[[UVSuggestion alloc] initWithDictionary:suggestionDict] autorelease];
			NSString *key = [NSString stringWithFormat:@"%d", theSuggestion.suggestionId];
			NSLog(@"Looking for suggestionId: %@", key);
			NSNumber *index = (NSNumber *)[suggestionIds objectForKey:key];			
			NSLog(@"Existing index: %@", index);
		
			if (index) {
				[[UVSession currentSession].clientConfig.forum.currentTopic.suggestions replaceObjectAtIndex:[index intValue] 
																								  withObject:theSuggestion];				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"TopicSuggestionsUpdated" object:self];
			}
			if ([event.type isEqualToString:@"vote"]) {
				NSLog(@"New vote");				
				
			} else if ([event.type isEqualToString:@"comment"]) {
				NSLog(@"New comment");
				
			} else if ([event.type isEqualToString:@"suggestion_status"]) {
				NSLog(@"New status");
				
			}
		}
	}
}

- (void)didRetrievePrivateStream:(NSArray *)theStream {
	NSLog(@"Got private stream");
}

- (NSDictionary *)userInfo {
    return [NSDictionary dictionaryWithObject:[NSDate date] forKey:@"StartDate"];
}

- (BOOL)timerIsRunning {
	return self.repeatingTimer != nil;
}

- (void)startTimer {	
	if (self.repeatingTimer == nil) {
		NSLog(@"Instantiating timer to start in 60 seconds");				
		
		NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:60.0];
		repeatingTimer = [[NSTimer alloc] initWithFireDate:fireDate
                                                  interval:60.0
                                                    target:self
                                                  selector:@selector(pollServer:)
                                                  userInfo:[self userInfo]
                                                   repeats:YES];
		
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:self.repeatingTimer forMode:NSDefaultRunLoopMode];
	}
}

- (void)stopTimer {
	[repeatingTimer invalidate];
	[repeatingTimer release];
    self.repeatingTimer = nil;
}

- (void)dealloc {
    [self stopTimer];
    self.lastPollTime = nil;
	[super dealloc];
}

@end
