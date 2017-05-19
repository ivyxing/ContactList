//
//  ColorGenerator.m
//  ContactList
//
//  Created by Ivy Xing on 5/18/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

#import "ColorGenerator.h"

@implementation ColorGenerator

// Returns a random color whose r/g/b value is between 0 and the specified maxRGBValue
+(UIColor *)generateRandomColorWithUniformRGBValue:(int)maxRGBValue
{
    CGFloat red = arc4random_uniform(maxRGBValue) / 255.0;
    CGFloat green = arc4random_uniform(maxRGBValue) / 255.0;
    CGFloat blue = arc4random_uniform(maxRGBValue) / 255.0;
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    return color;
}

@end
