//
//  BubbleChatViewController.m
//  PubNubDemo
//
//  Created by Brian Lee on 2/23/15.
//  Copyright (c) 2015 Brian Lee. All rights reserved.
//

#import "BubbleChatViewController.h"

@interface BubbleChatViewController ()
{
    int keyboard_size;
}

@property (weak, nonatomic) IBOutlet UITableView *chatTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendTextBottomConstraint;
@property (nonatomic, retain) NSMutableArray *allchat;

@end

@implementation BubbleChatViewController
@synthesize allchat, sendTextBottomConstraint, chatTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self alloc];
    
    //linking custom cells
    [self.chatTable registerNib:[UINib nibWithNibName:@"chatCell" bundle:nil]
         forCellReuseIdentifier:@"chatCell"];
    
    //autosizing cells
    self.chatTable.estimatedRowHeight = 50;
    self.chatTable.rowHeight = UITableViewAutomaticDimension;
    
    
}

- (void) alloc {
    //removing empty cells from initial load
    chatTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    self.allchat = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.chatTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"chatCell";
    
    chatCellTableViewCell *cell = (chatCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];

    cell.message.text = [allchat objectAtIndex:indexPath.row];
    
//    [chatTable beginUpdates];
//    
//    
//    
//    [chatTable endUpdates];

    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [allchat count];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[textField resignFirstResponder];
    NSLog(@"Logged");
    
//    [PubNub sendMessage:[NSString stringWithFormat:@"{\"username\":\"%@\", \"text\":\"%@\"}", username, textField.text ] toChannel:my_channel ];

    [allchat addObject:[NSString stringWithFormat:@"%@", textField.text]];
    
    
    textField.text = @"";
    [chatTable reloadData];
    
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
    
    if (!keyboard_size)
    {
        NSDictionary* info = [notification userInfo];
        NSLog(@"%@", info);
        keyboard_size = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    }
    sendTextBottomConstraint.constant = keyboard_size;
    

    
    [UIView animateWithDuration:0.1 animations:^{[self.inputView layoutIfNeeded];}];
    
    
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    self.sendTextBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{[self.inputView layoutIfNeeded];}];
    
}


@end
