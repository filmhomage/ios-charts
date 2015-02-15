//
//  EGMGraphProvider.h
//  newgraph
//
//  Created by Ivan Schuetz on 20/09/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "EGMGraphDataPointsManager.h"
#import "EGMGraph.h"
#import "EGMGraphDataPoint.h"

@interface EGMGraphProvider : EGMGraphDataPointsManager


+ (EGMGraph *)getBarsChart:(NSArray *)dataPoints frame:(CGRect)frame timeRange:(NSInteger)timeRange resizeBlock:(void(^)(CGSize))resizeBlock;

+ (EGMGraph *)getTargetChart:(NSArray *)dataPoints frame:(CGRect)frame resizeBlock:(void(^)(CGSize))resizeBlock;

+ (EGMGraph *)getAreasChart:(NSArray *)dataPointsArr frame:(CGRect)frame resizeBlock:(void(^)(CGSize))resizeBlock;

+ (EGMGraph *)getTrackerChart:(NSArray *)dataPoints frame:(CGRect)frame resizeBlock:(void(^)(CGSize))resizeBlock;

@end
