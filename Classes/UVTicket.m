//
//  UVTicket.m
//  UserVoice
//
//  Created by Scott Rutherford on 26/04/2011.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//


// format 	             String - xml, json 	
// ticket[custom_field_values][_field_name_] String - Replace _field_name_ with the name of your custom field
// ticket[lang] 	     String 				
// ticket[message] 	     String - required 			
// ticket[referrer] 	 String 				
// ticket[subject] 	     String - required 			
// ticket[submitted_via] String - Your name for where this ticket came from (ex: web, email)
// ticket[user_agent] 	 String 				

#import "UVTicket.h"
#import "UVSubject.h"
#import "UVResponseDelegate.h"


@implementation UVTicket

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

+ (id)createWithSubject:(UVSubject *)subject
                   text:(NSString *)text
               delegate:(id)delegate {
	NSString *path = [self apiPath:@"/tickets.json"];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							text == nil ? @"" : text, @"ticket[text]",
							subject == nil ? @"" : 
                            [[NSNumber numberWithInteger:subject.subjectId] stringValue], @"ticket[message_subject_id]",
							nil];
    
	return [[self class] postPath:path
					   withParams:params
						   target:delegate
						 selector:@selector(didCreateMessage:)];
}


@end
