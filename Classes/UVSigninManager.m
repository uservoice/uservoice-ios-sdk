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

@implementation UVSigninManager {
    NSInteger _state;
    UVCallback *_callback;
}

+ (UVSigninManager *)manager {
    return [self new];
}

- (void)showEmailAlertView {
    [self clearAlertViewDelegate];
    
    _state = STATE_EMAIL;

    _alertView = [UIAlertView new];
    _alertView.title = NSLocalizedStringFromTable(@"Enter your email", @"UserVoice", nil);
    _alertView.delegate = self;
    if ([_alertView respondsToSelector:@selector(setAlertViewStyle:)])
        _alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [_alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)];
    [_alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Done", @"UserVoice", nil)];
    UITextField *textField = [_alertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    [_alertView show];
}

- (void)clearAlertViewDelegate {
    if (_alertView) {
        _alertView.delegate = nil;
    }
}

- (void)showPasswordAlertView {
    [self clearAlertViewDelegate];
    
    _state = STATE_PASSWORD;
    
    _alertView = [UIAlertView new];
    _alertView.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Enter UserVoice password for %@", @"UserVoice", nil), _email];
    _alertView.delegate = self;
    
    if ([_alertView respondsToSelector:@selector(setAlertViewStyle:)])
        _alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
    [_alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)];
    [_alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Sign in", @"UserVoice", nil)];
    
    UITextField *textField = [_alertView textFieldAtIndex:0];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    
    [_alertView show];
}

- (void)showFailedAlertView {
    [self clearAlertViewDelegate];
    
    _state = STATE_FAILED;
    
    _alertView = [UIAlertView new];
    _alertView.title = NSLocalizedStringFromTable(@"There was a problem logging you in.", @"UserVoice", nil);
    _alertView.delegate = self;
    [_alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Try again", @"UserVoice", nil)];
    [_alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Forgot password", @"UserVoice", nil)];
    [_alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)];
    [_alertView show];
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
            _callback = callback;
            [self showEmailAlertView];
        }
    }
}

- (void)signInWithEmail:(NSString *)theEmail name:(NSString *)theName callback:(UVCallback *)callback {
    if (self.user && [self.user.email isEqualToString:theEmail]) {
        [callback invokeCallback:nil];
    } else {
        _state = STATE_EMAIL;
        _email = theEmail;
        _name = theName;
        _callback = callback;
        [UVUser discoverWithEmail:_email delegate:self];
    }
}

- (UVUser *)user {
    return [UVSession currentSession].user;
}

#pragma mark - Invoke UVSigninManagerDelegate methods

- (void)invokeDidSignIn {
    if (_callback) {
        [_callback invokeCallback:self.user];
        _callback = nil;
    }

    if ([_delegate respondsToSelector:@selector(signinManagerDidSignIn:)]) {
        [_delegate signinManagerDidSignIn:self.user];
    }
}

- (void)invokeDidFail {
    if ([_delegate respondsToSelector:@selector(signinManagerDidFail)]) {
        [_delegate signinManagerDidFail];
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

    _alertView = [UIAlertView new];
    _alertView.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Password reset email sent to %@", @"UserVoice", nil), _email];
    [_alertView addButtonWithTitle:NSLocalizedStringFromTable(@"OK", @"UserVoice", nil)];
    [_alertView show];
    
    [self invokeDidFail];
}

- (void)alertView:(UIAlertView *)theAlertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_state == STATE_EMAIL) {
        if (buttonIndex == 1) {
            NSString *text = [_alertView textFieldAtIndex:0].text;
            if (text.length == 0)
                return;

            _email = text;
            [UVUser discoverWithEmail:text delegate:self];
        }
    } else if (_state == STATE_PASSWORD) {
        if (buttonIndex == 1) {
            _password = [_alertView textFieldAtIndex:0].text;
            if ([UVSession currentSession].requestToken == nil) {
                [UVRequestToken getRequestTokenWithDelegate:self];
            } else {
                [UVAccessToken getAccessTokenWithDelegate:self andEmail:_email andPassword:_password];
                _password = nil;
            }
        } else {
            [self invokeDidFail];
        }
    } else if (_state == STATE_FAILED) {
        if (buttonIndex == 0) {
            [self showPasswordAlertView];
        } else if (buttonIndex == 1) {
            [UVUser forgotPassword:_email delegate:self];
        } else {
            [self invokeDidFail];
        }
    }
}

- (void)didRetrieveRequestToken:(UVRequestToken *)token {
    [UVSession currentSession].requestToken = token;
    if (_state == STATE_EMAIL) {
        [UVUser findOrCreateWithEmail:_email andName:_name andDelegate:self];
    } else if (_state == STATE_PASSWORD) {
        [UVAccessToken getAccessTokenWithDelegate:self andEmail:_email andPassword:_password];
        _password = nil;
    }
}

- (void)didReceiveError:(NSError *)error {
    if (_state == STATE_EMAIL && [UVUtils isNotFoundError:error]) {
        if ([UVSession currentSession].requestToken == nil) {
            [UVRequestToken getRequestTokenWithDelegate:self];
        } else {
            [UVUser findOrCreateWithEmail:_email andName:_name andDelegate:self];
        }
    } else if ([UVUtils isAuthError:error] || [UVUtils isNotFoundError:error]) {
        [self showFailedAlertView];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_alertView dismissWithClickedButtonIndex:1 animated:YES];
    return YES;
}

- (void)dealloc {
    [self clearAlertViewDelegate];
}

@end
