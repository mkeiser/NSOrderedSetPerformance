//
//  main.m
//  TestOrderedSet
//
//  Created by meister on 17.05.13.
//  Copyright (c) 2013 meister. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRTester.h"

void test(void);

int main(int argc, const char * argv[])
{

	@autoreleasepool {
	    
		test();
	}
    return 0;
}

void test(void) {
	
	TRTester *tester = [TRTester new];
	[tester testSpeed:nil];
	[tester testMemory:nil];
}
