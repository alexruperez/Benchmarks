//
//  ARBenchmarkSet.m
//  Benchmarks
//
//  Created by Alejandro Rupérez on 16/09/14.
//  Copyright (c) 2014 alexruperez. All rights reserved.
//

#import "ARBenchmarkSet.h"

@interface ARBenchmarkSet ()

@property (strong, nonatomic) NSMutableArray *mutableBenchmarks;

@end

@implementation ARBenchmarkSet

+ (instancetype)benchmarkSetWithBenchmarks:(NSArray *)benchmarks
{
    return [self.alloc initWithBenchmarks:benchmarks];
}

- (instancetype)init
{
    return [self initWithBenchmarks:nil];
}

- (instancetype)initWithBenchmarks:(NSArray *)benchmarks
{
    self = [super init];
    if (self)
    {
        for (ARBenchmark *benchmark in benchmarks)
        {
            [self addBenchmark:benchmark];
        }
    }
    return self;
}

- (NSMutableArray *)mutableBenchmarks
{
    if (!_mutableBenchmarks)
    {
        _mutableBenchmarks = NSMutableArray.new;
    }

    return _mutableBenchmarks;
}

- (void)addBenchmark:(ARBenchmark *)benchmark
{
    if (benchmark && [benchmark isKindOfClass:ARBenchmark.class])
    {
        [self.mutableBenchmarks addObject:benchmark];
    }
}

- (void)removeBenchmark:(ARBenchmark *)benchmark
{
    if (benchmark)
    {
        [self.mutableBenchmarks removeObject:benchmark];
    }
}

- (NSUInteger)count
{
    return self.mutableBenchmarks.count;
}

- (ARBenchmark *)benchmark:(NSUInteger)index
{
    return self.mutableBenchmarks[index];
}

- (NSArray *)benchmarks
{
    return self.mutableBenchmarks.copy;
}

- (uint64_t)runAll:(size_t)iterations
{
    uint64_t total;
    for (ARBenchmark *benchmark in self.mutableBenchmarks)
    {
        total += [benchmark run:iterations];
    }
    [self analyzeResults];
    return total;
}

- (void)analyzeResults
{
    [self.mutableBenchmarks sortUsingComparator:^NSComparisonResult(ARBenchmark *benchmark1, ARBenchmark *benchmark2) {
        return [benchmark1.time compare:benchmark2.time];
    }];
    if (self.mutableBenchmarks.count)
    {
        ARBenchmark *winner = self.mutableBenchmarks.firstObject;
        if (winner && [winner isKindOfClass:ARBenchmark.class])
        {
            [self.mutableBenchmarks.firstObject setWinner:YES];
        }
        if (self.mutableBenchmarks.count > 1 && winner.time.doubleValue)
        {
            ARBenchmark *loser = self.mutableBenchmarks.lastObject;
            if (loser && [loser isKindOfClass:ARBenchmark.class])
            {
                winner.advantage = @(loser.time.doubleValue / winner.time.doubleValue);
                NSLog(@"%@ benchmark is %@", winner.name, winner.advantageText);
            }
        }
    }
}

@end
