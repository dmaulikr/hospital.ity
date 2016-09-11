//
//  HealthChatBotViewController.m
//  Sports_Travel_Meet
//
//  Created by Nishanth Salinamakki on 9/10/16.
//  Copyright © 2016 Nishanth Salinamakki. All rights reserved.
//

#import "HealthChatBotViewController.h"
#import "Message.h"
#import "ChatCell.h"

@interface HealthChatBotViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextView *messageField;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;
@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSMutableArray *dates;

@property (strong, nonatomic) NSString *humanAPIOutput;

@end

@implementation HealthChatBotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    [self.view addSubview: navbar];
    [self.navigationItem setTitle: @"OmniBot"];
    
    BOOL localIncoming = YES;
    
    //Set up Wit.AI
    [Wit sharedInstance].delegate = self;
    self.medWit = [[Wit alloc] init];
    
    self.messages = [[NSMutableArray alloc] init];
    self.sections = [[NSMutableDictionary alloc] init];
    self.dates = [[NSMutableArray alloc] init];
    
    self.humanAPIOutput = @"";
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970: 1100000000];
    
    //Adding dummy data
    //*******************************************************
    for (int i = 1; i <= 10; i++) {
        Message *m = [[Message alloc] init];
        m.messageText = @"DUMMY MESSAGE";
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

#pragma mark - Queries to Human API
- (void) getHumanAPIData: (NSString *) witIntent {
    //Accessing demo data provided by Human API
    NSString *encodedWitIntent = [witIntent stringByAppendingString: @"?access_token=demo"];
    NSURL *humanAPIURL;
    if ([[witIntent lowercaseString] containsString: @"body"] || [[witIntent lowercaseString] containsString: @"bmi"] || [[witIntent lowercaseString] containsString: @"blood_oxygen"] || [[witIntent lowercaseString] containsString: @"blood_glucose"] || [[witIntent lowercaseString] containsString: @"weight"] || [[witIntent lowercaseString] containsString: @"height"] || [[witIntent lowercaseString] containsString: @"activities"]) {
        humanAPIURL = [NSURL URLWithString: [@"https://api.humanapi.co/v1/human/" stringByAppendingString: encodedWitIntent]];
    }
    else if ([[witIntent lowercaseString] containsString: @"meal"]) {
        humanAPIURL = [NSURL URLWithString: [@"https://api.humanapi.co/v1/human/food/" stringByAppendingString: encodedWitIntent]];
        NSLog(@"EXECUTING MEALS URL");
    }
    else if ([[witIntent lowercaseString] containsString: @"allergies"] || [[witIntent lowercaseString] containsString: @"encounters"] || [[witIntent lowercaseString] containsString: @"immunizations"] || [[witIntent lowercaseString] containsString: @"medications"]) {
        humanAPIURL = [NSURL URLWithString: [@"https://api.humanapi.co/v1/human/medical/" stringByAppendingString: encodedWitIntent]];
    }
    NSLog(@"URL STRING: %@", humanAPIURL.absoluteString);
    NSURLRequest *humanAPIRequest = [NSURLRequest requestWithURL: humanAPIURL];
    
    [NSURLConnection sendAsynchronousRequest: humanAPIRequest queue: [NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSError *error = nil;
        NSDictionary *dataJSON = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingAllowFragments error: &error];
        //NSDictionary *dataJSON = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData: data];
        
        //Add underscores b/w spaces later
        if ([[witIntent lowercaseString] isEqualToString: @"body_fat"] ||
            [[witIntent lowercaseString] isEqualToString: @"bmi"] ||
            [[witIntent lowercaseString] isEqualToString: @"blood_oxygen"] ||
            [[witIntent lowercaseString] isEqualToString: @"blood_glucose"] ||
            [[witIntent lowercaseString] isEqualToString: @"weight"] ||
            [[witIntent lowercaseString] isEqualToString: @"height"] ||
            [[witIntent lowercaseString] isEqualToString: @"activities"]) {
            NSLog(@"WIT INTENT CONDITION SATISFIED!");
            NSLog(@"PARTS: %@ %@", dataJSON[@"value"], dataJSON[@"unit"]);
            self.humanAPIOutput = [[dataJSON[@"value"] stringValue] stringByAppendingString: dataJSON[@"unit"]];
            //[[self.humanAPIOutput stringByAppendingString: dataJSON[@"value"]] stringByAppendingString: dataJSON[@"unit"]];
            NSString *prefix = [[@"Your " stringByAppendingString: witIntent] stringByAppendingString: @" is "];
            [self addBotMessage: [prefix stringByAppendingString: self.humanAPIOutput]];
        }
        else if ([[witIntent lowercaseString] containsString: @"meal"]) {
            NSLog(@"WIT INTENT IS MEAL!");
            NSLog(@"MEAL DATA JSON: %@", dataJSON);
            
        }
        else if ([[witIntent lowercaseString] containsString: @"allergies"] || [[witIntent lowercaseString] containsString: @"immunizations"] || [[witIntent lowercaseString] containsString: @"medications"]) {
            NSLog(@"MEDICAL JSON: %@", dataJSON);
            NSError *e = nil;
            NSArray *JSONarray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
            for(int i=0;i<[JSONarray count];i++)
            {
                NSLog(@"ID: %@",[[JSONarray objectAtIndex:i] objectForKey:@"id"]);
                NSLog(@"NAME: %@",[[JSONarray objectAtIndex:i] objectForKey:@"name"]);
                [self addBotMessage: [[JSONarray objectAtIndex: i] objectForKey: @"name"]];
            }
        }
        else if ([[witIntent lowercaseString] containsString: @"encounters"]) {
            NSLog(@"DOCTOR VISIT JSON: %@", dataJSON);
            NSError *e = nil;
            NSArray *JSONarray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
            for(int i=0;i<[JSONarray count];i++)
            {
                NSLog(@"ID: %@",[[JSONarray objectAtIndex:i] objectForKey:@"id"]);
                NSLog(@"NAME: %@",[[JSONarray objectAtIndex:i] objectForKey:@"visitType"]);
                NSString *messageText = [[JSONarray objectAtIndex: i] objectForKey: @"visitType"];
                NSString *secondMessageText = [[[JSONarray objectAtIndex: i] objectForKey: @"dateTime"] substringWithRange: NSMakeRange(0, 10)];
                NSArray *infoArray = [[NSArray alloc] initWithObjects: messageText, secondMessageText, nil];
                NSString *joinedString = [infoArray componentsJoinedByString:@"\n"];
                [self addBotMessage: joinedString];
            }
        }
    }];
    //[self addBotMessage: self.humanAPIOutput];
    
}

- (void)witDidGraspIntent:(NSArray *)outcomes messageId:(NSString *)messageId customData:(id) customData error:(NSError*)e {
    NSLog(@"OUTCOMES: %@", outcomes);
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
        
        NSString* encodedUrl = [newMessage.messageText stringByAddingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding];
        
        NSString *urlString = [NSString stringWithFormat:@"https://api.wit.ai/message?q=%@", encodedUrl];
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlString]];
        [req setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [req setTimeoutInterval:15.0];
        [req setValue:[NSString stringWithFormat: @"Bearer %@", self.medWit.accessToken] forHTTPHeaderField:@"Authorization"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [NSURLConnection sendAsynchronousRequest: req queue: [NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            NSLog(@"URL STRING: %@", urlString);
            NSError *serializationError;
            NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:&serializationError];
            NSLog(@"WIT.AI DATA: %@", object);
            NSString *witIntent = object[@"entities"][@"intent"][0][@"value"];
            NSLog(@"WIT.AI INTENT: %@", witIntent);
            //if ([witIntent containsString: @"height"] || [witIntent containsString: @"weight"] || [witIntent containsString: @"bmi"] || [witIntent containsString: @"body"] || [witIntent containsString: @"blood"]) {
                [self getHumanAPIData: object[@"entities"][@"intent"][0][@"value"]];
            //}
            
        }];
        
        //[self getHumanAPIData: witIntent];
        [self.messageField setText: @""];
        
        //Temporary -- get Wit.AI intent here
        //[self.medWit interpretString: newMessage.messageText customData: nil withBlock: ^(NSString *intent) {
        //[self getHumanAPIData: intent];
        //NSLog(@"INTENT PARAMETER: %@", intent);
        //}];
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end





//**************************************************************************************
/*
 - (void) postRequest {
 NSURL *url = [NSURL URLWithString: @"https://user.humanapi.co/v1/connect/tokens"];
 NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
 [urlRequest setHTTPMethod:@"POST"];
 [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
 
 NSError *error = nil;
 
 NSDictionary *humanAPIPostJSON = @{
 @"humanId": @"d90582b0b57c328a38f789ce041184c1",
 @"clientId": @"b08d69b2b61b291f7ef312753a3e382fa56b0264",
 @"sessionToken": @"8171d06fdb11d3bfec917b1cac95db9b",
 @"clientSecret": @"723882d73e42b84361ddd63757e4556f212c40bf"
 };
 NSData *humanAPIPostData = [NSJSONSerialization dataWithJSONObject: humanAPIPostJSON options: 0 error: &error];
 [urlRequest setHTTPBody: humanAPIPostData];
 
 NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
 [[session dataTaskWithRequest: urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
 NSString *requestReply = [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding];
 NSLog(@"requestReply: %@", requestReply);
 }] resume];
 
 /*
 [NSURLConnection sendAsynchronousRequest: urlRequest queue: [NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
 NSLog(@"DATA: %@", data);
 NSError *error = nil;
 NSDictionary *humanAPIData = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData: data];
 NSString *newStr1 = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
 NSLog(@"HUMAN API DATA: %@", newStr1);
 NSLog(@"HUMAN API JSON DATA: %@", humanAPIData);
 }];
 
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
//********************************************************************************************
