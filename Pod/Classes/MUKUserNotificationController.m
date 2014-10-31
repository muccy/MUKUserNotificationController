#import "MUKUserNotificationController.h"
#import "MUKUserNotificationWindow.h"
#import "MUKUserNotificationWindowViewController.h"

#define DEBUG_NOTIFICATION_WINDOW_BACKGROUND    1

NSTimeInterval const MUKUserNotificationControllerDefaultMinimumIntervalBetweenNotifications = 1.0f;

static NSTimeInterval const kNotificationViewAnimationDuration = 0.45;
static CGFloat const kNotificationViewAnimationSpringDamping = 1.0f;
static CGFloat const kNotificationViewAnimationSpringVelocity = 1.0f;
static CGFloat const kDefaultStatusBarHeight = 20.0f;
static CGFloat const kNavigationBarSnapDifference = 14.0f;

@interface MUKUserNotificationController ()
@property (nonatomic) UIWindow *notificationWindow;
@property (nonatomic, readwrite) NSMutableArray *notificationQueue;
@property (nonatomic) NSMapTable *notificationToViewMapping, *viewToNotificationMapping;
@property (nonatomic) NSDate *lastNotificationPresentationDate;
@property (nonatomic) CGFloat statusBarHeight;
@end

@implementation MUKUserNotificationController
@dynamic notifications;
@dynamic visibleNotification;

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        _notificationQueue = [[NSMutableArray alloc] init];
        _notificationToViewMapping = [NSMapTable weakToWeakObjectsMapTable];
        _viewToNotificationMapping = [NSMapTable weakToWeakObjectsMapTable];
        _minimumIntervalBetweenNotifications = MUKUserNotificationControllerDefaultMinimumIntervalBetweenNotifications;
        _statusBarHeight = kDefaultStatusBarHeight;
    }
    return self;
}

- (instancetype)init {
    return [self initWithViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
}

#pragma mark - Accessors

- (NSArray *)notifications {
    return [self.notificationQueue copy];
}

- (MUKUserNotification *)visibleNotification {
    for (MUKUserNotification *notification in [self.notifications reverseObjectEnumerator])
    {
        // if it has not an associated view, it means notification view has not
        // been presented yet (probabily because of rate limit)
        if ([self viewForNotification:notification]) {
            return notification;
        }
    }
    
    return nil;
}

- (UIWindow *)notificationWindow {
    if (!_notificationWindow) {
        MUKUserNotificationWindow *notificationWindow = [[MUKUserNotificationWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        notificationWindow.backgroundColor = DEBUG_NOTIFICATION_WINDOW_BACKGROUND ? [[UIColor purpleColor] colorWithAlphaComponent:0.2f] : [UIColor clearColor];
        notificationWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        notificationWindow.windowLevel = UIWindowLevelStatusBar;
        
        MUKUserNotificationWindowViewController *rootViewController = [MUKUserNotificationWindowViewController new];
        rootViewController.view.clipsToBounds = YES;
        rootViewController.notificationController = self;
        notificationWindow.rootViewController = rootViewController;
        
        self.notificationWindow = notificationWindow;
    }
    
    return _notificationWindow;
}

#pragma mark - Expiration

- (void)notificationWillExpire:(MUKUserNotification *)notification {
    //
}

- (void)notificationDidExpire:(MUKUserNotification *)notification {
    //
}

#pragma mark - Display

- (void)showNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL completed))completionHandler
{
    [self showNotification:notification addToQueue:YES passingTest:nil animated:animated completion:completionHandler];
}

- (void)hideNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler
{
    if (!notification) {
        return;
    }
    
    // Get view for notification
    UIView *const notificationView = [self viewForNotification:notification];
    
    // Remove from queue
    [self removeNotification:notification];
    
    if (!notificationView) {
        return;
    }
    
    // Animate out
    NSTimeInterval const duration = animated ? kNotificationViewAnimationDuration : 0.0;
    
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kNotificationViewAnimationSpringDamping initialSpringVelocity:kNotificationViewAnimationSpringVelocity options:0 animations:^{
        // Move out
        notificationView.transform = CGAffineTransformMakeTranslation(0.0f, -CGRectGetHeight(notificationView.frame));
    } completion:^(BOOL finished) {
        // Remove view from view hierarchy
        [notificationView removeFromSuperview];
        
        // If it's last notification hide window
        if ([self.notificationQueue count] == 0) {
            self.notificationWindow.hidden = YES;
        }
        
        // Notify completion if needed
        if (completionHandler) {
            completionHandler(finished);
        }
    }];
}

#pragma mark - Notification View

- (MUKUserNotificationView *)viewForNotification:(MUKUserNotification *)notification {
    if (!notification) {
        return nil;
    }
    
    return [self.notificationToViewMapping objectForKey:notification];
}

- (MUKUserNotification *)notificationForView:(MUKUserNotificationView *)view
{
    if (!view) {
        return nil;
    }
    
    return [self.viewToNotificationMapping objectForKey:view];
}

- (MUKUserNotificationView *)newViewForNotification:(MUKUserNotification *)notification
{
    MUKUserNotificationView *view = [[MUKUserNotificationView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return view;
}

- (void)configureView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification
{
    view.titleLabel.text = notification.title;
    view.textLabel.text = notification.text;
    
    view.titleLabel.textColor = notification.textColor ?: [UIColor whiteColor];
    view.textLabel.textColor = notification.textColor ?: [UIColor whiteColor];
    view.backgroundColor = notification.color ?: self.viewController.view.tintColor;
    
    // Set gesture recognizer actions
    [view.tapGestureRecognizer addTarget:self action:@selector(handleNotificationViewTapGestureRecognizer:)];
    [view.panGestureRecognizer addTarget:self action:@selector(handleNotificationViewPanGestureRecognizer:)];
}

- (CGRect)frameForView:(MUKUserNotificationView *)view notification:(MUKUserNotification *)notification minimumSize:(CGSize)minimumSize
{
    CGFloat const maxHeight = roundf(CGRectGetHeight(self.notificationWindow.frame) * 0.35f);
    CGSize expandedSize = [view sizeThatFits:CGSizeMake(minimumSize.width, maxHeight)];
    CGRect frame = CGRectMake(0.0f, 0.0f, minimumSize.width, fmaxf(minimumSize.height, expandedSize.height));
    
    // Navigation bar snap
     if (notification.snapsToNavigationBar) {
         CGFloat const affectedNavigationBarsMaxY = [self affectedNavigationBarsMaxY];
         CGFloat const diff = CGRectGetMaxY(frame) - affectedNavigationBarsMaxY;
         
         if (diff < 0.0f && fabsf(diff) < kNavigationBarSnapDifference) {
             frame.size.height -= diff;
         }
     }
    
    return frame;
}

- (void)didTapView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification
{
    if (notification.tapGestureHandler) {
        notification.tapGestureHandler(self, view);
    }
    else {
        [self hideNotification:notification animated:YES completion:nil];
    }
}

- (void)didPanUpView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification
{
    if (notification.panUpGestureHandler) {
        notification.panUpGestureHandler(self, view);
    }
    else {
        [self hideNotification:notification animated:YES completion:nil];
    }
}

#pragma mark - Navigation Controllers

- (NSArray *)affectedNavigationControllers {
    NSMutableArray *navigationControllers = [[NSMutableArray alloc] init];
    
    if ([self.viewController isKindOfClass:[UINavigationController class]]) {
        [navigationControllers addObject:self.viewController];
    }
    else if ([self.viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)self.viewController;
        
        if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]])
        {
            [navigationControllers addObject:tabBarController.selectedViewController];
        }
    }
    else if (self.viewController.navigationController) {
        [navigationControllers addObject:self.viewController.navigationController];
    }
    
    if (self.viewController.splitViewController) {
        for (UIViewController *viewController in self.viewController.splitViewController.viewControllers)
        {
            if ([viewController isKindOfClass:[UINavigationController class]])
            {
                [navigationControllers addObject:viewController];
            }
        } // for
    }
    
    return [navigationControllers copy];
}

#pragma mark - Private - Queue

- (void)addNotification:(MUKUserNotification *)notification {
    if (notification) {
        [self.notificationQueue addObject:notification];
    }
}

- (void)removeNotification:(MUKUserNotification *)notification {
    if (notification) {
        [self.notificationQueue removeObject:notification];
    }
}

#pragma mark - Private - Rate Limit

- (BOOL)hasPassedMinimumIntervalFromLastNotification {
    if (!self.lastNotificationPresentationDate) {
        return YES;
    }
    
    return [self missingTimeIntervalToNextPresentableNotification] > 0.0;
}

- (NSTimeInterval)missingTimeIntervalToNextPresentableNotification {
    NSTimeInterval interval = -[self.lastNotificationPresentationDate timeIntervalSinceNow];
    return interval - self.minimumIntervalBetweenNotifications;
}

#pragma mark - Private — Notification View

+ (CGFloat)actualStatusBarHeight {
    CGRect const statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    return fminf(CGRectGetWidth(statusBarFrame), CGRectGetHeight(statusBarFrame));
}

- (void)captureStatusBarHeightIfAvailable {
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        CGFloat const statusBarHeight = [[self class] actualStatusBarHeight];
        
        if (statusBarHeight > 0.0f) {
            self.statusBarHeight = statusBarHeight;
        }
    }
}

- (CGSize)minimumUserNotificationViewSize {
    return CGSizeMake(CGRectGetWidth(self.notificationWindow.bounds), self.statusBarHeight);
}

- (void)handleNotificationViewTapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        MUKUserNotificationView *view = (MUKUserNotificationView *)recognizer.view;
        MUKUserNotification *notification = [self notificationForView:view];
        
        if (view && notification) {
            [self didTapView:view forNotification:notification];
        }
    }
}

- (void)handleNotificationViewPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint const translation = [recognizer translationInView:recognizer.view];
        if (translation.y < 0.0f && fabsf(translation.y) > 0.3f * CGRectGetHeight(recognizer.view.frame))
        {
            MUKUserNotificationView *view = (MUKUserNotificationView *)recognizer.view;
            MUKUserNotification *notification = [self notificationForView:view];
            
            if (view && notification) {
                [self didPanUpView:view forNotification:notification];
            }
        }
    }
}

#pragma mark - Private — Notification <-> view mapping

- (void)setView:(MUKUserNotificationView *)view forUserNotification:(MUKUserNotification *)notification
{
    if (view && notification) {
        [self.notificationToViewMapping setObject:view forKey:notification];
    }
}

- (void)setUserNotification:(MUKUserNotification *)notification forView:(MUKUserNotificationView *)view
{
    if (view && notification) {
        [self.viewToNotificationMapping setObject:notification forKey:view];
    }
}

#pragma mark - Private — Notification Expiration

- (BOOL)notificationCanExpire:(MUKUserNotification *)notification {
    return notification.duration > 0.0f;
}

- (void)scheduleExpirationForNotification:(MUKUserNotification *)notification
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(notification.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // If notification is still there proceed with expiration
        if ([self.notifications containsObject:notification]) {
            [self notificationWillExpire:notification];
            [self hideNotification:notification animated:YES completion:^(BOOL completed)
             {
                 [self notificationDidExpire:notification];
             }];
        }
    });
}

#pragma mark - Private - Display

- (void)showNotification:(MUKUserNotification *)notification addToQueue:(BOOL)addToQueue passingTest:(BOOL (^)(void))testBlock animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler
{
    if (!notification) {
        return;
    }
    
    // Add to notification queue if needed
    if (addToQueue) {
        [self addNotification:notification];
    }
    
    // Pass test before to proceed
    BOOL const testPassed = testBlock ? testBlock() : YES;
    if (!testPassed) {
        return;
    }
    
    // Check against rate limit
    if (![self hasPassedMinimumIntervalFromLastNotification]) {
        NSTimeInterval remainingInterval = [self missingTimeIntervalToNextPresentableNotification];
        
        // Retry later
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(remainingInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            // Deferred recursion
            // Note addToQueue:NO, because I don't want to add model twice
            // What is more I have to check if notification object is still
            // inside queue (e.g. -hideNotification:... called during rate
            // limit interval
            [self showNotification:notification addToQueue:NO passingTest:^
            {
                return [self.notifications containsObject:notification];
            } animated:animated completion:completionHandler];
        });
        
        // Exit point
        return;
    }
    
    // Rate limit test is passed
    // Presentation will take place now
    self.lastNotificationPresentationDate = [NSDate date];
    
    // Get real status bar height if available
    [self captureStatusBarHeightIfAvailable];
    
    // Create notification view
    MUKUserNotificationView *notificationView = [self newViewForNotification:notification];
    [self configureView:notificationView forNotification:notification];
    
    // Adjust frame
    notificationView.frame = [self frameForView:notificationView notification:notification minimumSize:[self minimumUserNotificationViewSize]];
    
    // Map view to notification (and viceversa)
    [self setView:notificationView forUserNotification:notification];
    [self setUserNotification:notification forView:notificationView];
    
    // Move offscreen
    CGAffineTransform const targetTransform = notificationView.transform;
    notificationView.transform = CGAffineTransformMakeTranslation(0.0f, -CGRectGetHeight(notificationView.frame));
    
    // Insert in view hierarchy above averything
    [self.notificationWindow.rootViewController.view addSubview:notificationView];
    
    // Show notification window
    self.notificationWindow.hidden = NO;
    
    // Animate in
    NSTimeInterval const duration = animated ? kNotificationViewAnimationDuration : 0.0;
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kNotificationViewAnimationSpringDamping initialSpringVelocity:kNotificationViewAnimationSpringVelocity options:0 animations:^
    {
        // Move notification view in
        notificationView.transform = targetTransform;
    } completion:^(BOOL inAnimationFinished) {
        // Set expiration if needed
        if ([self notificationCanExpire:notification]) {
            [self scheduleExpirationForNotification:notification];
        }
        
        // Invoke completion handler if any
        if (completionHandler) {
            completionHandler(inAnimationFinished);
        }
    }];
}

#pragma mark - Private — Navigation Controllers

- (CGFloat)affectedNavigationBarsMaxY {
    CGFloat foundMaxY = -1.0f;
    
    for (UINavigationController *navigationController in [self affectedNavigationControllers])
    {
        CGRect const convertedNavigationBarFrame = [navigationController.navigationBar.superview convertRect:navigationController.navigationBar.frame toView:self.notificationWindow];
        CGFloat const maxY = CGRectGetMaxY(convertedNavigationBarFrame);
        
        if (maxY > 0.0f) {
            foundMaxY = fmaxf(foundMaxY, maxY);
        }
    } // for
    
    return foundMaxY;
}

@end
