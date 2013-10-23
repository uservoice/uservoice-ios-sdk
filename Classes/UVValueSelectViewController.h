//
//  UVValueSelectViewController.h
//  UserVoice
//
//  Created by UserVoice on 6/9/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@class UVCustomField;

@interface UVValueSelectViewController : UVBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSMutableDictionary *valueDictionary;
@property (nonatomic, retain) UVCustomField *customField;

- (id)initWithCustomField:(UVCustomField *)customField valueDictionary:(NSMutableDictionary *)valueDictionary;

@end
