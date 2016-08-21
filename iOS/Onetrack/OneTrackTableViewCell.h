//
//  OneTrackTableViewCell.h
//  Onetrack
//
//  Created by Andrew Dekker on 21/08/2016.
//  Copyright © 2016 Andrew Dekker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneTrackTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *data;

-(void)initCellWithData:(NSDictionary *)data;

@end
