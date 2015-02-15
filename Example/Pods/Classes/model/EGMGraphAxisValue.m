//
//  EGMGraphAxisValue.m
//  TrainerApp
//
//  Created by Ivan Schuetz on 26/09/14.
//  Copyright (c) 2014 eGym. All rights reserved.
//

#import "EGMGraphAxisValue.h"
#import "EGMGraphAxisLabel.h"

@interface EGMGraphAxisValue()

@end

@implementation EGMGraphAxisValue

- (void)setScalar:(CGFloat)scalar {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (CGFloat)getScalar {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setInternalScalar:(CGFloat)scalar {
}

- (CGFloat)getInternalScalar {
    return [self getScalar];
}

- (void)setLabels:(NSString *)labels {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSArray *)getLabels {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (EGMGraphAxisLabel *)getFirstLabel {
    return [[self getLabels] objectAtIndex:0];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"label: %@, scalar: %f", [self getFirstLabel], [self getScalar]];
}

- (EGMGraphAxisValue *)clone {
    EGMGraphAxisValue * clone = [[EGMGraphAxisValue alloc] init];
    [clone setScalar: [self getScalar]];
    return clone;
}

- (BOOL)isEqual:(id)object {
    EGMGraphAxisValue *objectCasted = (EGMGraphAxisValue *)object;
    // default - compare scalar
    return [self getScalar] == [objectCasted getScalar];
}

- (void)setIsHidden:(BOOL)isHidden {
    _isHidden = isHidden;
    
    for (EGMGraphAxisLabel *label in [self getLabels]) {
        label.hidden = YES;
    }
}


@end
