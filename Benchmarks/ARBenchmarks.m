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
    [NSUserDefaults.standardUserDefaults registerDefaults:@{@"iterations_preference": @"100", @"sample_preference": @"100", @"content_preference": @"", }];
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

+ (NSArray *)sampleArray
{
    NSInteger sample = self.sample;
    NSString *content = self.content;
    NSMutableArray *sampleArray = [NSMutableArray arrayWithCapacity:sample];
    for (size_t i = 0; i < sample; i++)
    {
        [sampleArray addObject:content];
    }
    return sampleArray.copy;
}

+ (NSArray *)runBenchmarks
{
    NSArray *benchmarks = @[self.mutableArrayBenchmarkSet, self.arrayBenchmarkSet, self.arraySortingBenchmarkSet];

    for (ARBenchmarkSet *benchmarkSet in benchmarks)
    {
        [benchmarkSet runAll:self.iterations];
    }

    return benchmarks;
}

#pragma mark - Benchmarks

+ (ARBenchmarkSet *)mutableArrayBenchmarkSet
{
    size_t sample = self.sample;
    NSString *content = self.content;
    return [ARBenchmarkSet benchmarkSetWithBenchmarks:@[[ARBenchmark benchmarkWithName:@"[[NSMutableArray array] addObject:]" block:^{
        @autoreleasepool {
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (size_t i = 0; i < sample; i++)
            {
                [mutableArray addObject:content];
            }
        }
    }], [ARBenchmark benchmarkWithName:@"[[NSMutableArray arrayWithCapacity] addObject:]" block:^{
        @autoreleasepool {
            NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:sample];
            for (size_t i = 0; i < sample; i++)
            {
                [mutableArray addObject:content];
            }
        }
    }]]];
}

+ (ARBenchmarkSet *)arrayBenchmarkSet
{
    NSArray *sampleArray = self.sampleArray;
    return [ARBenchmarkSet benchmarkSetWithBenchmarks:@[[ARBenchmark benchmarkWithName:@"for (i = 0; i < NSArray.count; i++)" block:^{
        @autoreleasepool {
            for (size_t i = 0; i < sampleArray.count; i++)
            {
                [sampleArray[i] description];
            }
        }
    }], [ARBenchmark benchmarkWithName:@"for (id object in NSArray)" block:^{
        @autoreleasepool {
            for (id object in sampleArray)
            {
                [object description];
            }
        }
    }], [ARBenchmark benchmarkWithName:@"[NSArray enumerateObjectsUsingBlock:]" block:^{
        @autoreleasepool {
            [sampleArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                [object description];
            }];
        }
    }], [ARBenchmark benchmarkWithName:@"[[NSArray objectEnumerator] nextObject]" block:^{
        @autoreleasepool {
            NSEnumerator *enumerator = [sampleArray objectEnumerator];
            id object;
            while (object = [enumerator nextObject])
            {
                [object description];
            }
        }
    }]]];
}

+ (ARBenchmarkSet *)arraySortingBenchmarkSet
{
    NSArray *sampleArray = self.sampleArray;
    return [ARBenchmarkSet benchmarkSetWithBenchmarks:@[[ARBenchmark benchmarkWithName:@"[NSArray sortedArrayUsingDescriptors:]" block:^{
        @autoreleasepool {
            [sampleArray sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"description" ascending:YES]]];
        }
    }], [ARBenchmark benchmarkWithName:@"[NSArray sortedArrayUsingComparator:]" block:^{
        @autoreleasepool {
            [sampleArray sortedArrayUsingComparator:^NSComparisonResult(NSObject *a, NSObject *b) {
                return [a.description compare:b.description];
            }];
        }
    }], [ARBenchmark benchmarkWithName:@"[NSArray sortedArrayUsingSelector:]" block:^{
        @autoreleasepool {
            [sampleArray sortedArrayUsingSelector:@selector(compare:)];
        }
    }]]];
}

@end
