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

@end


@interface DetailViewController : UIViewController <JBBarChartViewDataSource, JBBarChartViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISegmentedControl *filter;

@property (weak) id delegate;
@property (assign) int selectedFilter;

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSArray *filteredData;
@property (nonatomic, strong) JBBarChartView *barChartView;
- (IBAction)filterTapped:(id)sender;
- (IBAction)backTapped:(id)sender;

//Friends
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (strong, nonatomic) NSArray *activeFriends;
@property (strong, nonatomic) NSArray *friends;





@property (weak, nonatomic) IBOutlet UILabel *outputValue;
@property (weak, nonatomic) IBOutlet UILabel *outputDate;

@end
