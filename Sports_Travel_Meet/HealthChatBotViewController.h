//
//  HealthChatBotViewController.h
//  Sports_Travel_Meet
//
//  Created by Nishanth Salinamakki on 9/10/16.
//  Copyright © 2016 Nishanth Salinamakki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Wit.h"

@interface HealthChatBotViewController : UIViewController <WitDelegate>

@property (strong, nonatomic) Wit *medWit;

@end
