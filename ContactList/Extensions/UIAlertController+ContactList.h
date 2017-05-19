//
//  UIAlertController+ContactList.h
//  ContactList
//
//  Created by Ivy Xing on 5/19/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (ContactList)

// Returns a alert with a simple "OK" title for cancel action
+ (UIAlertController *)alertWithMessage:(NSString *)message;

@end
