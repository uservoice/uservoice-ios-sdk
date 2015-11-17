//
//  UserVoiceTests.m
//  UserVoiceTests
//
//  Created by ANNA BILLSTROM on 11/16/15.
//  Copyright © 2015 UserVoice Inc. All rights reserved.
//

#import "Kiwi.h"
#import "UserVoice.h"

SPEC_BEGIN(UserVoiceInit)

describe(@"Init Uservoice", ^{
    UVConfig *config = [UVConfig configWithSite:@"blah"];
    
    [UserVoice initialize:config];

    
    
});

SPEC_END