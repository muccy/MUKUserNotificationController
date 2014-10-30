//
//  MUKUserNotificationController.h
//  MUKUserNotificationController
//
//  Created by Marco on 30/10/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUKUserNotificationController : NSObject
@property (nonatomic, weak, readonly) UIViewController *viewController;
- (instancetype)initWithViewController:(UIViewController *)viewController;
@end
