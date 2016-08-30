//
//  EditViewController.m
//  Onetrack
//
//  Created by Andrew Dekker on 30/08/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import "EditViewController.h"
#import "AppModel.h"

@interface EditViewController ()

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.data);
    self.nameTextField.text = [self.data objectForKey:@"name"];
    self.maxTextField.text = [NSString stringWithFormat:@"%@", [self.data objectForKey:@"maxCount"]];
    // Do any additional setup after loading the view.
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

- (IBAction)backTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveTapped:(id)sender {
    NSLog(@"SAVING");
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *maxUsage = [f numberFromString:self.maxTextField.text];
    if(maxUsage == nil) {
        maxUsage = @0;
    }
    [[AppModel sharedModel] updateTrackerWithId:[self.data objectForKey:@"tracker_id"] withName:self.nameTextField.text withMaxUse:maxUsage withColor:[self.data objectForKey:@"color"]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
