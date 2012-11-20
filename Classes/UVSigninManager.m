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
#import "NSError+UVExtras.h"

@implementation UVSigninManager

@synthesize email;
@synthesize alertView;

+ (UVSigninManager *)manager {
    return [[[self alloc] init] autorelease];
}

- (void)signInWithDelegate:(id)theDelegate action:(SEL)theAction {
    if ([UVSession currentSession].user) {
        [theDelegate performSelector:theAction];
    } else {
        delegate = theDelegate;
        action = theAction;
        state = STATE_EMAIL;
        self.alertView = [[[UIAlertView alloc] init] autorelease];
        alertView.title = NSLocalizedStringFromTable(@"Enter your email", @"UserVoice", nil);
        alertView.delegate = self;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Done", @"UserVoice", nil)];
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        [alertView show];
    }
}

- (void)signInWithEmail:(NSString *)theEmail delegate:(id)theDelegate action:(SEL)theAction {
    if ([UVSession currentSession].user && [UVSession currentSession].user.email == theEmail) {
        [theDelegate performSelector:theAction];
    } else {
        delegate = theDelegate;
        action = theAction;
        state = STATE_PASSWORD;
        self.email = theEmail;
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
    state = STATE_PASSWORD;
    self.alertView = [[[UIAlertView alloc] init] autorelease];
    alertView.title = [NSString stringWithFormat:@"%@\n%@", NSLocalizedStringFromTable(@"Enter your password", @"UserVoice", nil), email];
    alertView.delegate = self;
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Sign in", @"UserVoice", nil)];
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    [alertView show];
}

- (void)alertView:(UIAlertView *)theAlertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *text = [alertView textFieldAtIndex:0].text;
    if (state == STATE_EMAIL) {
        if (text.length == 0)
            return;
        [delegate performSelector:@selector(showActivityIndicator)];
        self.email = text;
        [UVUser discoverWithEmail:text delegate:self];
    } else if (state == STATE_PASSWORD) {
        if (text.length == 0)
            return;
        [delegate performSelector:@selector(showActivityIndicator)];
        [UVAccessToken getAccessTokenWithDelegate:self andEmail:email andPassword:text];
    }
}

- (void)didReceiveError:(NSError *)error {
    if (state == STATE_EMAIL && [error isNotFoundError]) {
        [UVUser findOrCreateWithEmail:email andName:nil andDelegate:self];
    } else if ([error isAuthError] || [error isNotFoundError]) {
        [delegate performSelector:@selector(hideActivityIndicator)];
        NSString *msg = NSLocalizedStringFromTable(@"There was a problem logging you in, please check your password and try again.", @"UserVoice", nil);
        [delegate performSelector:@selector(alertError:) withObject:msg];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [alertView dismissWithClickedButtonIndex:alertView.firstOtherButtonIndex animated:YES];
    return YES;
}

- (void)dealloc {
    self.email = nil;
    self.alertView = nil;
    [super dealloc];
}

@end
