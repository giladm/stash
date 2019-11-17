/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <Foundation/Foundation.h>
#import "UrlInboxActionPlugin.h"
#import <IBMMobilePush/IBMMobilePush.h>

@interface UrlInboxActionPlugin  ()
@property NSString * attribution;
@property NSString * mailingId;
@property NSString * richContentIdToShow;
@property id <MCETemplateDisplay> displayViewController;
@end

@implementation UrlInboxActionPlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)showUrlInboxMessage:(NSDictionary*)action payload:(NSDictionary*)payload
{
    NSString *url=action[@"value"][@"url"]; //
    if (!url) {
        NSLog(@"No URL. Aborting");
        return ;
    }
    NSString *urlLink=[NSString stringWithFormat:@"%@",url];
    NSURL *urlX = [NSURL URLWithString:urlLink];
    NSLog(@"URL for custom News. Opening %@ with Safari",urlLink);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        if (![[UIApplication sharedApplication] openURL:urlX]) {
            NSLog(@"App started as a result of push. Failed to open urlX:%@",[urlX description]);
        }
    });

    self.attribution=nil;
    if(payload[@"mce"] && payload[@"mce"][@"attribution"])
    {
        self.attribution = payload[@"mce"][@"attribution"];
    }
    
    self.mailingId=nil;
    if(payload[@"mce"] && payload[@"mce"][@"mailingId"])
    {
        self.mailingId = payload[@"mce"][@"mailingId"];
    }
    
    NSString * richContentId = action[@"value"];
  
    self.richContentIdToShow=richContentId;

}

+(void)registerPlugin
{
    [[NSNotificationCenter defaultCenter] addObserver:[self sharedInstance] selector:@selector(syncDatabase:) name:@"MCESyncDatabase" object:nil];
    
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(showUrlInboxMessage:payload:) forAction: @"UrlInboxMessage"];
}

@end
