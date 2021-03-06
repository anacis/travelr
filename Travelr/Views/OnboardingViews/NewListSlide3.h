//
//  NewListSlide3.h
//  Travelr
//
//  Created by Ana Cismaru on 7/22/20.
//  Copyright © 2020 anacismaru. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewListSlide3 : UIView <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *placesSearchTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *suggestionsCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *myPlacesTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *placeSearchBar;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UILabel *suggestionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectStartButton;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tap;

- (void)setUpGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
