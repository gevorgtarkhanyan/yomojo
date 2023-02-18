//
//  NSDate+Compare.h
//  Yomojo
//
//  Created by Gevorg Tarkhanyan on 9/29/22.
//  Copyright © 2022 AcquireBPO. All rights reserved.
//

#ifndef NSDate_Compare_h
#define NSDate_Compare_h


#endif /* NSDate_Compare_h */
@implementation NSDate (Compare)

-(BOOL) isLaterThanOrEqualTo:(NSDate*)date {
    return !([self compare:date] == NSOrderedAscending);
}

-(BOOL) isEarlierThanOrEqualTo:(NSDate*)date {
    return !([self compare:date] == NSOrderedDescending);
}
-(BOOL) isLaterThan:(NSDate*)date {
    return ([self compare:date] == NSOrderedDescending);

}
-(BOOL) isEarlierThan:(NSDate*)date {
    return ([self compare:date] == NSOrderedAscending);
}

@end
