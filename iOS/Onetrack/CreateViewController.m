//
//  CreateViewController.m
//  Onetrack
//
//  Created by Andrew Dekker on 15/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import "CreateViewController.h"

@interface CreateViewController ()

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",self.delegate);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"DISMISSED");
    }];
}

- (IBAction)addTapped:(id)sender {
    if(![self.name.text isEqualToString:@""]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *maxUsage = [f numberFromString:self.maxUse.text];
        if(maxUsage == nil) {
            maxUsage = @0;
        }
        [self.delegate addCount:self.name.text withMaxUse:maxUsage];
        [self closeTapped:sender];
    }
}

- (IBAction)resetTapped:(id)sender {
    [self.delegate resetAll];
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
