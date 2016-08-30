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
#define hasInternetConnection \
[AFNetworkReachabilityManager sharedManager].reachable

//#define APIString @"http://habitcount.com"
#define APIString @"http://0.0.0.0"
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
        if ([WCSession isSupported]) {
            self.session = [WCSession defaultSession];
            self.session.delegate = self;
            [self.session activateSession];
            NSLog(@"ACTIVATING SESSION");
        }
    }
    return self;
}

-(void)save {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"dataz.txt"];
    [NSKeyedArchiver archiveRootObject:self.items toFile:appFile];
    [self updateWatchState];
}

-(void)restore {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"dataz.txt"];
    self.items = [NSKeyedUnarchiver unarchiveObjectWithFile:appFile];
    if(!self.items) {
        self.items = [[NSArray alloc] init];
    }
    [self updateWatchState];
}

-(void)moveTrackerFrom:(int)from to:(int)to {
    NSMutableArray *mutableItems = [self.items mutableCopy];
    NSDictionary *item = [(NSArray *)[[AppModel sharedModel] items] objectAtIndex:from];
    [mutableItems removeObjectAtIndex:from];
    [mutableItems insertObject:item atIndex:to];
    [self setItems:[mutableItems copy]];
    [self save];
}

-(BOOL)addCountToTracker:(int)index {
    BOOL completed = NO;
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
        completed = YES;
    }
    return completed;
}

-(void)removeCountFromTracker:(int)index {
    NSMutableArray *mutableItems = [self.items mutableCopy];
    NSMutableDictionary *item = [[mutableItems objectAtIndex:index] mutableCopy];
    NSMutableArray *clicks = [[item objectForKey:@"clicks"] mutableCopy];
    NSNumber *maxCount = [item objectForKey:@"maxCount"];
    if(clicks.count > 0 && ([maxCount integerValue] == 0 || [self getTodayCount:clicks] > 0)) {
        [clicks removeObjectAtIndex:clicks.count-1];
        [item setObject:[clicks copy] forKey:@"clicks"];
        [mutableItems replaceObjectAtIndex:index withObject:[item copy]];
        [self setItems:[mutableItems copy]];
    }
    [self save];
}

-(void)addTracker:(NSString *)name withMaxUse:(NSNumber *)usePerDay withColor:(UIColor *)color {
    NSMutableArray *mutableItems = [[[AppModel sharedModel] items] mutableCopy];
    NSDictionary *item = @{@"name" : name, @"clicks" : @[], @"maxCount": usePerDay, @"color": color};
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
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, email"}]
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

#pragma mark friends apis
- (void)getFriendsWithSuccess:(void (^)(NSArray *))success andFailure:(void (^)())failure {
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/taggable_friends?limit=100" parameters:@{@"fields": @"id, name, picture.width(80).height(80)"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             success([result objectForKey:@"data"]);
         } else {
             NSLog(@"%@",error);
             failure();
         }
     }];
}

#pragma mark watch functions

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message {
    NSLog(@"RECEIVED ON PHONE");
    NSNumber *indexTapped = [message objectForKey:@"index"];
    [self addCountToTracker:(int)[indexTapped integerValue]];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"UpdatedDataNotification"
     object:self];
    NSLog(@"SENT NOTIFICATION");
}

- (void)updateWatchState {
    if ([self.session isReachable]) {
        NSDictionary *applicationData = @{@"state":[[AppModel sharedModel] items]};
        [self.session sendMessage:applicationData
                     replyHandler:^(NSDictionary *reply) {
                         NSLog(@"GOT REPLY %@", reply);
                     }
                     errorHandler:^(NSError *error) {
                         NSLog(@"GOT ERROR %@", error);
                     }
         ];
    }
}


-(void)addUser{
    [[AppModel sharedModel] verifyLoginWithSuccess:^{
        NSDictionary *userDetails = [[AppModel sharedModel] getUserDetails];
        NSLog(@"THESE ARE THE USERS DETAILS%@",userDetails);

        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        [data setObject:[userDetails objectForKey:@"user_id"] forKey:@"fb_id"];
        [data setObject:[userDetails objectForKey:@"user_name"] forKey:@"name"];
        [self callAPIWithPostWithEndpoint:@"add_user" andParameters:data andSuccess:^(id response) {
            NSLog(@"response %@", response);
        } andFailure:^(NSError *error) {
            NSLog(@"error %@", error);
        }];
    } andFailure:nil];
}
-(void)callAPIWithPostWithEndpoint:(NSString *)URLString andParameters:(NSDictionary *)parameters andSuccess:(void(^)(id response))success andFailure:(void(^)(NSError *error))failure{
    NSString *endpoint = [self endpointWithString:URLString];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    NSLog(@"hasInternet %d", hasInternetConnection);
//    if (hasInternetConnection) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

        NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:endpoint parameters:parameters error:nil];

        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
                failure(error);
            } else {
                NSLog(@"%@ %@", response, responseObject);
                success(responseObject);
            }
        }];
        [dataTask resume];
//    }else{
//        NSLog(@"no internet");
//    }
}

-(NSString *)endpointWithString:(NSString *)endpoint{
    return [NSString stringWithFormat:@"%@/%@",APIString, endpoint];
}
@end
