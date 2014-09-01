//
//  DWGNicoVideoExtractor.m
//  DWGNicoVideoExtractor
//
//  Created by konomae on 2014/09/01.
//  Copyright (c) 2014 konomae. All rights reserved.
//

#import "DWGNicoVideoExtractor.h"

@interface DWGNicoVideoExtractor ()
@property (nonatomic, copy, readwrite) NSString *videoID;
@end

@implementation DWGNicoVideoExtractor

+ (void)fetchVideoURLFromID:(NSString *)videoID completion:(DWGCompletionHandler)completion {
    DWGNicoVideoExtractor *client = [[DWGNicoVideoExtractor alloc] initWithVideoID:videoID];
    client.completionHandler = completion;
    [client start];
}

- (instancetype)initWithVideoID:(NSString *)videoID {
    self = [super init];
    if (self) {
        self.videoID = videoID;
    }
    return self;
}

- (void)start {
    NSString *urlString = [NSString stringWithFormat:@"http://ext.nicovideo.jp/thumb_watch/%@?w=490&h=307", self.videoID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    //[req setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:29.0) Gecko/20100101 Firefox/29.0" forHTTPHeaderField:@"User-Agent"];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if (self.completionHandler) {
                self.completionHandler(nil, error);
            }
        }
        else {
            NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *params = [self parseJavaScript:script forIdentifier:self.videoID];
            [self loadVideoURL:params];
        }
    }];
}

- (void)loadVideoURL:(NSDictionary *)params {
    NSString *formData = [self.class URLEncodedStringFromDict:params];
    NSString *urlString = @"http://ext.nicovideo.jp/thumb_watch";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    req.HTTPBody = [formData dataUsingEncoding:NSUTF8StringEncoding];
    //[req setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:29.0) Gecko/20100101 Firefox/29.0" forHTTPHeaderField:@"User-Agent"];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *values = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (error) {
            if (self.completionHandler) {
                self.completionHandler(nil, error);
            }
        }
        else {
            [self videoInfoReceived:values];
        }
    }];
}

- (void)videoInfoReceived:(NSString *)values {
    NSDictionary *d = [self.class dictionaryFromURLEncodedString:values];
    NSURL *url = [NSURL URLWithString:d[@"url"]];
    
    /* Cookies are very important!
    NSHTTPCookieStorage *s = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *c in s.cookies) {
        [s deleteCookie:c];
    }*/
    
    if (self.completionHandler) {
        self.completionHandler(url, nil);
    }
}


#pragma mark - Parse JavaScript

- (NSDictionary *)parseJavaScript:(NSString *)script forIdentifier:(NSString *)videoID {
    NSString *thumbPlayKey = [self extractValueFromDictKey:@"thumbPlayKey" inScript:script];
    NSString *accessFromHash = [self extractValueFromDictKey:@"accessFromHash" inScript:script];
    
    NSMutableDictionary *d = @{}.mutableCopy;
    //d[@"thumbPlayKey"] = thumbPlayKey;
    d[@"k"] = thumbPlayKey; // required
    d[@"accessFromHash"] = accessFromHash;
    d[@"v"] = videoID;
    d[@"accessFromDomain"] = @"";
    d[@"accessFromCount"] = @"0";
    d[@"as3"] = @"1";
    
    return d;
}

- (NSString *)extractValueFromDictKey:(NSString *)key inScript:(NSString *)script {
    // 'key': 'value'
    NSString *pattern = [NSString stringWithFormat:@"'%@':\\s+'(.+)'", key];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:script options:0 range:NSMakeRange(0, script.length)];
    
    return [script substringWithRange:[result rangeAtIndex:1]];
}


#pragma mark - URL Encode/Decode

+ (NSString *)URLDecode:(NSString *)s {
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)s, CFSTR(""), kCFStringEncodingUTF8);
}

+ (NSString *)URLEncode:(NSString *)s {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)s, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
}

+ (NSDictionary *)dictionaryFromURLEncodedString:(NSString *)s {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (NSString *param in [s componentsSeparatedByString:@"&"]) {
        NSArray *elements = [param componentsSeparatedByString:@"="];
        if([elements count] != 2) continue;
        NSString *key = [self URLDecode:elements[0]];
        NSString *val = [self URLDecode:elements[1]];
        [params setObject:val forKey:key];
    }
    
    if (params.count > 0) return params;
    return nil;
}

+ (NSString *)URLEncodedStringFromDict:(NSDictionary *)dict {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in dict) {
        NSString *value = dict[key];
        NSString *escapedKey = [self URLEncode:key];
        NSString *escapedVal = [self URLEncode:value];
        NSString *escapedPair =[NSString stringWithFormat:@"%@=%@", escapedKey, escapedVal];
        [array addObject:escapedPair];
    }
    return [array componentsJoinedByString:@"&"];
}

@end
