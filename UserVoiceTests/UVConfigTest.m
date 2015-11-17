//
//  UVConfigTest.m
//  UserVoice
//
//  Created by ANNA BILLSTROM on 11/16/15.
//  Copyright © 2015 UserVoice Inc. All rights reserved.
//

#import "Kiwi.h"
#import "UVConfig.h"


SPEC_BEGIN(ConfigSetup)

describe(@"Setup Config", ^{
    UVConfig *config = [UVConfig configWithSite:@"blah"];
    it(@"user can create a config with site", ^{
       
        // should probably do some validation and error handling
        
        [[config should] beNonNil];
    });
    
#pragma mark config defaults
    it(@"should have showForum default to yes", ^{
        BOOL desiredVal = YES;
        [[theValue(config.showForum) should] equal:theValue(desiredVal)];
    });
    
    it(@"should have showPostIdea default to yes", ^{
        BOOL desiredVal = YES;
        [[theValue(config.showPostIdea) should] equal:theValue(desiredVal)];
    });
    it(@"should have showContactUs default to yes", ^{
        BOOL desiredVal = YES;
        [[theValue(config.showContactUs) should] equal:theValue(desiredVal)];
    });
    
    it(@"should have showKnowledgeBase default to yes", ^{
        BOOL desiredVal = YES;
        [[theValue(config.showKnowledgeBase) should] equal:theValue(desiredVal)];
    });
});

SPEC_END