//
//  UVArticleViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 5/8/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVArticleViewController.h"
#import "UVSession.h"
#import "UVNewTicketViewController.h"
#import "UVStyleSheet.h"

@implementation UVArticleViewController

@synthesize article;
@synthesize webView;
@synthesize helpfulPrompt;
@synthesize returnMessage;

- (id)initWithArticle:(UVArticle *)theArticle helpfulPrompt:(NSString *)theHelpfulPrompt returnMessage:(NSString *)theReturnMessage{
    if (self = [super init]) {
        self.article = theArticle;
        self.helpfulPrompt = theHelpfulPrompt;
        self.returnMessage = theReturnMessage;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Knowledge Base", @"UserVoice", nil);
    self.view = [[[UIView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 40)] autorelease];
    NSString *html = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"http://cdn.uservoice.com/stylesheets/vendor/typeset.css\"/></head><body class=\"typeset\" style=\"font-family: sans-serif; margin: 1em\"><h3>%@</h3>%@</body></html>", article.question, article.answerHTML];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.webView.backgroundColor = [UIColor whiteColor];
    for (UIView* shadowView in [self.webView.scrollView subviews]) {
        if ([shadowView isKindOfClass:[UIImageView class]]) {
            [shadowView setHidden:YES];
        }
    }
    [self.webView loadHTMLString:html baseURL:nil];
    [self.view addSubview:webView];

    UIToolbar *helpfulBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40)] autorelease];
    helpfulBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    helpfulBar.barStyle = UIBarStyleBlack;
    helpfulBar.tintColor = [UIColor colorWithRed:1.00f green:0.99f blue:0.90f alpha:1.0f];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, helpfulBar.bounds.size.width - 100, 40)] autorelease];
    label.text = NSLocalizedStringFromTable(@"Was this article helpful?", @"UserVoice", nil);
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [helpfulBar addSubview:label];
    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *yesItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Yes!", @"UserVoice", nil) style:UIBarButtonItemStyleDone target:self action:@selector(yesButtonTapped)] autorelease];
    yesItem.width = 50;
    yesItem.tintColor = [UIColor colorWithRed:0.42f green:0.64f blue:0.85f alpha:1.0f];
    UIBarButtonItem *noItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"No", @"UserVoice", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(noButtonTapped)] autorelease];
    noItem.width = 50;
    noItem.tintColor = [UIColor colorWithRed:0.46f green:0.55f blue:0.66f alpha:1.0f];
    helpfulBar.items = @[space, yesItem, noItem];
    [self.view addSubview:helpfulBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (helpfulPrompt) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if (buttonIndex == 1) {
            [self dismissUserVoice];
        }
    } else {
        if (buttonIndex == 0) {
            UIViewController *next = [UVNewTicketViewController viewController];
            UINavigationController *navigationController = [[[UINavigationController alloc] init] autorelease];
            navigationController.navigationBar.tintColor = [UVStyleSheet navigationBarTintColor];
            navigationController.viewControllers = @[next];
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentModalViewController:navigationController animated:YES];
        }
    }
}

- (void)yesButtonTapped {
    [[UVSession currentSession] trackInteraction:@"u"];
    if (helpfulPrompt) {
        // Do you still want to contact us?
        // Yes, go to my message
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(helpfulPrompt, @"UserVoice", nil)
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedStringFromTable(returnMessage, @"UserVoice", nil), NSLocalizedStringFromTable(@"No, I'm done", @"UserVoice", nil), nil] autorelease];
        [actionSheet showInView:self.view];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)noButtonTapped {
    if (helpfulPrompt) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"Would you like to contact us?", @"UserVoice", nil)
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedStringFromTable(@"No", @"UserVoice", nil)
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedStringFromTable(@"Yes", @"UserVoice", nil), nil] autorelease];
        [actionSheet showInView:self.view];
    }
}

- (void)dealloc {
    self.article = nil;
    self.webView = nil;
    self.helpfulPrompt = nil;
    self.returnMessage = nil;
    [super dealloc];
}

@end
