/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2016, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

#import "GMNotificationDelegate.h"
#import <IBMMobilePush/IBMMobilePush.h>

@implementation GMNotificationDelegate

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000


// This allows notifications to be presented by the iOS system instead of the SDK while the app is open in iOS 10
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;
{
    NSDictionary * userInfo = notification.request.content.userInfo;
    NSLog(@"GMNotificationDelegate willPresentNotification:%@",userInfo);
    // check if app is in the foreground then handle the notification
    [self handleSimplePush:userInfo];
    completionHandler(UNNotificationPresentationOptionAlert+UNNotificationPresentationOptionSound+UNNotificationPresentationOptionBadge);
}

// This is where we will deal with category actions chosen by the user in iOS 10.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler;
{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSLog(@"GMNotificationDelegate didReceiveNotificationResponse:%@",userInfo);

    // at the end - call MCE notification reponse handler
    [MCENotificationDelegate.sharedInstance userNotificationCenter: center didReceiveNotificationResponse:response withCompletionHandler: completionHandler];
   
}

- (void) handleSimplePush:(NSDictionary *) aPush
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *aps=[aPush objectForKey:@"aps"];
    NSDictionary *alert=[aps objectForKey:@"alert"];
    NSString *body=nil;
    if([alert isKindOfClass:[NSString class]])
        body =(NSString *)alert ;
    else
        body =alert [@"body"];
    
    // App was active when notification has arrived. Open a dialog with an OK and cancel button
    UIAlertView *alertView =nil;
    NSString *action ;
    if (body !=nil && [body length]==0) {
        NSLog(@"Inbox Only. Don't show alert");
        return;
    }
    NSString * prodName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if(!prodName)
    {
        prodName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    }
    if (body !=nil) {
        if ( [alert isKindOfClass:[NSDictionary class]]) {
            action=[alert objectForKey:@"action-loc-key"] ==[NSNull null]  ?@"Open" : [alert objectForKey:@"action-loc-key"];
        } else {
            action = @"Open" ;
        }
        alertView = [[UIAlertView alloc] initWithTitle:prodName message:body
                                              delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:action, nil];
    }
    else {
        NSString *action_loc_key=[alert objectForKey:@"action-loc-key"] ==nil  ?@"Open" : [alert objectForKey:@"action-loc-key"];
        action = [NSString stringWithFormat:NSLocalizedString(action_loc_key, @"")];
        
        NSString *loc_key=[alert objectForKey:@"loc-key"] ==nil ? @"Use_a_default_message" : [alert objectForKey:@"loc-key"];
        NSString *loc_args=[alert objectForKey:@"loc-args"] ==nil ? nil : [alert objectForKey:@"loc-args"];
        if (loc_args != nil) {
            NSString *variableOne = @"";
            NSString *variableTwo = @"";
            NSString *variableThree = @"";
            int i = 0;
            for (NSString *eachVariable in [[[aPush valueForKey:@"aps"] valueForKey:@"alert"] valueForKey:@"loc-args"]) {
                switch (i) {
                    case 0:
                        variableOne = eachVariable;
                        break;
                    case 1:
                        variableTwo = eachVariable;
                        break;
                    case 2:
                        variableThree = eachVariable;
                        
                    default:
                        break;
                }
                i++;
            }
            
            
            NSString *locText = [NSString stringWithFormat:NSLocalizedString(loc_key, @""),variableOne,variableTwo,variableThree];
            NSLog(@"loc_key=%@, action_loc_key=%@, action=%@",loc_key,action_loc_key,action);
            
            alertView = [[UIAlertView alloc] initWithTitle:prodName message:locText
                                                  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:action, nil];
        }
    }
    
    [alertView show];
    
}

#pragma mark -
#pragma mark - UIAlertViewDelegate
//User clicks the 'Open' after a push when the app is open.
// this is the application which puts the message
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { // user select open
        NSLog(@"user clicks open simple");
    }
    else // user selected cancel
    {
        NSLog(@"user clicks cancel");
        
    }
}

#endif

@end
