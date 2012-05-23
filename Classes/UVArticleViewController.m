//
//  UVArticleViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 5/8/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVArticleViewController.h"
#import "UVSession.h"

@implementation UVArticleViewController

@synthesize article;
@synthesize webView;

- (id)initWithArticle:(UVArticle *)theArticle {
    if (self = [super init]) {
        self.article = theArticle;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [self hideExitButton];
    self.webView = [[[UIWebView alloc] initWithFrame:[self contentFrame]] autorelease];
    NSString *html = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"http://cdn.uservoice.com/stylesheets/vendor/typeset.css\"/></head><body class=\"typeset\" style=\"font-family: sans-serif; margin: 1em\"><h3>%@</h3>%@</body></html>", article.question, article.answerHTML];
    [self.webView loadHTMLString:html baseURL:nil];
    self.view = self.webView;
}

- (NSString *)backButtonTitle {
    return @"Back";
}

- (void)dealloc {
    self.article = nil;
    self.webView = nil;
    [super dealloc];
}

@end
