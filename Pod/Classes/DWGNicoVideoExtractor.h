//
//  DWGNicoVideoExtractor.h
//  DWGNicoVideoExtractor
//
//  Created by konomae on 2014/09/01.
//  Copyright (c) 2014 konomae. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DWGCompletionHandler)(NSURL *videoURL, NSError *error);

@interface DWGNicoVideoExtractor : NSObject
@property (nonatomic, copy, readonly) NSString *videoID;
@property (nonatomic, copy) DWGCompletionHandler completionHandler;
+ (void)fetchVideoURLFromID:(NSString *)videoID completion:(DWGCompletionHandler)completion;
- (instancetype)initWithVideoID:(NSString *)videoID;
- (void)start;
@end
