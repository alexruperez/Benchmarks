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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) NSArray *benchmarks;

@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self runBenchmarks:self.navigationItem.rightBarButtonItem];
}

- (NSArray *)benchmarkNumber:(NSUInteger)number
{
    return self.benchmarks[number];
}

- (NSDictionary *)benchmarkNumber:(NSUInteger)number result:(NSUInteger)result
{
    return self.benchmarks[number][result];
}

- (IBAction)showSettings
{
    IASKAppSettingsViewController *settings = IASKAppSettingsViewController.new;
    settings.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:settings] animated:YES completion:nil];
}

- (IBAction)runBenchmarks:(UIBarButtonItem *)barButtonItem
{
    barButtonItem.enabled = NO;
    self.benchmarks = nil;
    [self.tableView reloadData];
    [NSOperationQueue.new addOperationWithBlock:^{
        self.benchmarks = ARBenchmarks.runBenchmarks;
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self.tableView reloadData];
            barButtonItem.enabled = YES;
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.benchmarks.count)
    {
        [self.activityIndicatorView stopAnimating];
    }
    else
    {
        [self.activityIndicatorView startAnimating];
    }

    return self.benchmarks.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self benchmarkNumber:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    [self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *benchmark = [self benchmarkNumber:indexPath.section result:indexPath.row];
    NSMutableString *detail = [[NSMutableString alloc] initWithFormat:@"Avg. Runtime: %llu ns", [benchmark[@"time"] unsignedLongLongValue]];
    if ([benchmark[@"winner"] boolValue])
    {
        cell.backgroundColor = UIColor.greenColor;
        double bonus = [benchmark[@"bonus"] doubleValue];
        if (bonus > 1)
        {
            [detail appendFormat:@" -> %.2fx faster!", bonus];
        }
        else
        {
            [detail appendFormat:@" -> %.2f%% faster!", bonus*100];
        }
    }
    else
    {
        cell.backgroundColor = UIColor.whiteColor;
    }
    cell.textLabel.text = benchmark[@"name"];
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
