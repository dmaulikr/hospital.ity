//
//  ChatCell.h
//  Sports_Travel_Meet
//
//  Created by Nishanth Salinamakki on 7/15/16.
//  Copyright © 2016 Nishanth Salinamakki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell

@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIImageView *messageImage;
@property (strong, nonatomic) UIImageView *bubbleImageView;
@property (strong, nonatomic) NSArray<NSLayoutConstraint *> *incomingConstraints;
@property (strong, nonatomic) NSArray<NSLayoutConstraint *> *outgoingConstraints;

@property (strong, nonatomic) UIImage *bubbleImageIncoming;
@property (strong, nonatomic) UIImage *bubbleImageOutgoing;

- (void) incoming: (BOOL) incoming;

@end
