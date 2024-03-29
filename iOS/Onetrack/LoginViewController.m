//
//  LoginViewController.m
//  Onetrack
//
//  Created by Andrew Dekker on 21/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import "LoginViewController.h"
#import "AppModel.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.messageLabel.text = @"";
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.readPermissions = @[@"email", @"user_friends"];
    loginButton.center = CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height - 40);
    loginButton.delegate = self;
    [self.view addSubview:loginButton];
    NSLog(@"STARTING");
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backClicked)];
    singleTap.numberOfTapsRequired = 1;
    [self.backButtonImage setUserInteractionEnabled:YES];
    [self.backButtonImage addGestureRecognizer:singleTap];
    
    [[AppModel sharedModel] verifyLoginWithSuccess:^{
        self.backButtonImage.hidden = NO;
    } andFailure:^{
        self.backButtonImage.hidden = YES;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupInstructions];
}

- (void)setupInstructions {
    [self.instructionScrollView setPagingEnabled:YES];
    [self.instructionScrollView setBackgroundColor:[UIColor colorWithRed:0.282 green:0.282 blue:0.282 alpha:1]];
    int screens = 6;
    int pageWidth = self.instructionScrollView.frame.size.width;
    self.instructionScrollView.contentSize = CGSizeMake(pageWidth*screens, self.instructionScrollView.frame.size.height);
    for (int i=0; i<screens; i++) {
        NSString *screenName = [NSString stringWithFormat:@"screen_%d", (i+1)];
        UIImageView *screen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:screenName]];
        CGRect screenSize = self.instructionScrollView.frame;
        screenSize.size.width = pageWidth;
        screenSize.origin.x = i*pageWidth;
        screenSize.origin.y = 0;
        screen.frame = screenSize;
        [screen setContentMode:UIViewContentModeScaleAspectFit];
        [self.instructionScrollView addSubview:screen];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) backClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error {
    NSLog(@"loginButton %@",result.grantedPermissions);
    self.messageLabel.text = @"";
    if ((error) != nil) {
        NSLog(@"THERE WAS AN ERROR %@", error);
        self.messageLabel.text = [NSString stringWithFormat:@"%@", error];
    } else if ([result isCancelled]) {
        self.messageLabel.text = @"Login cancelled, please try again";
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [[AppModel sharedModel] addUser];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    self.messageLabel.text = @"You have been logged out";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
