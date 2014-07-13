//
//  BYMainViewCell.h
//  Becky
//
//  Created by Geoffrey Woo on 6/4/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYFriend.h"

extern NSString * const kBYMainViewCellIdentifier;

@interface BYMainViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *beckyButton;
@property (nonatomic, strong) IBOutlet UIButton *bballButton;
@property (nonatomic, strong) IBOutlet UIButton *pizzaButton;
@property (nonatomic, strong) IBOutlet UIButton *pooButton;
@property (nonatomic, strong) IBOutlet UIButton *initialsButton;
@property (nonatomic, strong) IBOutlet UILabel *scoreField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

@property (nonatomic) BOOL pooToggled;
@property (nonatomic) BOOL detailsToggled;

- (void) loadFriend:(BYFriend*)friend;


@end
