//
//  MainTableTableViewController.h
//  Onetrack
//
//  Created by Andrew Dekker on 15/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "CreateViewController.h"
#import "DetailViewController.h"

@interface MainTableTableViewController : UITableViewController <CreationViewControllerDelegate, DetailViewControllerDelegate, UIGestureRecognizerDelegate, FBSDKLoginButtonDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

- (IBAction)editingClicked:(id)sender;

@end
