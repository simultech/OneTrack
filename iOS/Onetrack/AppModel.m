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

#define APIString @"http://habitcount.com"
//#define APIString @"http://localhost"
@implementation AppModel

+ (id)sharedModel {
    static AppModel *sharedAppModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAppModel = [[self alloc] init];
        sharedAppModel.currentOperations = 0;
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

-(NSDictionary *)getDataForTrackerID:(NSString *)trackerID {
    NSDictionary *data = @{};
    for(int i=0; i<self.items.count; i++) {
        if([trackerID isEqualToString:[[self.items objectAtIndex:i] objectForKey:@"tracker_id"]]) {
            data = [self.items objectAtIndex:i];
            break;
        }
    }
    return data;
}

-(BOOL)addCountToTracker:(int)index {
    BOOL completed = NO;
    NSMutableArray *mutableItems = [self.items mutableCopy];
    NSMutableDictionary *item = [[mutableItems objectAtIndex:index] mutableCopy];
    NSNumber *maxCount = [item objectForKey:@"maxCount"];
    NSMutableArray *clicks = [[item objectForKey:@"clicks"] mutableCopy];
    NSDate *now = [NSDate date];
    if([maxCount integerValue] == 0 || [maxCount longValue] > [self getTodayCount:clicks]) {
        NSString *date = [self stringFromDate:now];
        [clicks addObject:date];
        [item setObject:[clicks copy] forKey:@"clicks"];
        [mutableItems replaceObjectAtIndex:index withObject:[item copy]];
        [self setItems:[mutableItems copy]];
        [self save];
        completed = YES;
        [self countUpTrackerWithId:[item objectForKey:@"tracker_id"] andClickValue:date];
    }
//    return completed;
    return YES;
}

-(void)removeCountFromTracker:(int)index {
    NSMutableArray *mutableItems = [self.items mutableCopy];
    NSMutableDictionary *item = [[mutableItems objectAtIndex:index] mutableCopy];
    NSMutableArray *clicks = [[item objectForKey:@"clicks"] mutableCopy];
    NSNumber *maxCount = [item objectForKey:@"maxCount"];
    if(clicks.count > 0 && ([maxCount integerValue] == 0 || [self getTodayCount:clicks] > 0)) {
        NSString *clickValue = [[clicks lastObject]copy];
        [clicks removeObjectAtIndex:clicks.count-1];
        [item setObject:[clicks copy] forKey:@"clicks"];
        [mutableItems replaceObjectAtIndex:index withObject:[item copy]];
        [self setItems:[mutableItems copy]];
        [self countDownTrackerWithId:[item objectForKey:@"tracker_id"] andClickValue:clickValue];
    }
    [self save];
}

-(void)addTracker:(NSString *)name withMaxUse:(NSNumber *)usePerDay withColor:(UIColor *)color {
    NSMutableArray *mutableItems = [[[AppModel sharedModel] items] mutableCopy];
    NSString *tracker_id = [AppModel uuid];
    NSDictionary *item = @{@"tracker_id": tracker_id, @"name" : name, @"clicks" : @[], @"maxCount": usePerDay, @"color": color};
    [mutableItems addObject:item];
    NSLog(@"ADDING NEW");
    [self setItems:[mutableItems copy]];
    [self save];


    //API call
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue: &b alpha: &a];
    int rInt = (int)(255.0 * r);
    int gInt = (int)(255.0 * g);
    int bInt = (int)(255.0 * b);
    NSString *hexString = [NSString stringWithFormat:@"%d.%d.%d", rInt, gInt, bInt];
    [self createTrackerWithName:name andMaxCount:[usePerDay stringValue] andColor:hexString andTrackerID:tracker_id];

}

-(void)updateTrackerWithId:(NSString *)id withName:(NSString *)name withMaxUse:(NSNumber *)usePerDay withColor:(UIColor *)color {
    NSMutableArray *mutableItems = [[self items] mutableCopy];
    for(int i=0; i<mutableItems.count; i++) {
        if([id isEqualToString:[[mutableItems objectAtIndex:i] objectForKey:@"tracker_id"]]) {
            NSMutableDictionary *mutableItem = [[mutableItems objectAtIndex:i] mutableCopy];
            [mutableItem setObject:name forKey:@"name"];
            [mutableItem setObject:usePerDay forKey:@"maxCount"];
            [mutableItem setObject:color forKey:@"color"];
            [mutableItems replaceObjectAtIndex:i withObject:mutableItem];
        }
    }
    [self setItems:[mutableItems copy]];
    [self save];
    NSLog(@"UPDATING TRACKER");
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
             NSLog(@"FB ID: %@", result[@"id"]);
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
    [self verifyLoginWithSuccess:^{
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

-(void)createTrackerWithName:(NSString *)name andMaxCount:(NSString *)maxCount andColor:(NSString *)color andTrackerID:(NSString *)trackerID{
    NSDictionary *userDetails = [[AppModel sharedModel] getUserDetails];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:[userDetails objectForKey:@"user_id"] forKey:@"fb_id"];
    [data setObject:name forKey:@"name"];
    [data setObject:maxCount forKey:@"max_count"];
    [data setObject:color forKey:@"color"];
    [data setObject:trackerID forKey:@"tracker_id"];
    [self callAPIWithPostWithEndpoint:@"create_tracker" andParameters:data andSuccess:^(id response) {
        NSLog(@"createTracker %@", response);
    } andFailure:^(NSError *error) {
        NSLog(@"createTracker ERROR %@", error);
    }];
}

-(void)countUpTrackerWithId:(NSString *)trackerID andClickValue:(NSString *)clickValue{
    //params: fb_id, track_id, click_value
    NSLog(@"countUpTrackerWithId %@, %@", trackerID, clickValue);
    NSDictionary *userDetails = [[AppModel sharedModel] getUserDetails];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:[userDetails objectForKey:@"user_id"] forKey:@"fb_id"];
    [data setObject:trackerID forKey:@"tracker_id"];
    [data setObject:clickValue forKey:@"click_value"];
    [self callAPIWithPostWithEndpoint:@"count_up_tracker" andParameters:data andSuccess:^(id response) {
        NSLog(@"count_up_tracker %@", response);
    } andFailure:^(NSError *error) {
        NSLog(@"count_up_tracker ERROR %@", error);
    }];
}

-(void)countDownTrackerWithId:(NSString *)trackerID andClickValue:(NSString *)clickValue{
    //params: fb_id, track_id, click_value
    NSLog(@"countDownTrackerWithId %@", trackerID);
    NSDictionary *userDetails = [[AppModel sharedModel] getUserDetails];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:[userDetails objectForKey:@"user_id"] forKey:@"fb_id"];
    [data setObject:trackerID forKey:@"tracker_id"];
    [data setObject:clickValue forKey:@"click_value"];
    [self callAPIWithPostWithEndpoint:@"count_down_tracker" andParameters:data andSuccess:^(id response) {
        NSLog(@"count_down_tracker %@", response);
    } andFailure:^(NSError *error) {
        NSLog(@"count_down_tracker ERROR %@", error);
    }];
}


-(void)callAPIWithPostWithEndpoint:(NSString *)URLString andParameters:(NSDictionary *)parameters andSuccess:(void(^)(id response))success andFailure:(void(^)(NSError *error))failure{
    
    self.currentOperations += 1;
    
    NSString *endpoint = [self endpointWithString:URLString];

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:endpoint parameters:parameters error:nil];


    //THE API CALL
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            self.currentOperations -= 1;
            NSLog(@"Error: %@", error);
            failure(error);
        } else {
            self.currentOperations -= 1;
            NSLog(@"%@ %@", response, responseObject);
            success(responseObject);
        }
    }];
    [dataTask resume];
}

-(void)getTrackersFromServerWithSuccess:(void(^)(id response))success andFailure:(void(^)(NSError *error))failure{
    
    NSLog(@"GETTING TRACKERS ");
    
    if (self.currentOperations == 0) {
    
        NSDictionary *userDetails = [[AppModel sharedModel] getUserDetails];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSDictionary *params = @{@"fb_id": [userDetails objectForKey:@"user_id"]};
        
        NSString *endpoint = [self endpointWithString:@"get_trackers"];
        
        NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:endpoint parameters:params error:nil];
        
        //THE API CALL
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"FAILED");
                NSLog(@"FIALED %@", responseObject);
                NSLog(@"FIALED %@", error);
                failure(error);
            } else {
                //Fix colours
                NSMutableArray *newItems = [[responseObject objectForKey:@"trackers"] mutableCopy];
                for(int i=0; i<newItems.count; i++) {
                    NSMutableDictionary *item = [[newItems objectAtIndex:i] mutableCopy];
                    NSString *colorString = [item objectForKey:@"color"];
                    NSArray *components = [colorString componentsSeparatedByString:@"."];
                    CGFloat r = [[components objectAtIndex:0] floatValue] / 255.0;
                    CGFloat g = [[components objectAtIndex:1] floatValue] / 255.0;
                    CGFloat b = [[components objectAtIndex:2] floatValue] / 255.0;
                    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
                    [item setObject:color forKey:@"color"];
                    [newItems replaceObjectAtIndex:i withObject:item];
                }
                self.items = [newItems copy];
                NSLog(@"%@", self.items);
                [self save];
                success(responseObject);
            }
        }];
        [dataTask resume];
        
    } else {
        NSLog(@"FAILED SOMETHING HAPPENING");
    }
    
}

-(NSString *)endpointWithString:(NSString *)endpoint{
    return [NSString stringWithFormat:@"%@/%@",APIString, endpoint];
}

+ (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

@end
