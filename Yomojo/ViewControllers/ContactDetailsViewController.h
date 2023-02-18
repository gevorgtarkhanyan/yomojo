//
//  ContactDetailsViewController.h
//  Yomojo
//
//  Created by Kevin Theodore Gonzales on 05/04/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ContactDetailsViewController : UIViewController
{
    MBProgressHUD *HUB;
    NSData *urlData;
    NSMutableArray *phonesArray;
    NSString *clientID;
    NSString *sessionID;
    int phonesArrayIndex;
    
    NSMutableArray *xmlOutputData;
    NSMutableString *nodecontent;
    NSXMLParser *xmlParserObject;
    
    IBOutlet UITextField *txtEmailAdd;
    IBOutlet UITextView *txtViewAddress;
    IBOutlet UILabel *lblNotes;

    BOOL fromFB;
}
@property (nonatomic) BOOL fromFB;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (nonatomic) int phonesArrayIndex;

@property (strong, nonatomic) IBOutlet UITextField *txtEmailAdd;

@property (strong, nonatomic) IBOutlet UITextView *txtViewAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblNotes;


- (IBAction)btnSave:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnRefresh:(id)sender;



@end
