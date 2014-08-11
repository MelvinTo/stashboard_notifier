//
//  StatusPreferenceViewController.h
//  iStatus
//
//  Created by Melvin Tu on 8/9/14.
//  Copyright (c) 2014 Tu Melvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusPreferenceViewController : NSViewController <NSTextFieldDelegate, NSWindowDelegate>  {
    BOOL _isChangedInLastSession;
}

-(IBAction) onAutoStartCheckbox:(id)sender;
-(IBAction) onSliderChange:(id)sender;

@property (nonatomic,retain) IBOutlet NSButton *autoStartButton;
@property (nonatomic,retain) IBOutlet NSTextField * stashboardURL;
@property (nonatomic,retain) IBOutlet NSSlider *checkIntervalSlider;


@end
