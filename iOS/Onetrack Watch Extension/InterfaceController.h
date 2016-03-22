//
//  InterfaceController.h
//  Onetrack Watch Extension
//
//  Created by Andrew Dekker on 22/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController : WKInterfaceController <WCSessionDelegate>

@property (nonatomic, strong) WCSession *session;
@property (nonatomic, strong) NSArray *state;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *tableView;
- (IBAction)buttonClicked;

@end
