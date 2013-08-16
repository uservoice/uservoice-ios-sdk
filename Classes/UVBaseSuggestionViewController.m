//
//  UVBaseSuggestionViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 11/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVBaseSuggestionViewController.h"
#import "UVUtils.h"
#import "UVSession.h"
#import "UVForum.h"
#import "UVCategory.h"
#import "UVClientConfig.h"
#import "UVSuggestion.h"
#import "UVUser.h"
#import "UVSuggestionListViewController.h"
#import "UVWelcomeViewController.h"
#import "UVCategorySelectViewController.h"
#import "UVCallback.h"

@implementation UVBaseSuggestionViewController {
    
    BOOL _isSubmittingSuggestion;
    UVCallback *_didCreateCallback;
    UVCallback *_didAuthenticateCallback;

}

@synthesize forum;
@synthesize title;
@synthesize text;
@synthesize name;
@synthesize email;
@synthesize textView;
@synthesize titleField;
@synthesize nameField;
@synthesize emailField;
@synthesize category;
@synthesize shouldShowCategories;

#define UV_CATEGORY_VALUE 100

- (id)initWithTitle:(NSString *)theTitle {
    if (self = [self init]) {
        self.title = theTitle;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        self.forum = [UVSession currentSession].forum;
        self.shouldShowCategories = self.forum.categories && [self.forum.categories count] > 0;
        self.articleHelpfulPrompt = NSLocalizedStringFromTable(@"Do you still want to post an idea?", @"UserVoice", nil);
        self.articleReturnMessage = NSLocalizedStringFromTable(@"Yes, go to my idea", @"UserVoice", nil);
        
        _didCreateCallback = [[UVCallback alloc] initWithTarget:self selector:@selector(didCreateSuggestion:)];
        _didAuthenticateCallback = [[UVCallback alloc] initWithTarget:self selector:@selector(createSuggestion)];
    }
    return self;
}

- (void)didReceiveError:(NSError *)error {
    _isSubmittingSuggestion = NO;
    
    if ([UVUtils isNotFoundError:error]) {
        [self hideActivityIndicator];
    } else if ([UVUtils isUVRecordInvalid:error forField:@"title" withMessage:@"is not allowed."]) {
        [self hideActivityIndicator];
        [self alertError:NSLocalizedStringFromTable(@"A suggestion with this title already exists. Please change the title.", @"UserVoice", nil)];
    } else {
        [super didReceiveError:error];
    }
}

- (void)createSuggestion {
    self.title = titleField.text;
    self.text = textView.text;
    [[UVSession currentSession] trackInteraction:@"pi"];
    
    [UVSuggestion createWithForum:self.forum
                         category:self.category
                            title:self.title
                             text:self.text
                            votes:1
                         callback:_didCreateCallback];
}

- (void)createButtonTapped {
    self.title = titleField.text;
    self.text = textView.text;
    self.name = nameField.text;
    self.email = emailField.text;
    [nameField resignFirstResponder];
    [emailField resignFirstResponder];

    if (self.email && [self.email length] > 1) {
        [self disableSubmitButton];
        [self showActivityIndicator];

        _isSubmittingSuggestion = YES;
        
        [self requireUserAuthenticated:email name:name callback:_didAuthenticateCallback];
    } else {
        [self alertError:NSLocalizedStringFromTable(@"Please enter your email address before submitting your suggestion.", @"UserVoice", nil)];
    }
}

- (BOOL)shouldEnableSubmitButton {
    return !_isSubmittingSuggestion;
}

- (void)didCreateSuggestion:(UVSuggestion *)theSuggestion {
    [[UVSession currentSession] flash:NSLocalizedStringFromTable(@"Your idea has been posted on our forum.", @"UserVoice", nil) title:NSLocalizedStringFromTable(@"Success!", @"UserVoice", nil) suggestion:theSuggestion];

    // increment the created suggestions and supported suggestions counts
    [[UVSession currentSession].user didCreateSuggestion:theSuggestion];

    self.forum.suggestionsNeedReload = YES;

    // update the remaining votes
    [UVSession currentSession].user.votesRemaining = theSuggestion.votesRemaining;

    // Back out to the welcome screen
    if ([UVSession currentSession].isModal && firstController) {
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3;
        transition.type = kCATransitionFade;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        UVWelcomeViewController *welcomeView = [[[UVWelcomeViewController alloc] init] autorelease];
        welcomeView.firstController = YES;
        NSArray *viewControllers = @[[self.navigationController.viewControllers objectAtIndex:0], welcomeView];
        [self.navigationController setViewControllers:viewControllers animated:NO];
    } else {
        UVSuggestionListViewController *list = (UVSuggestionListViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject];
        [list.navigationController setNavigationBarHidden:NO animated:NO];
        if ([UVSession currentSession].isModal && list.firstController) {
            CATransition* transition = [CATransition animation];
            transition.duration = 0.3;
            transition.type = kCATransitionFade;
            [list.navigationController.view.layer addAnimation:transition forKey:kCATransition];
            UVWelcomeViewController *welcomeView = [[[UVWelcomeViewController alloc] init] autorelease];
            welcomeView.firstController = YES;
            NSArray *viewControllers = @[[list.navigationController.viewControllers objectAtIndex:0], welcomeView];
            [list.navigationController setViewControllers:viewControllers animated:NO];
        } else {
            [list.navigationController popViewControllerAnimated:NO];
            [(UVWelcomeViewController *)[list.navigationController.viewControllers lastObject] updateLayout];
        }
    }
    
    _isSubmittingSuggestion = NO;
    
    [self hideActivityIndicator];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)initCellForCategory:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    UILabel *label = [self addCellLabel:cell];
    label.text = NSLocalizedStringFromTable(@"Category", @"UserVoice", nil);
    UILabel *valueLabel = [self addCellValueLabel:cell];
    valueLabel.tag = UV_CATEGORY_VALUE;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForCategory:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:UV_CATEGORY_VALUE];
    if (self.category.name) {
        valueLabel.text = self.category.name;
        valueLabel.textColor = [UIColor blackColor];
    } else {
        valueLabel.text = NSLocalizedStringFromTable(@"select", @"UserVoice", nil);
        valueLabel.textColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.80f alpha:1.0f];
    }
}

- (void)initCellForName:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    self.nameField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Name", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"“Anonymous”", @"UserVoice", nil)];
    self.nameField.text = self.userName;
    self.nameField.delegate = self;
}

- (void)initCellForEmail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    self.emailField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Email", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"(required)", @"UserVoice", nil)];
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.text = self.userEmail;
    self.emailField.delegate = self;
}

- (void)reloadCategoryTable {
    [tableView reloadData];
}

- (void)pushCategorySelectView {
    UIViewController *next = [[[UVCategorySelectViewController alloc] initWithSelectedCategory:self.category] autorelease];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)keyboardDidShow:(NSNotification*)notification {
    [super keyboardDidShow:notification];
    _isSubmittingSuggestion = NO;
    [self enableSubmitButton];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        [self dismissModalViewControllerAnimated:YES];
}

- (void)dismiss {
    if (titleField.text.length > 0 && !_isSubmittingSuggestion) {
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"You have not posted your idea. Are you sure you want to lose your unsaved data?", @"UserVoice", nil)
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                    destructiveButtonTitle:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil)
                                                         otherButtonTitles:nil] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
        } else {
            [actionSheet showInView:self.view];
        }
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)initNavigationItem {
    [super initNavigationItem];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismiss)] autorelease];
}


#pragma mark - UVSigninManageDelegate

- (void)signinManagerDidFail {
    _isSubmittingSuggestion = NO;
    [super signinManagerDidFail];
}


- (void)dealloc {
    self.forum = nil;
    self.title = nil;
    self.text = nil;
    self.name = nil;
    self.email = nil;
    self.textView = nil;
    self.titleField = nil;
    self.nameField = nil;
    self.emailField = nil;
    self.category = nil;
    
    [_didCreateCallback invalidate];
    [_didCreateCallback release];
    [_didAuthenticateCallback invalidate];
    [_didAuthenticateCallback release];
    
    [super dealloc];
}

@end
