//
//  OneTrackTableViewCell.m
//  Onetrack
//
//  Created by Andrew Dekker on 21/08/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import "OneTrackTableViewCell.h"
#import "AppModel.h"

@implementation OneTrackTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)initCellWithData:data {
    self.data = data;
    NSLog(@"HELLO ABCDEF");
    NSLog(@"%@",self.data);
    [self redraw];
}

- (void)redraw {
    
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.514  green:0.141  blue:0.149 alpha:1]];
    
    NSNumber *maxCount = [self.data objectForKey:@"maxCount"];
    UILabel *itemLabel = (UILabel *)[self viewWithTag:1];
    UILabel *todayLabel = (UILabel *)[self viewWithTag:2];
    UILabel *lastAdded = (UILabel *)[self viewWithTag:5];
    UIView *metaBG = (UIView *)[self viewWithTag:20];
    
    [metaBG setBackgroundColor:[UIColor colorWithRed:0.302  green:0.082  blue:0.086 alpha:1]];
    itemLabel.text = [self.data objectForKey:@"name"];
    if([maxCount integerValue] == 0) {
        todayLabel.text = [NSString stringWithFormat:@"%ld", [[AppModel sharedModel] getTodayCount:[self.data objectForKey:@"clicks"]]];
    } else {
        todayLabel.text = [NSString stringWithFormat:@"%ld / %@", [[AppModel sharedModel] getTodayCount:[self.data objectForKey:@"clicks"]], maxCount];
    }
    lastAdded.text = @"";
    if([[self.data objectForKey:@"clicks"] count] > 0) {
        NSDate *date = [[AppModel sharedModel] dateFromString:[[self.data objectForKey:@"clicks"] lastObject]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        dateFormatter.dateFormat = @"hh:mma";
        lastAdded.text = [NSString stringWithFormat:@"Last: %@",[dateFormatter stringFromDate:date]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
