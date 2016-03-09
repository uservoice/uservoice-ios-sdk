//
//  UVPaginationInfo.m
//  UserVoice
//
//  Created by Austin Taylor on 3/9/16.
//  Copyright © 2016 UserVoice Inc. All rights reserved.
//

#import "UVPaginationInfo.h"

@implementation UVPaginationInfo

- (NSInteger)recordsLoaded {
    return _pageSize * _page;
}

- (BOOL)hasMoreData {
    return self.recordsLoaded < _totalRecords;
}

@end
