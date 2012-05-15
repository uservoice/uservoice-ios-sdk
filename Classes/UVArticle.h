//
//  UVArticle.h
//  UserVoice
//
//  Created by Austin Taylor on 5/8/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseModel.h"

@interface UVArticle : UVBaseModel {
    NSString *question;
    NSString *answerHTML;
}

+ getInstantAnswers:(NSString *)query delegate:(id)delegate;

@property (nonatomic, retain) NSString *question;
@property (nonatomic, retain) NSString *answerHTML;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
