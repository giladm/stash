/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 *
 *  gilad m
 */
#import <MessageUI/MessageUI.h>
#import <IBMMobilePush/IBMMobilePush.h>

@interface URLDelegate : NSObject <MCEActionProtocol>
-(void)getURL:(NSDictionary*)action;
@end
