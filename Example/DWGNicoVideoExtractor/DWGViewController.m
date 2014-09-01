//
//  DWGViewController.m
//  DWGNicoVideoExtractor
//
//  Created by konomae on 09/01/2014.
//  Copyright (c) 2014 konomae. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <DWGNicoVideoExtractor/DWGNicoVideoExtractor.h>
#import "DWGViewController.h"

@interface DWGViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation DWGViewController

- (IBAction)buttonPressed:(UIButton *)sender {
    NSString *videoID = self.textField.text;
    [DWGNicoVideoExtractor fetchVideoURLFromID:videoID completion:^(NSURL *videoURL, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [vc.moviePlayer prepareToPlay];
        [vc.moviePlayer play];
        [self presentMoviePlayerViewControllerAnimated:vc];
    }];
}

@end
