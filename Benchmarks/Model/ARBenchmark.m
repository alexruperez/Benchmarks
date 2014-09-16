//
//  ARBenchmark.m
//  Benchmarks
//
//  Created by Alejandro Rupérez on 16/09/14.
//  Copyright (c) 2014 alexruperez. All rights reserved.
//

#import "ARBenchmark.h"

uint64_t dispatch_benchmark(size_t count, void (^block)(void));

@implementation ARBenchmark

+ (instancetype)benchmarkWithName:(NSString *)name block:(ARBenchmarkBlock)block
{
    return [self.alloc initWithName:name block:block];
}

- (instancetype)init
{
    return [self initWithName:nil block:nil];
}

- (instancetype)initWithName:(NSString *)name block:(ARBenchmarkBlock)block
{
    self = [super init];
    if (self)
    {
        _name = name;
        _block = block;
    }
    return self;
}

- (uint64_t)run:(size_t)iterations
{
    self.winner = NO;
    NSLog(@"Running %@ benchmark. Iterations: %zu", self.name, iterations);
    _time = @(dispatch_benchmark(iterations, self.block));
    NSLog(@"Finished %@ benchmark. %@", self.name, self.timeText);
    return self.time.unsignedLongLongValue;
}

- (NSString *)timeText
{
    if (self.time)
    {
        return [NSString stringWithFormat:@"Avg. Runtime: %llu ns", self.time.unsignedLongLongValue];
    }

    return @"Avg. Runtime: Unknown";
}

- (NSString *)advantageText
{
    if (self.advantage)
    {
        double advantage = self.advantage.doubleValue;
        
        if (advantage < 2)
        {
            return [NSString stringWithFormat:@"%.2f%% faster!", (advantage-1)*100];
        }
        else
        {
            return [NSString stringWithFormat:@"%.2fx faster!", advantage];
        }
    }

    return @"unknown!";
}

@end
