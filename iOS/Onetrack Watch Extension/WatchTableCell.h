//
//  WatchTableCell.h
//  Onetrack
//
//  Created by Andrew Dekker on 22/03/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import <Foundation/Foundation.h>

@import WatchKit;

@interface WatchTableCell : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceLabel* label;

@end
