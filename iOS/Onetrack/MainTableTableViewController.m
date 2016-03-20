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
#import "AppModel.h"


@interface MainTableTableViewController ()

@end

@implementation MainTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AppModel sharedModel] restore];
    [[AppModel sharedModel] verifyLoginWithSuccess:^{
        NSLog(@"%@",[[AppModel sharedModel] getUserDetails]);
    } andFailure:^{
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }];

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
    lpgr.minimumPressDuration = 3.0; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"APPEARING");
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < [[AppModel sharedModel] items].count) {
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
    return [[[AppModel sharedModel] items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [(NSArray *)[[AppModel sharedModel] items] objectAtIndex:indexPath.row];
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
    UILabel *ratios = (UILabel *)[cell viewWithTag:6];
    UIView *bg = (UIView *)[cell viewWithTag:99];
    bg.layer.cornerRadius = 10;
    itemLabel.text = [item objectForKey:@"name"];
    if([maxCount integerValue] == 0) {
        todayLabel.text = [NSString stringWithFormat:@"%ld today", [[AppModel sharedModel] getTodayCount:[item objectForKey:@"clicks"]]];
    } else {
        todayLabel.text = [NSString stringWithFormat:@"(%ld / %@) today", [[AppModel sharedModel] getTodayCount:[item objectForKey:@"clicks"]], maxCount];
    }
    lastAdded.text = @"";
    ratios.text = @"";
    if([[item objectForKey:@"clicks"] count] > 0) {
        NSDate *date = [[AppModel sharedModel] dateFromString:[[item objectForKey:@"clicks"] lastObject]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        dateFormatter.dateFormat = @"dd/MM/yy hh:mma";
        lastAdded.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:now];
        NSInteger hour = [components hour];
        long todayCount = [[AppModel sharedModel] getTodayCount:[item objectForKey:@"clicks"]];
        long yesterdayCount = [[AppModel sharedModel] getYesterdayCount:[item objectForKey:@"clicks"]];
        double todayRatio = todayCount / (float)hour;
        double totalRatio = yesterdayCount / 24.0f;
        ratios.text = [NSString stringWithFormat:@"(%.2fp.h. (prev %.2fp.h.))",todayRatio, totalRatio];
    }
    totalLabel.text = [NSString stringWithFormat:@"%d total", (int)[[item objectForKey:@"clicks"] count]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundView.backgroundColor = [AppDelegate colorFromHexString:@"#eeeeee"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[UIDevice currentDevice] playInputClick];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [[AppModel sharedModel] addCountToTracker:(int)indexPath.row];
    [self.tableView reloadData];
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
        vc.data = [(NSArray *)[[AppModel sharedModel] items] objectAtIndex:indexPath.row];
    }
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
        [[AppModel sharedModel] deleteTracker:(int)indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [[AppModel sharedModel] moveTrackerFrom:(int)fromIndexPath.row to:(int)toIndexPath.row];
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
        [[AppModel sharedModel] removeCountFromTracker:(int)indexPath.row];
        [self.tableView reloadData];
    }
}

-  (void)handleLongPress:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"UIGestureRecognizerStateBegan.");
        //Do Whatever You want on Began of Gesture
        CGPoint p = [sender locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        if(indexPath != nil) {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Reset counter"
                                          message:@"Do you want to reset this counter?  All entries will be removed."
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* reset = [UIAlertAction
                                 actionWithTitle:@"Reset"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [[AppModel sharedModel] resetTracker:(int)indexPath.row];
                                     [self.tableView reloadData];
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

@end
