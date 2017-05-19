//
//  NSString+ContactList.m
//  ContactList
//
//  Created by Ivy Xing on 5/19/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

#import "NSString+ContactList.h"

@implementation NSString (ContactList)

- (NSString *)toPhoneNumber
{
    // regular 10 digit phone number
    int regularLength = 10;
    int startIndex = 0;
    
    // invalid phone number
    if (self.length < regularLength)
    { return self; }
    
    // no need to format country code, ignore what's before regular length
    if (self.length > regularLength)
    { startIndex = (int)self.length - regularLength; }
    
    // format
    NSRange range = NSMakeRange(startIndex, self.length - startIndex);
    NSString *formatted = [self stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d{4})" withString:@"($1) $2-$3" options:NSRegularExpressionSearch range:range];
    
    return formatted;
}

@end
