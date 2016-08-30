//
//  CreateViewController.m
//  Onetrack
//
//  Created by Andrew Dekker on 15/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import "CreateViewController.h"
#import "AppModel.h"

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
        UIColor *trackerColor = [UIColor blackColor];
        int randCol=[[AppModel sharedModel] items].count%6;
        switch(randCol) {
            case 0:
                trackerColor = [UIColor colorWithRed:0.514  green:0.141  blue:0.149 alpha:1];
                break;
            case 1:
                trackerColor = [UIColor colorWithRed:0.141  green:0.514  blue:0.141 alpha:1];
                break;
            case 2:
                trackerColor = [UIColor colorWithRed:0.141  green:0.141  blue:0.514 alpha:1];
                break;
            case 3:
                trackerColor = [UIColor colorWithRed:0.514  green:0.514  blue:0.149 alpha:1];
                break;
            case 4:
                trackerColor = [UIColor colorWithRed:0.514  green:0.141  blue:0.514 alpha:1];
                break;
            case 5:
                trackerColor = [UIColor colorWithRed:0.141  green:0.514  blue:0.514 alpha:1];
                break;
            default:
                break;
        }
        [[AppModel sharedModel] addTracker:self.name.text withMaxUse:maxUsage withColor:trackerColor];
        [self closeTapped:sender];
    }
}

- (IBAction)resetTapped:(id)sender {
    [[AppModel sharedModel] resetAll];
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
