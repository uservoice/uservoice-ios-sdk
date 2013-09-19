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
#import "UVRequestToken.h"
#import "UVBabayaga.h"

@implementation UVSigninManager

@synthesize email;
@synthesize name;
@synthesize password;
@synthesize alertView;

+ (UVSigninManager *)manager {
    return [[[self alloc] init] autorelease];
}

- (void)showEmailAlertView {
    [self clearAlertViewDelegate];
    
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

- (void)clearAlertViewDelegate {
    if (self.alertView) {
        self.alertView.delegate = nil;
    }
}

- (void)showPasswordAlertView {
    [self clearAlertViewDelegate];
    
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
    [self clearAlertViewDelegate];
    
    state = STATE_FAILED;
    
    self.alertView = [[[UIAlertView alloc] init] autorelease];
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        alertView.title = NSLocalizedStringFromTable(@"There was a problem logging you in.", @"UserVoice", @"shorter version for landscpae");
    } else {
        alertView.title = NSLocalizedStringFromTable(@"There was a problem logging you in, please check your password and try again.", @"UserVoice", @"longer version for portrait");
    }
    alertView.delegate = self;
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Try again", @"UserVoice", nil)];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Forgot password", @"UserVoice", nil)];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)];
    [alertView show];
}

- (void)signInWithCallback:(UVCallback *)callback {
    if ([self user]) {
        [callback invokeCallback:nil];
    } else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *storedEmail = [prefs stringForKey:@"uv-user-email"];
        NSString *storedName = [prefs stringForKey:@"uv-user-name"];
        if (storedEmail && [storedEmail length] > 0) {
            [self signInWithEmail:storedEmail name:storedName callback:callback];
        } else {
            if (_callback) {
                [_callback release];
            }
            _callback = [callback retain];
            [self showEmailAlertView];
        }
    }
}

- (void)signInWithEmail:(NSString *)theEmail name:(NSString *)theName callback:(UVCallback *)callback {
    if ([self user] && [[self user].email isEqualToString:theEmail]) {
        [callback invokeCallback:nil];
    } else {
        state = STATE_EMAIL;
        self.email = theEmail;
        self.name = theName;
        if (_callback) {
            [_callback release];
        }
        _callback = [callback retain];
        [UVUser discoverWithEmail:email delegate:self];
    }
}

- (UVUser *)user {
    return [UVSession currentSession].user;
}

#pragma mark - Invoke UVSigninManagerDelegate methods

- (void)invokeDidSignIn {
    if (_callback) {
        [_callback invokeCallback:[self user]];
        [_callback release];
        _callback = nil;
    }

    if ([self.delegate respondsToSelector:@selector(signinManagerDidSignIn:)]) {
        [self.delegate signinManagerDidSignIn:[self user]];
    }
}

- (void)invokeDidFail {
    if ([self.delegate respondsToSelector:@selector(signinManagerDidFail)]) {
        [self.delegate signinManagerDidFail];
    }
}

- (void)didRetrieveAccessToken:(UVAccessToken *)token {
    [token persist];
    [UVSession currentSession].accessToken = token;
    [UVUser retrieveCurrentUser:self];
}


#pragma mark - UVUserDelegate

- (void)didCreateUser:(UVUser *)theUser {
    [UVSession currentSession].user = theUser;
    [[UVSession currentSession].accessToken persist];
    [UVBabayaga track:AUTHENTICATE];
    [self invokeDidSignIn];
}

- (void)didRetrieveCurrentUser:(UVUser *)theUser {
    [UVSession currentSession].user = theUser;
    [UVBabayaga track:AUTHENTICATE];
    [self invokeDidSignIn];
}

- (void)didDiscoverUser:(UVUser *)theUser {
    [self showPasswordAlertView];
}

- (void)didSendForgotPassword:(id)obj {
    [self clearAlertViewDelegate];

    self.alertView = [[[UIAlertView alloc] init] autorelease];
    alertView.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Password reset email sent to %@", @"UserVoice", nil), email];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil)];
    [alertView show];
    
    [self invokeDidFail];
}

- (void)alertView:(UIAlertView *)theAlertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (state == STATE_EMAIL) {
        if (buttonIndex == 1) {
            NSString *text = [alertView textFieldAtIndex:0].text;
            if (text.length == 0)
                return;

            self.email = text;
            [UVUser discoverWithEmail:text delegate:self];
        }
    } else if (state == STATE_PASSWORD) {
        if (buttonIndex == 1) {
            self.password = [alertView textFieldAtIndex:0].text;
            if ([UVSession currentSession].requestToken == nil) {
                [UVRequestToken getRequestTokenWithDelegate:self];
            } else {
                [UVAccessToken getAccessTokenWithDelegate:self andEmail:email andPassword:password];
                self.password = nil;
            }
        } else {
            [self invokeDidFail];
        }
    } else if (state == STATE_FAILED) {
        if (buttonIndex == 0) {
            [self showPasswordAlertView];
        } else if (buttonIndex == 1) {
            [UVUser forgotPassword:email delegate:self];
        } else {
            [self invokeDidFail];
        }
    }
}

- (void)didRetrieveRequestToken:(UVRequestToken *)token {
    [UVSession currentSession].requestToken = token;
    if (state == STATE_EMAIL) {
        [UVUser findOrCreateWithEmail:email andName:name andDelegate:self];
    } else if (state == STATE_PASSWORD) {
        [UVAccessToken getAccessTokenWithDelegate:self andEmail:email andPassword:password];
        self.password = nil;
    }
}

- (void)didReceiveError:(NSError *)error {
    if (state == STATE_EMAIL && [UVUtils isNotFoundError:error]) {
        if ([UVSession currentSession].requestToken == nil) {
            [UVRequestToken getRequestTokenWithDelegate:self];
        } else {
            [UVUser findOrCreateWithEmail:email andName:name andDelegate:self];
        }
    } else if ([UVUtils isAuthError:error] || [UVUtils isNotFoundError:error]) {
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

    [self clearAlertViewDelegate];
    self.alertView = nil;

    [super dealloc];
}

@end
