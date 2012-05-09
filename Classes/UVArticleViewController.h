//
//  UVArticleViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 5/8/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseViewController.h"
#import "UVArticle.h"

@interface UVArticleViewController : UVBaseViewController {
    UVArticle *article;
    UIWebView *webView;
}

@property (nonatomic, retain) UVArticle *article;
@property (nonatomic, retain) UIWebView *webView;

- (id)initWithArticle:(UVArticle *)article;

@end
