//
//  ARBenchmarks.m
//  Benchmarks
//
//  Created by Alejandro Rupérez on 15/09/14.
//  Copyright (c) 2014 alexruperez. All rights reserved.
//

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

#import "ARBenchmarks.h"

@interface ARObject : NSObject

- (void)method;
- (void)runBlock:(void (^)(void))block;

@end

@implementation ARObject

- (void)method
{
}

- (void)runBlock:(void (^)(void))block
{
    block();
}

@end

@implementation ARBenchmarks

+ (size_t)iterations
{
    return [[NSUserDefaults.standardUserDefaults objectForKey:@"iterations_preference"] longLongValue];
}

+ (size_t)sample
{
    return [[NSUserDefaults.standardUserDefaults objectForKey:@"sample_preference"] longLongValue];
}

+ (NSString *)content
{
    return [NSUserDefaults.standardUserDefaults objectForKey:@"content_preference"];
}

+ (NSArray *)runBenchmarks
{
    NSMutableArray *benchmarks = NSMutableArray.new;

    [benchmarks addObject:self.mutableArrayBenchmarks];
    [benchmarks addObject:self.arrayBenchmarks];
    [benchmarks addObject:self.blockBenchmarks];

    return benchmarks;
}

+ (NSArray *)mutableArrayBenchmarks
{
    NSMutableDictionary *arrayBenchmark = NSMutableDictionary.new;
    NSMutableDictionary *arrayWithCapacityBenchmark = NSMutableDictionary.new;

    arrayBenchmark[@"name"] = @"[[NSMutableArray array] addObject:]";
    arrayWithCapacityBenchmark[@"name"] = @"[[NSMutableArray arrayWithCapacity] addObject:]";

    NSLog(@"Running %@ benchmark. Iterations: %zu Sample: %zu Content: \"%@\"", arrayBenchmark[@"name"], self.iterations, self.sample, self.content);

    uint64_t arrayBenchmarkTime = dispatch_benchmark(self.iterations, ^{
        @autoreleasepool {
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (size_t i = 0; i < self.sample; i++)
            {
                [mutableArray addObject:self.content];
            }
        }
    });

    NSLog(@"Finished %@ benchmark. Avg. Runtime: %llu ns", arrayBenchmark[@"name"], arrayBenchmarkTime);

    NSLog(@"Running %@ benchmark. Iterations: %zu Sample: %zu Content: \"%@\"", arrayWithCapacityBenchmark[@"name"], self.iterations, self.sample, self.content);

    uint64_t arrayWithCapacityBenchmarkTime = dispatch_benchmark(self.iterations, ^{
        @autoreleasepool {
            NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:self.sample];
            for (size_t i = 0; i < self.sample; i++)
            {
                [mutableArray addObject:self.content];
            }
        }
    });

    NSLog(@"Finished %@ benchmark. Avg. Runtime: %llu ns", arrayWithCapacityBenchmark[@"name"], arrayWithCapacityBenchmarkTime);

    arrayBenchmark[@"time"] = @(arrayBenchmarkTime);
    arrayWithCapacityBenchmark[@"time"] = @(arrayWithCapacityBenchmarkTime);

    if (arrayBenchmarkTime < arrayWithCapacityBenchmarkTime)
    {
        arrayBenchmark[@"winner"] = @YES;
        arrayWithCapacityBenchmark[@"winner"] = @NO;
        arrayBenchmark[@"bonus"] = arrayBenchmarkTime ? @(((double)arrayWithCapacityBenchmarkTime/(double)arrayBenchmarkTime) - 1) : @0;
    }
    else if (arrayWithCapacityBenchmarkTime < arrayBenchmarkTime)
    {
        arrayWithCapacityBenchmark[@"winner"] = @YES;
        arrayBenchmark[@"winner"] = @NO;
        arrayWithCapacityBenchmark[@"bonus"] = arrayWithCapacityBenchmarkTime ? @(((double)arrayBenchmarkTime/(double)arrayWithCapacityBenchmarkTime) - 1) : @0;
    }
    else
    {
        arrayBenchmark[@"winner"] = @NO;
        arrayWithCapacityBenchmark[@"winner"] = @NO;
    }

    return @[arrayBenchmark, arrayWithCapacityBenchmark];
}

+ (NSArray *)arrayBenchmarks
{
    NSMutableDictionary *arrayForBenchmark = NSMutableDictionary.new;
    NSMutableDictionary *arrayForInBenchmark = NSMutableDictionary.new;

    arrayForBenchmark[@"name"] = @"for (i = 0; i < array.count; i++) [array[i] description];";
    arrayForInBenchmark[@"name"] = @"for (id object in array) [object description]";

    NSLog(@"Running %@ benchmark. Iterations: %zu Sample: %zu Content: \"%@\"", arrayForBenchmark[@"name"], self.iterations, self.sample, self.content);

    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:self.sample];
    for (size_t i = 0; i < self.sample; i++)
    {
        [mutableArray addObject:self.content];
    }

    uint64_t arrayForBenchmarkTime = dispatch_benchmark(self.iterations, ^{
        @autoreleasepool {
            for (size_t i = 0; i < mutableArray.count; i++)
            {
                [mutableArray[i] description];
            }
        }
    });

    NSLog(@"Finished %@ benchmark. Avg. Runtime: %llu ns", arrayForBenchmark[@"name"], arrayForBenchmarkTime);

    NSLog(@"Running %@ benchmark. Iterations: %zu Sample: %zu Content: \"%@\"", arrayForInBenchmark[@"name"], self.iterations, self.sample, self.content);

    uint64_t arrayForInBenchmarkTime = dispatch_benchmark(self.iterations, ^{
        @autoreleasepool {
            for (id object in mutableArray)
            {
                [object description];
            }
        }
    });

    NSLog(@"Finished %@ benchmark. Avg. Runtime: %llu ns", arrayForInBenchmark[@"name"], arrayForInBenchmarkTime);

    arrayForBenchmark[@"time"] = @(arrayForBenchmarkTime);
    arrayForInBenchmark[@"time"] = @(arrayForInBenchmarkTime);

    if (arrayForBenchmarkTime < arrayForInBenchmarkTime)
    {
        arrayForBenchmark[@"winner"] = @YES;
        arrayForInBenchmark[@"winner"] = @NO;
        arrayForBenchmark[@"bonus"] = arrayForBenchmarkTime ? @(((double)arrayForInBenchmarkTime/(double)arrayForBenchmarkTime) - 1) : @0;
    }
    else if (arrayForInBenchmarkTime < arrayForBenchmarkTime)
    {
        arrayForInBenchmark[@"winner"] = @YES;
        arrayForBenchmark[@"winner"] = @NO;
        arrayForInBenchmark[@"bonus"] = arrayForInBenchmarkTime ? @(((double)arrayForBenchmarkTime/(double)arrayForInBenchmarkTime) - 1) : @0;
    }
    else
    {
        arrayForBenchmark[@"winner"] = @NO;
        arrayForInBenchmark[@"winner"] = @NO;
    }

    return @[arrayForBenchmark, arrayForInBenchmark];
}

+ (NSArray *)blockBenchmarks
{
    NSMutableDictionary *methodBenchmark = NSMutableDictionary.new;
    NSMutableDictionary *blockBenchmark = NSMutableDictionary.new;

    methodBenchmark[@"name"] = @"[instance method]";
    blockBenchmark[@"name"] = @"[instance runBlock:^{[instance method]}]";

    NSLog(@"Running %@ benchmark. Iterations: %zu", methodBenchmark[@"name"], self.iterations);

    uint64_t methodBenchmarkTime = dispatch_benchmark(self.iterations, ^{
        @autoreleasepool {
            ARObject *instance = [ARObject new];
            [instance method];
        }
    });

    NSLog(@"Finished %@ benchmark. Avg. Runtime: %llu ns", methodBenchmark[@"name"], methodBenchmarkTime);

    NSLog(@"Running %@ benchmark. Iterations: %zu", blockBenchmark[@"name"], self.iterations);

    uint64_t blockBenchmarkTime = dispatch_benchmark(self.iterations, ^{
        @autoreleasepool {
            ARObject *instance = [ARObject new];
            [instance runBlock:^{
                [instance method];
            }];
        }
    });

    NSLog(@"Finished %@ benchmark. Avg. Runtime: %llu ns", blockBenchmark[@"name"], blockBenchmarkTime);

    methodBenchmark[@"time"] = @(methodBenchmarkTime);
    blockBenchmark[@"time"] = @(blockBenchmarkTime);

    if (methodBenchmarkTime < blockBenchmarkTime)
    {
        methodBenchmark[@"winner"] = @YES;
        blockBenchmark[@"winner"] = @NO;
        methodBenchmark[@"bonus"] = methodBenchmarkTime ? @(((double)blockBenchmarkTime/(double)methodBenchmarkTime) - 1) : @0;
    }
    else if (blockBenchmarkTime < methodBenchmarkTime)
    {
        blockBenchmark[@"winner"] = @YES;
        methodBenchmark[@"winner"] = @NO;
        blockBenchmark[@"bonus"] = blockBenchmarkTime ? @(((double)methodBenchmarkTime/(double)blockBenchmarkTime) - 1) : @0;
    }
    else
    {
        methodBenchmark[@"winner"] = @NO;
        blockBenchmark[@"winner"] = @NO;
    }

    return @[methodBenchmark, blockBenchmark];
}

@end
