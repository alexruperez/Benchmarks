# Benchmarks

![Benchmarks screenshot](https://raw.github.com/alexruperez/Benchmarks/master/Benchmarks.png "Benchmarks screenshot")

You can add your own benchmarks at [ARBenchmarks.m](https://github.com/alexruperez/Benchmarks/blob/master/Benchmarks/ARBenchmarks.m):

```objectivec
[ARBenchmarkSet benchmarkSetWithBenchmarks:@[[ARBenchmark benchmarkWithName:@"DESCRIPTION" block:^{
  @autoreleasepool {
		BENCHMARK CODE
	}
}], ...]];
```

## Thanks

* Contributions are very welcome! Create new amazing benchmarks!
* Attribution is appreciated (let's spread the word!), but not mandatory.

[@sferik](http://github.com/sferik) [Erik Michaels-Ober - Writing Fast Ruby](https://speakerdeck.com/sferik/writing-fast-ruby)

[@mattt](http://github.com/mattt) aka. [@NSHipster](http://github.com/NSHipster) [Mattt Thompson - Benchmarking](http://nshipster.com/benchmarking/)

[@baruco](http://github.com/baruco) [Barcelona Ruby Conference 2014](http://www.baruco.org)
