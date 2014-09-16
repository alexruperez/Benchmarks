//
//  ARBenchmarkSet.h
//  Benchmarks
//
//  Created by Alejandro Rupérez on 16/09/14.
//  Copyright (c) 2014 alexruperez. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARBenchmark.h"

@interface ARBenchmarkSet : NSObject

@property (strong, nonatomic, readonly) NSArray *benchmarks;

+ (instancetype)benchmarkSetWithBenchmarks:(NSArray *)benchmarks;

- (void)addBenchmark:(ARBenchmark *)benchmark;

- (void)removeBenchmark:(ARBenchmark *)benchmark;

- (NSUInteger)count;

- (ARBenchmark *)benchmark:(NSUInteger)index;

- (uint64_t)runAll:(size_t)iterations;

@end
