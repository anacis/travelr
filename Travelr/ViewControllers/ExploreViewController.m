//
//  ExploreViewController.m
//  Travelr
//
//  Created by Ana Cismaru on 7/29/20.
//  Copyright © 2020 anacismaru. All rights reserved.
//

#import "ExploreViewController.h"
#import "PlaceListCell.h"
#import "LocationFeedController.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "ProfileViewController.h"
#import <MBProgressHUD.h>
#import "UserCell.h"

@interface ExploreViewController () <UITableViewDelegate, UITableViewDataSource, PlaceListCellDelegate, UISearchBarDelegate, UserCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray *exploreResults;
@property (strong, nonatomic) NSArray *searchResults;

@end

@implementation ExploreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];
    
    [self fetchExplore];
    
}

- (IBAction)logout:(id)sender {
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
    }
    
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"User is logged out");
            SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavController"];
            myDelegate.window.rootViewController = loginViewController;
        }
        else {
            NSLog(@"Error logging out: %@", error.localizedDescription);
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"listToLocationSegue"]) {
        LocationFeedController *locationFeed = [segue destinationViewController];
        locationFeed.placeList = sender;
    } else if ([segue.identifier isEqualToString:@"listToProfile"]) {
        ProfileViewController *destination = [segue destinationViewController];
        destination.user = sender;
        
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.searchResults == nil) {
        if (self.searchBar.selectedScopeButtonIndex == 0) {
            UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserCell"];
            //TODO: handle situation where user is fb user!
            cell.user = self.exploreResults[indexPath.row];
            cell.delegate = self;
            [cell setUpCell];
            return cell;
        } else {
            PlaceListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PlaceListCell"];
            cell.placeList = self.exploreResults[indexPath.row];
            cell.delegate = self;
            [cell setUpExploreCell];
            return cell;
        }
    } else if ((self.searchResults.count > 0) && [self.searchResults[0] isKindOfClass:[PlaceList class]]){
        PlaceListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PlaceListCell"];
        cell.placeList = self.searchResults[indexPath.row];
        cell.delegate = self;
        [cell setUpExploreCell];
        return cell;
    } else {
        UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        cell.user = self.searchResults[indexPath.row];
        cell.delegate = self;
        [cell setUpCell];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchResults == nil) {
        return self.exploreResults.count;
    } else {
        return self.searchResults.count;
    }
}

- (void)fetchExplore {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query;
    if (self.searchBar.selectedScopeButtonIndex == 0) {
        query = [PFUser query];
        [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    } else {
        query = [PFQuery queryWithClassName:@"PlaceList"];
        [query includeKey:@"placesUnsorted"];
        [query whereKey:@"author" notEqualTo:[PFUser currentUser]];
    }
    
    [query orderByDescending:@"updatedAt"];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (results != nil) {
            self.exploreResults = (NSMutableArray *)results;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)placeListCell:(nonnull PlaceListCell *)placeListCell didTap:(nonnull PlaceList *)placeList {
    [self performSegueWithIdentifier:@"listToLocationSegue" sender:placeList];
}

- (void)placeListCell:(PlaceListCell *) placeListCell didTapUsername: (PFUser *)user {
    [self performSegueWithIdentifier:@"listToProfile" sender:user];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        self.searchResults = nil;
        [self.tableView reloadData];
    } else {
        [self search:searchText];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchResults = nil;
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if (![self.searchBar.text isEqualToString:@""] || self.searchBar.text == nil) {
        [self search:self.searchBar.text];
    } else {
        [self fetchExplore];
    }
}

- (void)search:(NSString *)searchInput {
    PFQuery *query;
    if (self.searchBar.selectedScopeButtonIndex == 0) {
        PFQuery *usernames = [PFUser query];
        [usernames whereKey:@"username" containsString:searchInput]; //can't use matchesText for a user query so this will have to do, doesn't take into account capitalization
        PFQuery *names = [PFUser query];
        [names whereKey:@"name" containsString:searchInput];
        query = [PFQuery orQueryWithSubqueries:@[usernames,names]];
    } else if (self.searchBar.selectedScopeButtonIndex == 1) {
        query = [PFQuery queryWithClassName:@"PlaceList"];
        [query whereKey:@"name" matchesText:searchInput]; //matches text matches both uppercase and lowercase
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
      // results contains players with lots of wins or only a few wins.
        if (error == nil) {
            NSLog(@"Results: %@", results);
            self.searchResults = results;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error searching: %@", error.localizedDescription);
        }
    }];
}

- (void)UserCell:(UserCell *) userCell didTapUser: (PFUser *)user {
    NSLog(@"%@", user);
    [self performSegueWithIdentifier:@"listToProfile" sender:user];
}

@end
