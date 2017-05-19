//
//  ContactPerson.h
//  ContactList
//
//  Created by Ivy Xing on 5/17/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactPerson : NSObject

@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (copy, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) UIImage *profileImage;

@end
