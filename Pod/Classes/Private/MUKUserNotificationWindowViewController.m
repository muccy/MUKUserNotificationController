#import "MUKUserNotificationWindowViewController.h"
#import "MUKUserNotificationController.h"

@interface MUKUserNotificationWindowViewController ()
@end

@implementation MUKUserNotificationWindowViewController

#pragma mark - Overrides

- (BOOL)prefersStatusBarHidden {
    return [self.notificationController.viewController prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.notificationController.viewController preferredStatusBarStyle];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return [self.notificationController.viewController preferredStatusBarUpdateAnimation];
}

@end
