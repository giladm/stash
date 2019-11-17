/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 *
 *  gilad
 */
#import "URLDelegate.h"
#import <IBMMobilePush/IBMMobilePush.h>

@interface URLDelegate ()
@end

@implementation URLDelegate

#pragma mark Process Custom Action
-(void)getURL:(NSDictionary*)action
{
    NSLog(@"Befor dispatch action=%@", action);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        NSLog(@"URL action with value %@", action[@"value"]);

        NSString *url=action[@"value"];//[@"url"]; //
        if (!url) {
            NSLog(@"No URL or Article URL. Aborting");
            return ;
        }
        NSString *urlLink=[NSString stringWithFormat:@"%@",url];
        NSURL *urlX = [NSURL URLWithString:urlLink];
        NSLog(@"URL for customer. Opening %@ with Safari",urlLink);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
            if (![[UIApplication sharedApplication] openURL:urlX]) {
                NSLog(@"App started as a result of push. Failed to open urlX:%@",[urlX description]);
            }
        });
    });
}

@end
