/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <Foundation/Foundation.h>
#import "MCEInboxActionPlugin.h"
#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInboxActionPlugin  ()
@property NSString * attribution;
@property NSString * mailingId;
@property NSString * richContentIdToShow;
@property NSString * inboxMessageIdToShow;
@property UIViewController <MCETemplateDisplay> * displayViewController;
@end

@implementation MCEInboxActionPlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)syncDatabase:(NSNotification*)notification
{
    MCEInboxMessage * message = nil;
    if(self.inboxMessageIdToShow)
    {
        message = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId: self.inboxMessageIdToShow];
    }
    else if(self.richContentIdToShow)
    {
        message = [[MCEInboxDatabase sharedInstance] inboxMessageWithRichContentId:self.richContentIdToShow];
    }
    
    if(message)
    {
// gm remove unwanted message from the inbox based on 'keep-message-array'
        NSLog(@"message content:%@",message.content);
        
        BOOL isNews;
        if (message.content[@"messagePreview"] ) {
             isNews= [[message.content[@"messagePreview"] valueForKey:@"additionalDevData"] boolValue];
            NSLog(@"additionalDevData:%@",message.content[@"messagePreview"][@"additionalDevData"]);
            NSLog(@"isNews:%d",isNews);
        }
 //
        [self.displayViewController setLoading];
        
        UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
        [controller presentViewController:(UIViewController*)self.displayViewController animated:TRUE completion:nil];

        [self displayRichContent: message];
        self.richContentIdToShow=nil;
        self.inboxMessageIdToShow=nil;
    }
    else
    {
        NSLog(@"Could not get inbox message from database");
    }
}

-(void)displayRichContent: (MCEInboxMessage*)inboxMessage
{
    inboxMessage.isRead = TRUE;
    [[MCEEventService sharedInstance] recordViewForInboxMessage:inboxMessage attribution: self.attribution mailingId: self.mailingId];
    
    self.displayViewController.inboxMessage = inboxMessage;
    [self.displayViewController setContent];
}

-(void)showInboxMessage:(NSDictionary*)action payload:(NSDictionary*)payload
{
    self.attribution=nil;
    self.mailingId=nil;
    if(payload[@"mce"])
    {
        self.attribution = payload[@"mce"][@"attribution"];
        self.mailingId = payload[@"mce"][@"mailingId"];
    }
    
    self.inboxMessageIdToShow=action[@"inboxMessageId"];
    self.richContentIdToShow=action[@"value"];
    
// gm keep the message id in 'keep-message-array'
    NSLog(@"message inboxMessageId:%@",self.inboxMessageIdToShow);
    NSLog(@"message richContentId:%@",self.richContentIdToShow);
    // use the method at the bottom
// end
    NSString * template = action[@"template"];
    self.displayViewController = [[MCETemplateRegistry sharedInstance] viewControllerForTemplate: template];

    if(!self.displayViewController)
    {
        NSLog(@"Could not showInboxMessage %@, %@ template not registered", action, template);
        return;
    }
    
    [[MCEInboxQueueManager sharedInstance] syncInbox];
}

+(void)registerPlugin
{
    [[NSNotificationCenter defaultCenter] addObserver:[self sharedInstance] selector:@selector(syncDatabase:) name:@"MCESyncDatabase" object:nil];
    
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(showInboxMessage:payload:) forAction: @"openInboxMessage"];
}
// gm keep-message-array
-(NSMutableArray *) getKeepMessagesArray {
    NSString *arrayFilename =[self getArrayFilename];
    NSMutableArray *messageArray = [[NSMutableArray alloc] initWithContentsOfFile: arrayFilename];
    if(messageArray == nil)    {         //Array file didn't exist... create one
        messageArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return messageArray ;
}
-(NSString *) getArrayFilename {
    //Creating a file path under iOS:
    //Search for the app's documents directory (copy+paste from Documentation)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //Create the full file path by appending the desired file name
    return ( [documentsDirectory stringByAppendingPathComponent:@"example.dat"]);
}
-(void) saveArray:(NSMutableArray *)messagesArray {
    NSString *arrayFilename =[self getArrayFilename];
    [messagesArray writeToFile:arrayFilename atomically:YES];
}
@end
