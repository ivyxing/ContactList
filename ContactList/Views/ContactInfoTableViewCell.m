//
//  ContactInfoTableViewCell.m
//  ContactList
//
//  Created by Ivy Xing on 5/17/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

#import "ContactInfoTableViewCell.h"

#import "ContactPerson.h"
#import "ColorGenerator.h"

static const int kGradientDarkness = 100;

@interface ContactInfoTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *containerView;
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
    
    // random gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.containerView.bounds;
    
    UIColor *firstColor = [ColorGenerator generateRandomColorWithUniformRGBValue:kGradientDarkness];
    UIColor *secondColor = [ColorGenerator generateRandomColorWithUniformRGBValue:kGradientDarkness];
    gradient.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    [self.containerView.layer insertSublayer:gradient atIndex:0];
    
}

- (void)tableView:(UITableView *)tableView setupCellWithObject:(id)object;
{
    NSAssert([object isKindOfClass:[ContactPerson class]], @"Expecting a ContactPerson object");
    
    ContactPerson *person = (ContactPerson *)object;
    
    self.firstNameLabel.text = person.firstName;
    self.lastNameLabel.text = person.lastName;
    self.phonerNumberLabel.text = person.phoneNumber;
    self.profileImageView.image = person.profileImage;
}

#pragma mark - Initialization Helper Functions
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

@end
