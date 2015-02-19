//
//  ViewController.m
//  PubNubDemo
//
//  Created by Brian Lee on 2/16/15.
//  Copyright (c) 2015 Brian Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    PNChannel *my_channel;
    NSString *username;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *sendText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviBar;


@end



@implementation ViewController

@synthesize textView, sendText, scrollView, naviBar, bottomConstraint;

- (void)viewDidLoad
{
    [super viewDidLoad];
    username = @"Brian";
    
    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
                                                             publishKey:@"pub-c-250c7ff6-290a-48c6-96fd-0754fe6a55d9"
                                                           subscribeKey:@"sub-c-80c6653c-b625-11e4-80fe-02ee2ddab7fe"
                                                              secretKey:nil];
    // #1 define new channel name "demo"
    my_channel = [PNChannel channelWithName:@"demo"
                                 shouldObservePresence:YES];
    [naviBar setTitle:my_channel.name];
    
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
                [PubNub sendMessage:[NSString stringWithFormat:@"%@ has entered.", username ] toChannel:my_channel ];
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
        
        id messageData = message.message;
        if ([messageData isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic = (NSDictionary*) messageData;
            if ([dic objectForKey:@"username"] != nil)
            {
                textView.text = [NSString stringWithFormat:@"%@\n%@: %@", textView.text,
                             [dic valueForKey:@"username"],[dic valueForKey:@"text"]];
            }
        }
        else
        {
            textView.text = [NSString stringWithFormat:@"%@\n%@", textView.text, message.message];
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSLog(@"Logged");

    [PubNub sendMessage:[NSString stringWithFormat:@"{\"username\":\"%@\", \"text\":\"%@\"}", username, textField.text ] toChannel:my_channel ];
    textField.text = @"";
    
    return YES;
}

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
}



- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    NSLog(@"%@", info);
    int keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height + [[info objectForKey:UIKeyboardCenterBeginUserInfoKey] CGRectValue].size.height;
    
    self.bottomConstraint.constant = keyboardSize + 5;
    [UIView animateWithDuration:0.3 animations:^{[self.sendText layoutIfNeeded];}];
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {

    self.bottomConstraint.constant = 5;
    [UIView animateWithDuration:0.3 animations:^{[self.sendText layoutIfNeeded];}];
    
}


@end
