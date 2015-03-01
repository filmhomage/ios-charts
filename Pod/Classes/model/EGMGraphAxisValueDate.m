//
//  EGMGraphAxisValue.m
//  TrainerApp
//
//  Created by Ivan Schuetz on 23/09/14.
//  Copyright (c) 2014 eGym. All rights reserved.
//

#import "EGMGraphAxisValueDate.h"
#import "EGMGraphAxisLabel.h"

@interface EGMGraphAxisValueDate()

@property (nonatomic, strong) NSDateFormatter* formatter;

@end

@implementation EGMGraphAxisValueDate

- (instancetype)initWithDate: (NSDate *)date formatter: (NSDateFormatter *) formatter {
    self = [super init];
    if (self) {
        self.scalar = [self scalarFromDate:date];
        self.formatter = formatter;
    }
    return self;
}

- (NSArray *)labels {
    NSString *formatted = [self.formatter stringFromDate:self.date];
    EGMGraphAxisLabel *graphAxisLabel = [[EGMGraphAxisLabel alloc] initWithText:formatted color:[UIColor blackColor] font:[UIFont systemFontOfSize:14]];
    graphAxisLabel.hidden = self.isHidden;
    return [NSArray arrayWithObjects: graphAxisLabel, nil];
}

- (CGFloat)scalarFromDate:(NSDate *)date {
    return [date timeIntervalSince1970];
}

- (NSDate *)date {
    return [NSDate dateWithTimeIntervalSince1970: self.scalar];
}

- (EGMGraphAxisValue *)clone {
    EGMGraphAxisValueDate * clone = [[EGMGraphAxisValueDate alloc] init];
    clone.scalar = self.scalar;
    clone.formatter = self.formatter;
    return clone;
}

- (BOOL)isEqual:(id)object {
    EGMGraphAxisValueDate *date = (EGMGraphAxisValueDate *)object;
    // 2 date axis values are equal if it's the same day
    // TODO make clear this date is day based, or create a new subclass
    return [[self zeroDate:self.date] isEqual:date];
}

// TODO date category
- (NSDate *)zeroDate:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit) fromDate:self.date];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

@end