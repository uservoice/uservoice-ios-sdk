//
//  UVTicket.m
//  UserVoice
//
//  Created by Scott Rutherford on 26/04/2011.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//


// format                String - xml, json
// ticket[custom_field_values][_field_name_] String - Replace _field_name_ with the name of your custom field
// ticket[lang]          String
// ticket[message]       String - required
// ticket[referrer]      String
// ticket[subject]       String - required
// ticket[submitted_via] String - Your name for where this ticket came from (ex: web, email)
// ticket[user_agent]    String

#import "UVTicket.h"
#import "UVCustomField.h"
#import "UVResponseDelegate.h"
#import "UVSession.h"
#import "UVConfig.h"

@implementation UVTicket

+ (void)initialize {
    [self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
    [self setBaseURL:[self siteURL]];
}

+ (id)createWithMessage:(NSString *)message
  andEmailIfNotLoggedIn:(NSString *)email
                andName:(NSString *)name
        andCustomFields:(NSDictionary *)fields
            andDelegate:(id)delegate {
    NSString *path = [self apiPath:@"/tickets.json"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        message == nil ? @"" : message, @"ticket[message]",
        email   == nil ? @"" : email,   @"email",
        name    == nil ? @"" : name,    @"display_name",
        nil];
    
    for (NSString *scope in [UVSession currentSession].externalIds) {
        NSString *identifier = [[UVSession currentSession].externalIds valueForKey:scope];
        [params setObject:identifier forKey:[NSString stringWithFormat:@"created_by[external_ids][%@]", scope]];
    }

    NSDictionary *defaultFields = [UVSession currentSession].config.customFields;
    for (NSString *name in [defaultFields keyEnumerator]) {
        [params setObject:[defaultFields objectForKey:name] forKey:[NSString stringWithFormat:@"ticket[custom_field_values][%@]", name]];
    }

    for (NSString *name in [fields keyEnumerator]) {
        [params setObject:[fields objectForKey:name] forKey:[NSString stringWithFormat:@"ticket[custom_field_values][%@]", name]];
    }

    return [[self class] postPath:path
                       withParams:params
                           target:delegate
                         selector:@selector(didCreateTicket:)];
}

@end
