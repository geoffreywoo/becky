//
//  BYFriend.m
//  Becky
//
//  Created by Geoffrey Woo on 6/10/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import "BYFriend.h"

@implementation BYFriend


- (id)initWithJSON:(NSDictionary *)dict
{
    self.firstName = [dict objectForKey:@"firstName"];
    self.lastName = [dict objectForKey:@"lastName"];
    self.phoneNumber = [dict objectForKey:@"phone"];
    self.score = [[dict objectForKey:@"score"] intValue];
    
    if ([self.lastName isEqualToString:@""]) {
        if ([self.firstName isEqualToString:@""]) {
            self.initials = @"??";
        } else if ([self.firstName length] == 1) {
            self.initials = [NSString stringWithFormat:@"%@?",[self.firstName substringToIndex:1]];
        } else if ([self.firstName length] > 1) {
            self.initials = [self.firstName substringToIndex:2];
        }
    } else if ([self.lastName length] > 0){
        if ([self.firstName isEqualToString:@""]) {
            self.initials = [NSString stringWithFormat:@"?%@",[self.lastName substringToIndex:1]];
        } else if ([self.firstName length] > 0) {
            self.initials = [NSString stringWithFormat:@"%@%@",[self.firstName substringToIndex:1], [self.lastName substringToIndex:1]];
        }
    } else {
         self.initials = [NSString stringWithFormat:@"%@%@",[self.firstName substringToIndex:1], [self.lastName substringToIndex:1]];
    }
    return self;
}

@end
