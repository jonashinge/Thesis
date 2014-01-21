//
//  MixerCoreAudioController.m
//  HeadsetExplorer
//
//  Created by Jonas Hinge on 20/01/2014.
//  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
//

#import "MixerCoreAudioController.h"

@interface MixerCoreAudioController()

@property (nonatomic) AUNode mixerNode;
@property (nonatomic) AudioUnit mixerUnit;

@end


@implementation MixerCoreAudioController

- (BOOL)connectOutputBus:(UInt32)sourceOutputBusNumber
                  ofNode:(AUNode)sourceNode
              toInputBus:(UInt32)destinationInputBusNumber
                  ofNode:(AUNode)destinationNode
                 inGraph:(AUGraph)graph
                   error:(NSError *__autoreleasing *)error {
    
    // A description for the Mixer Device
    AudioComponentDescription mixerDescription;
    mixerDescription.componentType = kAudioUnitType_Mixer;
    mixerDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    mixerDescription.componentFlags = 0;
    mixerDescription.componentFlagsMask = 0;
    
    // Add the Mixer node to the AUGraph
    AUGraphAddNode(graph, &mixerDescription, &_mixerNode);
    
    // Get the Audio Unit from the node so we can set properties on it
    AUGraphNodeInfo(graph, self.mixerNode, NULL, &_mixerUnit);
    
    // Initialize the audio unit
    AudioUnitInitialize(self.mixerUnit);
    
    // Set Mixer to panning center
    AudioUnitSetParameter(self.mixerUnit, kMultiChannelMixerParam_Pan, kAudioUnitScope_Output, 0, 0.0, 0);
    
    // Connect the output of the provided audio source node to the input of our Mixer.
    AUGraphConnectNodeInput(graph, sourceNode, sourceOutputBusNumber, _mixerNode, 0);
    
    // Connect the output of our Mixer to the input of the provided audio destination node.
    AUGraphConnectNodeInput(graph, self.mixerNode, 0, destinationNode, destinationInputBusNumber);
    
    return YES;
}

- (void)disposeOfCustomNodesInGraph:(AUGraph)graph {
    
    // Shut down our unit.
    AudioUnitUninitialize(_mixerUnit);
    self.mixerUnit = NULL;
    
    // Remove the unit's node from the graph.
    AUGraphRemoveNode(graph, _mixerNode);
    self.mixerNode = 0;
}

- (void)applyPanningToMixer:(float) panVal {
    
    if(self.mixerUnit == NULL) return;
    
    AudioUnitSetParameter(self.mixerUnit, kMultiChannelMixerParam_Pan, kAudioUnitScope_Output, 0, panVal, 0);
}

@end
