//
//  AppModel.h
//  ;
//
//  Created by Andrew Dekker on 20/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <UIKit/UIKit.h>

@interface AppModel : NSObject <WCSessionDelegate>

@property (nonatomic, strong) WCSession *session;
@property (nonatomic, strong) NSArray *items;

+ (id)sharedModel;

-(void)save;
-(void)restore;
-(void)resetAll;
-(void)moveTrackerFrom:(int)from to:(int)to;
-(BOOL)addCountToTracker:(int)index;
-(void)resetTracker:(int)index;
-(void)addTracker:(NSString *)name withMaxUse:(NSNumber *)usePerDay withColor:(UIColor *)color;
-(void)updateTrackerWithId:(NSString *)id withName:(NSString *)name withMaxUse:(NSNumber *)usePerDay withColor:(UIColor *)color;
-(void)deleteTracker:(int)index;
-(void)removeCountFromTracker:(int)index;

- (void)verifyLoginWithSuccess:(void (^)())success andFailure:(void (^)())failure;
- (NSDictionary *)getUserDetails;

//Friends
- (void)getFriendsWithSuccess:(void (^)(NSArray *))success andFailure:(void (^)())failure;

- (long)getTodayCount:(NSArray *)counts;
- (long)getYesterdayCount:(NSArray *)counts;

//API Methods
-(void)addUser;
-(void)createTrackerWithName:(NSString *)name andMaxCount:(NSString *)maxCount;
-(void)callAPIWithPostWithEndpoint:(NSString *)URLString andParameters:(NSDictionary *)parameters andSuccess:(void(^)(id response))success andFailure:(void(^)(NSError *error))failure;


@end
