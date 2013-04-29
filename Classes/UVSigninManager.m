//
//  UVSigninManager.m
//  UserVoice
//
//  Created by Austin Taylor on 11/20/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVSigninManager.h"
#import "UVSession.h"
#import "UVUser.h"
#import "UVAccessToken.h"
#import "UVUtils.h"

@implementation UVSigninManager

@synthesize email;
@synthesize name;
@synthesize alertView;

+ (UVSigninManager *)manager {
    return [[[self alloc] init] autorelease];
}

- (void)showEmailAlertView {
    state = STATE_EMAIL;
    self.alertView = [[[UIAlertView alloc] init] autorelease];
    alertView.title = NSLocalizedStringFromTable(@"Enter your email", @"UserVoice", nil);
    alertView.delegate = self;
    if ([alertView respondsToSelector:@selector(setAlertViewStyle:)])
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Done", @"UserVoice", nil)];
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    [alertView show];
}

- (void)showPasswordAlertView {
    state = STATE_PASSWORD;
    self.alertView = [[[UIAlertView alloc] init] autorelease];
    alertView.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Enter UserVoice password for %@", @"UserVoice", nil), email];
    alertView.delegate = self;
    if ([alertView respondsToSelector:@selector(setAlertViewStyle:)])
        alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Sign in", @"UserVoice", nil)];
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    [alertView show];
}

- (void)showFailedAlertView {
    state = STATE_FAILED;
    self.alertView = [[[UIAlertView alloc] init] autorelease];
    alertView.title = NSLocalizedStringFromTable(@"There was a problem logging you in, please check your password and try again.", @"UserVoice", nil);
    alertView.delegate = self;
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Try again", @"UserVoice", nil)];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Forgot password", @"UserVoice", nil)];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)];
    [alertView show];
}

- (void)signInWithDelegate:(id)theDelegate action:(SEL)theAction {
    if ([UVSession currentSession].user) {
        [theDelegate performSelector:theAction];
    } else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *storedEmail = [prefs stringForKey:@"uv-user-email"];
        NSString *storedName = [prefs stringForKey:@"uv-user-name"];
        if (storedEmail && [storedEmail length] > 0) {
            [self signInWithEmail:storedEmail name:storedName delegate:theDelegate action:theAction];
        } else {
            delegate = theDelegate;
            action = theAction;
            [self showEmailAlertView];
        }
    }
}

- (void)signInWithEmail:(NSString *)theEmail name:(NSString *)theName delegate:(id)theDelegate action:(SEL)theAction {
    if ([UVSession currentSession].user && [[UVSession currentSession].user.email isEqualToString:theEmail]) {
        [theDelegate performSelector:theAction];
    } else {
        delegate = theDelegate;
        action = theAction;
        state = STATE_EMAIL;
        self.email = theEmail;
        self.name = theName;
        [delegate performSelector:@selector(showActivityIndicator)];
        [UVUser discoverWithEmail:email delegate:self];
    }
}

- (void)didRetrieveAccessToken:(UVAccessToken *)token {
    [delegate performSelector:@selector(hideActivityIndicator)];
    [token persist];
    [UVSession currentSession].accessToken = token;
    [UVUser retrieveCurrentUser:self];
}

- (void)didCreateUser:(UVUser *)theUser {
    [delegate performSelector:@selector(hideActivityIndicator)];
    [UVSession currentSession].user = theUser;
    [[UVSession currentSession].accessToken persist];
    [delegate performSelector:action];
}

- (void)didRetrieveCurrentUser:(UVUser *)theUser {
    [delegate performSelector:@selector(hideActivityIndicator)];
    [UVSession currentSession].user = theUser;
    [delegate performSelector:action];
}

- (void)didDiscoverUser:(UVUser *)theUser {
    [delegate performSelector:@selector(hideActivityIndicator)];
    [self showPasswordAlertView];
}

- (void)didSendForgotPassword:(id)obj {
    [delegate performSelector:@selector(hideActivityIndicator)];
    self.alertView = [[[UIAlertView alloc] init] autorelease];
    alertView.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Password reset email sent to", @"UserVoice", nil), email];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil)];
    [alertView show];
}

- (void)alertView:(UIAlertView *)theAlertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (state == STATE_EMAIL) {
        if (buttonIndex == 1) {
            NSString *text = [alertView textFieldAtIndex:0].text;
            if (text.length == 0)
                return;
            [delegate performSelector:@selector(showActivityIndicator)];
            self.email = text;
            [UVUser discoverWithEmail:text delegate:self];
        }
    } else if (state == STATE_PASSWORD) {
        if (buttonIndex == 1) {
            NSString *text = [alertView textFieldAtIndex:0].text;
            [delegate performSelector:@selector(showActivityIndicator)];
            [UVAccessToken getAccessTokenWithDelegate:self andEmail:email andPassword:text];
        }
    } else if (state == STATE_FAILED) {
        if (buttonIndex == 0) {
            [self showPasswordAlertView];
        } else if (buttonIndex == 1) {
            [delegate performSelector:@selector(showActivityIndicator)];
            [UVUser forgotPassword:email delegate:self];
        }
    }
}

- (void)didReceiveError:(NSError *)error {
    if (state == STATE_EMAIL && [UVUtils isNotFoundError:error]) {
        [UVUser findOrCreateWithEmail:email andName:name andDelegate:self];
    } else if ([UVUtils isAuthError:error] || [UVUtils isNotFoundError:error]) {
        [delegate performSelector:@selector(hideActivityIndicator)];
        [self showFailedAlertView];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [alertView dismissWithClickedButtonIndex:1 animated:YES];
    return YES;
}

- (void)dealloc {
    self.email = nil;
    self.name = nil;
    self.alertView = nil;
    [super dealloc];
}

@end
