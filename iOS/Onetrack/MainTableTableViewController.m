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
#import "OneTrackTableViewCell.h"

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
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUpdateNotification:)
                                                 name:@"UpdatedDataNotification"
                                               object:nil];
}

- (void)receiveUpdateNotification:(NSNotification *)notification {
    NSLog(@"RECEIVED NOTIFICATION");
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"DISPATCHING");
        [self.tableView reloadData];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"APPEARING");
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 90.0f;
    } else if(indexPath.row < [[AppModel sharedModel] items].count) {
        return 90.0f;
    }
    return 0.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 1;
    }
    return [[[AppModel sharedModel] items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddTrackCell" forIndexPath:indexPath];
        return cell;
    }
    NSDictionary *item = [(NSArray *)[[AppModel sharedModel] items] objectAtIndex:indexPath.row];
    OneTrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OneTrackCell" forIndexPath:indexPath];
    UIView *detail = (UIView*)[cell viewWithTag:20];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailClicked:)];
    singleTap.numberOfTapsRequired = 1;
    [detail setUserInteractionEnabled:YES];
    [detail addGestureRecognizer:singleTap];
    [cell initCellWithData:item];
    return cell;
}

- (void)detailClicked: (UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"DetailSegue" sender:(UITableViewCell *)recognizer.view.superview.superview];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundView.backgroundColor = [AppDelegate colorFromHexString:@"#eeeeee"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        [self performSegueWithIdentifier:@"CreateSegue" sender:self];
    } else {
        BOOL added = [[AppModel sharedModel] addCountToTracker:(int)indexPath.row];
        [self.tableView reloadData];
        if(added) {
            [self animateIndexPath:indexPath withType:@"success"];
        } else {
            [self animateIndexPath:indexPath withType:@"limit"];
        }
    }
    [[UIDevice currentDevice] playInputClick];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
}

- (void)animateIndexPath:(NSIndexPath *)indexPath withType:(NSString *)type {
    if([type isEqualToString:@"success"]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.layer.backgroundColor = [UIColor whiteColor].CGColor;
        [UIView animateWithDuration:0.1 animations:^{
            cell.layer.backgroundColor = [UIColor greenColor].CGColor;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                cell.layer.backgroundColor = [UIColor whiteColor].CGColor;
            } completion:nil];
        }];
    }
    if([type isEqualToString:@"limit"]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.layer.backgroundColor = [UIColor whiteColor].CGColor;
        [UIView animateWithDuration:0.1 animations:^{
            cell.layer.backgroundColor = [UIColor grayColor].CGColor;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                cell.layer.backgroundColor = [UIColor whiteColor].CGColor;
            } completion:nil];
        }];
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
}

- (IBAction)editingClicked:(id)sender {
    if([self.tableView isEditing]) {
        
        [self.tableView setEditing: NO animated: YES];
        self.editButton.image = [UIImage imageNamed:@"edit"];
    } else {
        [self.tableView setEditing: YES animated: YES];
        self.editButton.image = [UIImage imageNamed:@"edit_active"];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {    
    if ([[segue identifier] isEqualToString:@"CreateSegue"]) {
        // Get reference to the destination view controller
        UINavigationController *navController = [segue destinationViewController];
        CreateViewController *vc = (CreateViewController *)([navController viewControllers][0]);
        vc.delegate = self;
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
