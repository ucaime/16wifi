//
//  PWSHelper.m
//  PWSCalendar
//
//  Created by Sylar on 3/14/14.
//  Copyright (c) 2014 PWS. All rights reserved.
//

#import "PWSHelper.h"

@implementation PWSHelper

+ (UIColor*) GetRandomColor
{
    int r = arc4random()%255;
    int g = arc4random()%255;
    int b = arc4random()%255;
    UIColor* rt = [UIColor colorWithRed:r/255.9 green:g/255.9 blue:b/255.9 alpha:1];
    return rt;
}

+ (NSDate*) GetNextMonth:(NSDate*)_date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:_date];
    
    NSInteger year  = comps.year;
    NSInteger month = comps.month;
    NSInteger day   = comps.day;
    
    NSDate* rt = nil;
    
    if (day <= 28 || month == 12)
    {
        comps.month = month+1;
        rt = [cal dateFromComponents:comps];
    }
    else
    {
        NSString* ss = [NSString stringWithFormat:@"%ld-%ld-3", (long)year, month+1];
        NSDateFormatter* ff = [[NSDateFormatter alloc] init];
        [ff setDateFormat:@"yyyy年MM月dd日"];
        NSDate* the_month = [ff dateFromString:ss];
        NSRange rng = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:the_month];
        NSInteger day_in_month = rng.length;
        
        NSString* datestring = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)year, month+1, (long)(MIN(day, day_in_month))];
        rt = [ff dateFromString:datestring];
    }
    
    return rt;
}

+ (NSDate*) GetPreviousMonth:(NSDate*)_date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:_date];
    
    NSInteger year  = comps.year;
    NSInteger month = comps.month;
    NSInteger day   = comps.day;
    
    NSDate* rt = nil;
    
    if (day <= 28 || month == 1)
    {
        comps.month = month-1;
        rt = [cal dateFromComponents:comps];
    }
    else
    {
        NSString* ss = [NSString stringWithFormat:@"%ld-%ld-3", (long)year, month-1];
        NSDateFormatter* ff = [[NSDateFormatter alloc] init];
        [ff setDateFormat:@"yyyy年MM月dd日"];
        NSDate* the_month = [ff dateFromString:ss];
        NSRange rng = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:the_month];
        NSInteger day_in_month = rng.length;
        
        NSString* datestring = [NSString stringWithFormat:@"%ld-%ld-%ld", year, month-1, (long)MIN(day, day_in_month)];
        rt = [ff dateFromString:datestring];
    }
    return rt;
}

+ (NSDate*) GetNextWeek:(NSDate*)_date
{
    NSDate* rt = [_date dateByAddingTimeInterval:7*3600*24];
    return rt;
}

+ (NSDate*) GetPreviousWeek:(NSDate*)_date
{
    NSDate* rt = [_date dateByAddingTimeInterval:-7*3600*24];
    return rt;
}

+ (BOOL) CheckSameDay:(NSDate*)_date1 AnotherDate:(NSDate*)_date2
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSString* s1 = [formatter stringFromDate:_date1];
    NSString* s2 = [formatter stringFromDate:_date2];
    BOOL rt = [s1 isEqualToString:s2];
    return rt;
}

+(BOOL)CheckPreviousDay:(NSDate *)_date1 AnotherDate:(NSDate *)_date2{

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSInteger s1 = [[formatter stringFromDate:_date1] integerValue];
    NSInteger s2 = [[formatter stringFromDate:_date2] integerValue];
    BOOL rt =s1>s2;
    return rt;
    
}


+ (BOOL) CheckSignDay:(NSString*)_date1 AnotherDate:(NSDate*)_date2{

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString* s1 = [formatter stringFromDate:_date2];
    NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
    BOOL rt = [_date1 isEqualToString:[NSString stringWithFormat:@"%@%@",[def objectForKey:@"userID"],s1]];
    if (rt) {
        NSLog(@"%@,%@",_date1,_date2);
    }
    return rt;
}

+ (BOOL) CheckThisMonth:(NSDate*)_thisMonth NextMonth:(NSDate*)_nextMonth
{
    BOOL rt = [self CheckSameMonth:[self GetNextMonth:_thisMonth] AnotherMonth:_nextMonth];
    return rt;
}

+ (BOOL) CheckSameMonth:(NSDate*)_month1 AnotherMonth:(NSDate*)_month2
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents* m1 = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:_month1];
    NSDateComponents* m2 = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:_month2];
    BOOL rt = NO;
    if ((m1.year == m2.year) && (m1.month == m2.month))
    {
        rt = YES;
    }
    return rt;
}

+ (BOOL) CheckThisWeek:(NSDate*)_thisWeek NextWeek:(NSDate*)_nextWeek
{
    BOOL rt = [self CheckSameWeek:[self GetNextWeek:_thisWeek] AnotherWeek:_nextWeek];
    return rt;
}

+ (BOOL) CheckSameWeek:(NSDate*)_week1 AnotherWeek:(NSDate*)_week2
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents* w1 = [cal components:NSYearCalendarUnit|NSWeekCalendarUnit fromDate:_week1];
    NSDateComponents* w2 = [cal components:NSYearCalendarUnit|NSWeekCalendarUnit fromDate:_week2];
    BOOL rt = NO;
    if ((w1.week == w2.week) && ([_week1 timeIntervalSinceDate:_week2]<=24*3600*7))
    {
        rt = YES;
    }
    return rt;
}


@end
