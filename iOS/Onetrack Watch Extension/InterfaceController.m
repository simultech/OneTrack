//
//  InterfaceController.m
//  Onetrack Watch Extension
//
//  Created by Andrew Dekker on 22/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import "InterfaceController.h"
#import "WatchTableCell.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    // Configure interface objects here.
    self.state = @[];
    [self reloadTable];
}

- (void)willActivate {
    [super willActivate];
    if ([WCSession isSupported]) {
        self.session = [WCSession defaultSession];
        self.session.delegate = self;
        [self.session activateSession];
        NSLog(@"ACTIVATING SESSION");
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)reloadTable {
    [self.tableView setNumberOfRows:[self.state count] withRowType:@"defaultCell"];
    for (NSInteger i = 0; i < self.tableView.numberOfRows; i++) {
        WatchTableCell* theRow = [self.tableView rowControllerAtIndex:i];
        NSDictionary* dataObj = [self.state objectAtIndex:i];
        NSString *itemText = [dataObj objectForKey:@"name"];
        long todayCount = [self getTodayCount:[dataObj objectForKey:@"clicks"]];
        if([[dataObj objectForKey:@"maxCount"] integerValue] == 0) {
            itemText = [NSString stringWithFormat:@"%@ (%ld)", itemText, todayCount];
        } else {
            itemText = [NSString stringWithFormat:@"%@ (%ld / %@)", itemText, todayCount, [dataObj objectForKey:@"maxCount"]];
        }
        [theRow.label setText:itemText];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSLog(@"SELECTED ZZ");
    NSNumber *index = [NSNumber numberWithInteger:rowIndex];
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[index] forKeys:@[@"index"]];
    if ([self.session isReachable]) {
        NSLog(@"IS REACHABLE ZZ");
        [self.session sendMessage:applicationData replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
            NSLog(@"SENT");
        } errorHandler:nil];
    } else {
        NSLog(@"IS NOT REACHABLE");
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message {
    NSArray *newState = [message objectForKey:@"state"];
    self.state = newState;
    [self reloadTable];
}

- (long)getTodayCount:(NSArray *)counts {
    long todayCount = 0;
    for(NSString *dateString in counts) {
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
        NSDate *today = [cal dateFromComponents:components];
        components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[self dateFromString:dateString]];
        NSDate *otherDate = [cal dateFromComponents:components];
        if([today isEqualToDate:otherDate]) {
            //do stuff
            todayCount += 1;
        }
    }
    return todayCount;
}

- (NSDate *)dateFromString:(NSString *)aString {
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [gmtDateFormatter dateFromString:aString];
}

@end



