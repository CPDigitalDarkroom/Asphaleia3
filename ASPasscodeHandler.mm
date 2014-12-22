#import "ASPasscodeHandler.h"
#import "ASCommon.h"
#import "UIAlertView+Blocks.h"
#import "SpringBoard.h"
#import "PreferencesHandler.h"
#import "SBUIPasscodeEntryField.h"
#import "SBUIPasscodeLockNumberPad.h"
#import <AudioToolbox/AudioServices.h>

@interface ASPasscodeHandler ()
@property SBUIPasscodeLockViewSimple4DigitKeypad *passcodeView;
@property UIWindow *passcodeWindow;
@property ASPasscodeHandlerEventBlock eventBlock;
@end

@implementation ASPasscodeHandler

+(instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}
 
-(void)showInKeyWindowWithPasscode:(NSString *)passcode iconView:(SBIconView *)iconView eventBlock:(ASPasscodeHandlerEventBlock)eventBlock {
	self.passcode = passcode;
	self.eventBlock = [eventBlock copy];

	if (self.passcodeView && self.passcodeWindow) {
		[self.passcodeView removeFromSuperview];
		[self.passcodeWindow setHidden:YES];
		self.passcodeView = nil;
		self.passcodeWindow = nil;
	}

	self.passcodeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.passcodeWindow.windowLevel = UIWindowLevelAlert;
	self.passcodeView = [[objc_getClass("SBUIPasscodeLockViewSimple4DigitKeypad") alloc] init];
	[self.passcodeView setShowsEmergencyCallButton:NO];
	[self.passcodeView setDelegate:(id)self];
	[self.passcodeView updateStatusText:@"Enter Passcode" subtitle:nil animated:NO];

	UIVisualEffect *effect;
	effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	
	UIVisualEffectView *effectView;
	effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
	
	effectView.frame = self.passcodeWindow.bounds;
	[self.passcodeWindow insertSubview:effectView atIndex:0];

	[self.passcodeView setBackgroundAlpha:0.f];

	UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[iconView.icon getIconImage:1]];
	iconImageView.contentMode = UIViewContentModeScaleAspectFill;
	iconImageView.frame = CGRectMake(0,0,40,40);
	iconImageView.center = CGPointMake(CGRectGetMidX(self.passcodeWindow.bounds),32);

	self.passcodeView.luminosityBoost = 0.33;
	[self.passcodeView _evaluateLuminance];

	[self.passcodeWindow addSubview:iconImageView];
    [self.passcodeWindow addSubview:self.passcodeView];
    [self.passcodeWindow setAlpha:0.f];
    [self.passcodeWindow makeKeyAndVisible];
    [UIView animateWithDuration:.15f delay:0.0
                    options:UIViewAnimationOptionCurveEaseIn
                 animations:^{[self.passcodeWindow setAlpha:1.f];}
                 completion:nil];
}

-(void)passcodeLockViewPasscodeEntered:(SBUIPasscodeLockViewSimple4DigitKeypad *)arg1 {
	if (arg1.passcode.length == 4 && [arg1.passcode isEqual:self.passcode]) {
		[UIView animateWithDuration:.15f delay:0.0
                    options:UIViewAnimationOptionCurveEaseIn
                 animations:^{[self.passcodeWindow setAlpha:0.f];}
                 completion:^(BOOL finished){
                 	if (finished) {
                 		[self.passcodeView removeFromSuperview];
						[self.passcodeWindow setHidden:YES];
						self.passcodeView = nil;
						self.passcodeWindow = nil;
						self.eventBlock(YES);
                 	}
                 }];
	} else if (arg1.passcode.length == 4 && ![arg1.passcode isEqual:self.passcode]) {
		[arg1 resetForFailedPasscode];
	}
}

-(void)passcodeLockViewCancelButtonPressed:(id)arg1 {
	[UIView animateWithDuration:.15f delay:0.0
                    options:UIViewAnimationOptionCurveEaseIn
                 animations:^{[self.passcodeWindow setAlpha:0.f];}
                 completion:^(BOOL finished){
                 	if (finished) {
                 		[self.passcodeView removeFromSuperview];
						[self.passcodeWindow setHidden:YES];
						self.passcodeView = nil;
						self.passcodeWindow = nil;
						self.eventBlock(NO);
                 	}
                 }];
}
 
@end