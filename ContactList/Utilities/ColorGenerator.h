//
//  ColorGenerator.h
//  ContactList
//
//  Created by Ivy Xing on 5/18/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorGenerator : NSObject

// Returns a random color whose r/g/b value is between 0 and the specified maxRGBValue
+(UIColor *)generateRandomColorWithUniformRGBValue:(int)maxRGBValue;

@end
