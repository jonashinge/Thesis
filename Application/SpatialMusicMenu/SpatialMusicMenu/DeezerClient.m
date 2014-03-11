//
//  SMMClient.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 08/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "DeezerClient.h"

#import "DeezerConnect.h"
#import "Track.h"

#import <AVFoundation/AVFoundation.h>


#define kDeezerAppId @"133691"

@interface DeezerClient () <DeezerSessionDelegate, DeezerRequestDelegate>

@property (strong, nonatomic) DeezerConnect *deezerConnect;

@property (strong) AVAssetReader *assetReader;
@property (strong) AVAssetWriter *assetWriter;
@property (strong) AVAssetWriterInput *assetWriterInput;
@property (strong) NSString *exportPath;

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      1

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation DeezerClient

- (id)init
{
    self = [super init];
    if(self)
    {
        [self connectToDeezer];
    }
    return self;
}


#pragma mark - Misc

- (void)connectToDeezer
{
    self.deezerConnect = [[DeezerConnect alloc] initWithAppId:kDeezerAppId andDelegate:self];
    
    /* List of permissions available from the Deezer SDK web site */
    NSMutableArray* permissionsArray = [NSMutableArray arrayWithObjects:@"basic_access", @"email", @"offline_access", @"manage_library", @"delete_library", nil];
    
    [self.deezerConnect authorize:permissionsArray];
}

- (void)requestExample
{
    NSString* servicePath =@"track/3135556";
    DeezerRequest* request = [self.deezerConnect createRequestWithServicePath:servicePath
                                                                   params:nil
                                                                 delegate:self];
    
    [self.deezerConnect launchAsyncRequest:request];
}


#pragma mark - DeezerSessionDelegate implementation

- (void)deezerDidLogin
{
    DEBUGLog(@"Deezer user did login");
    
    [self requestExample];
}

-(void)deezerDidLogout
{
    
}


#pragma mark - DeezerRequestDelegate

- (void)request:(DeezerRequest *)request didReceiveResponse:(NSData *)response
{
    NSError *error;
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&error];
    Track *track = [MTLJSONAdapter modelOfClass:[Track class] fromJSONDictionary:json error:&error];
    DEBUGLog(@"Track preview url: %@",track.preview);
    
    // save mp3 locally
    NSData *data = [NSData dataWithContentsOfURL:track.preview];
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documents stringByAppendingPathComponent:@"track.mp3"];
    [data writeToFile:filePath atomically:YES];
    DEBUGLog(@"MP3 saved locally");
    
    // setup asset reader and output
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    NSError *assetError = nil;
    _assetReader = [AVAssetReader assetReaderWithAsset:asset error:&assetError];
    if(assetError)
    {
        NSLog(@"Error: %@",assetError);
        return;
    }
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:asset.tracks audioSettings:nil];
    if(![_assetReader canAddOutput:assetReaderOutput])
    {
        NSLog(@"Can not add reader output...");
        return;
    }
    [_assetReader addOutput:assetReaderOutput];
    
    // input
    NSArray *dirs = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    _exportPath = [documentsDirectoryPath
                             stringByAppendingPathComponent:@"track_converted.wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_exportPath
                                                   error:nil];
    }
    NSURL *exportURL = [NSURL fileURLWithPath:_exportPath];
    
    _assetWriter =
	[AVAssetWriter assetWriterWithURL:exportURL
                              fileType:AVFileTypeCoreAudioFormat
                                 error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
     [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
     [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
     [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)],
     AVChannelLayoutKey,
     [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
     [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
     [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
     [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
     nil];
    
    _assetWriterInput =
	[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                        outputSettings:outputSettings];
    if ([_assetWriter canAddInput:_assetWriterInput]) {
        [_assetWriter addInput:_assetWriterInput];
    } else {
        NSLog (@"can't add asset writer input... die!");
        return;
    }
    _assetWriterInput.expectsMediaDataInRealTime = NO;
    
    [_assetWriter startWriting];
    [_assetReader startReading];
    AVAssetTrack *soundTrack = [asset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [_assetWriter startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    dispatch_queue_t mediaInputQueue =
	dispatch_queue_create("mediaInputQueue", NULL);
    [_assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue usingBlock:^{
        while (_assetWriterInput.readyForMoreMediaData) {
            CMSampleBufferRef nextBuffer =
            [assetReaderOutput copyNextSampleBuffer];
            if (nextBuffer) {
                // append buffer
                [_assetWriterInput appendSampleBuffer: nextBuffer];
                // update ui
                convertedByteCount +=
                CMSampleBufferGetTotalSampleSize (nextBuffer);
                NSNumber *convertedByteCountNumber =
                [NSNumber numberWithLong:convertedByteCount];
                [self performSelectorOnMainThread:@selector(updateSizeLabel:)
                                       withObject:convertedByteCountNumber
                                    waitUntilDone:NO];
            }
            else {
                // done!
                [_assetWriterInput markAsFinished];
                [_assetWriter finishWritingWithCompletionHandler:^{
                }];
                //[_assetWriter finishWriting];
                [_assetReader cancelReading];
                NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_exportPath error:nil];
                DEBUGLog(@"done. file size is %ld",[outputFileAttributes fileSize]);
                NSNumber *doneFileSize = [NSNumber numberWithLong:
                                          [outputFileAttributes fileSize]];
                [self performSelectorOnMainThread:@selector(updateCompletedSizeLabel:)
                                       withObject:doneFileSize
                                    waitUntilDone:NO];
                break;
            }
        }
    }];
}

- (void)updateSizeLabel:(id)count
{
    DEBUGLog(@"update count: %@",count);
}

-(void)request:(DeezerRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}


@end
