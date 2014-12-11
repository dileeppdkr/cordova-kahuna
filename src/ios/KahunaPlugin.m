/*
 * Kahuna CONFIDENTIAL
 * __________________
 *
 *  2014 Kahuna, Inc.
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Kahuna, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Kahuna, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Kahuna, Inc.
 */
//
//  KahunaCordovaPlugin.m
//

#import "KahunaPlugin.h"
#import "KahunaAnalytics.h"

@implementation KahunaPlugin

static NSString *secretKey;

- (void)startWithKey:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSString* key = [command.arguments objectAtIndex:0];
    
    if (key != nil && [key length] > 0) {
        [KahunaAnalytics setDeepIntegrationMode:true];
        [KahunaAnalytics setSDKWrapper:@"cordova" withVersion:@""];
        [KahunaAnalytics startWithKey:key];
        secretKey = key;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Need non-nil & non-empty Secret Key."];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onStart:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    if (secretKey != nil && [secretKey length] > 0) {
        [KahunaAnalytics startWithKey:secretKey];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Need non-nil & non-empty Secret Key to be set in onStart."];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onStop:(CDVInvokedUrlCommand*)command {
    // Not implemented in iOS since we have the observer already setup.
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)trackEvent:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSString* eventName = [command.arguments objectAtIndex:0];
    
    if (eventName != nil && [eventName length] > 0) {
        [KahunaAnalytics trackEvent:eventName];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Need non-nil & non-empty event name."];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setUserCredentials:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSString* username = [command.arguments objectAtIndex:0];
    NSString* email = [command.arguments objectAtIndex:1];
    
    [KahunaAnalytics setUserCredentialsWithKey:KAHUNA_CREDENTIAL_USERNAME andValue:username];
    [KahunaAnalytics setUserCredentialsWithKey:KAHUNA_CREDENTIAL_EMAIL andValue:email];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)logout:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    
    [KahunaAnalytics logout];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setUserAttributes:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSDictionary *userAttributes = [command.arguments objectAtIndex:0];
    
    [KahunaAnalytics setUserAttributes:userAttributes];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)enablePush:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSDictionary *notificationOptions = [command.arguments objectAtIndex:0];
    
    NSUInteger notificationTypes = 0;
    id badgeArg = nil;
    id soundArg = nil;
    id alertArg = nil;
    
    if (notificationOptions && [notificationOptions isKindOfClass:[NSDictionary class]])
    {
        badgeArg = [notificationOptions objectForKey:@"badge"];
        soundArg = [notificationOptions objectForKey:@"sound"];
        alertArg = [notificationOptions objectForKey:@"alert"];
    }
    else
    {
        alertArg = @"true";
    }
    
    if ([badgeArg isKindOfClass:[NSString class]])
    {
        if ([badgeArg isEqualToString:@"true"])
            notificationTypes |= (1 << 0);
    }
    else if ([badgeArg boolValue])
        notificationTypes |= (1 << 0);
    
    if ([soundArg isKindOfClass:[NSString class]])
    {
        if ([soundArg isEqualToString:@"true"])
            notificationTypes |= (1 << 1);
    }
    else if ([soundArg boolValue])
        notificationTypes |= (1 << 1);
    
    if ([alertArg isKindOfClass:[NSString class]])
    {
        if ([alertArg isEqualToString:@"true"])
            notificationTypes |= (1 << 2);
    }
    else if ([alertArg boolValue])
        notificationTypes |= (1 << 2);
    
    if (notificationTypes == 0)
    {
        return;
    }

#ifdef NSFoundationVersionNumber_iOS_7_1
    // iOS 8 has a new way to register for notifications. This conditional code takes care of iOS 8 and
    // previous versions.
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
#endif
    
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)disablePush:(CDVInvokedUrlCommand*)command {
    // Not implemented in iOS since the OS controls enabling/disabling push
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setDebugMode:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    id value = [command.arguments objectAtIndex:0];
    if (!([value isKindOfClass:[NSNumber class]])) {
        value = [NSNumber numberWithBool:NO];
    }
    
    [KahunaAnalytics setDebugMode:[value boolValue]];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
