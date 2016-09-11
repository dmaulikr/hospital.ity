//
//  Message.h
//  Sports_Travel_Meet
//
//  Created by Nishanth Salinamakki on 7/15/16.
//  Copyright © 2016 Nishanth Salinamakki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Message : NSObject

@property (strong, nonatomic) NSString *messageText;
@property (strong, nonatomic) UIImage *messagePic;
@property (nonatomic) BOOL incoming;
@property (strong, nonatomic) NSDate *timeStamp;

@end
