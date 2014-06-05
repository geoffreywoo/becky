//
//  BYMainViewCell.h
//  Becky
//
//  Created by Geoffrey Woo on 6/4/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kBYMainViewCellIdentifier;

@interface BYMainViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *beckyButton;
@property (nonatomic, strong) IBOutlet UIButton *bballButton;
@property (nonatomic, strong) IBOutlet UIButton *pizzaButton;
@property (nonatomic, strong) IBOutlet UITextView *initialsField;

@end
