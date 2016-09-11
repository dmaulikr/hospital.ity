//
//  ViewController.h
//  Sports_Travel_Meet
//
//  Created by Nishanth Salinamakki on 7/7/16.
//  Copyright © 2016 Nishanth Salinamakki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "CloudSightConnection.h"
#import "CloudSightQuery.h"
#import "CloudSightImageRequestDelegate.h"
#import "CloudSightQueryDelegate.h"

@interface ChatViewController : UIViewController <CloudSightImageRequestDelegate, CloudSightQueryDelegate>

@property (strong, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) CloudSightQuery *query;

@end

