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
#import "NewsDelegate.h"
#import <IBMMobilePush/IBMMobilePush.h>

@interface NewsDelegate ()
@end

@implementation NewsDelegate

#pragma mark Process Custom Action
-(void)getNews:(NSDictionary*)action
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        NSLog(@"Custom action with value %@", action[@"value"]);

        NSString *cu=action[@"value"][@"cu"]; //@"/five-senses";
        NSString *au=action[@"value"][@"au"];//@"/east-and-west/2017-03-07-1.2879453?_ga=1.173536288.2092588678.1488955851";
        if (!au || !cu) {
            NSLog(@"No Category or Article URL. Aborting");
            return ;
        }
        NSString *urlLink=[NSString stringWithFormat:@"http://www.albayan.ae%@%@",cu,au];
        NSURL *url = [NSURL URLWithString:urlLink];
        NSLog(@"URL for custom News. Opening %@ with Safari",urlLink);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
            if (![[UIApplication sharedApplication] openURL:url]) {
                NSLog(@"App started as a result of push. Failed to open url:%@",[url description]);
            }
        });
    });
}

@end
