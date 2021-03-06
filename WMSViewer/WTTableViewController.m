//
//  WTTableViewController.m
//  Weather
//
//  Created by Scott on 26/01/2013.
//  Updated by Joshua Greene 16/12/2013.
//
//  Copyright (c) 2013 Scott Sherwood. All rights reserved.
//

#import "WTTableViewController.h"
#import "WTResourceTableViewController.h"
#import "AFHTTPRequestOperation.h"
//static NSString * const urlprefix = @"https://catalog.data.gov";
static NSString * const urlprefix = @"https://data.noaa.gov";
//static NSString * const urlprefix = @"http://data.gov.uk";

@interface WTTableViewController ()<UISearchResultsUpdating>
@property int numItems;

@property (nonatomic) NSMutableArray *results;
@property (nonatomic) NSMutableArray *tags;
@end

@implementation WTTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.numItems = 0;
        self.results = nil;
        self.tags=nil;
        // Custom initialization
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder");
    
    self = [super initWithCoder: aDecoder];
    if (self)
    {
        self.numItems = 0;
        self.results = nil;
        self.tags=nil;
 
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.ckan==nil)
        self.ckan = urlprefix;
    
   // self.navigationController.toolbarHidden = NO;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"View Will Appear");
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"WeatherDetailSegue"]){
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.section==0)
        {
        
        }
        else
        {
        WTResourceTableViewController *wac = (WTResourceTableViewController *)segue.destinationViewController;
        
        NSDictionary *w;
        w = self.results[indexPath.row];
        wac.result = w;
        }
    }
}

#pragma mark - Actions

- (IBAction)clear:(id)sender
{
    self.title = @"";
    [self.tableView reloadData];
}

- (IBAction)closeTapped:(id)sender
{
    NSLog(@"close Tapped");
    [[self presentingViewController] dismissViewControllerAnimated: YES completion:nil];
}
- (IBAction)jsonTapped:(id)sender
{
}

- (IBAction)plistTapped:(id)sender
{
    
}

- (IBAction)xmlTapped:(id)sender
{
    
}

- (IBAction)clientTapped:(id)sender
{
    
}

- (IBAction)apiTapped:(id)sender
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tags!=nil && [self.tags count])
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"number of rows, section: %d",section);

    switch(section)
    {
        case 0:
        if(!self.tags)
            return 0;
        NSLog(@"tags rows: %d",[self.tags count]);
        return [self.tags count];

        break;
        case 1:
        if(!self.results)
            return 0;
        NSLog(@"results rows: %d",[self.results count]);
        return [self.results count];
        break;
    }

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        return @"Tag Facets";
        break;
        case 1:
        return @"Data Sets";
        break;
    }
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WeatherCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.section) {

        case 0:
        {
            NSDictionary *dict = self.tags[indexPath.row];
            NSString *label = [NSString stringWithFormat:@"%@ (%@)", dict[@"display_name"],dict[@"count"] ];
            cell.textLabel.text = label;
        }
        break;
        case 1:
        {
            NSDictionary *dict = self.results[indexPath.row];
           cell.textLabel.text = dict[@"title"];
        }
       break;
    }
    
    

    return cell;
}


#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    // we have to think about what to do with section 0
    if (indexPath.section==0)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        [self performSegueWithIdentifier:@"WeatherDetailSegue" sender:cell];

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - JMStatefulTableViewControllerDelegate
- (void) statefulTableViewControllerWillBeginInitialLoading:(JMStatefulTableViewController *)vc completionBlock:(void (^)())success failure:(void (^)(NSError *error))failure {
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSLog(@"initial loading..");
        // 1
        NSString *string = [NSString stringWithFormat:@"%@/api/3/action/package_search?q=res_format:WMS&rows=100&facet=true&facet.field=tags",self.ckan];
        NSURL *url = [NSURL URLWithString:string];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // 3
            
            self.results = [NSMutableArray arrayWithArray:responseObject[@"result"][@"results"]];
            
            self.tags = [NSMutableArray arrayWithArray:responseObject[@"result"][@"search_facets"][@"tags"][@"items"]];


//            self.tags = [self.tags sortedArrayUsingSelector:@selector(???)];
            self.title = @"JSON Retrieved";
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // 4
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
        
        // 5
        [operation start];
        
    });
}

- (void) statefulTableViewControllerWillBeginLoadingFromPullToRefresh:(JMStatefulTableViewController *)vc completionBlock:(void (^)(NSArray *indexPathsToInsert))success failure:(void (^)(NSError *error))failure {
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSLog(@"pull to refresh..");
        // 1
        NSString *string = [NSString stringWithFormat:@"%@/api/3/action/package_search?q=res_format:WMS&rows=100&facet=true&facet.field=tags",_ckan];
        NSURL *url = [NSURL URLWithString:string];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // 3
            [self.results arrayByAddingObjectsFromArray: responseObject[@"result"][@"results"]];
            [self.tags arrayByAddingObjectsFromArray: responseObject[@"result"][@"search_facets"][@"tags"][@"items"]];

            self.title = @"JSON Retrieved";
            //[self.tableView reloadData];
            
                NSMutableArray *a = [NSMutableArray array];
                
                for(NSInteger i = 0; i < [self.results count]; i++) {
                    [a addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    success([NSArray arrayWithArray:a]);
                });
            
            
       
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // 4
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
         [operation start];

    });
}


- (void) statefulTableViewControllerWillBeginLoadingNextPage:(JMStatefulTableViewController *)vc completionBlock:(void (^)())success failure:(void (^)(NSError *))failure {
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        self.numItems+=100;
NSLog(@"loading next page.. %d",self.numItems);

        // 1
        NSString *string = [NSString stringWithFormat:@"%@/api/3/action/package_search?q=res_format:WMS&start=%d&rows=100&facet=true&facet.field=tags",_ckan,self.numItems];
        NSURL *url = [NSURL URLWithString:string];
        NSLog(@"loading next page.. %@",string);

        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // 3

            [self.results addObjectsFromArray: responseObject[@"result"][@"results"]];
            [self.tags addObjectsFromArray: responseObject[@"result"][@"search_facets"][@"tags"][@"items"]];
            NSLog(@"arows: %d",[self.results count]);

            self.title = @"JSON Retrieved";
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // 4
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
        
        // 5
        [operation start];
        
    });
}

/* is there more content? */

- (BOOL) statefulTableViewControllerShouldBeginLoadingNextPage:(JMStatefulTableViewController *)vc {
    NSLog(@"should begin next page..");
   return true;
}


- (BOOL) statefulTableViewControllerShouldPullToRefresh:(JMStatefulTableViewController *)vc
{
    return false;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSLog(@"search text: %@",searchText);
}

@end