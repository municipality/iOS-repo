//
//  ViewController.m
//  RealtimeFrameworkDemo
//
//  Created by Brian Lee on 2/23/15.
//  Copyright (c) 2015 Brian Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Instantiate Messaging Client
    ortcClient = [OrtcClient ortcClientWithConfig:self];
    
    // Set connection properties
    [ortcClient setConnectionMetadata:@"clientConnMeta"];
    [ortcClient setClusterUrl:@"http://ortc-developers.realtime.co/server/2.1/"];
    
    // Connect
    [ortcClient connect:@"[YOUR_APPLICATION_KEY]"
    authenticationToken:@"myAuthenticationToken"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    
}

@end
