//
//  ViewController.m
//  Sports_Travel_Meet
//
//  Created by Nishanth Salinamakki on 7/7/16.
//  Copyright © 2016 Nishanth Salinamakki. All rights reserved.
//

#import "ChatViewController.h"
#import "Message.h"
#import "ChatCell.h"
#import "XMLReader.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextView *messageField;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;
@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSMutableArray *dates;

@property (strong, nonatomic) NSMutableArray *podIDInformation;
@property (strong, nonatomic) NSMutableArray *podLinkInformation;

@property (strong, nonatomic) NSString *identifiedPic;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [self.view addSubview: navbar];
    [self.navigationItem setTitle: @"OmniBot"];
    
    [CloudSightConnection sharedInstance].consumerKey = @"ytQ78EZnXq-Lr5NJWX-FDg";
    [CloudSightConnection sharedInstance].consumerSecret = @"JZpiI06Txz4HeCiJb2F4wg";
    
    self.identifiedPic = [[NSString alloc] init];
    
    BOOL localIncoming = YES;
    
    self.messages = [[NSMutableArray alloc] init];
    self.sections = [[NSMutableDictionary alloc] init];
    self.dates = [[NSMutableArray alloc] init];
    
    self.podIDInformation = [[NSMutableArray alloc] init];
    self.podLinkInformation = [[NSMutableArray alloc] init];
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970: 1100000000];
    
    //Adding dummy data
    //*******************************************************
    for (int i = 1; i <= 3; i++) {
        Message *m = [[Message alloc] init];
        m.messageText = @"Hi, I'm OmniBot! What's up?";
        m.incoming = localIncoming;
        m.timeStamp = date;
        localIncoming = !localIncoming;
        [self addMessage: m];//[self.messages addObject: m];
        
        if (i%2 == 0) {
            date = [NSDate dateWithTimeInterval: 60 * 60 * 24 sinceDate: date];
        }
    }
    //*******************************************************
    
    UIView *newMessageArea = [[UIView alloc] init];
    newMessageArea.backgroundColor = [UIColor lightGrayColor];
    //Property in use for custom constraints
    newMessageArea.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview: newMessageArea];
    
    self.messageField = [[UITextView alloc] init];
    [self.messageField setBackgroundColor: [UIColor blackColor]];
    [self.messageField setFont: [UIFont fontWithName: @"Avenir Next" size: 12]];
    [self.messageField setTextColor: [UIColor whiteColor]];
    self.messageField.translatesAutoresizingMaskIntoConstraints = NO;
    [newMessageArea addSubview: self.messageField];
    self.messageField.scrollEnabled = NO;
    
    UIButton *sendButton = [[UIButton alloc] init];
    sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [newMessageArea addSubview: sendButton];
    [sendButton setTitle: @"Send" forState: UIControlStateNormal];
    [sendButton setContentHuggingPriority: 251 forAxis: UILayoutConstraintAxisHorizontal];
    [sendButton setContentCompressionResistancePriority: 751 forAxis: UILayoutConstraintAxisHorizontal];
    [sendButton addTarget: self action: @selector(pressSendButton:) forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *attachPhotoButton = [[UIButton alloc] init];
    attachPhotoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [newMessageArea addSubview: attachPhotoButton];
    
    [attachPhotoButton setImage: [self resizeImage: [UIImage imageNamed: @"camera_icon.png"] andWidth: 35 andHeight: 35] forState: UIControlStateNormal];
    [attachPhotoButton setContentHuggingPriority: 251 forAxis: UILayoutConstraintAxisHorizontal];
    [attachPhotoButton setContentCompressionResistancePriority: 751 forAxis: UILayoutConstraintAxisHorizontal];
    [attachPhotoButton addTarget: self action: @selector(pressAttachPhotoButton) forControlEvents: UIControlEventTouchUpInside];
    
    self.bottomConstraint = [[NSLayoutConstraint alloc] init];
    self.bottomConstraint = [newMessageArea.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor];
    self.bottomConstraint.active = YES;
    
    NSArray<NSLayoutConstraint *> *newMessageAreaConstraints = [NSArray arrayWithObjects:
    [newMessageArea.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor],
    [newMessageArea.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor],
    [self.messageField.leadingAnchor constraintEqualToAnchor: newMessageArea.leadingAnchor constant: 45],
    [self.messageField.centerYAnchor constraintEqualToAnchor: newMessageArea.centerYAnchor],
    [sendButton.trailingAnchor constraintEqualToAnchor: newMessageArea.trailingAnchor constant: -10],
    [self.messageField.trailingAnchor constraintEqualToAnchor: sendButton.leadingAnchor constant: -10],
    [sendButton.centerYAnchor constraintEqualToAnchor: newMessageArea.centerYAnchor],
    [newMessageArea.heightAnchor constraintEqualToAnchor: self.messageField.heightAnchor constant: 20],[attachPhotoButton.centerYAnchor constraintEqualToAnchor: newMessageArea.centerYAnchor], [attachPhotoButton.leadingAnchor constraintEqualToAnchor: newMessageArea.leadingAnchor constant: 5], nil];
    
    [NSLayoutConstraint activateConstraints: newMessageAreaConstraints];
    
    self.tableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStyleGrouped];
    
    [self.tableView registerClass: [ChatCell class] forCellReuseIdentifier: @"Cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setEstimatedRowHeight: 50];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview: self.tableView];
    
    //Make table view constrained to the constraints of the view
    NSArray<NSLayoutConstraint*> *tableViewConstraints = [NSArray arrayWithObjects:[self.tableView.topAnchor constraintEqualToAnchor: self.view.topAnchor], [self.tableView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor], [self.tableView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor], [self.tableView.bottomAnchor constraintEqualToAnchor: newMessageArea.topAnchor], nil];
    
    [NSLayoutConstraint activateConstraints: tableViewConstraints];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object: nil];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleSingleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapRecognizer];
    
    NSLog(@"DICTIONARY: %@", self.sections);
}

- (void) scrollToBottom {
    if ([self.tableView numberOfRowsInSection: 0] > 0) {
        [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: [self.tableView numberOfRowsInSection: [self.tableView numberOfSections] - 1] - 1 inSection: [self.tableView numberOfSections] - 1] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [self scrollToBottom];
}

- (void) handleSingleTap: (UITapGestureRecognizer *) tapRecognizer {
    [self.view endEditing: YES];
}

- (void) updateBottomConstraint: (NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect frame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if (userInfo != nil) {
        CGRect newFrame = [self.view convertRect: frame fromView: [[[UIApplication sharedApplication] delegate] window]];
        self.bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
        [UIView animateWithDuration: animationDuration animations:^{
            [self.view layoutIfNeeded];
        }];
        [self scrollToBottom];
    }
}

- (void) keyboardWillShow: (NSNotification *) notification {
    [self updateBottomConstraint: notification];
}

- (void) keyboardWillHide: (NSNotification *) notification {
    [self updateBottomConstraint: notification];
}

- (NSString *) modifyPlainTextData: (NSString *) originalPlainTextData {
    NSString *modifiedString = [[originalPlainTextData stringByReplacingOccurrencesOfString: @"integral" withString: @"∫"] stringByReplacingOccurrencesOfString: @"_" withString: @" "];
    NSString *secondModifiedString = [modifiedString stringByReplacingOccurrencesOfString: @"~~" withString: @"="];
    return secondModifiedString;
}

- (void) wolframQuery: (NSString *) text {
    NSString *encodedText = [text stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSString *requestWolframAPIURL = [@"http://api.wolframalpha.com/v2/query?appid=LTW5PH-XA766A928W&input=" stringByAppendingString: encodedText];
    NSURL *wolframURL = [NSURL URLWithString: requestWolframAPIURL];
    NSURLRequest *request = [NSURLRequest requestWithURL: wolframURL];
    
    [NSURLConnection sendAsynchronousRequest: request queue: [NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSLog(@"THE DATA RETURNED IS: %@", data);
        NSError *error = nil;
        NSDictionary *xmlDoc = [XMLReader dictionaryForXMLData: data error: &error];
        NSLog(@"COMPLETE PARSED JSON FILE: %@", xmlDoc);
        int numberOfPods = [xmlDoc[@"queryresult"][@"numpods"] intValue];
        NSLog(@"NUMBER OF PODS RETURNED: %@", xmlDoc[@"queryresult"][@"numpods"]);
        NSLog(@"PODS ERROR STATUS: %@", xmlDoc[@"queryresult"][@"pod"][0][@"error"]);
        NSLog(@"NUMBER OF SUBPODS: %@", xmlDoc[@"queryresult"][@"pod"][0][@"numsubpods"]);
        //NSLog(@"SUBPOD VALUE OF FIRST POD: %@", xmlDoc[@"queryresult"][@"pod"][0][@"subpod"][@"img"][@"src"]);
        if (numberOfPods > 0) {
            for (int i = 0; i < numberOfPods; i++) {
                if ([xmlDoc[@"queryresult"][@"pod"][i][@"error"] isEqualToString: @"false"]) {
                    //No error message required; working fine
                    //Now get data and store in array
                    NSLog(@"PODS ID: %@", xmlDoc[@"queryresult"][@"pod"][i][@"id"]);
                    [self.podIDInformation addObject: xmlDoc[@"queryresult"][@"pod"][i][@"id"]];
                    NSString *subPodNumber = xmlDoc[@"queryresult"][@"pod"][i][@"numsubpods"];
                    int numSubPods = [subPodNumber intValue];
                    if (numSubPods > 1) {
                        for (int j = 0; j < numSubPods; j++) {
                            NSLog(@"PODS: %@", xmlDoc[@"queryresult"][@"pod"][i][@"subpod"][j][@"plaintext"][@"text"]);
                            [self.podLinkInformation addObject: xmlDoc[@"queryresult"][@"pod"][i][@"subpod"][j][@"plaintext"][@"text"]];
                        }
                    }
                    else {
                        NSLog(@"PODS: %@", xmlDoc[@"queryresult"][@"pod"][i][@"subpod"][@"plaintext"][@"text"]);
                        [self.podLinkInformation addObject: xmlDoc[@"queryresult"][@"pod"][i][@"subpod"][@"plaintext"][@"text"]];
                    }
                    NSLog(@"POD INFO: %@", self.podLinkInformation);
                }
                else {
                    NSLog(@"NUMBER OF PODS: %@", xmlDoc[@"queryresult"][@"numpods"]);
                    NSLog(@"DATA RETRIEVAL FAILED!");
                    Message *botErrorMessage = [[Message alloc] init];
                    [self addMessage: botErrorMessage];
                }
            }
        }
        else {
            
        }
        
        if (numberOfPods > 0) {
            //Popup view controller setup
            //NSString *plainTextMessage = xmlDoc[@"queryresult"][@"pod"][0][@"subpod"][@"plaintext"][@"text"];
            //NSLog(@"PLAIN TEXT DATA: %@", plainTextMessage);
            NSString *plainTextMessage = @"";
            NSLog(@"POD INFO AFTER: %@", self.podLinkInformation);
            if ([self.podLinkInformation count] > 3) {
                for (int i = 0; i < 3; i++) {
                    if ([[self.podLinkInformation objectAtIndex: i] isEqualToString: @""]) {
                        break;
                    }
                    else {
                        NSString *modifiedString = [self modifyPlainTextData: [self.podLinkInformation objectAtIndex: i]];
                        plainTextMessage = [plainTextMessage stringByAppendingString: modifiedString];
                        plainTextMessage = [plainTextMessage stringByAppendingString: @"\r__________\r"];
                    }
                }
            }
            else {
                for (int i = 0; i < [self.podLinkInformation count]; i++) {
                    if ([[self.podLinkInformation objectAtIndex: i] isEqualToString: @""]) {
                        break;
                    }
                    else {
                        NSString *modifiedString = [self modifyPlainTextData: [self.podLinkInformation objectAtIndex: i]];
                        plainTextMessage = [plainTextMessage stringByAppendingString: modifiedString];
                        plainTextMessage = [plainTextMessage stringByAppendingString: @"\r__________\r"];
                    }
                }
            }
            NSLog(@"PLAIN TEXT DATA: %@", plainTextMessage);
            [self addBotMessage: plainTextMessage];
            NSLog(@"PODS EXIST!");
            [self.podIDInformation removeAllObjects];
            [self.podLinkInformation removeAllObjects];
        }
        else {
            NSLog(@"ZERO PODS!");
            [self addBotMessage: @"So sorry! I don't know!"];
        }
        
    }];
}

- (UIImage *) resizeImage: (UIImage *) image andWidth: (CGFloat) imageWidth andHeight: (CGFloat) imageHeight {
    CGSize itemSize = CGSizeMake(imageWidth, imageHeight);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
    UIImage *bubbleViewImage = image;
    [bubbleViewImage drawInRect: imageRect];
    bubbleViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return bubbleViewImage;
}

- (void) pressSendButton: (UIButton *) button {
    if (self.messageField.text.length > 0) {
        Message *newMessage = [[Message alloc] init];
        newMessage.messageText = self.messageField.text;
        NSLog(@"MESSAGE TEXT: %@", self.messageField.text);
        newMessage.timeStamp = [NSDate date];
        newMessage.incoming = NO;
        /*
        UIImage *samplePic = [UIImage imageNamed: @"wit.png"];
        //[self resizeImage: samplePic];
        newMessage.messagePic = [self resizeImage: samplePic andWidth: samplePic.size.width/2 andHeight: samplePic.size.height/2];
         */
        [self addMessage: newMessage];//[self.messages addObject: newMessage];
        
        [self.tableView reloadData];
        [self scrollToBottom];
        [self.view endEditing: YES];
        
        //Take newMessage as parameter to Wolfram Alpha query
        [self wolframQuery: newMessage.messageText];
        [self.messageField setText: @""];
    }
    else {
        Message *newMessage = [[Message alloc] init];
        newMessage.messageText = self.messageField.text;
        NSLog(@"MESSAGE TEXT: %@", self.messageField.text);
        newMessage.timeStamp = [NSDate date];
        newMessage.incoming = NO;
        UIImage *samplePic = [UIImage imageNamed: @"wit.png"];
        //[self resizeImage: samplePic];
        newMessage.messagePic = [self resizeImage: samplePic andWidth: 50 andHeight: 50];
        [self addMessage: newMessage];
        
        [self.tableView reloadData];
        [self scrollToBottom];
        [self.view endEditing: YES];
        
        [self searchImage: newMessage.messagePic];
    }
}

//Enable user to take photo right away instead of simply selecting
- (void) pressAttachPhotoButton {
    self.imagePicker = [[UIImagePickerController alloc] init];
    [self.imagePicker setDelegate: self];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController: self.imagePicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self searchImage: selectedImage];
    
    Message *newMessage = [[Message alloc] init];
    newMessage.messageText = @"";
    newMessage.timeStamp = [NSDate date];
    newMessage.incoming = NO;
    newMessage.messagePic = [self resizeImage: selectedImage andWidth: 50 andHeight: 50];
    [self addMessage: newMessage];
    
    [self.tableView reloadData];
    [self scrollToBottom];
    [self.view endEditing: YES];
    
    /*
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://usekenko.co/food-analysis"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
     */
    
    [self.imagePicker dismissModalViewControllerAnimated:YES];
    
}
                                            
- (void) addMessage: (Message *) message {
    NSDate *date = message.timeStamp;
    if (date) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *startDay = [calendar startOfDayForDate: date];
        NSMutableArray<Message*> *messages = self.sections[startDay];
        if (messages == nil) {
            [self.dates addObject: startDay];
            messages = [[NSMutableArray alloc] init];
        }
        [messages addObject: message];
        self.sections[startDay] = messages;
    }
    NSLog(@"ADDED");
}

- (void) addBotMessage: (NSString *) text {
    NSLog(@"ADD BOT MESSAGE 1");
    Message *botMessage = [[Message alloc] init];
    botMessage.messageText = text;
    //botMessage.messagePic = [UIImage imageNamed: @"wit.png"];
    botMessage.incoming = YES;
    NSDate *whateverdate = [NSDate date];
    botMessage.timeStamp = whateverdate;
    [self addMessage: botMessage];
    
    [self.tableView reloadData];
    [self scrollToBottom];
}

- (NSMutableArray*) getMessages: (int) section {
    NSDate *date = self.dates[section];
    return self.sections[date];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dates count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self getMessages: section] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //ChatCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"Cell"];
    ChatCell *cell = [[ChatCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"Cell"];
    if (cell == nil) {
        cell = [[ChatCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"Cell"];
    }
    
    NSMutableArray<Message*> *messages = [self getMessages: indexPath.section];
    Message *message = [messages objectAtIndex: indexPath.row];
    
    //cell.textLabel.text = message.messageText;
    [cell.messageLabel setFont: [UIFont fontWithName: @"Avenir Next" size: 12]];
    [cell.messageLabel setTextColor: [UIColor whiteColor]];
    cell.messageLabel.text = message.messageText;
    cell.messageImage.image = message.messagePic;
    [cell incoming: message.incoming];
    
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    UIView *paddingView = [[UIView alloc] init];
    [view addSubview: paddingView];
    paddingView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *dateLabel = [[UILabel alloc] init];
    [dateLabel setFont: [UIFont fontWithName: @"Avenir Next" size: 12]];
    [dateLabel setTextColor: [UIColor whiteColor]];
    [paddingView addSubview: dateLabel];
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray<NSLayoutConstraint*> *constraints = [NSArray arrayWithObjects:
    [paddingView.centerXAnchor constraintEqualToAnchor: view.centerXAnchor],
    [paddingView.centerYAnchor constraintEqualToAnchor: view.centerYAnchor],
    [dateLabel.centerXAnchor constraintEqualToAnchor: paddingView.centerXAnchor],
    [dateLabel.centerYAnchor constraintEqualToAnchor: paddingView.centerYAnchor],
    [paddingView.heightAnchor constraintEqualToAnchor: dateLabel.heightAnchor constant: 5],
    [paddingView.widthAnchor constraintEqualToAnchor: dateLabel.widthAnchor constant: 10],
    [view.heightAnchor constraintEqualToAnchor: paddingView.heightAnchor], nil];
    
    [NSLayoutConstraint activateConstraints: constraints];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd, YYYY";
    dateLabel.text = [dateFormatter stringFromDate: self.dates[section]];
    
    paddingView.layer.cornerRadius = 10;
    paddingView.layer.masksToBounds = YES;
    paddingView.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    return view;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

// Think of implementing this method with interesting functionality 
/*
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%lu", indexPath.row);
}
*/

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void) nutritionixQuery: (NSString *) foodText {
    NSString *requestNutritionixURLString = @"https://api.nutritionix.com/v1_1/item";
    NSURL *nutritionixURL = [NSURL URLWithString: requestNutritionixURLString];
    //NSURLRequest *nutritionixRequest = [NSURLRequest requestWithURL: nutritionixURL];
    NSMutableURLRequest *nutritionixRequest = [[NSMutableURLRequest alloc] init];
    [nutritionixRequest setURL: nutritionixURL];
    [nutritionixRequest setHTTPMethod:@"POST"];
    //[nutritionixRequest setValue: postLength forHTTPHeaderField:@"Content-Length"];
    //[nutritionixRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *nutritionixPostJSON = @{@"appId": @"472977fe",
                                         @"appKey": @"be8bddae93f2485fedbc57c16e2c1ae0",
                                          @"phrase": foodText};
    NSData *nutritionixPostData = [NSKeyedArchiver archivedDataWithRootObject: nutritionixPostJSON];
    [nutritionixRequest setHTTPBody: nutritionixPostData];
    [nutritionixRequest setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest: nutritionixRequest queue: [NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"THE NUTRITIONIX DATA RETURNED IS: %@", data);
        //NSDictionary *nutritionixData = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData: data];
        NSError *error = nil;
        NSDictionary *nutritionixData = [NSJSONSerialization JSONObjectWithData: data
                                                                     options: NSJSONReadingAllowFragments
                                                                       error: &error];
        NSLog(@"NUTRITIONIX JSON DATA: %@", nutritionixData);
    }];
}

- (void) searchImage: (UIImage *) image {
    //UIImage *sampleImage = [UIImage imageNamed: @"BackButton.png"];
    //NSData *sampleImageData = UIImageJPEGRepresentation(sampleImage, 0.6);
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    CGPoint focalPoint = CGPointZero;
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude: [@"37.3688" floatValue] longitude: [@"-122.0363" floatValue]];
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.query = [[CloudSightQuery alloc] initWithImage: imageData
                                             atLocation: focalPoint
                                           withDelegate: self
                                            atPlacemark: userLocation
                                           withDeviceId: deviceIdentifier];
    // Start the query process
    [self.query start];
    
}

#pragma mark CloudSightQueryDelegate

- (void) cloudSightQueryDidFinishUploading:(CloudSightQuery *)query {
    NSLog(@"FINISHED UPLOADING!");
}

- (void)cloudSightQueryDidFinishIdentifying:(CloudSightQuery *)query {
    if (query.skipReason != nil) {
        NSLog(@"Skipped: %@", query.skipReason);
    }
    else {
        NSLog(@"Identified: %@", query.title);
        self.identifiedPic = query.title;
        NSLog(@"PICTURE: %@", self.identifiedPic);
        [self addBotMessage: self.identifiedPic];
        //[self nutritionixQuery: @"coffee"];
    }
}

- (void)cloudSightQueryDidFail:(CloudSightQuery *)query withError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (void) cloudSightQueryDidUpdateTag:(CloudSightQuery *)query {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
