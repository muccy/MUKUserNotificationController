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
@end

@interface MUKUserNotificationController (Display)
/**
 Display a notification.
 @param notification Notification which will be added to notifications and displayed
 if minimumIntervalBetweenNotifications has passed.
 @param animated If YES, notification view will be presented with an animation.
 @param completionHandler A block which will be invoked as transition finishes.
 */
- (void)showNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL completed))completionHandler;
/**
 Hide a notification.
 @param notification Notification which will be removed from notifications and
 hidden. You could also hide a notification which has not been presented yet (due
 rate limit).
 @param animated If YES, notification view will be hidden with an animation.
 @param completionHandler A block which will be invoked as transition finishes.
 */
- (void)hideNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL completed))completionHandler;
@end

@interface MUKUserNotificationController (Expiration)
/**
 Callback invoked when an expired notification is about to be hidden.
 @param notification Notification which will be removed from notifications and
 hidden.
 */
- (void)notificationWillExpire:(MUKUserNotification *)notification;
/**
 Callback invoked when an expired notification has been hidden.
 @param notification Notification which has been removed from notifications and
 hidden.
 */
- (void)notificationDidExpire:(MUKUserNotification *)notification;
@end

@interface MUKUserNotificationController (NotificationView)
/**
 Search presented view for a notification.
 @param notification Notification to search for.
 @return The view which is displayed for a notification. It could return nil.
 */
- (MUKUserNotificationView *)viewForNotification:(MUKUserNotification *)notification;
/**
 Search notification for a presented view.
 @param view Notification view to search for.
 @return The notification for a displayed notification view. It could return nil.
 */
- (MUKUserNotification *)notificationForView:(MUKUserNotificationView *)view;
/**
 Creates new notification view.
 @param notification The notification which originates this view.
 @return A new notification view.
 */
- (MUKUserNotificationView *)newViewForNotification:(MUKUserNotification *)notification;
/**
 Configures a new notification view with notification details.
 @param view The view to configure.
 @param notification The notification which originates this view.
 */
- (void)configureView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification;
/**
 Frame for notification view.
 @param view The notification view. It will be inkoved -sizeThatFits: on it.
 @param notification The notification model object.
 @param minimumSize The minimum size for resulting frame.
 @return The frame that will be set on view.
 */
- (CGRect)frameForView:(MUKUserNotificationView *)view notification:(MUKUserNotification *)notification minimumSize:(CGSize)minimumSize;
/**
 Callback for tap gesture.
 It no tap gesture handler is set inside notification, it automatically hides
 the view.
 @param view The view where gesture occured.
 @param notification The notification which view displays.
 */
- (void)didTapView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification;
/**
 Callback for pan up gesture.
 It no pan up gesture handler is set inside notification, it automatically hides
 the view.
 @param view The view where gesture occured.
 @param notification The notification which view displays.
 */
- (void)didPanUpView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification;
@end
