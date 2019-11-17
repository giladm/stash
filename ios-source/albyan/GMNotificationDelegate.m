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
#import "RemoteNotificationsManager.h"


#import "CustomNotifications.h"

@implementation GMNotificationDelegate


///INHOUSE IBM
NSDictionary    *_remoteUserInfo;
UIAlertView     *_remoteNotificationAlertView;
//END

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
    
   /*
    [_remoteNotificationAlertView dismissWithClickedButtonIndex:0
                                                       animated:NO];
    

    _remoteNotificationAlertView = nil;
    _remoteUserInfo = nil;
    
    _remoteNotificationAlertView = [[UIAlertView alloc] initWithTitle:CS_APPLICATION_NAME
                                                              message:[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"]
                                                             delegate:self
                                                    cancelButtonTitle:@"تجاهل"
                                                    otherButtonTitles:@"عرض", nil];
    [_remoteNotificationAlertView show];
    _remoteUserInfo = userInfo;
    */
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

#endif

- (void)launchWithOptions:(UIApplication *)application andOptions:(NSDictionary *)launchOptions {
    
   
}


- (void)IBMSettingAttributes:(NSString*)attributename :(NSString*)attributetext;
{
    ///Enter the attributes
    
    [[[MCEAttributesClient alloc] init] setUserAttributes:@{attributename:attributetext} completion:^(NSError *error) {
        if(error) {
            NSLog(@"Error while updating with attributename:'%@', attributetext:'%@' error is  %@",attributename,attributetext, error);
        }
        else {

            NSLog(@"Succesfully set attributename:'%@', attributetext:    %@",attributename,attributetext);        }
    }];

}

- (void)IBMSettingAttributestimestamp:(NSString*)attributename;
{
    
 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"]; //set required time format
    NSDate *now = [NSDate date];
   NSString *timestampString = [dateFormatter stringFromDate:now];
    
    
    [[[MCEAttributesClient alloc] init] setUserAttributes:@{attributename:timestampString} completion:^(NSError *error) {
        if(error) {
            NSLog(@"Error while updating with attributename:'%@', attributetext:'%@' error is  %@",attributename,timestampString, error);
        }
        else {
            
            NSLog(@"Succesfully set attributename:'%@', attributetext:    %@",attributename,timestampString);        }
    }];
    
}

-(void)storedetails;
{
  NSString *AppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *Appbuild = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    NSString *Devicetype = [UIDevice currentDevice].model;
   
   
    NSString *DeviceName = [UIDevice currentDevice].name;
    NSString *DeviceOSVersion = [UIDevice currentDevice].systemVersion;
    NSString *DeviceSoftware = [UIDevice currentDevice].systemName;
   
    
    [[MCEAttributesQueueManager sharedInstance] setUserAttributes:@{@"AppName":@"Albayan-IOS",
                                                                   @"AppVersion":AppVersion,
                                                                   @"Appbuild":Appbuild,
                                                                   @"Devicetype":Devicetype,
                                                                   @"DeviceName":DeviceName,
                                                                   @"DeviceOSVersion":DeviceOSVersion,
                                                                   @"DeviceSoftware":DeviceSoftware
                                                                   } ];
    
    
    
        
  
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView isEqual:_remoteNotificationAlertView] && buttonIndex == 1) {
       
        
         [[CustomNotifications sharedInstance] handleRemoteNotifications:_remoteUserInfo];
        
        
        
        
     
    }
}
// set the index of the tabbar where the inbox is hooked to


@end
