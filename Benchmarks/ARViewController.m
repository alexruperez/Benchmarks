//
//  ARViewController.m
//  Benchmarks
//
//  Created by Alejandro Rupérez on 15/09/14.
//  Copyright (c) 2014 alexruperez. All rights reserved.
//

#import "ARViewController.h"

#import "IASKAppSettingsViewController.h"
#import "ARBenchmarks.h"

@interface ARViewController ()
<UITableViewDataSource, UITableViewDelegate, IASKSettingsDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *benchmarkSets;

@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self runBenchmarks];
}

- (ARBenchmarkSet *)benchmarkSet:(NSUInteger)set
{
    return self.benchmarkSets[set];
}

- (ARBenchmark *)benchmarkSet:(NSUInteger)set benchmark:(NSUInteger)benchmark
{
    return [[self benchmarkSet:set] benchmark:benchmark];
}

- (IBAction)showSettings
{
    IASKAppSettingsViewController *settings = IASKAppSettingsViewController.new;
    settings.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:settings] animated:YES completion:nil];
}

- (IBAction)runBenchmarks
{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
    [NSOperationQueue.new addOperationWithBlock:^{
        self.benchmarkSets = ARBenchmarks.runBenchmarks;
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self.tableView reloadData];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Run" style:UIBarButtonItemStyleBordered target:self action:@selector(runBenchmarks)];
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.benchmarkSets.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self benchmarkSet:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    [self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARBenchmark *benchmark = [self benchmarkSet:indexPath.section benchmark:indexPath.row];
    NSMutableString *detail = [[NSMutableString alloc] initWithString:benchmark.timeText];
    if (benchmark.winner)
    {
        cell.backgroundColor = [UIColor colorWithRed:46.0f/255.0f green:204.0f/255.0f blue:113.0f/255.0f alpha:1.0f];
        [detail appendString:@" -> "];
        [detail appendString:benchmark.advantageText];
    }
    else
    {
        cell.backgroundColor = UIColor.whiteColor;
    }
    cell.textLabel.text = benchmark.name;
    cell.detailTextLabel.text = detail;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    [sender dismissViewControllerAnimated:YES completion:nil];
}

@end
