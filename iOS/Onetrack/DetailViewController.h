//
//  DetailViewController.h
//  Onetrack
//
//  Created by Andrew Dekker on 15/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBChartView.h"
#import "JBBarChartView.h"
#import "JBLineChartView.h"

@protocol DetailViewControllerDelegate

// define protocol functions that can be used in any class using this delegate
-(void)resetAll;

@end


@interface DetailViewController : UIViewController <JBBarChartViewDataSource, JBBarChartViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *filter;

@property (weak) id delegate;
@property (assign) int selectedFilter;

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSArray *filteredData;
@property (nonatomic, strong) JBBarChartView *barChartView;
- (IBAction)filterTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *outputValue;
@property (weak, nonatomic) IBOutlet UILabel *outputDate;

@end
