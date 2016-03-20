//
//  AppModel.h
//  Onetrack
//
//  Created by Andrew Dekker on 20/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppModel : NSObject

@property (nonatomic, strong) NSArray *items;

+ (id)sharedModel;

-(void)save;
-(void)restore;
-(void)resetAll;
-(void)moveTrackerFrom:(int)from to:(int)to;
-(void)addCountToTracker:(int)index;
-(void)resetTracker:(int)index;
-(void)addTracker:(NSString *)name withMaxUse:(NSNumber *)usePerDay;
-(void)deleteTracker:(int)index;
-(void)removeCountFromTracker:(int)index;

- (long)getTodayCount:(NSArray *)counts;
- (long)getYesterdayCount:(NSArray *)counts;


@end
