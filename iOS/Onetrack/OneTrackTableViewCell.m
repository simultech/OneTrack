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
    
    [self.contentView setBackgroundColor:[self.data objectForKey:@"color"]];
    
    NSNumber *maxCount = [self.data objectForKey:@"maxCount"];
    UILabel *itemLabel = (UILabel *)[self viewWithTag:1];
    UILabel *todayLabel = (UILabel *)[self viewWithTag:2];
    UILabel *lastAdded = (UILabel *)[self viewWithTag:5];
    UIView *metaBG = (UIView *)[self viewWithTag:20];
    
    
    [metaBG setBackgroundColor:[self darkerColorForColor:[self.data objectForKey:@"color"] withChange:0.1]];
    itemLabel.text = [self.data objectForKey:@"name"];
    if([maxCount integerValue] == 0) {
        todayLabel.text = [NSString stringWithFormat:@"%ld", [[AppModel sharedModel] getTodayCount:[self.data objectForKey:@"clicks"]]];
    } else {
        NSString *text = [NSString stringWithFormat:@"%ld / %@", [[AppModel sharedModel] getTodayCount:[self.data objectForKey:@"clicks"]], maxCount];
        NSMutableAttributedString *fancyText = [[NSMutableAttributedString alloc] initWithString:text];
        int index = (int)[text rangeOfString:@"/"].location;
        [fancyText addAttribute:NSForegroundColorAttributeName value:[self lighterColorForColor:[self.data objectForKey:@"color"] withChange:0.5] range:NSMakeRange(index, text.length - index)];
        todayLabel.attributedText = fancyText;
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

- (UIColor *)darkerColorForColor:(UIColor *)c withChange:(float)change {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - change, 0.0)
                               green:MAX(g - change, 0.0)
                                blue:MAX(b - change, 0.0)
                               alpha:a];
    return nil;
}

- (UIColor *)lighterColorForColor:(UIColor *)c withChange:(float)change {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r + change, 0.0)
                               green:MAX(g + change, 0.0)
                                blue:MAX(b + change, 0.0)
                               alpha:a];
    return nil;
}

@end
