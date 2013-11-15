//
//  UVForum.m
//  UserVoice
//
//  Created by UserVoice on 11/23/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVForum.h"
#import "UVCategory.h"

@implementation UVForum

+ (id)getWithId:(int)forumId delegate:(id)delegate {
    return [self getPath:[self apiPath:[NSString stringWithFormat:@"/forums/%d.json", forumId]]
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveForum:)
                 rootKey:@"forum"];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _forumId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        _name = [self objectOrNilForDict:dict key:@"name"];

        NSDictionary *topic = [[self objectOrNilForDict:dict key:@"topics"] objectAtIndex:0];
        
        _example = [topic objectForKey:@"example"];
        _prompt = [topic objectForKey:@"prompt"];
        _suggestionsCount = [(NSNumber *)[topic objectForKey:@"open_suggestions_count"] integerValue];

        _categories = [NSMutableArray array];
        NSMutableArray *categoryDicts = [self objectOrNilForDict:topic key:@"categories"];
        for (NSDictionary *categoryDict in categoryDicts) {
            [_categories addObject:[[UVCategory alloc] initWithDictionary:categoryDict]];
        }
    }
    return self;
}

@end
