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

#define kAuthTokenKey       @"authToken"
#define kGatewayId          @"gatewayId"
#define kRequestTokenKey    @"requestToken"

#import "DigitalLifeConnector.h"
#import "DLDevice.h"
#import "EEControlEvent.h"

static DigitalLifeConnector *sharedConnector = nil;

@implementation DigitalLifeConnector

+(DigitalLifeConnector*)sharedConnector {
    if(sharedConnector) {
        return sharedConnector;
    }
    sharedConnector = [[DigitalLifeConnector alloc] init];
    return sharedConnector;
}

-(id)init {
    self = [super init];
    sharedConnector = self;
    self.devices = [[NSMutableArray alloc] init];
    
    [self authenticate];
    
    return self;
}

-(NSString*)getToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAuthTokenKey];
}

-(NSString*)getGateway {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kGatewayId];
}

-(NSString*)getRequestToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRequestTokenKey];
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
            NSString *reqestToke = [content objectForKey:@"requestToken"];
            NSArray *gateways = [content objectForKey:@"gateways"];
            NSDictionary *gateway = [gateways firstObject];
            NSString *gatewayId = [gateway objectForKey:@"id"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:authToken forKey:kAuthTokenKey];
            [defaults setObject:gatewayId forKey:kGatewayId];
            [defaults setObject:reqestToke forKey:kRequestTokenKey];
            [defaults synchronize];
            
            
            
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                
                NSString *url = [NSString stringWithFormat:@"%@%@/devices", kDLBaseURL, gatewayId];
                //Generate Request
                NSLog(@"Backend URL: %@", url);
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15.0];
                [request setHTTPMethod:@"GET"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [request setValue:kDLAppKey forHTTPHeaderField:@"appKey"];
                [request setValue:reqestToke forHTTPHeaderField:@"requestToken"];
                [request setValue:authToken forHTTPHeaderField:@"authToken"];
                
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
                    
                    //NSLog(@"Successfully listed devices with DL backend: %@", dict);
                    
                    NSArray *content = [dict objectForKey:@"content"];
                    
                    for(NSDictionary *d in content) {
                        DLDevice *foundDevice = nil;
                        for(DLDevice *aDevice in self.devices) {
                            if([aDevice.deviceGuid isEqualToString:[d objectForKey:@"deviceGuid"]]) {
                                foundDevice = aDevice; //We already have this device in our array, just update it
                            }
                        }
                        if(!foundDevice) {
                            foundDevice = [[DLDevice alloc] init];
                            foundDevice.deviceGuid = [d objectForKey:@"deviceGuid"];
                            foundDevice.deviceType = [d objectForKey:@"deviceType"];
                            [self.devices addObject:foundDevice];
                        }
                        
                        foundDevice.attributes = [d objectForKey:@"attributes"];
                        
                    }
                    
                    //NSLog(@"We found %d devices", [self.devices count]);
                    for(DLDevice *d in self.devices) {
                        //NSLog(@"deviceGuid: %@  deviceType: %@", d.deviceGuid, d.deviceType);
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:DigitalLifeConntectorDevicesUpdatedNotification object:self];
                    
                    [self performSelector:@selector(authenticate) withObject:nil afterDelay:1.0];
                    
                });
            });
            
        });
        
    });
}

-(void)updateDevice:(DLDevice*)device attribute:(NSString*)attributeName toValue:(NSString*)value withCompletionHandler:(void (^)(bool success))completion {
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        
        NSString *url = [NSString stringWithFormat:@"%@%@/devices/%@/%@/%@", kDLBaseURL, [self getGateway], device.deviceGuid, attributeName, value];
        //Generate Request
        NSLog(@"Backend URL: %@", url);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:kDLAppKey forHTTPHeaderField:@"appKey"];
        [request setValue:[self getRequestToken] forHTTPHeaderField:@"requestToken"];
        [request setValue:[self getToken] forHTTPHeaderField:@"authToken"];
        
        NSError *error = nil;
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if(error) {
            NSLog(@"Error updating device with DL backend: %@", [error localizedDescription]);
            completion(false);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *jsonError = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            if(jsonError) {
                NSLog(@"Error parsing device update json: %@", [error localizedDescription]);
                completion(false);
                return;
            }
            
            NSLog(@"Update completed successfully: %@", dict);
            completion(true);
            
        });
    });

    
}

@end
