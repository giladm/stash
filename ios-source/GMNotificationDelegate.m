/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2016, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

#import "MCENotificationDelegate.h"
#import "MCEInAppManager.h"
#import "MCESdk.h"

@implementation MCENotificationDelegate

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
    completionHandler(UNNotificationPresentationOptionAlert+UNNotificationPresentationOptionSound+UNNotificationPresentationOptionBadge);
}

// This is where we will deal with category actions chosen by the user in iOS 10.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler;
{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    [[MCEInAppManager sharedInstance] processPayload: userInfo];

    if([response.actionIdentifier isEqual:UNNotificationDefaultActionIdentifier])
    {
        [[MCESdk sharedInstance] performNotificationAction: userInfo];
    }
    else if([response.actionIdentifier isEqual:UNNotificationDismissActionIdentifier])
    {
        // Send mce event here once event is defined by server team.
    }
    else if([response isKindOfClass:[UNTextInputNotificationResponse class]])
    {
        UNTextInputNotificationResponse * textResponse = (UNTextInputNotificationResponse*)response;
        [[MCESdk sharedInstance] processDynamicCategoryNotification: userInfo identifier:response.actionIdentifier userText: textResponse.userText];
    }
    else
    {
        [[MCESdk sharedInstance] processDynamicCategoryNotification: userInfo identifier:response.actionIdentifier userText: nil];
    }
    
    // Currently text input doesn't exist, implement when available
    
    completionHandler();
}

#endif

@end
