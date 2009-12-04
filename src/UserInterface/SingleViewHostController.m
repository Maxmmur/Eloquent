//
//  SingleViewHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 16.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SingleViewHostController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "BibleCombiViewController.h"
#import "CommentaryViewController.h"
#import "DictionaryViewController.h"
#import "GenBookViewController.h"
#import "HostableViewController.h"
#import "BibleSearchOptionsViewController.h"
#import "LeftSideBarViewController.h"
#import "RightSideBarViewController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SearchTextObject.h"

@interface SingleViewHostController ()

@end

@implementation SingleViewHostController

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -init] loading nib");        
    }
    
    return self;
}

- (id)initForViewType:(ModuleType)aType {
    self = [self init];
    if(self) {
        if(aType == bible) {
            contentViewController = [[BibleCombiViewController alloc] initWithDelegate:self];
            self.searchType = ReferenceSearchType;
        } else if(aType == commentary) {
            contentViewController = [[CommentaryViewController alloc] initWithDelegate:self];
            self.searchType = ReferenceSearchType;
        } else if(aType == dictionary) {
            contentViewController = [[DictionaryViewController alloc] initWithDelegate:self];
            self.searchType = ReferenceSearchType;        
        } else if(aType == genbook) {
            contentViewController = [[GenBookViewController alloc] initWithDelegate:self];
            self.searchType = IndexSearchType;        
        }
        
        // set hosting delegate
        [contentViewController setHostingDelegate:self];

        // load nib
        BOOL stat = [NSBundle loadNibNamed:SINGLEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SingleViewHostController -init] unable to load nib!");
        }        
    }
    
    return self;
}

- (id)initWithModule:(SwordModule *)aModule {
    self = [self init];
    if(self) {
        ModuleType moduleType = [aModule type];
        if(moduleType == bible) {
            contentViewController = [[BibleCombiViewController alloc] initWithDelegate:self andInitialModule:(SwordBible *)aModule];
            self.searchType = ReferenceSearchType;
        } else if(moduleType == commentary) {
            contentViewController = [[CommentaryViewController alloc] initWithModule:aModule delegate:self];
            self.searchType = ReferenceSearchType;
        } else if(moduleType == dictionary) {
            contentViewController = [[DictionaryViewController alloc] initWithModule:aModule delegate:self];
            self.searchType = ReferenceSearchType;
        } else if(moduleType == genbook) {
            contentViewController = [[GenBookViewController alloc] initWithModule:aModule delegate:self];
            self.searchType = IndexSearchType;
        }
        
        // set hosting delegate
        [contentViewController setHostingDelegate:self];
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:SINGLEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SingleViewHostController -init] unable to load nib!");
        }        
    }
    
    return self;    
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -awakeFromNib]");
    
    [super awakeFromNib];

    // set recent searche array
    [searchTextField setRecentSearches:[currentSearchText recentSearchsForType:self.searchType]];
        
    // set font for bottombar segmented control
    [leftSideBottomSegControl setFont:FontStd];
    [rightSideBottomSegControl setFont:FontStd];

    if(contentViewController != nil) {
        [self setupContentRelatedViews];
        [self adaptAccessoryViewComponents];
        [self adaptUIToCurrentlyDisplayingModuleType];
    }
}

#pragma mark - Methods

- (NSView *)view {
    return [(NSBox *)placeHolderView contentView];
}

- (void)setView:(NSView *)aView {
    [(NSBox *)placeHolderView setContentView:aView];
}

#pragma mark - Actions

- (IBAction)forceReload:(id)sender {
    [(ModuleCommonsViewController *)contentViewController setForceRedisplay:YES];
    [(ModuleCommonsViewController *)contentViewController displayTextForReference:[currentSearchText searchTextForType:[currentSearchText searchType]]];
    [(ModuleCommonsViewController *)contentViewController setForceRedisplay:NO];
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -contentViewInitFinished:]");
    
    // first let super class handle it's things
    [super contentViewInitFinished:aView];
    
    if([aView isKindOfClass:[ContentDisplayingViewController class]]) {
        self.contentViewController = (ContentDisplayingViewController *)aView;
        [self setupContentRelatedViews];
        [self adaptAccessoryViewComponents];
        [self adaptUIToCurrentlyDisplayingModuleType];
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [super removeSubview:aViewController];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {        
        // decode contentViewController
        contentViewController = [decoder decodeObjectForKey:@"HostableViewControllerEncoded"];
        [contentViewController setDelegate:self];
        [contentViewController setHostingDelegate:self];
        [contentViewController adaptUIToHost];
        
        self.currentSearchText = [decoder decodeObjectForKey:@"SearchTextObject"];

        [super initWithCoder:decoder];

        // load nib
        BOOL stat = [NSBundle loadNibNamed:SINGLEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SingleViewHostController -init] unable to load nib!");
        }

        // set window frame
        NSRect frame;
        frame.origin = [decoder decodePointForKey:@"WindowOriginEncoded"];
        frame.size = [decoder decodeSizeForKey:@"WindowSizeEncoded"];
        if(frame.size.width > 0 && frame.size.height > 0) {
            [[self window] setFrame:frame display:YES];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:contentViewController forKey:@"HostableViewControllerEncoded"];
    
    [super encodeWithCoder:encoder];
}

@end
