//
//  ARBenchmarks.m
//  Benchmarks
//
//  Created by Alejandro Rupérez on 15/09/14.
//  Copyright (c) 2014 alexruperez. All rights reserved.
//

#import "ARBenchmarks.h"

@interface NSObject (runBlock)

- (void)runBlock:(void (^)(void))block;

@end

@implementation NSObject (runBlock)

- (void)runBlock:(void (^)(void))block
{
    block();
}

@end

@implementation ARBenchmarks

+ (void)load
{
    [NSUserDefaults.standardUserDefaults registerDefaults:@{@"iterations_preference": @100, @"sample_preference": @100, @"content_preference": @"", }];
}

+ (NSUserDefaults *)userDefaults
{
    return NSUserDefaults.standardUserDefaults;
}

+ (size_t)iterations
{
    return [[self.userDefaults objectForKey:@"iterations_preference"] longLongValue];
}

+ (size_t)sample
{
    return [[self.userDefaults objectForKey:@"sample_preference"] longLongValue];
}

+ (NSString *)content
{
    return [self.userDefaults objectForKey:@"content_preference"];
}

+ (NSArray *)runBenchmarks
{
    NSArray *benchmarks = @[self.mutableArrayBenchmarkSet, self.arrayBenchmarkSet, self.blockBenchmarkSet];

    for (ARBenchmarkSet *benchmarkSet in benchmarks)
    {
        [benchmarkSet runAll:self.iterations];
    }

    return benchmarks;
}

+ (ARBenchmarkSet *)mutableArrayBenchmarkSet
{
    return [ARBenchmarkSet benchmarkSetWithBenchmarks:@[[ARBenchmark benchmarkWithName:@"[[NSMutableArray array] addObject:]" block:^{
        @autoreleasepool {
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (size_t i = 0; i < self.sample; i++)
            {
                [mutableArray addObject:self.content];
            }
        }
    }], [ARBenchmark benchmarkWithName:@"[[NSMutableArray arrayWithCapacity] addObject:]" block:^{
        @autoreleasepool {
            NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:self.sample];
            for (size_t i = 0; i < self.sample; i++)
            {
                [mutableArray addObject:self.content];
            }
        }
    }]]];
}

+ (ARBenchmarkSet *)arrayBenchmarkSet
{
    NSMutableArray *sampleArray = [NSMutableArray arrayWithCapacity:self.sample];
    for (size_t i = 0; i < self.sample; i++)
    {
        [sampleArray addObject:self.content];
    }
    return [ARBenchmarkSet benchmarkSetWithBenchmarks:@[[ARBenchmark benchmarkWithName:@"for (i = 0; i < array.count; i++) [array[i] method]" block:^{
        @autoreleasepool {
            for (size_t i = 0; i < sampleArray.count; i++)
            {
                [sampleArray[i] description];
            }
        }
    }], [ARBenchmark benchmarkWithName:@"for (id object in array) [object method]" block:^{
        @autoreleasepool {
            for (id object in sampleArray)
            {
                [object description];
            }
        }
    }]]];
}

+ (ARBenchmarkSet *)blockBenchmarkSet
{
    return [ARBenchmarkSet benchmarkSetWithBenchmarks:@[[ARBenchmark benchmarkWithName:@"[object method]" block:^{
        @autoreleasepool {
            NSObject *object = NSObject.new;
            [object description];
        }
    }], [ARBenchmark benchmarkWithName:@"[object runBlock:^{[object method]}]" block:^{
        @autoreleasepool {
            NSObject *object = NSObject.new;
            [object runBlock:^{
                [object description];
            }];
        }
    }]]];
}

@end
