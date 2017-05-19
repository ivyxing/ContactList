//
//  ContactListViewController.m
//  ContactList
//
//  Created by Ivy Xing on 5/17/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "ContactListViewController.h"

// Views
#import "ContactPerson.h"
#import "ContactInfoTableViewCell.h"
// Utilities
#import "UIAlertController+ContactList.h"

@interface ContactListViewController()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    ABAddressBookRef addressBook;
    BOOL isSearching;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *contactPersonsArray;
@property (strong, nonatomic) NSMutableArray *filteredContactPersonsArray;
@end

@implementation ContactListViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupDataArrays];
    [self setupTableView];
    [self registerCells];

    // create address book
    CFErrorRef error = nil;
    addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    // check error -> if no error, check authorization status
    if (error)
    {
        NSError *mError = (__bridge_transfer NSError *)error;
        [self showAddressbookError:mError];
    }
    else
    {
        [self checkAuthorizationStatus];
    }
}

-(void)dealloc
{
    // release from memory
    CFRelease(addressBook);
}


#pragma mark - Permissions

// Checks the user's address book permission status
- (void)checkAuthorizationStatus
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
    {
        // user denied autorization
        [self showAccessDeniedMessage];
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
    {
        // user under parental control
        [self showPermissionError];
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        // undetermined, ask for permission
        __weak typeof (self) weakself = self;
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                // encountered error
                if (error)
                {
                    NSError *mError = (__bridge_transfer NSError *)error;
                    [weakself showAddressbookError:mError];
                    CFRelease(error);
                    return;
                }
                
                // only fetch contacts if permission granted
                if (granted)
                {
                    [weakself fetchContacts];
                    [weakself.tableView reloadData];
                }
                else
                { [weakself showAccessDeniedMessage]; }
                
            });
            
        });
    }
    else
    {
        // authorized
        [self fetchContacts];
    }
}


#pragma mark - Contact Data

// Fetches a list of the user's contacts
- (void)fetchContacts
{
    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    NSArray *records = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByLastName);
    [self populateContacts:records];
    
    CFRelease(source);
}

- (void)searchContacts:(NSString *)searchString
{
    // frist name or last name containing search string
    NSPredicate * firstNamePredicate = [NSPredicate predicateWithFormat:@"firstName contains %@", searchString];
    NSPredicate * lastNamePredicate = [NSPredicate predicateWithFormat:@"lastName contains %@", searchString];
    NSPredicate *namePredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[firstNamePredicate, lastNamePredicate]];
    
    self.filteredContactPersonsArray = [NSMutableArray arrayWithArray:[self.contactPersonsArray filteredArrayUsingPredicate:namePredicate]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return count depending on search state
    return isSearching ? self.filteredContactPersonsArray.count : self.contactPersonsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // identifier
    NSString *identifier = [ContactInfoTableViewCell cellIdentifier];
    ContactInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    id contactPerson;
    
    if (isSearching)
    {
        // get filtered data
        if (indexPath.row < self.filteredContactPersonsArray.count)
        { contactPerson = self.filteredContactPersonsArray[indexPath.row]; }
    }
    else if (indexPath.row < self.contactPersonsArray.count)
    {
        // get original data
        contactPerson = self.contactPersonsArray[indexPath.row];
    }
    
    // set up cell with person's info
    if ([contactPerson isKindOfClass:[ContactPerson class]])
    {
        [cell tableView:tableView setupCellWithObject:contactPerson];
    }
    
    return cell;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    // index titles -> alphabet A-Z
    NSMutableArray *alphabet = [NSMutableArray array];
    
    for (char current = 'a'; current <= 'z'; current++)
    {
        [alphabet addObject:[NSString stringWithFormat:@"%c", current]];
    }
    
    return alphabet;
}

#pragma mark - Helper Functions: Initialization

- (void)setupDataArrays
{
    self.contactPersonsArray = [NSMutableArray array];
    self.filteredContactPersonsArray = [NSMutableArray array];
}

- (void)setupTableView
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
 
    self.searchBar.placeholder = NSLocalizedString(@"Search", @"Search");
    isSearching = NO;
}

- (void)registerCells
{
    [ContactInfoTableViewCell registerCellForTableView:self.tableView];
}


#pragma mark - Helper Functions: Utilities

// Populates person objects from contact records
- (void)populateContacts:(NSArray *)contactRecords
{
    for (int i = 0; i < contactRecords.count; i++)
    {
        // get the recordref and initialize a person obj
        ABRecordRef record = (__bridge ABRecordRef)contactRecords[i];
        ContactPerson *person = [[ContactPerson alloc] init];
        
        // populate person obj with first and last name, phone number
        person.firstName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
        person.lastName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
        
        // phone number
        ABMultiValueRef phones = ABRecordCopyValue(record, kABPersonPhoneProperty);
        CFIndex index = ABMultiValueGetIndexForIdentifier(phones, 0);
        person.phoneNumber = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, index);
        CFRelease(phones);
        
        // profile pic
        NSData *imageData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail);
        if (imageData != nil)
        { person.profileImage = [[UIImage alloc] initWithData:imageData]; }
        
        // add person and release recordref
        [self.contactPersonsArray addObject:person];
        CFRelease(record);
    }
}


#pragma mark - Helper Functions: Alerts

// Show user denied access message
- (void)showAccessDeniedMessage
{
    NSString *message = NSLocalizedString(@"Access denied. Don't worry, you can go to settings later to grant access again.", @"Access denied message");
    
    UIAlertController *alertController = [UIAlertController alertWithMessage:message];
    [self presentViewController:alertController animated:YES completion:nil];
}

// Show permission error
- (void)showPermissionError
{
    NSString *message = NSLocalizedString(@"Permission denied.", @"Permission denied");
    
    UIAlertController *alertController = [UIAlertController alertWithMessage:message];
    [self presentViewController:alertController animated:YES completion:nil];
}

// An error has occurred while checking permissions
- (void)showAddressbookError:(NSError *)error
{
    NSString *message = error.localizedDescription;
    
    // use failure reason if possible
    if (error.localizedFailureReason != nil )
    { message = error.localizedFailureReason; }
    
    // show error message alert
    UIAlertController *alert = [UIAlertController alertWithMessage:message];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Orientation 

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text != nil && searchBar.text.length > 0)
    { [self searchContacts:searchBar.text]; }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearching = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // clear old data
    [self.filteredContactPersonsArray removeAllObjects];
    
    if ([searchText length] > 0)
    {
        // current searching
        isSearching = YES;
        [self searchContacts:searchText];
    }
    else
    {
        isSearching = NO;
    }
    
    [self.tableView reloadData];
}

@end
