//
//  ChatCell.m
//  Sports_Travel_Meet
//
//  Created by Nishanth Salinamakki on 7/15/16.
//  Copyright © 2016 Nishanth Salinamakki. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    
    self.messageLabel = [[UILabel alloc] init];
    self.messageImage = [[UIImageView alloc] init];
    
    //Creation of bubble
    UIEdgeInsets incomingInsets = UIEdgeInsetsMake(17.0, 20.0, 17.5, 21.0);
    UIEdgeInsets outgoingInsets = UIEdgeInsetsMake(17.0, 21.0, 17.5, 26.5);
    
    CGSize itemSize = CGSizeMake(35, 35);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
    UIImage *bubbleViewImage = [UIImage imageNamed: @"Message_Bubble_1.png"];
    [bubbleViewImage drawInRect: imageRect];
    bubbleViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [bubbleViewImage imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    
    //Settings for picture
    
    
    // Set different properties (orientation, color) for incoming and outgoing message bubbles
    self.bubbleImageIncoming = [bubbleViewImage resizableImageWithCapInsets: incomingInsets];
    self.bubbleImageOutgoing = [[UIImage imageWithCGImage: bubbleViewImage.CGImage
                                          scale: bubbleViewImage.scale
                                    orientation: UIImageOrientationUpMirrored] resizableImageWithCapInsets: outgoingInsets];
    
    self.bubbleImageView = [[UIImageView alloc] initWithImage: self.bubbleImageOutgoing];
    
    //Do this to use constraints in code
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Add subviews to table view (content view)
    [self.contentView addSubview: self.bubbleImageView];
    [self.bubbleImageView addSubview: self.messageLabel];
    [self.bubbleImageView addSubview: self.messageImage];
    
    //Set constraints
    //Message is centered in bubble image view
    [self.messageLabel.centerXAnchor constraintEqualToAnchor: self.bubbleImageView.centerXAnchor].active = YES;
    [self.messageLabel.centerYAnchor constraintEqualToAnchor: self.bubbleImageView.centerYAnchor].active = YES;
    
    //Set bubble image view constraints to as wide and tall as message label
    [self.bubbleImageView.widthAnchor constraintEqualToAnchor: self.messageLabel.widthAnchor constant: 25].active = YES;
    [self.bubbleImageView.heightAnchor constraintEqualToAnchor: self.messageLabel.heightAnchor constant: 20].active = YES;
    
    //Set message pic constraints
    [self.messageImage.centerXAnchor constraintEqualToAnchor: self.bubbleImageView.centerXAnchor].active = YES;
    [self.messageImage.centerYAnchor constraintEqualToAnchor: self.bubbleImageView.centerYAnchor].active = YES;
    
    //Set bubble image view constraints to as wide and tall as picture dimensions
    //Constraints used for sending only a photo and not text with it
    [self.bubbleImageView.widthAnchor constraintEqualToAnchor: self.messageImage.widthAnchor constant: 30].active = YES;
    [self.bubbleImageView.heightAnchor constraintEqualToAnchor: self.messageImage.heightAnchor constant: 30].active = YES;
    

    self.outgoingConstraints = [[NSArray alloc] init];
    self.outgoingConstraints = [NSArray arrayWithObjects: [self.bubbleImageView.trailingAnchor constraintEqualToAnchor: self.contentView.trailingAnchor], [self.bubbleImageView.leadingAnchor constraintGreaterThanOrEqualToAnchor: self.contentView.centerXAnchor], nil];
    
    self.incomingConstraints = [[NSArray alloc] init];
    self.incomingConstraints = [NSArray arrayWithObjects: [self.bubbleImageView.leadingAnchor constraintEqualToAnchor: self.contentView.leadingAnchor], [self.bubbleImageView.trailingAnchor constraintLessThanOrEqualToAnchor: self.contentView.centerXAnchor], nil];
    
    [self.bubbleImageView.topAnchor constraintEqualToAnchor: self.contentView.topAnchor constant: 10].active = YES;
    [self.bubbleImageView.bottomAnchor constraintEqualToAnchor: self.contentView.bottomAnchor constant: -10].active = YES;
    
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.numberOfLines = 0;
    
    return self;
}

- (void) incoming: (BOOL) incoming {
    if (incoming) {
        [NSLayoutConstraint deactivateConstraints: self.outgoingConstraints];
        [NSLayoutConstraint activateConstraints: self.incomingConstraints];
        self.bubbleImageView.image = self.bubbleImageIncoming;
    }
    else {
        [NSLayoutConstraint deactivateConstraints: self.incomingConstraints];
        [NSLayoutConstraint activateConstraints: self.outgoingConstraints];
        self.bubbleImageView.image = self.bubbleImageOutgoing;
    }
}

//Fix this method!
- (UIImageView *) colorMessageBubble: (UIImage *) image withRed: (CGFloat) red withGreen: (CGFloat) green withBlue: (CGFloat) blue andAlpha: (CGFloat) alpha {
    CGRect rect = CGRectMake(0, 0, 35, 35);
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, red, green, blue, alpha);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    CGContextFillRect(context, rect);
    UIImage *resultantImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView *resultantImageView = [[UIImageView alloc] initWithImage: resultantImage];
    UIGraphicsEndImageContext();
    
    return resultantImageView;
}

//Fix this method
- (UIImageView *) gradientMessageBubble: (UIImageView *) imageView withFirstColor: (UIColor *) firstColor andSecondColor: (UIColor *) secondColor {
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = imageView.bounds;
    gradientMask.colors = @[(id)[UIColor whiteColor].CGColor,
                            (id)[UIColor blueColor].CGColor];
    imageView.layer.mask = gradientMask;
    
    return imageView;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    return self;
}

@end
