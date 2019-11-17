//
//  AppDelegate.h
//  Al Bayan
//
//  Created by Vedran Čačić on 3/22/13.
//  Copyright (c) 2013 Vedran Čačić. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontSliderView.h"
#import "ModelCache.h"
#import "SectionView.h"
#import "GAI.h"

///IBM
#import <UserNotifications/UserNotifications.h>  
//


#import <GoogleMobileAds/DFPBannerView.h>
#import <GoogleMobileAds/GADAppEventDelegate.h>
#import <GoogleMobileAds/GADAdSizeDelegate.h>
#import <GoogleMobileAds/GADBannerViewDelegate.h>
#import "GAITrackedViewController.h"
///interstitial mobile ad banner
#import "GoogleMobileAds/DFPInterstitial.h"

@class GPPSignInButton;
@class ViewController;
@class GPPShare;

//INHOUSE XTIFY
//new Xtify code
@class XLappMgr;
//END

//@interface AppDelegate : UIResponder <UIApplicationDelegate> {
@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>{
    //INHOUSE new Xtify code
    UINavigationController *inboxNavController ,*settingNavController;
    //new Xtify code end here
    SectionView *_categoryView;
}


///IBM

///IBM CHANGE
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
///

/*
//INHOUSE new Xtify code
- (UINavigationController *) setupPortraitUserInterface;
- (void) redirectConsoleLogToDocumentFolder; //debug log to a file
- (void) doMyUpdate:(XLappMgr *)appM ;
- (UINavigationController *) developerNavigationController:(XLappMgr *)appM ;
- (void) moveToInbox:(XLappMgr *)appM ;
//new Xtify code end here
*/

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *statusBarBg;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) GPPSignInButton *signInButton;
@property (strong, nonatomic) GPPShare *share;
@property (strong, nonatomic) SectionView *categoryView;
@property (nonatomic, assign) BOOL tryRefresh;
///INHOUSE GOOGLE ANALYTIC
@property(nonatomic, strong) id<GAITracker> tracker;
//END

/// The interstitial ad.
@property(nonatomic, strong) GADInterstitial *interstitial;

///Happiness code inhouse
@property(nonatomic , weak)IBOutlet UIWebView *webView;
@property(nonatomic , weak)IBOutlet UISegmentedControl *segmentedControl;
//
- (void) changeFontSize;
- (void) toggleCategoryView;
- (void) removeMenu;
- (void) toggleCategoryViewAndPop;
- (void) NotificationHome;

- (void) showSplashScreen;
- (void) downloadAndParseXml;

- (void) hideLoader;
- (void) showLoader;

+(CGFloat)getStatusBarHeight;
+(CGFloat)getDisplayWidth;
+(CGFloat)getDisplayHeight;

+(CGRect)iPhoneViewRect;
+(CGRect)iPadViewRect;

@end
