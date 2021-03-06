#import "CommandsTableViewController.h"
#import <MUKUserNotificationController/MUKUserNotificationController.h>

#define DEBUG_STATUS_BAR_HIDDEN         0

@interface Command : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) dispatch_block_t action;
@end

@implementation Command
@end

@interface CommandsTableViewController ()
@property (nonatomic) NSArray *commands;
@property (nonatomic) MUKUserNotificationController *userNotificationController;
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

#pragma mark - Overrides

#if DEBUG_STATUS_BAR_HIDDEN
- (BOOL)prefersStatusBarHidden {
    return YES;
}
#endif

#pragma mark - Private

static void CommonInit(CommandsTableViewController *me) {
    me.title = @"Example";
    me->_commands = [me newCommands];
    me->_userNotificationController = [[MUKUserNotificationController alloc] initWithViewController:me];
}

#pragma mark - Private - Commands

- (NSArray *)newCommands {
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    __weak typeof(self)weakSelf = self;
    
    Command *command = [[Command alloc] init];
    command.title = @"Hide Displayed Notification";
    command.action = ^{
        [weakSelf.userNotificationController hideNotification:weakSelf.userNotificationController.visibleNotification animated:YES completion:nil];
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Show Sticky Notification";
    command.action = ^{
        MUKUserNotification *notification = [[MUKUserNotification alloc] init];
        notification.title = @"Sticky Notification";
        notification.tapGestureHandler = ^(MUKUserNotificationController *c, MUKUserNotificationView *v) {};
        notification.panUpGestureHandler = ^(MUKUserNotificationController *c, MUKUserNotificationView *v) {};
        notification.color = [UIColor colorWithRed:0.0f green:0.85f blue:0.0f alpha:1.0f];
        
        [weakSelf.userNotificationController showNotification:notification animated:YES completion:nil];
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Show Alert Notification";
    command.action = ^{
        MUKUserNotification *notification = [[MUKUserNotification alloc] init];
        notification.title = @"Alert Notification";
        notification.text = @"More text to explain alert. This text could also split in multiple lines in order to give user more detail about this notification.";
        notification.duration = 1.5;
        notification.color = [UIColor redColor];
        
        [weakSelf.userNotificationController showNotification:notification animated:YES completion:nil];
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
