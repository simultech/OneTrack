//
//  MainTableTableViewController.m
//  Onetrack
//
//  Created by Andrew Dekker on 15/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import "MainTableTableViewController.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioServices.h>


@interface MainTableTableViewController ()

@end

@implementation MainTableTableViewController

- (void)viewDidLoad {
    [self restore];
    [super viewDidLoad];

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView setBackgroundColor:[AppDelegate colorFromHexString:@"#313131"]];
    
    UISwipeGestureRecognizer *recognizer  = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(rightSwipe:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:recognizer];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 5.0; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.items.count) {
        return 120.0f;
    }
    return 0.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [self.items objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
    NSNumber *maxCount = [item objectForKey:@"maxCount"];
    [cell setBackgroundColor:[AppDelegate colorFromHexString:@"#fafafa"]];
    cell.layer.cornerRadius = 16;
    cell.layer.borderWidth = 4;
    cell.layer.borderColor = [AppDelegate colorFromHexString:@"#313131"].CGColor;
    UILabel *itemLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *todayLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *totalLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *lastAdded = (UILabel *)[cell viewWithTag:5];
    UIView *bg = (UIView *)[cell viewWithTag:99];
    bg.layer.cornerRadius = 10;
    itemLabel.text = [item objectForKey:@"name"];
    if([maxCount integerValue] == 0) {
        todayLabel.text = [NSString stringWithFormat:@"%ld today", [self getTodayCount:[item objectForKey:@"clicks"]]];
    } else {
        todayLabel.text = [NSString stringWithFormat:@"(%ld / %@) today", [self getTodayCount:[item objectForKey:@"clicks"]], maxCount];
    }
    lastAdded.text = @"";
    if([[item objectForKey:@"clicks"] count] > 0) {
        NSDate *date = [self dateFromString:[[item objectForKey:@"clicks"] lastObject]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        dateFormatter.dateFormat = @"dd/MM/yy hh:mma";
        lastAdded.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    }
    totalLabel.text = [NSString stringWithFormat:@"%d total", (int)[[item objectForKey:@"clicks"] count]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundView.backgroundColor = [AppDelegate colorFromHexString:@"#eeeeee"];
}

- (long)getTodayCount:(NSArray *)counts {
    long todayCount = 0;
    for(NSString *dateString in counts) {
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
        NSDate *today = [cal dateFromComponents:components];
        components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[self dateFromString:dateString]];
        NSDate *otherDate = [cal dateFromComponents:components];
        if([today isEqualToDate:otherDate]) {
            //do stuff
            todayCount += 1;
        }
    }
    return todayCount;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[UIDevice currentDevice] playInputClick];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSMutableArray *mutableItems = [self.items mutableCopy];
    NSMutableDictionary *item = [[mutableItems objectAtIndex:indexPath.row] mutableCopy];
    NSNumber *maxCount = [item objectForKey:@"maxCount"];
    NSMutableArray *clicks = [[item objectForKey:@"clicks"] mutableCopy];
    NSDate *now = [NSDate date];
    if([maxCount integerValue] == 0 || [maxCount longValue] > [self getTodayCount:clicks]) {
        [clicks addObject:[self stringFromDate:now]];
        [item setObject:[clicks copy] forKey:@"clicks"];
        [mutableItems replaceObjectAtIndex:indexPath.row withObject:[item copy]];
        self.items = [mutableItems copy];
        [self.tableView reloadData];
        [self save];
    }
}

- (NSString *)stringFromDate:(NSDate *)aDate {
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [gmtDateFormatter stringFromDate:aDate];
}

- (NSDate *)dateFromString:(NSString *)aString {
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [gmtDateFormatter dateFromString:aString];
}

- (IBAction)editingClicked:(id)sender {
    if([self.tableView isEditing]) {
        [self.tableView setEditing: NO animated: YES];
        self.editButton.title = @"Edit";
    } else {
        [self.tableView setEditing: YES animated: YES];
        self.editButton.title = @"Finish Editing";
    }
}

-(void)addCount:(NSString *)name withMaxUse:(NSNumber *)usePerDay {
    NSMutableArray *mutableItems = [self.items mutableCopy];
    NSDictionary *item = @{@"name" : name, @"clicks" : @[], @"maxCount": usePerDay};
    [mutableItems addObject:item];
    NSLog(@"ADDING NEW");
    self.items = [mutableItems copy];
    [self.tableView reloadData];
    [self save];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"DOING SEGUE %@", [segue identifier]);    
    if ([[segue identifier] isEqualToString:@"CreateSegue"]) {
        // Get reference to the destination view controller
        UINavigationController *navController = [segue destinationViewController];
        CreateViewController *vc = (CreateViewController *)([navController viewControllers][0]);
        vc.delegate = self;
        NSLog(@"SETTING DELEGATE %@", vc.delegate);
    } else if ([[segue identifier] isEqualToString:@"DetailSegue"]) {
        // Get reference to the destination view controller
        DetailViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        vc.data = [self.items objectAtIndex:indexPath.row];
    }
}

-(void)save {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"dataz.txt"];
    [NSKeyedArchiver archiveRootObject:self.items toFile:appFile];
}

-(void)restore {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"dataz.txt"];
    self.items = [NSKeyedUnarchiver unarchiveObjectWithFile:appFile];
    if(!self.items) {
        self.items = [[NSArray alloc] init];
    }
}

-(void)resetAll {
    self.items = @[];
    [self save];
    [self.tableView reloadData];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSLog(@"DELETING");
        NSMutableArray *mutableItems = [self.items mutableCopy];
        [mutableItems removeObjectAtIndex:indexPath.row];
        self.items = [mutableItems copy];
        [self save];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSMutableArray *mutableItems = [self.items mutableCopy];
    NSDictionary *item = [self.items objectAtIndex:fromIndexPath.row];
    [mutableItems removeObjectAtIndex:fromIndexPath.row];
    [mutableItems insertObject:item atIndex:toIndexPath.row];
    [self save];
    self.items = [mutableItems copy];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)rightSwipe:(UISwipeGestureRecognizer *)gestureRecognizer {
    [[UIDevice currentDevice] playInputClick];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if(indexPath != nil) {
        NSMutableArray *mutableItems = [self.items mutableCopy];
        NSMutableDictionary *item = [[mutableItems objectAtIndex:indexPath.row] mutableCopy];
        NSMutableArray *clicks = [[item objectForKey:@"clicks"] mutableCopy];
        if(clicks.count > 0) {
            [clicks removeObjectAtIndex:clicks.count-1];
            [item setObject:[clicks copy] forKey:@"clicks"];
            [mutableItems replaceObjectAtIndex:indexPath.row withObject:[item copy]];
            self.items = [mutableItems copy];
        }
        [self.tableView reloadData];
        [self save];
    }
}

-  (void)handleLongPress:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"UIGestureRecognizerStateBegan.");
        //Do Whatever You want on Began of Gesture
        CGPoint p = [sender locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        if(indexPath != nil) {
            NSLog(@"long press on table view at row %ld", indexPath.row);
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Reset counter"
                                          message:@"Do you want to reset this counter?  All entries will be removed."
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* reset = [UIAlertAction
                                 actionWithTitle:@"Reset"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     NSMutableArray *theItems = [self.items mutableCopy];
                                     NSMutableDictionary *theItem = [[self.items objectAtIndex:indexPath.row] mutableCopy];
                                     [theItem setObject:@[] forKey:@"clicks"];
                                     [theItems replaceObjectAtIndex:indexPath.row withObject:[theItem copy]];
                                     self.items = [theItems copy];
                                     [self.tableView reloadData];
                                     [self save];
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            [alert addAction:cancel];
            [alert addAction:reset];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
