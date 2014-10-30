//
//  MUKUserNotificationController.m
//  MUKUserNotificationController
//
//  Created by Marco on 30/10/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "MUKUserNotificationController.h"
#import "MUKUserNotificationWindow.h"
#import "MUKUserNotificationWindowViewController.h"

#define DEBUG_NOTIFICATION_WINDOW_BACKGROUND    1

@interface MUKUserNotificationController ()
@property (nonatomic) UIWindow *notificationWindow;
@end

@implementation MUKUserNotificationController

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (void)showNotification:(MUKUserNotification *)notification animated:(BOOL)animated
{
}

#pragma mark - Private — Notification Window

- (UIWindow *)notificationWindow {
    if (!_notificationWindow) {
        MUKUserNotificationWindow *notificationWindow = [[MUKUserNotificationWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        notificationWindow.backgroundColor = DEBUG_NOTIFICATION_WINDOW_BACKGROUND ? [[UIColor purpleColor] colorWithAlphaComponent:0.2f] : [UIColor clearColor];
        notificationWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        notificationWindow.windowLevel = UIWindowLevelStatusBar;
        notificationWindow.rootViewController = [MUKUserNotificationWindowViewController new];
        notificationWindow.rootViewController.view.clipsToBounds = YES;
        self.notificationWindow = notificationWindow;
    }
    
    return _notificationWindow;
}

@end
