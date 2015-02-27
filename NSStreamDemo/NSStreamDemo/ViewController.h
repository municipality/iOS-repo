//
//  ViewController.h
//  NSStreamDemo
//
//  Created by Brian Lee on 2/26/15.
//  Copyright (c) 2015 Brian Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSStreamDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}


@end

