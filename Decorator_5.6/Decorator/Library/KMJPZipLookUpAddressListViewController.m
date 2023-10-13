//
//  KMJPZipLookUpAddressListViewController.m
//  KMJPZipLookUp
//
//  Created by Kosuke Matsuda on 2013/04/23.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#import "KMJPZipLookUpAddressListViewController.h"

#define kAddressFont                    [UIFont boldSystemFontOfSize:16]

NSString *kKMJPZipLookUpAddressListDidSelectNotification = @"KMJPZipLookUpAddressListDidSelectNotification";
NSString *kKMJPZipLookUpAddressListResultsKey = @"KMJPZipLookUpAddressListResultsKey";

@interface KMJPZipLookUpAddressListViewController ()

@end

@implementation KMJPZipLookUpAddressListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.response.addresses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddressListCell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
    NSArray *addresses = self.response.addresses;
    KMJPZipLookUpAddress *address = addresses[indexPath.row];
    cell.textLabel.text = [address fullAddress];
    cell.textLabel.font = kAddressFont;
    cell.detailTextLabel.text = @"選択";
    cell.detailTextLabel.font = kAddressFont;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KMJPZipLookUpAddress *address = self.response.addresses[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:kKMJPZipLookUpAddressListDidSelectNotification
                                                        object:self
                                                      userInfo:@{kKMJPZipLookUpAddressListResultsKey: address}];
}

@end
