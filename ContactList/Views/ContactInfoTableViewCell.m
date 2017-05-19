//
//  ContactInfoTableViewCell.m
//  ContactList
//
//  Created by Ivy Xing on 5/17/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

#import "ContactInfoTableViewCell.h"

// Objects
#import "ContactPerson.h"
// Utilities
#import "ColorGenerator.h"
#import "NSString+ContactList.h"

static const int kGradientDarkness = 100;

@interface ContactInfoTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *blurredImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *phonerNumberLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *infoLabelCollection;

@end

@implementation ContactInfoTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // initialize with empty text
    for (UILabel *label in self.infoLabelCollection)
    { label.text = @""; }
    
    // my number label text
    self.phoneNumberTextLabel.text = NSLocalizedString(@"My Number:", "My Number");
    
    // image
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;
    self.profileImageView.layer.masksToBounds = YES;
    
    // container
    self.containerView.layer.cornerRadius = 5;
    self.containerView.layer.masksToBounds = YES;
}

- (void)tableView:(UITableView *)tableView setupCellWithObject:(id)object;
{
    NSAssert([object isKindOfClass:[ContactPerson class]], @"Expecting a ContactPerson object");
    
    ContactPerson *person = (ContactPerson *)object;
    
    // populate views
    self.firstNameLabel.text = person.firstName;
    self.lastNameLabel.text = person.lastName;
    self.phonerNumberLabel.text = [person.phoneNumber toPhoneNumber];
    self.profileImageView.image = person.profileImage;
    
    // if possible, set blurred photo for background
    if (!UIAccessibilityIsReduceTransparencyEnabled() && person.profileImage != nil)
    {
        UIImage *blurredImage = [self getBlurredImage:person.profileImage];
        self.blurredImageView.image = blurredImage;
    }
    else
    {
        // set some kind of gradient
        CAGradientLayer *gradient = [self getRandomGradient];
        gradient.frame = self.containerView.bounds;
        [self.containerView.layer insertSublayer:gradient atIndex:0];
    }
}

#pragma mark - Helper Functions: Initialization
// Returns the cell's identifier
+ (NSString *)cellIdentifier
{
    return NSStringFromClass([self class]);
}

// Registers the cell
+ (void)registerCellForTableView:(UITableView *)tableView
{
    UINib *nib = [UINib nibWithNibName:[self cellIdentifier] bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:[self cellIdentifier]];
}

#pragma mark - Helper Functions: Utilities
- (UIImage *)getBlurredImage:(UIImage *)theImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // create cg image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    UIImage *resultImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return resultImage;
}

- (CAGradientLayer *)getRandomGradient
{
    // random gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    // grab 2 random dark colors and make a gradient
    UIColor *firstColor = [ColorGenerator generateRandomColorWithUniformRGBValue:kGradientDarkness];
    UIColor *secondColor = [ColorGenerator generateRandomColorWithUniformRGBValue:kGradientDarkness];
    gradient.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    return  gradient;
}

@end
