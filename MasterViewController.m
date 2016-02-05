//
//  MasterViewController.m
//  movieApp
//
//  Created by Adis Cehajic on 02/02/16.
//  Copyright © 2016 EminaHuskic. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <RestKit/RestKit.h>
#import "MOVMovie.h"
#import "MOVMovieTableViewCell.h"
@interface MasterViewController ()

@property NSMutableArray *objects;
@property (strong, nonatomic) NSArray *movies;
@property (nonatomic, strong) NSMutableArray *searchResult;
@property (nonatomic, strong)  DetailViewController *controller;

@end

@implementation MasterViewController




- (void)loadMovies
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.themoviedb.org"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    RKObjectMapping* movieMapping = [RKObjectMapping mappingForClass:[MOVMovie class]];
    [movieMapping addAttributeMappingsFromDictionary:@{
                                                       @"title": @"title",
                                                   //    @"id": @"id",
                                                       @"backdrop_path": @"backdropPath",
                                                       @"belongs_to_collection":@"belongsToCollection",
                                                       @"adult": @"adult",
                                                       @"genres": @"genres",
                                                       @"homepage": @"homep,age",
                                                       @"original_language": @"originalLanguage",
                                                       @"overview": @"overview",
                                                       @"imdb_id": @"imdbID",
                                                       @"original_title": @"originalTitle",
                                                       @"poster_path": @"posterPath",
                                                       @"production_companies": @"productionCompanies",
                                                       @"popularity": @"popularity",
                                                       @"production_countries": @"productionCountries",
                                                       @"release_date": @"releaseDate",
                                                       @"revenue": @"revenue",
                                                       @"spoken_languages": @"spokenLanguages",
                                                       @"status": @"status",
                                                       @"tagline": @"tagline",
                                                       @"title": @"title",
                                                       @"video": @"video",
                                                       
                                                       @"vote_average": @"voteAverage"
                                                      
                                                       }];
     NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:movieMapping method:RKRequestMethodAny pathPattern:@"/3/movie/top_rated" keyPath:@"results" statusCodes:statusCodes];
    
    
    RKObjectManager *sharedManager = [[RKObjectManager alloc] initWithHTTPClient:client];    [sharedManager addResponseDescriptorsFromArray:@[responseDescriptor]];
    [ sharedManager getObjectsAtPath:@"/3/movie/top_rated" parameters:@{@"api_key" : @"41965971728f5fe48c3a8db464bd3825"}
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  self.movies = mappingResult.array;
                                                 self.objects = [NSMutableArray arrayWithArray:self.movies];
                                                  [self.tableView reloadData];
    }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                              }];
  
    
    
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    self.searchResult = [self.objects filteredArrayUsingPredicate:resultPredicate];
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [ self filterContentForSearchText:searchString
scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
       objectAtIndex:[self.searchDisplayController.searchBar
                      selectedScopeButtonIndex]]];
    
    
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
  if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
   }
    
     //Search
    self.searchResult = [NSMutableArray arrayWithCapacity:[self.objects count]];
    
    //DetailView controller
    if(!controller)
         controller = [[DetailViewController alloc] init];
    
    //RESTKIT
    [self loadMovies];
}

- (void)viewWillAppear:(BOOL)animated {
    //self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

@synthesize controller;
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
   controller = (DetailViewController *)[segue destinationViewController] ;
        if (self.searchDisplayController.active) {
            NSLog(@"Search Display Controller");
            controller.detailItem = [self.searchResult objectAtIndex: self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow.row];
        } else {
            NSLog(@"tututu Default Display Controller");
          controller.detailItem = [self.objects objectAtIndex: self.tableView.indexPathForSelectedRow.row];
        }
        
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
      }

#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResult count];
    }
    else
    {
        return [self.objects count];
    }
  //  return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    MOVMovieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[MOVMovieTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    MOVMovie *mov;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
         mov = [self.searchResult objectAtIndex:indexPath.row];
       }
    else
    {
        mov = [self.objects objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = [mov title];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[mov releaseDate]];
    
    cell.yearLabel.text=[NSString stringWithFormat:@"%d",[components year]];    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        controller.detailItem = [self.searchResult objectAtIndex: self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow.row];
            [self performSegueWithIdentifier: @"showDetail" sender:self];
        
        NSLog(@"Search Display Controller");
    } else {
        
       controller.detailItem = [self.objects objectAtIndex: indexPath.row];
        
        [self performSegueWithIdentifier: @"showDetail" sender: self];
        
        NSLog(@"Default Display Controller");
    }
     controller.navigationItem.leftItemsSupplementBackButton = YES;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
