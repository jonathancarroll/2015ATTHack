//
//  DigitalLifeConnector.m
//  MasterApp
//
//  Created by Jon Carroll on 1/3/15.
//  Copyright (c) 2015 Orbotix, Inc. All rights reserved.
//

#define kDLBaseURL      @"https://systest.digitallife.att.com:443/penguin/api/"
#define kDLUserId       @"553474438"
#define kDLPass         @"NO-PASSWD"
#define kDLDomain       @"DL"
#define kDLAppKey       @"TE_BDF8DA452DF1FBD7_1"

#define kAuthTokenKey   @"authToken"
#define kGatewayId      @"gatewayId"

#import "DigitalLifeConnector.h"

@implementation DigitalLifeConnector

-(id)init {
    self = [super init];
    
    [self authenticate];
    
    return self;
}

-(NSString*)getToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAuthTokenKey];
}

-(NSString*)getGateway {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kGatewayId];
}

-(void)authenticate {
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        //Generate URL
        NSString *url = [NSString stringWithFormat:@"%@authtokens?userId=%@&password=%@&domain=%@&appKey=%@", kDLBaseURL, kDLUserId, kDLPass, kDLDomain, kDLAppKey];
        //Generate Request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSError *error = nil;
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if(error) {
            NSLog(@"Error authenticating with DL backend: %@", [error localizedDescription]);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *jsonError = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            if(jsonError) {
                NSLog(@"Error parsing authentication json: %@", [error localizedDescription]);
                return;
            }
            
            NSLog(@"Successfully authenticated with DL backend: %@", dict);
            NSDictionary *content = [dict objectForKey:@"content"];
            NSString *authToken = [content objectForKey:@"authToken"];
            NSArray *gateways = [content objectForKey:@"gateways"];
            NSDictionary *gateway = [gateways firstObject];
            NSString *gatewayId = [gateway objectForKey:@"id"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:authToken forKey:kAuthTokenKey];
            [defaults setObject:gatewayId forKey:kGatewayId];
            [defaults synchronize];
            
            
            
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                
                NSString *url = [NSString stringWithFormat:@"%@%@/devices", kDLBaseURL, gatewayId];
                //Generate Request
                NSLog(@"Backend URL: %@", url);
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15.0];
                [request setHTTPMethod:@"GET"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                
                NSError *error = nil;
                NSURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                if(error) {
                    NSLog(@"Error listing devices with DL backend: %@", [error localizedDescription]);
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *jsonError = nil;
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                    if(jsonError) {
                        NSLog(@"Error parsing device listing json: %@", [error localizedDescription]);
                        return;
                    }
                    
                    NSLog(@"Successfully listed devices with DL backend: %@", dict);
                });
            });
            
        });
        
    });
}

@end
