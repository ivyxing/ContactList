//
//  UIAlertController+ContactList.m
//  ContactList
//
//  Created by Ivy Xing on 5/19/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

#import "UIAlertController+ContactList.h"

@implementation UIAlertController (ContactList)

// Returns a alert with a simple "OK" title for cancel action
+ (UIAlertController *)alertWithMessage:(NSString *)message
{
    // initialize with message
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // cancel action
    NSString *ok = NSLocalizedString(@"OK", @"OK");
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    return alertController;
}

@end
