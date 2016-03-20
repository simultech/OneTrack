//
//  CreateViewController.h
//  Onetrack
//
//  Created by Andrew Dekker on 15/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreationViewControllerDelegate

// define protocol functions that can be used in any class using this delegate
-(void)addCount:(NSString *)name withMaxUse:(NSNumber *)usePerDay;
-(void)resetAll;

@end

@interface CreateViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *maxUse;

@property (weak) id delegate;

- (IBAction)closeTapped:(id)sender;
- (IBAction)addTapped:(id)sender;
- (IBAction)resetTapped:(id)sender;

@end
