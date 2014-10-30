//
//  CommandsTableViewController.m
//  MUKUserNotificationController
//
//  Created by Marco on 30/10/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "CommandsTableViewController.h"

@interface Command : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) dispatch_block_t action;
@end

@implementation Command
@end

@interface CommandsTableViewController ()
@property (nonatomic) NSArray *commands;
@end

@implementation CommandsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CommonInit(self);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CommonInit(self);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Private

static void CommonInit(CommandsTableViewController *me) {
    me.title = @"Example";
    me->_commands = [me newCommands];
}

#pragma mark - Private - Commands

- (NSArray *)newCommands {
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    __weak typeof(self)weakSelf = self;
    
    Command *command = [[Command alloc] init];
    command.title = @"Hide Displayed Notification";
    command.action = ^{
        //
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Show Sticky Notification";
    command.action = ^{
        //
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Show Alert Notification";
    command.action = ^{
        //
    };
    [commands addObject:command];
    
    return [commands copy];
}

- (Command *)commandAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath || indexPath.row < 0 || indexPath.row >= [self.commands count])
    {
        return nil;
    }
    
    return self.commands[indexPath.row];
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Command *command = [self commandAtIndexPath:indexPath];
    if (command.action) {
        command.action();
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.commands count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Command *command = [self commandAtIndexPath:indexPath];
    cell.textLabel.text = command.title;
    
    return cell;
}

@end
