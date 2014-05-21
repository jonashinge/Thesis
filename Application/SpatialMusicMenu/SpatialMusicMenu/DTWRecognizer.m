//
//  DTWGestureRecognizer.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 12/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "DTWRecognizer.h"

@interface DTWRecognizer ()

// Known sequences and their labels
@property (strong, nonatomic) NSMutableArray *sequences;
@property (strong, nonatomic) NSMutableArray *labels;

// Size of obeservations vectors.
@property NSInteger dimension;
// Maximum DTW distance between an example and a sequence being classified.
@property CGFloat globalThreshold;
// Maximum distance between the last observations of each sequence.
@property CGFloat firstThreshold;
// Maximum vertical or horizontal steps in a row.
@property NSInteger maxSlope;

@end

@implementation DTWRecognizer

- (id)initWithDimension:(NSInteger)dimension GlobalThreshold:(CGFloat)threshold FirstThreshold:(CGFloat)firstThreshold AndMaxSlope:(NSInteger)maxSlope
{
    self = [super init];
    if(self) {
        self.sequences = [[NSMutableArray alloc] init];
        self.labels = [[NSMutableArray alloc] init];
        
        self.dimension = dimension;
        self.globalThreshold = threshold;
        self.firstThreshold = firstThreshold;
        self.maxSlope = maxSlope;
    }
    return self;
}

- (void)clearAllKnownSequences
{
    [self.sequences removeAllObjects];
    [self.labels removeAllObjects];
}

- (void)addKnownSequence:(NSArray *)seq WithLabel:(NSString *)label
{
    [self.sequences addObject:seq];
    [self.labels addObject:label];
}

- (double)outputAccuracy
{
    NSArray *testSeqences = [NSArray arrayWithObjects:
                             [_sequences objectAtIndex:2],
                             [_sequences objectAtIndex:4],
                             [_sequences objectAtIndex:6],
                             [_sequences objectAtIndex:8],
                             [_sequences objectAtIndex:10], nil];
    
    NSMutableArray *trainingSequences = [NSMutableArray arrayWithArray:_sequences];
    [trainingSequences removeObjectsInArray:testSeqences];
    
    double accuracy = 0;
    
    for (NSArray *testSeq in testSeqences) {
        
        CGFloat minDist = INFINITY;
        for(int i=0; i<[trainingSequences count]; i++)
        {
            NSArray *example = [trainingSequences objectAtIndex:i];
            if([self euclDist:[testSeq objectAtIndex:[testSeq count]-1] :[example objectAtIndex:[example count]-1]] < self.firstThreshold)
            {
                CGFloat d = [self dtw:testSeq :example] / [example count];
                if(d < minDist)
                {
                    minDist = d;
                }
            }
        }
        if(minDist < self.globalThreshold)
        {
            accuracy += 1;
        }
    }
    return accuracy/[testSeqences count];
    //return accuracy;
}

- (NSDictionary *)recognizeSequence:(NSArray *)seq
{
    CGFloat minDist = INFINITY;
    //double minDist = double.INFINITY;
    int idx = -1;
    NSString *class = @"__UNKNOWN";
    for(int i=0; i<[self.sequences count]; i++)
    {
        NSArray *example = [self.sequences objectAtIndex:i];
        if([self euclDist:[seq objectAtIndex:[seq count]-1] :[example objectAtIndex:[example count]-1]] < self.firstThreshold)
        {
            CGFloat d = [self dtw:seq :example] / [example count];
            if(d < minDist)
            {
                minDist = d;
                idx = i;
                class = [self.labels objectAtIndex:i];
            }
        }
    }
    if(minDist < self.globalThreshold)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:idx], @"id", class, @"class", nil];
        return dict;
    }
    else
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:-1], @"id", @"__UNKNOWN", @"class", nil];
        return dict;
    }
}

// Squared euclidian distance
- (double)euclDist:(NSArray*)a :(NSArray*)b
{
    CGFloat d = 0;
    for (int i=0; i<self.dimension; i++) {
        CGFloat aFloat = [(NSNumber*)[a objectAtIndex:i] floatValue];
        CGFloat bFloat = [(NSNumber*)[b objectAtIndex:i] floatValue];
        d += pow(aFloat-bFloat, 2);
    }
    return d;
}

- (CGFloat)dtw:(NSArray*)seqA :(NSArray*)seqB
{
    // Init
    NSArray *seqARev = [[seqA reverseObjectEnumerator] allObjects];
    NSArray *seqBRev = [[seqB reverseObjectEnumerator] allObjects];
    double tab[[seqA count]+1][[seqB count]+1];
    int slopeI[[seqA count]+1][[seqB count]+1];
    int slopeJ[[seqA count]+1][[seqB count]+1];
    
    for(int i=0; i<[seqARev count]+1; i++)
    {
        for(int j=0; j<[seqBRev count]+1; j++)
        {
            tab[i][j] = INFINITY;
            slopeI[i][j] = 0;
            slopeJ[i][j] = 0;
        }
    }
    tab[0][0] = 0;
    
    // Dynamic computation of the DTW matrix.
    for(int i=1; i<[seqARev count]+1; i++)
    {
        for(int j=1; j<[seqBRev count]+1; j++)
        {
            if(tab[i][j - 1] < tab[i - 1][j - 1] && tab[i][j - 1] < tab[i - 1][j] && slopeI[i][j - 1] < self.maxSlope)
            {
                tab[i][j] = [self euclDist:[seqARev objectAtIndex:i-1] :[seqBRev objectAtIndex:j-1]] + tab[i][j - 1];
                slopeI[i][j] = slopeJ[i][j-1] + 1;
                slopeJ[i][j] = 0;
            }
            else if(tab[i - 1][j] < tab[i - 1][j - 1] && tab[i - 1][j] < tab[i][j - 1] && slopeJ[i - 1][j] < self.maxSlope)
            {
                tab[i][j] = [self euclDist:[seqARev objectAtIndex:i-1] :[seqBRev objectAtIndex:j-1]] + tab[i - 1][j];
                slopeI[i][j] = 0;
                slopeJ[i][j] = slopeJ[i - 1][j] + 1;
            }
            else
            {
                tab[i][j] = [self euclDist:[seqARev objectAtIndex:i-1] :[seqBRev objectAtIndex:j-1]] + tab[i - 1][j - 1];
                slopeI[i][j] = 0;
                slopeJ[i][j] = 0;
            }
        }
    }
    
    // Find best between seq2 and an ending (postfix) of seq1.
    double bestMatch = INFINITY;
    for (int i=0; i<[seqARev count]+1; i++) {
        if(tab[i][[seqBRev count]] < bestMatch)
        {
            bestMatch = tab[i][[seqBRev count]];
        }
    }
    return bestMatch;
}

@end
