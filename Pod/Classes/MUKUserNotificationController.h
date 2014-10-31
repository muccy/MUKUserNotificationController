//
//  MUKUserNotificationController.h
//  MUKUserNotificationController
//
//  Created by Marco on 30/10/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MUKUserNotificationController/MUKUserNotification.h>
#import <MUKUserNotificationController/MUKUserNotificationView.h>

extern NSTimeInterval const MUKUserNotificationControllerDefaultMinimumIntervalBetweenNotifications;

@interface MUKUserNotificationController : NSObject
@property (nonatomic, weak, readonly) UIViewController *viewController;
/**
 Notifications which are displayed or pending (due rate limit).
 Keep in mind that not all notifications are currently displayed.
 */
@property (nonatomic, readonly) NSArray *notifications;
/**
 The latest notification which has been displayed.
 */
@property (nonatomic, readonly) MUKUserNotification *visibleNotification;
/**
 The amount of time which has to pass between a notification presentation and
 another.
 It defaults to `MUKUserNotificationControllerDefaultMinimumIntervalBetweenNotifications`.
 */
@property (nonatomic) NSTimeInterval minimumIntervalBetweenNotifications;

- (instancetype)initWithViewController:(UIViewController *)viewController;

- (void)showNotification:(MUKUserNotification *)notification animated:(BOOL)animated;
- (void)hideNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler;
@end

@interface MUKUserNotificationController (Expiration)
- (void)notificationWillExpire:(MUKUserNotification *)notification;
- (void)notificationDidExpire:(MUKUserNotification *)notification;
@end
