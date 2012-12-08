//
//  UVBaseSuggestionViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 11/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVBaseSuggestionViewController.h"
#import "NSError+UVExtras.h"
#import "UVSession.h"
#import "UVForum.h"
#import "UVCategory.h"
#import "UVClientConfig.h"
#import "UVSuggestion.h"
#import "UVUser.h"
#import "UVSuggestionListViewController.h"
#import "UVWelcomeViewController.h"
#import "UVCategorySelectViewController.h"

@implementation UVBaseSuggestionViewController

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

- (id)initWithTitle:(NSString *)theTitle {
    if (self = [self init]) {
        self.title = theTitle;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        self.forum = [UVSession currentSession].clientConfig.forum;
        self.shouldShowCategories = self.forum.categories && [self.forum.categories count] > 0;
        self.articleHelpfulPrompt = NSLocalizedStringFromTable(@"Do you still want to post an idea?", @"UserVoice", nil);
        self.articleReturnMessage = NSLocalizedStringFromTable(@"Yes, go to my idea", @"UserVoice", nil);
    }
    return self;
}

- (void)didReceiveError:(NSError *)error {
    if ([error isNotFoundError]) {
        [self hideActivityIndicator];
    } else if ([error isUVRecordInvalidForField:@"title" withMessage:@"is not allowed."]) {
        [self hideActivityIndicator];
        [self alertError:NSLocalizedStringFromTable(@"A suggestion with this title already exists. Please change the title.", @"UserVoice", nil)];
    } else {
        [super didReceiveError:error];
    }
}

- (void)createSuggestion {
    self.title = titleField.text;
    self.text = textView.text;
    [self showActivityIndicator];
    [[UVSession currentSession] trackInteraction:@"pi"];
    [UVSuggestion createWithForum:self.forum
                         category:self.category
                            title:self.title
                             text:self.text
                            votes:1
                         delegate:self];
}

- (void)createButtonTapped {
    self.title = titleField.text;
    self.text = textView.text;
    self.name = nameField.text;
    self.email = emailField.text;
    [nameField resignFirstResponder];
    [emailField resignFirstResponder];

    if (self.email && [self.email length] > 1) {
        [self requireUserAuthenticated:email name:name action:@selector(createSuggestion)];
    } else {
        [self alertError:NSLocalizedStringFromTable(@"Please enter your email address before submitting your suggestion.", @"UserVoice", nil)];
    }
}

- (void)didCreateSuggestion:(UVSuggestion *)theSuggestion {
    [self hideActivityIndicator];
    /* [self alertSuccess:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Your idea \"%@\" was successfully created.", @"UserVoice", nil), self.title]]; */
    [[UVSession currentSession] flash:NSLocalizedStringFromTable(@"Your idea has been posted on our forum.", @"UserVoice", nil) title:NSLocalizedStringFromTable(@"Success!", @"UserVoice", nil) suggestion:theSuggestion];

    // increment the created suggestions and supported suggestions counts
    [[UVSession currentSession].user didCreateSuggestion:theSuggestion];

    [UVSession currentSession].clientConfig.forum.suggestionsNeedReload = YES;

    // update the remaining votes
    [UVSession currentSession].user.votesRemaining = theSuggestion.votesRemaining;

    // Back out to the welcome screen
    UVSuggestionListViewController *list = (UVSuggestionListViewController *)[((UINavigationController *)self.presentingViewController).viewControllers lastObject];
    if ([UVSession currentSession].isModal && list.firstController) {
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3;
        transition.type = kCATransitionFade;
        [list.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [list.navigationController setNavigationBarHidden:NO animated:NO];
        UVWelcomeViewController *welcomeView = [[[UVWelcomeViewController alloc] init] autorelease];
        welcomeView.firstController = YES;
        NSArray *viewControllers = @[list.navigationController.viewControllers[0], welcomeView];
        [list.navigationController setViewControllers:viewControllers animated:NO];
    } else {
        [list.navigationController popViewControllerAnimated:NO];
        [(UVWelcomeViewController *)[list.navigationController.viewControllers lastObject] updateLayout];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (UITextField *)customizeTextFieldCell:(UITableViewCell *)cell label:(NSString *)label placeholder:(NSString *)placeholder {
    cell.textLabel.text = label;
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(65, 12, cell.bounds.size.width - 75, 22)];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.placeholder = placeholder;
    textField.returnKeyType = UIReturnKeyDone;
    textField.borderStyle = UITextBorderStyleNone;
    textField.delegate = self;
    [cell.contentView addSubview:textField];
    [textField release];
    return textField;
}

- (void)customizeCellForCategory:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = NSLocalizedStringFromTable(@"Category", @"UserVoice", nil);
    cell.detailTextLabel.text = self.category.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

- (void)pushCategorySelectView {
    UIViewController *next = [[[UVCategorySelectViewController alloc] initWithSelectedCategory:self.category] autorelease];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        [self dismissModalViewControllerAnimated:YES];
}

- (void)dismiss {
    if (titleField.text.length > 0) {
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"You have not posted your idea. Are you sure you want to lose your unsaved data?", @"UserVoice", nil)
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                    destructiveButtonTitle:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil)
                                                         otherButtonTitles:nil] autorelease];
        [actionSheet showInView:self.view];
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
    [super dealloc];
}

@end
