//
//  UVSubjectSelectViewController.h
//  UserVoice
//
//  Created by Mirko Froehlich on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@class UVSubject;

@interface UVSubjectSelectViewController : UVBaseViewController <UITableViewDelegate, UITableViewDataSource>  {
	NSArray *subjects;
	UVSubject *selectedSubject;
}

@property (nonatomic, retain) NSArray *subjects;
@property (nonatomic, retain) UVSubject *selectedSubject;

- (id)initWithSelectedSubject:(UVSubject *)subject;

@end
