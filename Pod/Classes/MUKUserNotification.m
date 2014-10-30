NSTimeInterval const MUKUserNotificationDurationInfinite = -1.0;

#import "MUKUserNotification.h"

@implementation MUKUserNotification

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = MUKUserNotificationDurationInfinite;
    }
    
    return self;
}

@end
