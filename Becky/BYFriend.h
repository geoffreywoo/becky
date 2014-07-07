//
//  BYFriend.h
//  Becky
//
//  Created by Geoffrey Woo on 6/10/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYFriend : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *initials;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic) int score;

- (id)initWithJSON:(NSDictionary *)obj;
- (void) update:(BYFriend*)tempFriend;

@end
