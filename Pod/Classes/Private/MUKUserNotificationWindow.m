#import "MUKUserNotificationWindow.h"
#import "MUKUserNotificationView.h"

@implementation MUKUserNotificationWindow

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    for (UIView *subview in self.subviews) {
        if ([[subview hitTest:[self convertPoint:point toView:subview] withEvent:event] isKindOfClass:[MUKUserNotificationView class]])
        {
            return YES;
        }
    }
    
    return NO;
}

@end
