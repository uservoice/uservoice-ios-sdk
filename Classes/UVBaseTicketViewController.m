//
//  UVBaseTicketViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVBaseTicketViewController.h"
#import "UVSession.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVArticleViewController.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVNewSuggestionViewController.h"
#import "UVCustomFieldValueSelectViewController.h"
#import "UVStylesheet.h"
#import "UVCustomField.h"
#import "UVUser.h"
#import "UVClientConfig.h"
#import "UVConfig.h"
#import "UVTicket.h"
#import "UVForum.h"
#import "UVKeyboardUtils.h"

@implementation UVBaseTicketViewController

@synthesize text;
@synthesize timer;
@synthesize textView;
@synthesize instantAnswers;
@synthesize emailField;
@synthesize selectedCustomFieldValues;

- (id)initWithText:(NSString *)theText {
    if (self = [self init]) {
        self.text = theText;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        self.selectedCustomFieldValues = [NSMutableDictionary dictionaryWithDictionary:[UVSession currentSession].config.customFields];
    }
    return self;
}

- (void)willLoadInstantAnswers {
}

- (void)didLoadInstantAnswers {
}

- (void)dismissKeyboard {
}

- (void)sendButtonTapped {
    [self dismissKeyboard];
    NSString *email = emailField.text;
    self.text = textView.text;
    if ([UVSession currentSession].user || (email && [email length] > 1)) {
        [self showActivityIndicator];
        [UVTicket createWithMessage:self.text andEmailIfNotLoggedIn:email andCustomFields:selectedCustomFieldValues andDelegate:self];
        [[UVSession currentSession] trackInteraction:@"pt"];
    } else {
        [self alertError:NSLocalizedStringFromTable(@"Please enter your email address before submitting your ticket.", @"UserVoice", nil)];
    }
}

- (void)didCreateTicket:(UVTicket *)theTicket {
    [self hideActivityIndicator];
    [self alertSuccess:NSLocalizedStringFromTable(@"Your ticket was successfully submitted.", @"UserVoice", nil)];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)suggestionButtonTapped {
    UIViewController *next = [[UVNewSuggestionViewController alloc] initWithForum:[UVSession currentSession].clientConfig.forum title:self.textView.text];
    [self pushViewControllerFromWelcome:next];
}

- (void)reloadCustomFieldsTable {
    [tableView reloadData];
}

- (void)selectCustomFieldAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)theTableView {
    [emailField resignFirstResponder];
    UVCustomField *field = [[UVSession currentSession].clientConfig.customFields objectAtIndex:indexPath.row];
    if ([field isPredefined]) {
        UIViewController *next = [[[UVCustomFieldValueSelectViewController alloc] initWithCustomField:field valueDictionary:selectedCustomFieldValues] autorelease];
        self.navigationItem.backBarButtonItem.title = NSLocalizedStringFromTable(@"Back", @"UserVoice", nil);
        [self.navigationController pushViewController:next animated:YES];
    } else {
        UITableViewCell *cell = [theTableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG];
        [textField becomeFirstResponder];
    }
}

- (void)nonPredefinedValueChanged:(NSNotification *)notification {
    UITextField *textField = (UITextField *)[notification object];
    UITableViewCell *cell = (UITableViewCell *)[textField superview];
    UITableView *table = (UITableView *)[cell superview];
    NSIndexPath *path = [table indexPathForCell:cell];
    UVCustomField *field = (UVCustomField *)[[UVSession currentSession].clientConfig.customFields objectAtIndex:path.row];
    [selectedCustomFieldValues setObject:textField.text forKey:field.name];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidChange:(UVTextView *)theTextEditor {
    if ([[self.text lowercaseString] isEqualToString:[self.textView.text lowercaseString]])
        return;
    self.text = self.textView.text;
    [self.timer invalidate];
    self.timer = nil;
    if (self.textView.text.length == 0) {
        self.instantAnswers = [NSArray array];
        [self didLoadInstantAnswers];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(loadInstantAnswers:) userInfo:nil repeats:NO];
    }
}

- (void)loadInstantAnswers:(NSTimer *)timer {
    loadingInstantAnswers = YES;
    self.instantAnswers = [NSArray array];
    [self willLoadInstantAnswers];
    // It's a combined search, remember?
    [[UVSession currentSession] trackInteraction:@"sf"];
    [[UVSession currentSession] trackInteraction:@"si"];
    [UVArticle getInstantAnswers:self.textView.text delegate:self];
}

- (void)didRetrieveInstantAnswers:(NSArray *)theInstantAnswers {
    self.instantAnswers = [theInstantAnswers subarrayWithRange:NSMakeRange(0, MIN(3, [theInstantAnswers count]))];
    loadingInstantAnswers = NO;
    [self didLoadInstantAnswers];
    
    // This seems like the only way to do justice to tracking the number of results from the combined search
    NSMutableArray *articleIds = [NSMutableArray arrayWithCapacity:[theInstantAnswers count]];
    for (id answer in theInstantAnswers) {
        if ([answer isKindOfClass:[UVArticle class]]) {
            [articleIds addObject:[NSNumber numberWithInt:[((UVArticle *)answer) articleId]]];
        }
    }
    [[UVSession currentSession] trackInteraction:[articleIds count] > 0 ? @"rfp" : @"rfz" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[articleIds count]], @"count", articleIds, @"ids", nil]];
    
    NSMutableArray *suggestionIds = [NSMutableArray arrayWithCapacity:[theInstantAnswers count]];
    for (id answer in theInstantAnswers) {
        if ([answer isKindOfClass:[UVSuggestion class]]) {
            [suggestionIds addObject:[NSNumber numberWithInt:[((UVSuggestion *)answer) suggestionId]]];
        }
    }
    [[UVSession currentSession] trackInteraction:[suggestionIds count] > 0 ? @"rip" : @"riz" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[suggestionIds count]], @"count", suggestionIds, @"ids", nil]];
}

- (UITextField *)customizeTextFieldCell:(UITableViewCell *)cell label:(NSString *)label placeholder:(NSString *)placeholder {
    cell.textLabel.text = label;
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(65, 11, 230, 22)];
    textField.placeholder = placeholder;
    textField.returnKeyType = UIReturnKeyDone;
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = [UIColor clearColor];
    textField.delegate = self;
    [cell.contentView addSubview:textField];
    return [textField autorelease];
}

- (void)initCellForCustomField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(16 + (IPAD ? 25 : 0), 0, cell.frame.size.width / 2 - 20, cell.frame.size.height)] autorelease];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.tag = UV_CUSTOM_FIELD_CELL_LABEL_TAG;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.adjustsFontSizeToFitWidth = YES;
    [cell addSubview:label];

    UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2 + 10, 10, cell.frame.size.width / 2 - (IPAD ? 64 : 20), cell.frame.size.height - 10)] autorelease];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    textField.borderStyle = UITextBorderStyleNone;
    textField.tag = UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG;
    textField.delegate = self;
    [cell addSubview:textField];

    UILabel *valueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width / 2 - 14, 5, cell.frame.size.width / 2 - (IPAD ? 64 : 20), cell.frame.size.height - 10)] autorelease];
    valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    valueLabel.font = [UIFont systemFontOfSize:16];
    valueLabel.tag = UV_CUSTOM_FIELD_CELL_VALUE_LABEL_TAG;
    valueLabel.textColor = [UIColor blackColor];
    valueLabel.backgroundColor = [UIColor clearColor];
    valueLabel.adjustsFontSizeToFitWidth = YES;
    valueLabel.textAlignment = NSTextAlignmentRight;
    [cell addSubview:valueLabel];
}

- (void)customizeCellForCustomField:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVCustomField *field = [[UVSession currentSession].clientConfig.customFields objectAtIndex:indexPath.row];
    UILabel *label = (UILabel *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_LABEL_TAG];
    UITextField *textField = (UITextField *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_TEXT_FIELD_TAG];
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:UV_CUSTOM_FIELD_CELL_VALUE_LABEL_TAG];
    label.text = field.name;
    cell.accessoryType = [field isPredefined] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    textField.enabled = [field isPredefined] ? NO : YES;
    cell.selectionStyle = [field isPredefined] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    valueLabel.hidden = ![field isPredefined];
    valueLabel.text = [selectedCustomFieldValues objectForKey:field.name];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nonPredefinedValueChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:textField];
}

- (void)initCellForEmail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    self.emailField = [self customizeTextFieldCell:cell label:NSLocalizedStringFromTable(@"Email", @"UserVoice", nil) placeholder:NSLocalizedStringFromTable(@"Required", @"UserVoice", nil)];
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell index:(int)index {
    id model = [instantAnswers objectAtIndex:index];
    if ([model isMemberOfClass:[UVArticle class]]) {
        UVArticle *article = (UVArticle *)model;
        cell.textLabel.text = article.question;
        cell.imageView.image = [UIImage imageNamed:@"uv_article.png"];
    } else {
        UVSuggestion *suggestion = (UVSuggestion *)model;
        cell.textLabel.text = suggestion.title;
        cell.imageView.image = [UIImage imageNamed:@"uv_idea.png"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
}

- (void)selectInstantAnswerAtIndex:(int)index {
    id model = [self.instantAnswers objectAtIndex:index];
    if ([model isMemberOfClass:[UVArticle class]]) {
        UVArticle *article = (UVArticle *)model;
        [[UVSession currentSession] trackInteraction:@"cf" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:article.articleId], @"id", self.textView.text, @"t", nil]];
        UVArticleViewController *next = [[[UVArticleViewController alloc] initWithArticle:article] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    } else {
        UVSuggestion *suggestion = (UVSuggestion *)model;
        [[UVSession currentSession] trackInteraction:@"ci" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:suggestion.suggestionId], @"id", self.textView.text, @"t", nil]];
        UVSuggestionDetailsViewController *next = [[[UVSuggestionDetailsViewController alloc] initWithSuggestion:suggestion] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    }
}

- (void)addSpinnerAndArrowTo:(UIView *)view atCenter:(CGPoint)center {
    UIImageView *arrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_arrow.png"]] autorelease];
    arrow.center = center;
    arrow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    arrow.tag = TICKET_VIEW_ARROW_TAG;
    [view addSubview:arrow];
    
    UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    spinner.center = center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    spinner.tag = TICKET_VIEW_SPINNER_TAG;
    [spinner startAnimating];
    [view addSubview:spinner];
}

- (void)updateSpinnerAndArrowIn:(UIView *)view withToggle:(BOOL)toggled animated:(BOOL)animated {
    UILabel *label = (UILabel *)[view viewWithTag:TICKET_VIEW_IA_LABEL_TAG];
    UIView *spinner = [view viewWithTag:TICKET_VIEW_SPINNER_TAG];
    UIView *arrow = [view viewWithTag:TICKET_VIEW_ARROW_TAG];
    if ([instantAnswers count] > 0)
      label.text = [self instantAnswersFoundMessage];
    void (^update)() = ^{
        if (loadingInstantAnswers) {
            spinner.layer.opacity = 1.0;
            arrow.layer.opacity = 0.0;
        } else {
            spinner.layer.opacity = 0.0;
            arrow.layer.opacity = 1.0;
            if (toggled) {
                arrow.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                arrow.layer.transform = CATransform3DIdentity;
            }
        }
    };
    if (animated) {
        [UIView animateWithDuration:0.3 animations:update];
    } else {
        update();
    }
}

- (BOOL)signedIn {
    return [UVSession currentSession].user != nil;
}

- (NSString *)instantAnswersFoundMessage {
    BOOL foundArticles = NO;
    BOOL foundIdeas = NO;
    for (id answer in instantAnswers) {
        if ([answer isKindOfClass:[UVArticle class]])
            foundArticles = YES;
        else if ([answer isKindOfClass:[UVSuggestion class]])
            foundIdeas = YES;
    }
    if (foundArticles && foundIdeas)
        return NSLocalizedStringFromTable(@"We've found some related articles and ideas that may help you faster than sending a message", @"UserVoice", nil);
    else if (foundArticles)
        return NSLocalizedStringFromTable(@"We've found some related articles that may help you faster than sending a message", @"UserVoice", nil);
    else if (foundIdeas)
        return NSLocalizedStringFromTable(@"We've found some related ideas that may help you faster than sending a message", @"UserVoice", nil);
    else
        return @"";
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    self.timer = nil;
    self.instantAnswers = nil;
    self.textView = nil;
    self.text = nil;
    self.emailField = nil;
    self.selectedCustomFieldValues = nil;
    [super dealloc];
}

@end
