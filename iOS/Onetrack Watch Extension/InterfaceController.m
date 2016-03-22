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
    NSArray *arr = @[@{@"a":@"b"}];
    [self configureTableWithData:arr];
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

- (void)configureTableWithData:(NSArray*)dataObjects {
    [self.tableView setNumberOfRows:[dataObjects count] withRowType:@"defaultCell"];
    for (NSInteger i = 0; i < self.tableView.numberOfRows; i++) {
        WatchTableCell* theRow = [self.tableView rowControllerAtIndex:i];
        NSDictionary* dataObj = [dataObjects objectAtIndex:i];
        [theRow.label setText:[dataObj objectForKey:@"a"]];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSLog(@"SELECTED ZZ");
    NSString *counterString = [NSString stringWithFormat:@"%d", 4];
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[counterString] forKeys:@[@"counterValue"]];
    if ([self.session isReachable]) {
        NSLog(@"IS REACHABLE ZZ");
        [self.session sendMessage:applicationData
                               replyHandler:^(NSDictionary *reply) {
                                   NSLog(@"GOT REPLY");
                                   //handle reply from iPhone app here
                               }
                               errorHandler:^(NSError *error) {
                                   NSLog(@"GOT ERROR %@", error);
                                   //catch any errors here
                               }
        ];
    } else {
        NSLog(@"IS NOT REACHABLE");
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message {
    NSLog(@"RECEIVED ON WATCH");
    NSString *counterValue = [message objectForKey:@"counterValue"];
    NSLog(@"FOUND ME A %@", counterValue);
}

- (IBAction)buttonClicked {
    NSLog(@"WOO APPLE WATCH");
}
@end



