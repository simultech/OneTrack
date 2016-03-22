//
//  DetailViewController.m
//  Onetrack
//
//  Created by Andrew Dekker on 15/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import "DetailViewController.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self organiseData];
    self.outputDate.text = @"";
    self.outputValue.text = @"";
    self.selectedFilter = 0;
    [self.view setBackgroundColor:[AppDelegate colorFromHexString:@"#313131"]];
    // Do any additional setup after loading the view.
    self.title = [self.data objectForKey:@"name"];
    self.barChartView = [[JBBarChartView alloc] init];
    self.barChartView.dataSource = self;
    self.barChartView.delegate = self;
    [self.view addSubview:self.barChartView];
    self.barChartView.layer.borderColor = [AppDelegate colorFromHexString:@"#444444"].CGColor;
    self.barChartView.layer.borderWidth = 1;
    self.barChartView.backgroundColor = [AppDelegate colorFromHexString:@"#333333"];
    [self setBarFrame];
}

- (void)organiseData {
    int numberOfDays = 30;
    int numberOfHours = 24;
    NSDate *today = [NSDate date];
    NSMutableArray *days = [[NSMutableArray alloc] init];
    for(int i=0; i<=numberOfDays; i++) {
        NSMutableArray *day = [[NSMutableArray alloc] init];
        for (int j=0; j<numberOfHours; j++) {
            NSNumber *randNum = @0;
            //randNum = [[NSNumber alloc]initWithInt:(arc4random() % 10)];
            [day addObject:randNum];
        }
        [days addObject:day];
    }
    for(NSString *strDate in [self.data objectForKey:@"clicks"]) {
        NSDate *theDate = [self dateFromString:strDate];
        int dayDelta = (int)[self daysBetweenDate:theDate andDate:today];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour) fromDate:theDate];
        NSInteger hour = [components hour];
        
        int plusOne = (int)[(NSNumber *)[[days objectAtIndex:dayDelta] objectAtIndex:hour] longValue] + 1;
        [[days objectAtIndex:dayDelta] setObject:[NSNumber numberWithInt:plusOne] atIndex:hour];
        
        [[days objectAtIndex:dayDelta] objectAtIndex:hour];
    }
    self.filteredData = [days copy];
}

- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index {
    return (index % 2 == 0) ? [AppDelegate colorFromHexString:@"#08bcef"] : [AppDelegate colorFromHexString:@"#34b234"];
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSString *dateString = @"";
    if(self.selectedFilter == 0) {
        NSDate *date = [NSDate date];
        NSDateComponents *components = [calendar components: NSUIntegerMax fromDate: date];
        [components setHour:index];
        date = [calendar dateFromComponents:components];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd / MM / yyyy 'at' ha"];
        dateString = [formatter stringFromDate:date];
    } else if (self.selectedFilter == 1) {
        NSDate *date = [NSDate date];
        NSDateComponents *components = [calendar components: NSUIntegerMax fromDate: date];
        int dayDeltaIndex = (int)index / 24;
        int hourIndex = index % 24;
        [components setHour:hourIndex];
        [components setDay:components.day - dayDeltaIndex];
        date = [calendar dateFromComponents:components];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd / MM / yyyy 'at' ha"];
        dateString = [formatter stringFromDate:date];
    } else {
        NSDate *date = [NSDate date];
        NSDateComponents *components = [calendar components: NSUIntegerMax fromDate: date];
        [components setDay:components.day - index];
        date = [calendar dateFromComponents:components];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd / MM / yyyy"];
        dateString = [formatter stringFromDate:date];
    }
    int value = [self barChartView:barChartView heightForBarViewAtIndex:index];
    self.outputValue.text = [NSString stringWithFormat:@"%d", value];
    self.outputDate.text = dateString;
}

- (void)didDeselectBarChartView:(JBBarChartView *)barChartView {
    self.outputDate.text = @"";
    self.outputValue.text = @"";
}

- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView {
    return [UIColor whiteColor];
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    return [difference day];
}

- (NSInteger)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSUInteger unitFlags = NSCalendarUnitHour;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:firstDate toDate:secondDate options:0];
    return [components hour]+1;
}

- (NSDate *)dateFromString:(NSString *)aString {
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [gmtDateFormatter dateFromString:aString];
}

- (void)setBarFrame {
    self.barChartView.frame = CGRectMake( 20, 140, self.view.frame.size.width-40, 150 );
    [self.barChartView reloadDataAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView {
    if(self.selectedFilter == 0) {
        return 24;
    } else if (self.selectedFilter == 1) {
        return 24*7;
    } else if (self.selectedFilter == 2) {
        return 30;
    }
    return 0;
}

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index {
    if(self.selectedFilter == 0) {
        return [(NSNumber *)[[self.filteredData objectAtIndex:0] objectAtIndex:index] floatValue];
    } else if (self.selectedFilter == 1) {
        int dayIndex = (int)index / 24;
        int hourIndex = index % 24;
        return [(NSNumber *)[[self.filteredData objectAtIndex:dayIndex] objectAtIndex:hourIndex] floatValue];
    } else {
        int total = 0;
        for (NSNumber *count in [self.filteredData objectAtIndex:index]) {
            total += [count integerValue];
        }
        return total;
    }
    return 0;
}

- (void)dealloc {
    self.barChartView.delegate = nil;
    self.barChartView.dataSource = nil;
}

- (IBAction)filterTapped:(id)sender {
    NSLog(@"FILTER TAPPED");
    self.selectedFilter = (int)[self.filter selectedSegmentIndex];
    [self.barChartView reloadDataAnimated:YES];
}

@end