//
//  MainTableTableViewController.h
//  Onetrack
//
//  Created by Andrew Dekker on 15/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "CreateViewController.h"
#import "DetailViewController.h"

@interface MainTableTableViewController : UITableViewController <CreationViewControllerDelegate, DetailViewControllerDelegate, UIGestureRecognizerDelegate, WCSessionDelegate>

@property (nonatomic, strong) WCSession *session;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

- (IBAction)editingClicked:(id)sender;

@end
