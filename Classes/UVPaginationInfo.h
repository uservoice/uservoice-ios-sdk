//
//  UVPaginationInfo.h
//  UserVoice
//
//  Created by Austin Taylor on 3/9/16.
//  Copyright © 2016 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UVPaginationInfo : NSObject {}

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger totalRecords;

- (BOOL)hasMoreData;
- (NSInteger)recordsLoaded;

@end
