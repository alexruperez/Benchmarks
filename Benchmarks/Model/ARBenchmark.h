//
//  ARBenchmark.h
//  Benchmarks
//
//  Created by Alejandro Rupérez on 16/09/14.
//  Copyright (c) 2014 alexruperez. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ARBenchmarkBlock)(void);

@interface ARBenchmark : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) ARBenchmarkBlock block;
@property (strong, nonatomic, readonly) NSNumber *time;
@property (strong, nonatomic, readonly) NSString *timeText;
@property (assign, nonatomic) BOOL winner;
@property (strong, nonatomic) NSNumber *advantage;
@property (strong, nonatomic, readonly) NSString *advantageText;

+ (instancetype)benchmarkWithName:(NSString *)name block:(ARBenchmarkBlock)block;

- (uint64_t)run:(size_t)iterations;

@end
