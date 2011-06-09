//
//  UVSubjectSelectViewController.h
//  UserVoice
//
//  Created by UserVoice on 6/9/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@class UVCustomField;

@interface UVSubjectSelectViewController : UVBaseViewController <UITableViewDelegate, UITableViewDataSource>  {
	NSArray *subjects;
	UVCustomField *selectedSubject;
}

@property (nonatomic, retain) NSArray *subjects;
@property (nonatomic, retain) UVCustomField *selectedSubject;

- (id)initWithSelectedSubject:(UVCustomField *)subject;

@end
