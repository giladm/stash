
//
//  GMHttpRestApi.m
//  Sample
//
//  Created by gilad on 2/26/17.
//  Copyright © 2017 IBM ExperienceOne Xtify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IBMMobilePush/IBMMobilePush.h>
#import "GMHttpRestApi.h"

@implementation GMHttpRestApi

-(id)init
{
    if (self = [super init])
    {
    }
    return self;
}

-(void)doCallApi : (double) latitude andLon:(double)longitude {
    NSError *error;
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"https://mcedemo.mybluemix.net/sptest"];
    //    NSURL *url = [NSURL URLWithString:@"http://localhost:3002/sptest"]; // for local testing
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    
    NSNumber *latNumber = [NSNumber numberWithDouble:latitude];
    NSNumber *lonNumber = [NSNumber numberWithDouble:longitude];
    MCEConfig * config = [[MCESdk sharedInstance] config];
    NSString *appkey=config.appKey;
    
    NSLog(@"Lat:%@ Lon:%@",[latNumber stringValue],[lonNumber stringValue]);
    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys:appkey,@"appkey", MCERegistrationDetails.userId,@"muid",MCERegistrationDetails.channelId,@"channelid",[latNumber stringValue],@"lat", [lonNumber stringValue],@"lon" ,nil];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSLog(@"Success");
            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        } else {
            NSLog(@"Error from post: %@",error);// The server answers with an error because it doesn't receive the params
        }
        
    }];
    
    [postDataTask resume];
    
}

@end
