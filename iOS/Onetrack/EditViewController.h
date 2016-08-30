//
//  EditViewController.h
//  Onetrack
//
//  Created by Andrew Dekker on 30/08/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditViewController : UIViewController

@property (nonatomic, strong) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxTextField;

- (IBAction)backTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;

@end
