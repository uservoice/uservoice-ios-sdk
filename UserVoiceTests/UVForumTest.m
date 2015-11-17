//
//  UVForumTest.m
//  UserVoice
//
//  Created by ANNA BILLSTROM on 11/16/15.
//  Copyright © 2015 UserVoice Inc. All rights reserved.
//

#import "Kiwi.h"
#import "UVForum.h"
#import "Nocilla.h"

//269223

SPEC_BEGIN(UserVoiceForumAPI)

__block UVForum *forum;
__block NSString *forumName;
__block NSInteger forumId;
__block NSString *prompt;
__block NSInteger suggestionsCount;

beforeAll(^{
//    [[LSNocilla sharedInstance] start];
    forumName = @"Feedback";
    prompt = @"Lorem ipsum";
    forumId = (int)333;
    suggestionsCount = (int)7;
    

    NSDictionary *topic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:suggestionsCount],@"open_suggestions_count", nil];
    NSArray *array = [[NSArray alloc] initWithObjects:topic, nil];
    NSDictionary *forumDict = [[NSDictionary alloc]
                               initWithObjectsAndKeys:
                               forumName, @"name",[NSNumber numberWithInt:forumId], @"id", prompt,@"prompt", array, @"topics", nil];
    forum = [[UVForum alloc] initWithDictionary:forumDict];

   
});
afterAll(^{
});
afterEach(^{
});
describe(@"UVForum should init with dictionary", ^{

    it(@" and name is set", ^{
        [[forum.name should] equal:forumName];
    });
    it(@" and suggestionCount is set",^{
        
        [[theValue(forum.suggestionsCount) should] equal:theValue(suggestionsCount)];
        
    });
    it(@" and forumId is set",^{
        
         //[[theValue(forum.forumId) should] equal:theValue(forumId)];
    });
    it(@" and prompt is set", ^{
         [[forum.prompt should] equal:prompt];
    });

    /*
     "anonymous_access" = 0;
     "created_at" = "2015/10/29 22:04:35 +0000";
     id = 328458;
     name = "Cootie Catcher";
     private = 0;
     "suggestions_count" = 3;
     topics =         (
     {
     categories =                 (
     );
     "closed_at" = "<null>";
     "created_at" = "2015/10/29 22:04:35 +0000";
     example = "Enter your idea";
     id = 328458;
     "open_suggestions_count" = 3;
     prompt = "How can we improve Cootie Catcher?";
     "suggestions_count" = 3;
     "updated_at" = "2015/10/29 22:04:35 +0000";
     "votes_allowed" = 10;
     "votes_remaining" = 1000;
     }
     );
     "updated_at" = "2015/10/29 22:04:35 +0000";
     "updated_by" =         {
     "avatar_url" = "https://secure.gravatar.com/avatar/93eea6efbc541bd96a92f383af799f81?size=70&default=https://assets0.uvcdn.com/pkg/admin/icons/user_70-c68d06098b40646a91b7656094632c19.png";
     "created_at" = "2015/10/07 23:44:46 +0000";
     id = 109277796;
     "karma_score" = 0;
     name = "Anna B";
     title = engineer;
     "updated_at" = "2015/11/09 22:01:26 +0000";
     url = "http://banane.uservoice.com/users/109277796-anna-b";
     };
     url = "http://banane.uservoice.com/forums/328458-cootie-catcher";
     welcome = "<null>";*/
    
});

SPEC_END