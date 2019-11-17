//
//  AppDelegate.m
//  Al Bayan
//
//  Created by Vedran Čačić on 3/22/13.
//  Copyright (c) 2013 Vedran Čačić. All rights reserved.
//

#import "AppDelegate.h"
#import "ModelCache.h"
#import "Article.h"
#import "LoaderView.h"
//#import "GPPShare.h"
//#import "GPPSignInButton.h"
//#import "GPPSignIn.h"
#import "SectionView.h"
#import "RemoteNotificationsManager.h"
#import "NewsParser.h"
#import "GAI.h"



/*XtifyChange
//INHOUSE following lines add for Xtify

#import "XLappMgr.h" // Xtify Application Manager-- include this in your app
#import "XRInboxDbInterface.h"
#import "CompanyDetailsVC.h"
#import "CompanyCustomInbox.h"
#import "CompanyInboxVC.h"
#import "CompanyInboxHandler.h"
#import "XLCustomInboxMgr.h"
#import "RichDbMessage.h"

#import "XLRichJsonMessage.h"
*/

////IMC PUSH Header
#import <IBMMobilePush/MCELocationClient.h>
#import <IBMMobilePush/IBMMobilePush.h>
#import <UserNotifications/UserNotifications.h>
#import "GMNotificationDelegate.h"


// Action Plugins
#import "ActionMenuPlugin.h"
#import "DisplayWebViewPlugin.h"


// MCE Inbox Plugins
#import "MCEInboxActionPlugin.h"
#import "MCEInboxPostTemplate.h"
#import "MCEInboxDefaultTemplate.h"
#import "MCEInboxTableViewController.h"

// MCE InApp Plugins
#import "MCEInAppVideoTemplate.h"
#import "MCEInAppImageTemplate.h"
#import "MCEInAppBannerTemplate.h"

#import "CustomNotifications.h"

//END IMC PUSH

#import "RootViewController.h"
#import "RootViewController_iPad.h"



///inhouse for facebook/linkedin/Google plus --- ahmed
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <linkedin-sdk/LISDK.h>
#import <GooglePlus/GooglePlus.h>
///end


///Happiness code inhouse
#import "NSString+DSGHappinessCrypto.h"
#import "Util.h"
#import "Header.h"
#import "User.h"
#import "Application.h"
#import "Transaction.h"
#import "VotingRequest.h"
#import "VotingManager.h"

//


///interstitial mobile ad banner
#import "GoogleMobileAds/DFPInterstitial.h"




#define XML_URL @"http://media.albayan.ae/rss/mobile/index-data.xml"

//#define XML_URL @"http://media.albayan.ae/rss/mobile/index-data.xml"

#define StatusBarHeight 20.0f

//INHOUSE NEW CODE GOOGLE ANALYTICS

/******* Set your tracking ID here *******/
static NSString *const kTrackingId = @"UA-994719-7";
static NSString *const kAllowTracking = @"allowTracking";








//new Xtify code
@interface AppDelegate ()
{}




/*XtifyChange
///INHOUSE XTIFY CODE ADD

- (void) successfullyGotRichMessage:(XLRichJsonMessage *)inputMsg;  // Get single message
- (void) failedToGetRichMessage:(CiErrorType )errorType;  // Something went wrong while getting the message
- (void) handleSimplePush:(NSDictionary *) aPush withAlert:(BOOL) alertFlag;
//END XTIFY
*/
 
// Used for sending Google Analytics traffic in the background.
@property(nonatomic, assign) BOOL okToWait;
@property(nonatomic, copy) void (^dispatchHandler)(GAIDispatchResult result);


@end

////END

// Method in the class are well Defined based on their names Specific Method which are longer and has extensive function are described with a comment to explain further


@implementation AppDelegate
{
    UIImageView *secondSplashScreen;
    CSNavigationController *navController;
    LoaderView *loaderView;
    FontSliderView *frv;
    UIButton *hiddenButton;
    UIButton *secondHiddenButton;
    UIImageView *_arrow;
    
    
    ///INHOUSE XTIFY
    NSDictionary    *_remoteUserInfo;
    UIAlertView     *_remoteNotificationAlertView;
    //END
    
    
    
    ///Happiness code inhouse
     UIButton *happinesshiddenButton;
    UIButton *happinessbtn;
    UIWebView *HappinesswebView;
    NSString *serviceProviderSecret;
    NSString *clientID;
    NSString *microApp;
    NSString *microAppDisplay;
    NSString *serviceProvider;
    NSString *lang;
    
    REQUEST_TYPE request_type;
    
    UIView* happinessloadingView;
    ///

    
}


////IMC

-(instancetype)init
{
    if(self = [super init])
    {
        [[MCESdk sharedInstance] handleApplicationLaunch];
        
        
        
        // MCE Inbox plugins
        [MCEInboxActionPlugin registerPlugin];
        [MCEInboxPostTemplate registerTemplate];
        [MCEInboxDefaultTemplate registerTemplate];
        
        // MCE InApp Plugins
        [MCEInAppVideoTemplate registerTemplate];
        [MCEInAppImageTemplate registerTemplate];
        [MCEInAppBannerTemplate registerTemplate];
        
        // Action Plugins
        [ActionMenuPlugin registerPlugin];
        
        [DisplayWebViewPlugin registerPlugin];
      //  [TextInputActionPlugin registerPlugin];

        
         ////ACTIONTYPE --
      /*   MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
         [registry registerTarget: self withSelector:@selector(PushOpenArticle:) forAction: @"GetNews"];
        
       
        
        [registry registerTarget: self withSelector:@selector(performWebAction:) forAction: @"Getwebnews"];
        */
     
        
        
        [[MCEActionRegistry sharedInstance] registerTarget:[[CustomNotifications alloc] init] withSelector:@selector(CustomPushOpenArticle:) forAction:@"GetNews"];
        
        [[MCEActionRegistry sharedInstance] registerTarget:[[CustomNotifications alloc] init] withSelector:@selector(CustomPushOpenURL:) forAction:@"Getwebnews"];
        
      
        
        [[MCEActionRegistry sharedInstance] registerTarget:[[CustomNotifications alloc] init] withSelector:@selector(CustomPushOpenArticleJson:) forAction:@"GetNewsTest"];
        
        
       
    
        ///
         ///END
         
        
    
        
           }
    return self;
}
///END

@synthesize categoryView = _categoryView;

- (void) hideLoader {
    [loaderView hide];
}

- (void) showLoader {
    [loaderView show];
}

+(CGFloat)getDisplayWidth
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect.size.width;
}

+(CGFloat)getDisplayHeight
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect.size.height;
}

+(CGFloat)getStatusBarHeight {
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
		return StatusBarHeight;
	else
		return 0.0f;
}

+(CGRect)iPhoneViewRect
{
	return CGRectMake(0, [AppDelegate getStatusBarHeight],
					  [AppDelegate getDisplayWidth],
					  [AppDelegate getDisplayHeight] - [AppDelegate getStatusBarHeight]);
}

+(CGRect)iPadViewRect
{
	return CGRectMake([AppDelegate getStatusBarHeight], 0,
					  [AppDelegate getDisplayWidth] - [AppDelegate getStatusBarHeight],
					  [AppDelegate getDisplayHeight]);
}

-(UIView *)addStatusBarBackgroundView:(BOOL)isIPhone
{
	CGRect rect = isIPhone ? CGRectMake(0, 0, [AppDelegate getDisplayWidth], [AppDelegate getStatusBarHeight]) :
	CGRectMake(0, 0, [AppDelegate getStatusBarHeight], [AppDelegate getDisplayHeight]);
	UIView *view = [[UIView alloc] initWithFrame:rect];
	view.backgroundColor = [UIColor blackColor];
	[self.window addSubview:view];
	return view;
}

static void UnhandledExceptionHandler(NSException *exception) {
    
    NSLog(@"%@", [exception callStackSymbols]);
}



// CSSocial frame work handles on the social framework which is used in the project below is the link
//https://github.com/cloverstudio/CSSocial/tree/master/CSSocial.framework
// Details of CSSocial also is provided on the Git Repository


// CSKit frame work handles on the UI events and other layoutting methods which simplified the link of the framework has been added
//https://github.com/CSKit
// Details of CSKit also is provided on the Git Repository



///////IMC PUSH/////


#pragma mark Location Fetch Support
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    
    if(MCESdk.sharedInstance.config.geofenceEnabled)
    {
        MCELocationClient * sync = [[MCELocationClient alloc] init];
        sync.fetchCompletionHandler = completionHandler;
        [sync scheduleSync];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
     
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    [[[MCELocationClient alloc] init] handleEventsForBackgroundURLSession: identifier completionHandler: completionHandler];
}

#pragma mark

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [MCEEventService.sharedInstance sendPushEnabledEvent];
}

-(void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[MCESdk sharedInstance]registerDeviceToken:deviceToken];
    
    if(![application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [MCEEventService.sharedInstance sendPushEnabledEvent];
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [MCEEventService.sharedInstance sendPushEnabledEvent];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^_Nonnull __strong)())completionHandler
{
    [[MCEInAppManager sharedInstance] processPayload: notification.userInfo];
    
    [[MCESdk sharedInstance] processDynamicCategoryNotification: notification.userInfo identifier:identifier userText: responseInfo[ UIUserNotificationActionResponseTypedTextKey]];
    completionHandler();
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)withResponseInfo completionHandler:(void (^_Nonnull __strong)())completionHandler
{
     NSLog(@"%@ button clicked void (^_Nonnull __strong)", identifier);
    [[MCEInAppManager sharedInstance] processPayload: userInfo];
    completionHandler();
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
     NSLog(@"%@ button clicked", identifier);
    [[MCEInAppManager sharedInstance] processPayload: userInfo];
    [[MCESdk sharedInstance] processCategoryNotification: userInfo identifier:identifier];
    completionHandler();
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    //self.textView.text = [userInfo description];
    // We can determine whether an application is launched as a result of the user tapping the action
    // button or whether the notification was delivered to the already-running application by examining
    // the application state.
    
    
    
    [[MCEInAppManager sharedInstance] processPayload: userInfo];
    [[MCESdk sharedInstance] presentOrPerformNotification: userInfo];
    
    /*
    NSLog(@"xtify--PushNotification: %@",userInfo);
    if ([application applicationState] == UIApplicationStateActive) {
        
        
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
    }
    else {
        [[RemoteNotificationsManager sharedInstance] handleRemoteNotification:userInfo];
    }
*/
    
    
    
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[MCEInAppManager sharedInstance] processPayload: userInfo];
    [[MCESdk sharedInstance] presentDynamicCategoryNotification: userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[MCESdk sharedInstance] presentOrPerformNotification: notification.userInfo];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    [[MCESdk sharedInstance] processDynamicCategoryNotification: notification.userInfo identifier:identifier userText: nil];
    completionHandler();
}




- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    //center.delegate=GMNotificationDelegate.sharedInstance;
    
    NSLog( @"Handle push from foreground @S" );
    // custom code to handle push while app is in the foreground
    
   // NSLog( @"ERROR: %@ - %@", notification.request.content.userInfo, center );
    
 
//   print("\(notification.request.content.userInfo)")

   
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler

{
    NSLog( @"Handle push from background or closed" );
    
    NSLog( @"ERROR: %@ - %@", response.notification.request.content.userInfo, center );
    
  
    
    
    
    [[RemoteNotificationsManager sharedInstance] handleRemoteNotification:response.notification.request.content.userInfo];
    // if you set a member variable in didReceiveRemoteNotification, you will know if this is from closed or background
}


//////END IMC//////


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[BugSenseController sharedControllerWithBugSenseAPIKey:@"8e4a961b" userDictionary:nil sendImmediately:YES];
    
    
    
   
    
    
     sleep(1);
    
    
    ///end of inhouse
    NSLog(@"didFinishLaunchingWithOptions");
    NSSetUncaughtExceptionHandler(&UnhandledExceptionHandler);
    
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
	
	BOOL isIPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
   
    
    NSString *rootViewControllerClass = isIPhone ? @"RootViewController" : @"RootViewController_iPad";
    
   navController = [[CSNavigationController alloc] initWithRootViewController:[CSKit viewControllerFromString:rootViewControllerClass]];
    
    [navController setBackgroundImageName:@"NavigationBar"];
    
    self.window.rootViewController = navController;
    
    
    
    
    
    
   //////////////
   /*
   // self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *viewController1 = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
   // UIViewController *viewController2 = [[RootViewController_iPad alloc] initWithNibName:@"RootViewController_iPad" bundle:nil];
    
   // UINavigationController *navControllers = [[UINavigationController alloc] initWithRootViewController:viewController1];
    
    navController = [[CSNavigationController alloc] initWithRootViewController:viewController1];
    
    
   
    //self.window.backgroundColor = [UIColor whiteColor];
    
    [navController setBackgroundImageName:@"NavigationBar"];
    
    self.window.rootViewController = navController;
    */
   
    /////////////
    
   
    
	
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		self.statusBarBg = [self addStatusBarBackgroundView:isIPhone];
	}
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
    [self.window makeKeyAndVisible];
    
    NSDictionary *pushDictionary = launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    
    loaderView = [[LoaderView alloc] initWithFrame:[self.window frame]];
    [self.window addSubview:loaderView];
    
    frv = [[FontSliderView alloc] initWithFrame:CGRectMake(50, 60, 53, 100)];
    
    NSString *pushCategoryURL = [pushDictionary objectForKey:@"cu"];
    NSString *pushArticleURL = [pushDictionary objectForKey:@"au"];
    
    [[NSUserDefaults standardUserDefaults] setObject:pushCategoryURL forKey:kPushCategoryUrl];
    [[NSUserDefaults standardUserDefaults] setObject:pushArticleURL forKey:kPushArticleUrl];
    [[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:kFontSize];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLoadAfterSplash];
    [[NSUserDefaults standardUserDefaults] setFloat:100 forKey:kSliderValue];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSliderOpen];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kCategoryTitle];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _categoryView = [[SectionView alloc] init];
    _categoryView.navigationController = navController;
    
    _arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MenuArrow"]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [_arrow setFrame:CGRectMake(navController.navigationBar.frame.size.width-7, 17, 8, 12)];
    }
    else
    {
        [_arrow setFrame:CGRectMake(navController.navigationBar.frame.size.width+249, 17, 8, 12)];
    }
    _arrow.hidden = YES;
    [navController.navigationBar addSubview:_arrow];
    
    
    
    
    hiddenButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y+55, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-44)];
    hiddenButton.backgroundColor = [UIColor clearColor];
    [hiddenButton addTarget:self action:@selector(removeSlider) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        secondHiddenButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, [UIScreen mainScreen].bounds.size.width-200, [UIScreen mainScreen].bounds.size.height)];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        secondHiddenButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    }
    
    secondHiddenButton.backgroundColor = [UIColor clearColor];
    [secondHiddenButton addTarget:self action:@selector(removeMenu) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    /////Happniess Meter
    
    ///////
    
   // DEMO
    /*
     //set parameters for webview request
     serviceProviderSecret   = @"AC4DFB8477D12A8A";//To be replaced by one provided by DSG.
     clientID                = @"dmipbeatuser";//To be replaced by one provided by DSG.
     microApp                = @"Albayan";//To be replaced by the name of your microapp.
     serviceProvider         = @"DMIP";//To be replaced by the spName e.g. RTA, DEWA.
     */
     ///
    
    
    ///Producstion
    //set parameters for webview request
    serviceProviderSecret   = @"IO9JK7HH0CD7FNN";//To be replaced by one provided by DSG.
    clientID                = @"dmipbeatuser";//To be replaced by one provided by DSG.
    microApp                = @"Albayan";//To be replaced by the name of your microapp.
    serviceProvider         = @"DMIP";//To be replaced by the spName e.g. RTA, DEWA.
   
    ///
    
    
    
     ////inhouse happiness
    
    
   
     CGRect screenRect = [[UIScreen mainScreen] bounds];
     CGFloat screenHeight = screenRect.size.height;
    
    /*
  happinessbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [happinessbtn setImage:[UIImage imageNamed:@"sideicon"] forState:UIControlStateNormal];
     [happinessbtn addTarget:self action:@selector(actionLog:) forControlEvents:UIControlEventTouchDown];
     happinessbtn.frame = CGRectMake(0, screenHeight - 90, 40, 40);
     [self.window addSubview:happinessbtn];
     //[self.view insertSubview:happiness aboveSubview:categoriesScrollView];
     //
    */
    
    
    CGFloat happinesswidth = [UIScreen mainScreen].bounds.size.width;
    //CGFloat height = [UIScreen mainScreen].bounds.size.height;
    //
    ////happiness inhouse
    HappinesswebView = [[UIWebView alloc] initWithFrame:CGRectMake(-10,screenHeight - 250, happinesswidth + 10, 250)];
    HappinesswebView.delegate = self;
    HappinesswebView.backgroundColor = [UIColor clearColor];
    HappinesswebView.opaque = NO;
    HappinesswebView.scrollView.scrollEnabled = NO;
    
    
    
    /////Happiness loading view
    happinessloadingView = [[UIView alloc]initWithFrame:CGRectMake(happinesswidth/2, screenHeight/2, 80, 80)];
    happinessloadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:1];
    happinessloadingView.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *HappinessactivityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    HappinessactivityView.center = CGPointMake(happinessloadingView.frame.size.width / 2.0, 35);
    [HappinessactivityView startAnimating];
    HappinessactivityView.tag = 100;
    [happinessloadingView addSubview:HappinessactivityView];
    
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
    lblLoading.text = @"Loading...";
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    [happinessloadingView addSubview:lblLoading];
    
    
    ///
    
    
    ///Happiness code inhouse
    //stop webview bouncing
    HappinesswebView.scrollView.bounces = NO;
    
  //  CGRect screenRect = [[UIScreen mainScreen] bounds];
  //  CGFloat screenHeight = screenRect.size.height;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        happinesshiddenButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, 375, screenHeight-235)];
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        happinesshiddenButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-300)];
        // hiddenButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, [UIScreen mainScreen].bounds.size.width-50, [UIScreen mainScreen].bounds.size.height)];
    }
    happinesshiddenButton.backgroundColor = [UIColor clearColor];
    [happinesshiddenButton addTarget:self action:@selector(calcelWebviewRequest) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    ///////

    
    ///
    ///
  
    
    secondSplashScreen = [[UIImageView alloc] initWithFrame:self.window.frame];
    [self showSplashScreen];
    
   
    
    ////////IBM START///////
    ///IMC START
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if([UNUserNotificationCenter class])
    {
        UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
        //    center.delegate=MCENotificationDelegate.sharedInstance;
        center.delegate=GMNotificationDelegate.sharedInstance;
        NSUInteger options = UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge|UNAuthorizationOptionCarPlay;
        [center requestAuthorizationWithOptions: options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            // Enable or disable features based on authorization.
            NSLog(@"Notifications response %d, %@", granted, error);
            [application registerForRemoteNotifications];
            [center setNotificationCategories:nil];
            
            
        }];
    }
    else
#endif
        
        
        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            
            
            
            //    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
            
            //  [application registerUserNotificationSettings:settings];
            
            //[application registerForRemoteNotifications];
            
            
            
            
            ////IBM
            
            if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) )
            {
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                
                // if( options != nil )
                //  {
                //      NSLog( @"registerForPushWithOptions:" );
                //  }
            }
            else
            {
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                center.delegate = self;
                [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
                 {
                     if( !error )
                     {
                         [[UIApplication sharedApplication] registerForRemoteNotifications]; // required to get the app to do anything at all about push notifications
                         NSLog( @"Push registration success." );
                     }
                     else
                     {
                         NSLog( @"Push registration FAILED" );
                         NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                         NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
                     }
                 }];
            }
            ///
            
        }
        else {
            //register to receive notifications iOS <8
            UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
            [application registerForRemoteNotificationTypes:myTypes];
        }
    
///IBM END///
  
    

    
    
   
    
    
    
    
    
    ////INHOUSE OLD CODE
    /*
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = YES;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-994719-7"];
    */
    /// END OF OLD CODE
    
    ///INHOUSE NEW CODE FOR GOOGLE ANALYTICS
    NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    // User must be able to opt out of tracking
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    
    // If your app runs for long periods of time in the foreground, you might consider turning
    // on periodic dispatching.  This app doesn't, so it'll dispatch all traffic when it goes
    // into the background instead.  If you wish to dispatch periodically, we recommend a 120
    // second dispatch interval.
    // [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].dispatchInterval = -1;
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    self.tracker = [[GAI sharedInstance] trackerWithName:@"AlbayanIOS"
                                              trackingId:kTrackingId];
    ////
    
	//    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
	//                                                         diskCapacity:20 * 1024 * 1024
	//                                                             diskPath:nil];
	//    [NSURLCache setSharedURLCache:URLCache];
    return YES;
}




- (void) changeFontSize
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kSliderOpen]) {
        
        [self.window addSubview:hiddenButton];
        [self.window addSubview:frv];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSliderOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [frv removeFromSuperview];
        [hiddenButton removeFromSuperview];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSliderOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
}

-(void) removeSlider
{
    [self changeFontSize];
    [hiddenButton removeFromSuperview];
}

-(void) removeMenu
{
    [self toggleCategoryView];
    [secondHiddenButton removeFromSuperview];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedCategories" object:nil];
    }
}

///////happiness meter integration
#pragma mark - gesture recognizer
-(IBAction)actionTapGesturePerformed:(id)sender {
    [self calcelWebviewRequest];
}


#pragma mark - gesture recognizer
-(IBAction)actionLog:(id)sender {
    
    
    EMReachability *networkReachability = [EMReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"مشكلة في شبكة الانترنت");
    }
    else
    
    {
    NSLog(@"CATEGORY action log");
    // UIButton *button = (UIButton *)sender;
    //  NSInteger tag = button.tag;
    NSInteger tag=2;
    request_type = tag;
    
    [self.window addSubview:happinessloadingView];
   [self.window addSubview:HappinesswebView];
    
    [self logRequestWithVotingManager];
    }
    
}

-(void)logRequestWithVotingManager {
    
    //set your preferred language accordingly. e.g. ar, en
    //  lang = (self.segmentedControl.selectedSegmentIndex == 0) ? @"en" : @"ar";
    lang = @"ar";
    
    //To be replaced by the English/Arabic micro app display name.
    // microAppDisplay = (self.segmentedControl.selectedSegmentIndex == 0) ? @"Micro App" : @"مايكرو أيب";
    microAppDisplay = @"Micro App ";
    //To be replaced by the credentials if present.
    User *user = [[User alloc] initWithPrams:@"ANONYMOUS" username:@"" email:@"" mobile:@""];
    
    //set themeColor as per your requirements e.g. #ff0000, #00ff00
    Header *header = [[Header alloc] initWithPrams:[Util currentTimestamp]
                                   serviceProvider:serviceProvider
                                      request_type:request_type
                                          microApp:microApp
                                   microAppDisplay:microAppDisplay
                                        themeColor:@"#BF232A"];
    
    //To be replaced by the credentials if present.
    Application *application = [[Application alloc] initWithPrams:@"Albayan_apps"
                                                             type:@"SMARTAPP"
                                                         platform:@"IOS"
                                                              url:@"https://itunes.apple.com/ae/app/shyft-albyan/id668577002"
                                                            notes:@"MobileSDK Vote"];
    
    //To be replaced by the credentials if present.
    Transaction *transaction = [[Transaction alloc] initWithPrams:@"SAMPLE123-REPLACEWITHACTUAL!"
                                                      gessEnabled:@"false"
                                                      serviceCode:@""
                                               serviceDescription:@"demo transaction"
                                                          channel:@"WEB"];
    
    //create the voting request
    VotingRequest *votingRequest = [[VotingRequest alloc] initWithPrams:user
                                                                 header:header
                                                            application:application
                                                            transaction:transaction];
    
    //init voting manager to execute the request
    VotingManager *votingManager = [[VotingManager alloc] initWithPrams:serviceProviderSecret clientID:clientID lang:lang];
    
    [votingManager loadRequestWithWebView:HappinesswebView usingVotignRequest:votingRequest];
    
    HappinesswebView.alpha = 1.0f;
    
    [self.window addSubview:happinesshiddenButton];
    NSLog(@"CATEGORY hidden button active");
    
    
    
    
}

//calcel the webview request
-(void)calcelWebviewRequest {
    
    //load blank page
    [HappinesswebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
    //hide webview
    HappinesswebView.alpha = 0.0f;
    
    [happinesshiddenButton removeFromSuperview];
    
    [HappinesswebView removeFromSuperview];
    //[self.view addSubview:happiness];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [happinessloadingView setHidden:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [happinessloadingView setHidden:NO];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if([[request.URL absoluteString] containsString:@"happiness://done"]) {
        [self calcelWebviewRequest];
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    NSLog(@"didFailLoadWithError: %@", error);
}



////////
// This method toggles between selection of the categories to be viewed in the home page.

-(void) toggleCategoryView
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSliderOpen]) {
        [self changeFontSize];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSliderOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self handleIpadTransform];
        return;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kSectionOpen]) {
        _arrow.hidden = NO;
        [self.window addSubview:_categoryView];
        [self.window addSubview:secondHiddenButton];
        [UIView animateWithDuration:0.5
                         animations:^{
                             
                             CGAffineTransform transform = CGAffineTransformMakeTranslation(-200, 0);
                             self.window.rootViewController.view.transform = transform;
                             _categoryView.transform = transform;
                             
                         }];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAreDifferentCategoriesSelected];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSectionOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else{
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kAreDifferentCategoriesSelected]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SectionActive" object:nil];
        }
        _arrow.hidden = YES;
        [secondHiddenButton removeFromSuperview];
        [UIView animateWithDuration:0.5
                         animations:^{
                             
                             CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 0);
                             self.window.rootViewController.view.transform = transform;
                             _categoryView.transform = transform;
                             
                         }];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSectionOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[ModelCache sharedCache]saveCategories];
    }
}


// Handle Ipad Transformation Ipad has different layout then iphone
// as its arabic it needs to be right to left
// All those Transformation to be a universal applicaiton are handled in the below method

-(void) handleIpadTransform {
    
    
    NSInteger translationX = 0;
    __block int flag = 0;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kSectionOpen]) {
        
        translationX = -200;
        
        _arrow.hidden = NO;
        [self.window addSubview:secondHiddenButton];

        [self.window addSubview:_categoryView];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAreDifferentCategoriesSelected];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSectionOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        _arrow.hidden = YES;
        [secondHiddenButton removeFromSuperview];
   //     [_categoryView removeFromSuperview];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kAreDifferentCategoriesSelected]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SectionActive" object:nil];
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSectionOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
        flag = 1;
        
        translationX = 0;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(translationX, 0);
    
    //CGAffineTransform transform2 = CGAffineTransformIdentity;
    
   /// CGAffineTransform translate2 = CGAffineTransformMakeTranslation(translationX, 0);

    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGAffineTransform rotate;
  //  CGAffineTransform rotate2;
    
    if (orientation == UIInterfaceOrientationLandscapeRight) {
        
        ///INHOUSE CHANGE FFIR IOS8 MENU
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            rotate = CGAffineTransformMakeRotation (M_PI * 90 / 180.0f);
           
        }
        else{
            rotate = CGAffineTransformMakeRotation (M_PI * 0 / 180.0f);
            
        }
        //   rotate2 = CGAffineTransformMakeRotation (M_PI * 0 / 180.0f);
        
        transform = CGAffineTransformConcat(translate, rotate);
        // transform2 = CGAffineTransformConcat(translate2, rotate2);
        
    }
    
    else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        
        
        ///INHOUSE CHANGE FFIR IOS8 MENU
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            rotate = CGAffineTransformMakeRotation ( M_PI * 270 / 180.0f);
        }else{
            rotate = CGAffineTransformMakeRotation ( M_PI * 0 / 180.0f);
        }
        //    rotate2 = CGAffineTransformMakeRotation (M_PI * 0 / 180.0f);
        
        transform = CGAffineTransformConcat(translate, rotate);
        //   transform2 = CGAffineTransformConcat(translate2, rotate2);
        
    }
    
    [UIView animateWithDuration:0.5
                     animations:^{
                     //    [self.window addSubview:_categoryView];
                         self.window.rootViewController.view.transform = transform;
                         _categoryView.transform = transform;
                         
                     } completion:^(BOOL finished) {
                         if (flag == 1) {
                             [_categoryView removeFromSuperview];
                             flag = 0;
                             [[ModelCache sharedCache] saveCategories];
                         }
                     }];
}

#pragma mark - Rotation
-(NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else{
        return UIInterfaceOrientationMaskLandscape;
    }
    
}
    
- (void)applicationWillResignActive:(UIApplication *)application
{
    
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    _tryRefresh = YES;
    
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //INHOUSE Google Analytic
    /***************Google Analytic************/
    
    [self sendHitsInBackground];
    
    /************END****************/
    


}
//INHOUSE Google Analytic
/***************Google Analytic************/
// This method sends hits in the background until either we're told to stop background processing,
// we run into an error, or we run out of hits.  We use this to send any pending Google Analytics
// data since the app won't get a chance once it's in the background.
- (void)sendHitsInBackground {
    self.okToWait = YES;
    __weak AppDelegate *weakSelf = self;
    __block UIBackgroundTaskIdentifier backgroundTaskId =
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        weakSelf.okToWait = NO;
    }];
    
    if (backgroundTaskId == UIBackgroundTaskInvalid) {
        return;
    }
    
    self.dispatchHandler = ^(GAIDispatchResult result) {
        // If the last dispatch succeeded, and we're still OK to stay in the background then kick off
        // again.
        if (result == kGAIDispatchGood && weakSelf.okToWait ) {
            [[GAI sharedInstance] dispatchWithCompletionHandler:weakSelf.dispatchHandler];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    };
    [[GAI sharedInstance] dispatchWithCompletionHandler:self.dispatchHandler];
}


/************END****************/

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    
    NSLog(@"XTify--Application moved to Foreground");
  
    /*XtifyChange
    [[XLappMgr get] appEnterForeground];
  */
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
   }

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    
    NSLog(@"xtify--Application applicationDidBecomeActive");
    /*XtifyChange
    [[XLappMgr get] appEnterActive];
*/
   
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAfterBackground" object:nil];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    /******Google ANALYTIC*//////////
    
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    /**********END*******/

    ///END
    
    
    ////start of banner interstitial
    
    GADRequest *request = [GADRequest request]; // here you need to crate object of GADRequest
    _interstitial = [[GADInterstitial alloc] init];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
   // _interstitial.adUnitID =@"/5900/alb-app/ios/phone/home";
        
      //  _interstitial.adUnitID =@"/5900/e247-app/test";
        
        _interstitial.adUnitID =@"/5900/alb-app/ios/phone/home";
        
         NSLog(@"_interstitial Phone");
    }
    else
    {
        
        _interstitial.adUnitID =@"/5900/alb-app/ios/tablet/home";
         NSLog(@"_interstitial tablet");
    }
    _interstitial.delegate = self;
    //6
   // request.testDevices = @[ @"589a84b4fb225acefbeda87086c38548" ];
    ///5S
   // request.testDevices = @[ @"54bf19e7b32c36f1e9ad0d86628e73a8" ];
    [_interstitial loadRequest:request];
    
    //end of banner
}

- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    
    
    NSLog(@"==%@",[error localizedDescription]);
    
    
}

-(void)interstitialWillPresentScreen:(GADInterstitial *)ad{
    NSLog(@"on screen");
    
    [self hideLoader];
}
- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    
    [interstitial presentFromRootViewController:self.window.rootViewController];
    
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/////INHOUSE ADDED EXCLUSIVE FOR FACEBOOK
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    
    ///inhouse change by ahmed for facebook/linkedin/googleplus
    
    if ([LISDKCallbackHandler shouldHandleUrl:url]) {
        
        return [LISDKCallbackHandler application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
       
    }else if([[FBSDKApplicationDelegate sharedInstance] application:application
                                                                 openURL:url
                                                       sourceApplication:sourceApplication
                                                              annotation:annotation])
    {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }    else
    {
        return [GPPURLHandler handleURL:url
                      sourceApplication:sourceApplication
                             annotation:annotation];
    }

    
    return YES;
    
    ///end
}




// CSSocial does not work on Simulators hence below method would help you understand the same
/*  inhouse code hidden for working facebook
- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    // Handle Google+ sign-in button URL.
/* commented arm64error
#if TARGET_IPHONE_SIMULATOR
	return YES;
#else
	return [CSSocial openURL:url sourceApplication:sourceApplication annotation:annotation];
#endif
 

}
 */

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    /* commented arm64error
    return [CSSocial handleOpenURL:url];
     */
#endif
}





#pragma mark - Remote Notifications
 /*XtifyChange
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Application did register with device token: %@", deviceToken);
    [[RemoteNotificationsManager sharedInstance] registerWithDeviceToken:deviceToken];
   
    [[XLappMgr get] registerWithXtify:deviceToken ];
  
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Application failed to register with error: %@", error.description);
    [[RemoteNotificationsManager sharedInstance] registerWithDeviceToken:nil];
    
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
   
   // [[RemoteNotificationsManager sharedInstance] handleRemoteNotification:userInfo];
//  [[RemoteNotificationsManager sharedInstance] handleRemoteNotification:_remoteUserInfo];
   
//    if (userInfo !=nil && [userInfo objectForKey:@"RN"]!=[NSNull null] && [[userInfo objectForKey:@"RN"] length] > 0 )
//    {
 //       NSLog(@"PushNotification: %@",userInfo);
 //   }
//    application.applicationIconBadgeNumber = 1;
//    application.applicationIconBadgeNumber = 0;
  
    // Check if content-available is there to create a dynamic category or for background download
   
     NSLog(@"xtify--PushNotification: %@",userInfo);
    if ([application applicationState] == UIApplicationStateActive) {
        
        
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
    }
    else {
        [[RemoteNotificationsManager sharedInstance] handleRemoteNotification:userInfo];
    }


    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    
   // [[XLappMgr get] removeAllNotifications];
    
    
}


*/


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView isEqual:_remoteNotificationAlertView] && buttonIndex == 1) {
        
        [[RemoteNotificationsManager sharedInstance] handleRemoteNotification:_remoteUserInfo];
    }
}

// Toggle between Cateogires are handled in the below method


-(void) toggleCategoryViewAndPop {
    [self toggleCategoryView];
    [navController popToRootViewControllerAnimated:YES];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAreDifferentCategoriesSelected] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedCategories" object:nil];
    }
}





///INHOUSE CHANGE FOR XTIFY PUSH YES/NO
-(void) NotificationHome
{
    
    
    [navController popToRootViewControllerAnimated:YES];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAreDifferentCategoriesSelected] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedCategories" object:nil];
    }
    
    
}

// END OF INHOUSE

//Parsing of the responded XML

- (void) downloadAndParseXml {
    NewsParser *newsParserDelegate = [[NewsParser alloc] init];
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:XML_URL]];
    [xmlparser setDelegate:newsParserDelegate];
    [xmlparser setShouldResolveExternalEntities:NO];
    
    BOOL ok = [xmlparser parse];//NO;//
    if (ok == NO) {
        NSLog(@"error");
    } else {
        NSLog(@"OK");
    }
}

- (void) showSplashScreen
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"splash_url"] != nil)
    {
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/splash.png", docDir];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                [secondSplashScreen setImage:[UIImage imageWithContentsOfFile:pngFilePath]];
                [self.window addSubview:secondSplashScreen];
                [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(removeSplashScreen) userInfo:nil repeats:NO];
                
            }];
            
        }
        else
        {
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"splash_url"]]]
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       if (data != (id)[NSNull null] && [data length] != 0)
                                       {
                                           [secondSplashScreen setImage:[UIImage imageWithData:data]];
                                           [self.window addSubview:secondSplashScreen];
                                           [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(removeSplashScreen) userInfo:nil repeats:NO];
                                       }
                                   }];
        }
    }
}

- (void) removeSplashScreen
{
    [secondSplashScreen removeFromSuperview];
    
}
-(void) application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation{
    
  //  NSLog(@"Orientation : %d",oldStatusBarOrientation);
    
    int orientationInt = oldStatusBarOrientation;
    
    if (loaderView != nil) {
        [loaderView changedOrientation:orientationInt];
        
    }
    
    if (_categoryView !=nil) {
        [_categoryView changedOrientation:orientationInt];
        
    }
    
    
}


@end
