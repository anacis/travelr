//
//  NewPlaceCell.h
//  Travelr
//
//  Created by Ana Cismaru on 7/13/20.
//  Copyright © 2020 anacismaru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewPlaceCell : UITableViewCell

@property (strong, nonatomic) Place *place;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

- (void)setUpCell;

@end

NS_ASSUME_NONNULL_END
