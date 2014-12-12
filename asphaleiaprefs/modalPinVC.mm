//
//  CRViewController.m
//  pintest
//
//  Created by Callum Ryan on 05/01/2014.
//  Copyright (c) 2014 Callum Ryan. All rights reserved.
//

#import "modalPinVC.h"
#import <AudioToolbox/AudioToolbox.h>
#import <Preferences/Preferences.h>
#import <sys/socket.h> 
#import <sys/sysctl.h>
#define prefpath @"/var/mobile/Library/Preferences/com.a3tweaks.asphaleia.plist"

@interface asphaleiaMain: PSListController {
}
-(void)goBack;
-(void)authenticated;
@end
@interface passcodeOptions: PSListController {
}
@end

@interface modalPinVC () {
}
@property (retain) NSString *oldPasscode;

@end

@implementation modalPinVC
- (void)viewDidLoad
{
    // NSLog(@"========initted");
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.view = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,20, self.view.frame.size.width, 44.0)];
    navBar.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:navBar];
    // [navBar release];
    UIView *topView = [[UIView alloc]initWithFrame:[[UIApplication sharedApplication] statusBarFrame]];
    topView.backgroundColor = [UIColor colorWithRed:0.9725 green:0.9725 blue:0.9725 alpha:1.f];
    [self.view addSubview:topView];
    // [topView release];
    
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.delegate = self;
    [self.view addSubview:textField];
    [textField becomeFirstResponder];
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    if (_isAuth) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonPressed:)];
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Authenticate"];
        
        item.rightBarButtonItem = rightButton;
        item.hidesBackButton = YES;
        [navBar pushNavigationItem:item animated:NO];
        _altView = [[UIView alloc]init];
        _altView.frame = CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height - 216 - 64);
        
        NSMutableArray *overallAray = [[NSMutableArray alloc]init];
        NSMutableArray *pageArray = [[NSMutableArray alloc]initWithCapacity:4];
        for (int k = 1; k < 5; k++) {
            UIImageView *dashView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]];
            dashView.frame = CGRectMake(86+((k-1)*43), ((_altView.frame.size.height-20)/2)-9, 18, 19);
            [_altView addSubview:dashView];
            [pageArray addObject:dashView];
        }
        [overallAray addObject:[[NSArray alloc]initWithArray:pageArray]];
        
        
        NSMutableArray *labelArray = [[NSMutableArray alloc]initWithCapacity:6];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, ((_altView.frame.size.height-20)/2)-60, 320, 20)];
        label.text = @"Enter your passcode";
        label.textAlignment = NSTextAlignmentCenter; label.font = [UIFont systemFontOfSize:15.f];
        [_altView addSubview:label]; [labelArray addObject:label];//[label release];
        
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, ((_altView.frame.size.height-20)/2)+40, 320, 20)];
        label.text = @"";
        label.textAlignment = NSTextAlignmentCenter; label.font = [UIFont systemFontOfSize:15.f];
        [_altView addSubview:label]; [labelArray addObject:label];//[label release];
        [overallAray addObject:labelArray];
        // [labelArray release];
        _imageViews = [[NSArray alloc]initWithArray:overallAray];
        // [overallAray release];
        
        [self.view addSubview:_altView];
        
        if([[NSFileManager defaultManager]fileExistsAtPath:prefpath]){
            NSDictionary *prefs=[[NSDictionary alloc]initWithContentsOfFile:prefpath];
            if([prefs objectForKey:@"passcode"]) {
                self.oldPasscode = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"passcode"]];
            } else {
                self.oldPasscode = @"";
            }
        }else{
            self.oldPasscode = @"";
        }

    } else if(_isSet) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonPressed:)];
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Set Passcode"];
        item.rightBarButtonItem = rightButton;
        item.hidesBackButton = YES;
        [navBar pushNavigationItem:item animated:NO];
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.frame = CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height - 216 - 64);
        //_scrollView.backgroundColor =   [UIColor blueColor];
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 2, _scrollView.frame.size.height);
        _scrollView.scrollEnabled = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_scrollView setPagingEnabled:YES];
        [_scrollView setDelegate:self];
        _currentPage = 1;
        
        NSMutableArray *overallAray = [[NSMutableArray alloc]initWithCapacity:8];
        for (int i = 1; i < 3; i++) {
            NSMutableArray *pageArray = [[NSMutableArray alloc]initWithCapacity:4];
            for (int k = 1; k < 5; k++) {
                UIImageView *dashView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]];
                dashView.frame = CGRectMake(86+((k-1)*43) + ((i-1)*320), ((_scrollView.frame.size.height-20)/2)-9, 18, 19);
                [_scrollView addSubview:dashView];
                [pageArray addObject:dashView];
                // [dashView release];
            }
            [overallAray addObject:[[NSArray alloc]initWithArray:pageArray]];
            // [pageArray release];
        }
        
        
        NSMutableArray *labelArray = [[NSMutableArray alloc]initWithCapacity:6];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, ((_scrollView.frame.size.height-20)/2)-60, 320, 20)];
        label.text = @"Enter your new passcode";
        label.textAlignment = NSTextAlignmentCenter; label.font = [UIFont systemFontOfSize:15.f];
        [_scrollView addSubview:label]; [labelArray addObject:label];//[label release];
        
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, ((_scrollView.frame.size.height-20)/2)+40, 320, 20)];
        label.text = @"";
        label.textAlignment = NSTextAlignmentCenter; label.font = [UIFont systemFontOfSize:15.f];
        [_scrollView addSubview:label]; [labelArray addObject:label];//[label release];
        
        label = [[UILabel alloc]initWithFrame:CGRectMake(320, ((_scrollView.frame.size.height-20)/2)-60, 320, 20)];
        label.text = @"Re-enter your new passcode";
        label.textAlignment = NSTextAlignmentCenter; label.font = [UIFont systemFontOfSize:15.f];
        [_scrollView addSubview:label]; [labelArray addObject:label];//[label release];
        
        [overallAray addObject:labelArray];
        // [labelArray release];
        _imageViews = [[NSArray alloc]initWithArray:overallAray];
        // [overallAray release];
        
        [self.view addSubview:_scrollView];
        
    } else {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonPressed:)];
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Change Passcode"];
        item.rightBarButtonItem = rightButton;
        item.hidesBackButton = YES;
        [navBar pushNavigationItem:item animated:NO];
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.frame = CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height - 216 - 64);
        //_scrollView.backgroundColor =   [UIColor blueColor];
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3, _scrollView.frame.size.height);
        _scrollView.scrollEnabled = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_scrollView setPagingEnabled : YES];
        [_scrollView setDelegate:self];
        _currentPage = 1;
        
        NSMutableArray *overallAray = [[NSMutableArray alloc]initWithCapacity:12];
        for (int i = 1; i < 4; i++) {
            NSMutableArray *pageArray = [[NSMutableArray alloc]initWithCapacity:4];
            for (int k = 1; k < 5; k++) {
                UIImageView *dashView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]];
                dashView.frame = CGRectMake(86+((k-1)*43) + ((i-1)*320), ((_scrollView.frame.size.height-20)/2)-9, 18, 19);
                [_scrollView addSubview:dashView];
                [pageArray addObject:dashView];
                // [dashView release];
            }
            [overallAray addObject:[[NSArray alloc]initWithArray:pageArray]];
            // [pageArray release];
        }
        
        
        NSMutableArray *labelArray = [[NSMutableArray alloc]initWithCapacity:6];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, ((_scrollView.frame.size.height-20)/2)-60, 320, 20)];
        label.text = @"Enter your old passcode";
        label.textAlignment = NSTextAlignmentCenter; label.font = [UIFont systemFontOfSize:15.f];
        [_scrollView addSubview:label]; [labelArray addObject:label];//[label release];
        
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, ((_scrollView.frame.size.height-20)/2)+40, 320, 20)];
        label.text = @"";
        label.textAlignment = NSTextAlignmentCenter; label.font = [UIFont systemFontOfSize:15.f];
        [_scrollView addSubview:label]; [labelArray addObject:label];//[label release];
        
        label = [[UILabel alloc]initWithFrame:CGRectMake(320, ((_scrollView.frame.size.height-20)/2)-60, 320, 20)];
        label.text = @"Enter your new passcode";
        label.textAlignment = NSTextAlignmentCenter; label.font = [UIFont systemFontOfSize:15.f];
        [_scrollView addSubview:label]; [labelArray addObject:label];//[label release];
        
        label = [[UILabel alloc]initWithFrame:CGRectMake(320, ((_scrollView.frame.size.height-20)/2)+40, 320, 20)];
        label.text = @"";
        label.textAlignment = NSTextAlignmentCenter; label.font = [UIFont systemFontOfSize:15.f];
        [_scrollView addSubview:label]; [labelArray addObject:label];//[label release];
        
        label = [[UILabel alloc]initWithFrame:CGRectMake(640, ((_scrollView.frame.size.height-20)/2)-60, 320, 20)];
        label.text = @"Re-enter your new passcode";
        label.textAlignment = NSTextAlignmentCenter; label.font = [UIFont systemFontOfSize:15.f];
        [_scrollView addSubview:label]; [labelArray addObject:label];//[label release];
        
        
        [overallAray addObject:labelArray];
        // [labelArray release];
        _imageViews = [[NSArray alloc]initWithArray:overallAray];
        // [overallAray release];
        
        [self.view addSubview:_scrollView];
        
        if([[NSFileManager defaultManager]fileExistsAtPath:prefpath]){
            NSDictionary *prefs=[[NSDictionary alloc]initWithContentsOfFile:prefpath];
            if([prefs objectForKey:@"passcode"]) {
                self.oldPasscode = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"passcode"]];
            } else {
                self.oldPasscode = @"";
            }
        }else{
            self.oldPasscode = @"";
        }
    }
    
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if(_isAuth) {
        int i = 1;
        for (UIImageView *imageView in (NSArray *)[_imageViews objectAtIndex:0]) {
            if (i <= textField.text.length) {
                [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dot.png"]];
            } else {
                [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]];
            }
            i++;
        }
        if (textField.text.length == 4) {
            NSLog(@"asphaleia - self.oldPasscode : %@",self.oldPasscode);
            if ([textField.text isEqualToString:self.oldPasscode]) {
                [(asphaleiaMain *)_delegate authenticated];
                [self dismissViewControllerAnimated:YES completion:NULL];
            } else {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                [(UILabel *)[(NSArray *)[_imageViews objectAtIndex:1]objectAtIndex:1] setText:@"Wrong Passcode"];
                textField.text = @"";
                i = 1;
                for (UIImageView *imageView in (NSArray *)[_imageViews objectAtIndex:0]) {
                    [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]]; 
                    i++;
                }
            }
        }
    } else if(_isSet) {
        int i = 1;
        for (UIImageView *imageView in (NSArray *)[_imageViews objectAtIndex:(_currentPage-1)]) {
            if (i <= textField.text.length) {
                [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dot.png"]];
            } else {
                [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]];
            }
            i++;
        }
        if (textField.text.length == 4) {
            if (_currentPage == 1) {
                [self scrollToPage:_currentPage];
                _currentPage++;
                _newPasscode = [[NSString alloc]initWithString:textField.text];
                textField.text = @"";
            } else if (_currentPage == 2) {
                if ([textField.text isEqualToString:_newPasscode]) {
                    //set passcode here
                    NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
                    [prefs addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefpath]];
                    [prefs setObject:_newPasscode forKey:@"passcode"];
                    if (_first) {
                        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"simplePasscode"];
                        size_t size;
                        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
                        char *machine = (char *)malloc(size);
                        sysctlbyname("hw.machine", machine, &size, NULL, 0);
                        if (isTouchIDDevice()) {
                            [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"touchID"];
                        }
                        [(asphaleiaMain *)_delegate authenticated];
                    }
                    [prefs writeToFile:prefpath atomically:YES];
                    CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia/ReloadPrefs"), NULL, NULL,true);
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                    [(UILabel *)[(NSArray *)[_imageViews objectAtIndex:2]objectAtIndex:1] setText:@"Passcodes did not match. Try again."];
                    textField.text = @"";
                    i = 1;
                    for (UIImageView *imageView in (NSArray *)[_imageViews objectAtIndex:(_currentPage-1)]) {
                        [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]];
                        i++;
                    }
                    i = 1;
                    for (UIImageView *imageView in (NSArray *)[_imageViews objectAtIndex:(_currentPage-2)]) {
                        [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]];
                        i++;
                    }
                    [self scrollToPage:(_currentPage-2)];
                    _currentPage = 1;
                }
            }
        }
    } else {
        int i = 1;
        for (UIImageView *imageView in (NSArray *)[_imageViews objectAtIndex:(_currentPage-1)]) {
            if (i <= textField.text.length) {
                [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dot.png"]];
            } else {
                [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]];
            }
            i++;
        }
        if (textField.text.length == 4) {
            if (_currentPage == 1) {
                if ([textField.text isEqualToString:self.oldPasscode]) {
                    [self scrollToPage:_currentPage];
                    _currentPage++;
                    textField.text = @"";
                } else {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                    [(UILabel *)[(NSArray *)[_imageViews objectAtIndex:3]objectAtIndex:1] setText:@"Wrong Passcode"];
                    textField.text = @"";
                    i = 1;
                    for (UIImageView *imageView in (NSArray *)[_imageViews objectAtIndex:(_currentPage-1)]) {
                        [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]]; 
                        i++;
                    }
                }
            } else if (_currentPage == 2) {
                [self scrollToPage:_currentPage];
                _currentPage++;
                _newPasscode = [[NSString alloc]initWithString:textField.text];
                textField.text = @"";
            } else if (_currentPage == 3) {
                if ([textField.text isEqualToString:_newPasscode]) {
                    //set passcode here
                    NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
                    [prefs addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefpath]];
                    [prefs setObject:_newPasscode forKey:@"passcode"];
                    [prefs writeToFile:prefpath atomically:YES];
                    CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia/ReloadPrefs"), NULL, NULL,true);
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                    [(UILabel *)[(NSArray *)[_imageViews objectAtIndex:3]objectAtIndex:3] setText:@"Passcodes did not match. Try again."];
                    textField.text = @"";
                    i = 1;
                    for (UIImageView *imageView in (NSArray *)[_imageViews objectAtIndex:(_currentPage-1)]) {
                        [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]];
                        i++;
                    }
                    i = 1;
                    for (UIImageView *imageView in (NSArray *)[_imageViews objectAtIndex:(_currentPage-2)]) {
                        [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle/dash.png"]];
                        i++;
                    }
                    [self scrollToPage:(_currentPage-2)];
                    _currentPage = 2;
                }
            }
        }
    }
}

-(id)initToAuthWithDelegate:(id)sender
{
    _isAuth = 1;
    _delegate = sender;
    self = [super init];
    return self;
}
-(id)initWithDelegate:(id)sender
{
    _delegate = sender;
    self = [super init];
    return self;
}
-(id)initToSetPasscode:(id)sender
{
    _isSet = 1;
    _delegate = sender;
    self = [super init];
    return self;
}
-(id)initToSetPasscodeFirst:(id)sender
{
    _isSet = 1;
    _first = 1;
    _delegate = sender;
    self = [super init];
    return self;
}
- (void)scrollToPage:(int)page
{
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:YES];
}

- (void)rightButtonPressed:(UIBarButtonItem *)sender
{
    if (_isAuth || _first) {
        [(asphaleiaMain *)_delegate goBack];
    } 
    [self dismissViewControllerAnimated:YES completion:nil]; 
    
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end