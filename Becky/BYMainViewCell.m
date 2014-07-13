//
//  BYMainViewCell.m
//  Becky
//
//  Created by Geoffrey Woo on 6/4/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import "BYMainViewCell.h"

NSString * const kBYMainViewCellIdentifier = @"BYMainViewCell";

@implementation BYMainViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) setPooToggled:(BOOL)pooToggled {
    _pooToggled = pooToggled;
    self.beckyButton.hidden = pooToggled;
    self.bballButton.hidden = pooToggled;
    self.pizzaButton.hidden = pooToggled;
    self.pooButton.hidden = !pooToggled;
    
    self.scoreField.hidden = YES;
    self.nameLabel.hidden = YES;
}


- (void) setDetailsToggled:(BOOL)detailsToggled {
    
}

@end
