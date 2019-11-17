/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2016, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import UserNotifications;

@interface GMNotificationDelegate : NSObject <UNUserNotificationCenterDelegate>

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

- (void)handleRemoteNotifications:(NSDictionary *)userInfo;
-(void)PushOpenArticle:(NSDictionary*)action;
- (void)IBMSettingAttributes:(NSString*)attributename :(NSString*)attributetext;
- (void)IBMSettingAttributestimestamp:(NSString*)attributename;
-(void)storedetails;
- (void)launchWithOptions:(UIApplication *)application andOptions:(NSDictionary *)launchOptions;

@end
