//
//  AppModel.m
//  Onetrack
//
//  Created by Andrew Dekker on 20/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import "AppModel.h"
#import "AFNetworking/AFNetworking.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation AppModel

+ (id)sharedModel {
    static AppModel *sharedAppModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAppModel = [[self alloc] init];
    });
    return sharedAppModel;
}

- (id)init {
    if (self = [super init]) {
        NSLog(@"CREATING MODEL");
    }
    return self;
}

-(void)save {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"dataz.txt"];
    [NSKeyedArchiver archiveRootObject:self.items toFile:appFile];
}

-(void)restore {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"dataz.txt"];
    self.items = [NSKeyedUnarchiver unarchiveObjectWithFile:appFile];
    if(!self.items) {
        self.items = [[NSArray alloc] init];
    }
}

-(void)moveTrackerFrom:(int)from to:(int)to {
    NSMutableArray *mutableItems = [self.items mutableCopy];
    NSDictionary *item = [(NSArray *)[[AppModel sharedModel] items] objectAtIndex:from];
    [mutableItems removeObjectAtIndex:from];
    [mutableItems insertObject:item atIndex:to];
    [self setItems:[mutableItems copy]];
    [self save];
}

-(void)addCountToTracker:(int)index {
    NSMutableArray *mutableItems = [self.items mutableCopy];
    NSMutableDictionary *item = [[mutableItems objectAtIndex:index] mutableCopy];
    NSNumber *maxCount = [item objectForKey:@"maxCount"];
    NSMutableArray *clicks = [[item objectForKey:@"clicks"] mutableCopy];
    NSDate *now = [NSDate date];
    if([maxCount integerValue] == 0 || [maxCount longValue] > [self getTodayCount:clicks]) {
        [clicks addObject:[self stringFromDate:now]];
        [item setObject:[clicks copy] forKey:@"clicks"];
        [mutableItems replaceObjectAtIndex:index withObject:[item copy]];
        [self setItems:[mutableItems copy]];
        [self save];
    }
}

-(void)removeCountFromTracker:(int)index {
    NSMutableArray *mutableItems = [self.items mutableCopy];
    NSMutableDictionary *item = [[mutableItems objectAtIndex:index] mutableCopy];
    NSMutableArray *clicks = [[item objectForKey:@"clicks"] mutableCopy];
    if(clicks.count > 0) {
        [clicks removeObjectAtIndex:clicks.count-1];
        [item setObject:[clicks copy] forKey:@"clicks"];
        [mutableItems replaceObjectAtIndex:index withObject:[item copy]];
        [self setItems:[mutableItems copy]];
    }
    [self save];
}

-(void)addTracker:(NSString *)name withMaxUse:(NSNumber *)usePerDay {
    NSMutableArray *mutableItems = [[[AppModel sharedModel] items] mutableCopy];
    NSDictionary *item = @{@"name" : name, @"clicks" : @[], @"maxCount": usePerDay};
    [mutableItems addObject:item];
    NSLog(@"ADDING NEW");
    [self setItems:[mutableItems copy]];
    [self save];
}

-(void)deleteTracker:(int)index {
    NSMutableArray *mutableItems = [[self items] mutableCopy];
    [mutableItems removeObjectAtIndex:index];
    [self setItems:[mutableItems copy]];
    [self save];
}

-(void)resetTracker:(int)index {
    NSMutableArray *theItems = [self.items mutableCopy];
    NSMutableDictionary *theItem = [[(NSArray *)[[AppModel sharedModel] items] objectAtIndex:index] mutableCopy];
    [theItem setObject:@[] forKey:@"clicks"];
    [theItems replaceObjectAtIndex:index withObject:[theItem copy]];
    [self setItems:[theItems copy]];
    [self save];
}

-(void)resetAll {
    self.items = @[];
    [self save];
}

#pragma mark HELPER FUNCTIONS

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

- (long)getYesterdayCount:(NSArray *)counts {
    long yesterdayCount = 0;
    for(NSString *dateString in counts) {
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate *yday = [[NSDate date] dateByAddingTimeInterval:-1*24*60*60];;
        NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:yday];
        //[components setDay:-1];
        NSDate *yesterday = [cal dateFromComponents:components];
        components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[self dateFromString:dateString]];
        NSDate *otherDate = [cal dateFromComponents:components];
        if([yesterday isEqualToDate:otherDate]) {
            //do stuff
            yesterdayCount += 1;
        }
    }
    NSLog(@"XX %ld",yesterdayCount);
    return yesterdayCount;
}

- (NSString *)stringFromDate:(NSDate *)aDate {
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [gmtDateFormatter stringFromDate:aDate];
}

- (NSDate *)dateFromString:(NSString *)aString {
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [gmtDateFormatter dateFromString:aString];
}

- (NSDictionary *)getUserDetails {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
    if([defaults objectForKey:@"user_id"]) {
        [details setObject:[defaults objectForKey:@"user_id"] forKey:@"user_id"];
    } else {
        [details setObject:@"" forKey:@"user_id"];
    }
    if([defaults objectForKey:@"user_name"]) {
        [details setObject:[defaults objectForKey:@"user_name"] forKey:@"user_name"];
    } else {
        [details setObject:@"" forKey:@"user_name"];
    }
    if([defaults objectForKey:@"user_email"]) {
        [details setObject:[defaults objectForKey:@"user_email"] forKey:@"user_email"];
    } else {
        [details setObject:@"" forKey:@"user_email"];
    }
    return [details copy];
}

- (void)verifyLoginWithSuccess:(void (^)())success andFailure:(void (^)())failure {
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             [defaults setObject:result[@"id"] forKey:@"user_id"];
             [defaults setObject:result[@"name"] forKey:@"user_name"];
             [defaults setObject:result[@"email"] forKey:@"user_email"];
             [defaults synchronize];
             success();
         } else {
             NSLog(@"%@",error);
             failure();
         }
     }];
}

@end
