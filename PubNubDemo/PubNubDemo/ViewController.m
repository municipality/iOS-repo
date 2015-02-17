//
//  ViewController.m
//  PubNubDemo
//
//  Created by Brian Lee on 2/16/15.
//  Copyright (c) 2015 Brian Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
                                                             publishKey:@"pub-c-250c7ff6-290a-48c6-96fd-0754fe6a55d9"
                                                           subscribeKey:@"sub-c-80c6653c-b625-11e4-80fe-02ee2ddab7fe"
                                                              secretKey:nil];
    // #1 define new channel name "demo"
    PNChannel *my_channel = [PNChannel channelWithName:@"demo"
                                 shouldObservePresence:YES];
    
    [PubNub setConfiguration:myConfig];
    [PubNub connect];
    
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self withCallbackBlock:^(NSString *origin, BOOL connected, PNError *connectionError){
        
        if (connected)
        {
            NSLog(@"OBSERVER: Successful Connection!");
            
            // Subscribe on the channel
            [PubNub subscribeOn:@[my_channel]];
        }
        else if (!connected || connectionError)
        {
            NSLog(@"OBSERVER: Error %@, Connection Failed!", connectionError.localizedDescription);
        }
        
    }];
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error){
        
        switch (state) {
            case PNSubscriptionProcessSubscribedState:
                NSLog(@"OBSERVER: Subscribed to Channel: %@", channels[0]);
                // #2 Send a welcome message on subscribe
                [PubNub sendMessage:[NSString stringWithFormat:@"Hello Everybody!" ] toChannel:my_channel ];
                break;
            case PNSubscriptionProcessNotSubscribedState:
                NSLog(@"OBSERVER: Not subscribed to Channel: %@, Error: %@", channels[0], error);
                break;
            case PNSubscriptionProcessWillRestoreState:
                NSLog(@"OBSERVER: Will re-subscribe to Channel: %@", channels[0]);
                break;
            case PNSubscriptionProcessRestoredState:
                NSLog(@"OBSERVER: Re-subscribed to Channel: %@", channels[0]);
                break;
        }
    }];
    [[PNObservationCenter defaultCenter] addClientChannelUnsubscriptionObserver:self withCallbackBlock:^(NSArray *channel, PNError *error) {
        if ( error == nil )
        {
            NSLog(@"OBSERVER: Unsubscribed from Channel: %@", channel[0]);
            [PubNub subscribeOn: @[my_channel]];
        }
        else
        {
            NSLog(@"OBSERVER: Unsubscribed from Channel: %@, Error: %@", channel[0], error);
        }
    }];
    // Observer looks for message received events
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
        NSLog(@"OBSERVER: Channel: %@, Message: %@", message.channel.name, message.message);
        
        // Look for a message that matches "**************"
        if ( [[[NSString stringWithFormat:@"%@", message.message] substringWithRange:NSMakeRange(1,14)] isEqualToString: @"**************" ])
        {
            // Send a goodbye message
            [PubNub sendMessage:[NSString stringWithFormat:@"Thank you, GOODBYE!" ] toChannel:my_channel withCompletionBlock:^(PNMessageState messageState, id data) {
                if (messageState == PNMessageSent) {
                    NSLog(@"OBSERVER: Sent Goodbye Message!");
                    //Unsubscribe once the message has been sent.
                    [PubNub unsubscribeFrom:@[my_channel] ];
                }
            }];
        }
    }];
    // #3 Add observer to catch message send events.
    [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data){
        
        switch (state) {
            case PNMessageSent:
                NSLog(@"OBSERVER: Message Sent.");
                break;
            case PNMessageSending:
                NSLog(@"OBSERVER: Sending Message...");
                break;
            case PNMessageSendingError:
                NSLog(@"OBSERVER: ERROR: Failed to Send Message.");
                break;
            default:
                break;
        }
    }];
}



@end
