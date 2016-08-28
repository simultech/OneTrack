//
//  LoginViewController.h
//  Onetrack
//
//  Created by Andrew Dekker on 21/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController : UIViewController <FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIImageView *backButtonImage;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
