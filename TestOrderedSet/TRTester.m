//
//  TRTester.m
//  NSOrderedSetPerformanceTest
//
//  Created by meister on 17.05.13.
//  Copyright (c) 2013 meister. All rights reserved.
//

#import "TRTester.h"
#import <DTPerformanceSession/DTSignalFlag.h>

static const NSUInteger kNumElements = 10000;
static const NSUInteger kNumIterations = 1000;

@interface TRTester ()

@property (strong) NSMutableArray *array;
@property (strong) NSMutableOrderedSet *orderedSet;
@property (strong) NSMutableString *resultString;

@end

@implementation TRTester

- (id)init
{
	if( !(self = [super init]) ) return nil;
	
    return self;
}

/* 
   Profile with the Allocations instrument. To see the flags go to
   Window->Manage Flags... and enable "Signal Flags"
*/
 
- (IBAction)testMemory:(id)sender {
	
	DTSendSignalFlag("Start Array Creation", DT_START_SIGNAL, TRUE);
	
	@autoreleasepool {
		
		NSMutableArray *array = [NSMutableArray new];
		[self creationTest:array];
		array = nil;
	}
	DTSendSignalFlag("End Array Creation", DT_END_SIGNAL, TRUE);
	
	DTSendSignalFlag("Start Set Creation", DT_START_SIGNAL, TRUE);
	
	@autoreleasepool {
		
		NSMutableOrderedSet *set = [NSMutableOrderedSet new];
		[self creationTest:set];
		set = nil;
	}
	DTSendSignalFlag("End Set Creation", DT_END_SIGNAL, TRUE);
}

- (IBAction)testSpeed:(id)sender {
	
	self.array = [NSMutableArray new];
	self.orderedSet = [NSMutableOrderedSet new];

	self.resultString = [NSMutableString new];
	
	[self test:@"CREATION" withBlock:^(id collectionObj) {
		
		[self creationTest:collectionObj];
	}];
	
	[self test:@"INDEX OF OBJECT (WORST CASE)" withBlock:^(id collectionObj) {
		
		[self indexOfObjectTest_nonExisting:collectionObj];
	}];
	
	[self test:@"INDEX OF OBJECT (AVERAGE)" withBlock:^(id collectionObj) {
		
		[self indexOfObjectTest_existing:collectionObj];
	}];
	
	[self test:@"WALKING" withBlock:^(id collectionObj) {
		
		[self walkingTest:collectionObj];
	}];
	[self test:@"BINARY SEARCH" withBlock:^(id collectionObj) {
		
		[self binarySearchTest:collectionObj];
	}];
	[self test:@"APPEND" withBlock:^(id collectionObj) {
		
		[self insertTest_append:collectionObj];
	}];
	[self test:@"PREPEND" withBlock:^(id collectionObj) {
		
		[self insertTest_prepend:collectionObj];
	}];

	NSLog(@"%@", self.resultString);
	
	self.array = nil;
	self.orderedSet = nil;
}

- (void)test:(NSString *)testName withBlock:(void(^)(id collectionObj))testBlock {
	
	NSDate *date1, *date2;
	NSTimeInterval arrayDuration, setDuration;
	
	date1 = [NSDate date];
	testBlock(self.array);
	date2 = [NSDate date];
	
	arrayDuration = [date2 timeIntervalSinceDate:date1];
	
	date1 = [NSDate date];
	testBlock(self.orderedSet);
	date2 = [NSDate date];
	
	setDuration = [date2 timeIntervalSinceDate:date1];
	
	NSString *logString = [NSString stringWithFormat:@"\n\n\t\t===%@===\n\narray:\t\t%f\nset:\t\t%f\t( * %f)", testName, arrayDuration, setDuration, setDuration / arrayDuration];
	
	[self.resultString appendString:logString];
}

- (void)creationTest:(id)testObj {
	
	for (NSUInteger i = 0; i < kNumElements; i++) {
		
		NSNumber *number =  [[NSNumber alloc] initWithUnsignedInteger:i];
		[testObj addObject:number];
	}
}

- (void)indexOfObjectTest_nonExisting:(id)testObj {
	
	NSUInteger culIdx = 0;
	
	for (NSUInteger i = 0; i < kNumElements; i++) { // We use kNumElements here for easy comparison with indexOfObjectTest_existing
		
		NSNumber *number = [[NSNumber alloc] initWithUnsignedInteger:kNumElements + i];// Worst case (also, prevent any caching shenanigans)
		
		culIdx += [testObj indexOfObject:number];
	}
}

- (void)indexOfObjectTest_existing:(id)testObj {
	
	NSUInteger culIdx = 0;
	
	for (NSUInteger i = 0; i < kNumElements; i++) { // We use kNumElements instead of kNumIterations to get every object once
		
		NSNumber *number = [[NSNumber alloc] initWithUnsignedInteger:i];
		
		culIdx += [testObj indexOfObject:number];
	}
}

- (void)walkingTest:(id)testObj {
	
	for (NSUInteger i = 0; i < kNumIterations; i++) {
		
		NSNumber *number = [[NSNumber alloc] initWithUnsignedInteger:kNumElements + i]; // Worst case (also, prevent any caching shenanigans)
		
		for (NSNumber *obj in testObj) {
			
			if([number isEqual:obj])
				break;
		}
	}
}

- (void)binarySearchTest:(id)testObj {
	
	NSRange range = NSMakeRange(0, [testObj count]);
	
	for (NSUInteger i = 0; i < kNumElements; i++) {
		
		[testObj indexOfObject:[[NSNumber alloc] initWithUnsignedInteger:i] inSortedRange:range options:NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id obj1, id obj2) {
			
			return [obj1 compare:obj2];
		}];
	}
}

- (void)insertTest_append:(id)testObj {
	
	for (NSUInteger i = 0; i < kNumIterations; i++) {
				
		NSNumber *number = [[NSNumber alloc] initWithUnsignedInteger:kNumElements + i];
		
		[testObj insertObject:number atIndex:kNumElements + i];
	}
}

- (void)insertTest_prepend:(id)testObj {
	
	for (NSUInteger i = 0; i < kNumIterations; i++) {
		
		NSNumber *number = [[NSNumber alloc] initWithUnsignedInteger:kNumElements + i];
		
		[testObj insertObject:number atIndex:0];
	}
}



@end
