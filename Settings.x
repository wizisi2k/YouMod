// Settings.x
// Thanks to the original codes from YTUHD by PoomSmart - https://github.com/PoomSmart/YTUHD/blob/0e735616fd8fc6546339da7fdc78466f16f23ffd/Settings.x

#import <PSHeader/Misc.h>
#import <YouTubeHeader/YTSettingsGroupData.h>
#import <YouTubeHeader/YTSettingsPickerViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSearchableSettingsViewController.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsViewController.h>
#import <YouTubeHeader/YTUIUtils.h>
#import <substrate.h>
#import "Headers.h"

#define TweakName @"YouMod"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

static const NSInteger TweakSection = 'ytmo';

@interface YTSettingsSectionItemManager (YouMod)
- (void)updateYouModSectionWithEntry:(id)entry;
@end

NSBundle *YouModBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:TweakName ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:PS_ROOT_PATH_NS(@"/Library/Application Support/%@.bundle"), TweakName]];
    });
    return bundle;
}

// Settings Search Bar
%hook YTSettingsViewController
- (void)loadWithModel:(id)model fromView:(UIView *)view {
    %orig;
    if ([[self valueForKey:@"_detailsCategoryID"] integerValue] == TweakSection)
        MSHookIvar<BOOL>(self, "_shouldShowSearchBar") = YES;
}
- (void)setSectionControllers {
    %orig;
    if (MSHookIvar<BOOL>(self, "_shouldShowSearchBar")) {
        YTSettingsSectionController *settingsSectionController = [self settingsSectionControllers][[self valueForKey:@"_detailsCategoryID"]];
        YTSearchableSettingsViewController *searchableVC = [self valueForKey:@"_searchableSettingsViewController"];
        if (settingsSectionController)
            [searchableVC storeCollectionViewSections:@[settingsSectionController]];
    }
}
%end

%hook YTSettingsGroupData

- (NSArray <NSNumber *> *)orderedCategories {
    if (self.type != 1 || class_getClassMethod(objc_getClass("YTSettingsGroupData"), @selector(tweaks)))
        return %orig;
    NSMutableArray *mutableCategories = %orig.mutableCopy;
    [mutableCategories insertObject:@(TweakSection) atIndex:0];
    return mutableCategories.copy;
}

%end

%hook YTAppSettingsPresentationData

+ (NSArray <NSNumber *> *)settingsCategoryOrder {
    NSArray <NSNumber *> *order = %orig;
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound) {
        NSMutableArray <NSNumber *> *mutableOrder = [order mutableCopy];
        [mutableOrder insertObject:@(TweakSection) atIndex:insertIndex + 1];
        order = mutableOrder.copy;
    }
    return order;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateYouModSectionWithEntry:(id)entry {
    NSMutableArray <YTSettingsSectionItem *> *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = YouModBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    // Tweak Version (at the top)
    // Thanks to the original codes from YTweaks by fosterbarnes - https://github.com/fosterbarnes/YTweaks/blob/e921591a89b87256a2b37c4788bd99282f70d9c2/Settings.x
    YTSettingsSectionItem *tweakVersion = [YTSettingsSectionItemClass itemWithTitle:@"YouMod v1.0.0"
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:tweakVersion];

    // Section 0
    // Github
    YTSettingsSectionItem *github = [YTSettingsSectionItemClass itemWithTitle:nil
        titleDescription:@"Github"
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:github];

    // Issues
    YTSettingsSectionItem *issues = [YTSettingsSectionItemClass itemWithTitle:LOC(@"NEW_ISSUES")
        titleDescription:LOC(@"NEW_ISSUES_DESC") // Found bug or Feature request -> Report Issues
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/Tonwalter888/YouMod/issues/new"]];
        }
    ];
    [sectionItems addObject:issues];

    // Sources codes
    YTSettingsSectionItem *sourceCodes = [YTSettingsSectionItemClass itemWithTitle:LOC(@"SOURCE_CODES")
        titleDescription:LOC(@"SOURCE_CODES_DESC") // Take a look
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/Tonwalter888/YouMod"]];
        }
    ];
    [sectionItems addObject:sourceCodes];

    /*
    // Perference Mgr - NEEDS TO DO THE LOGIC
    YTSettingsSectionItem *github = [YTSettingsSectionItemClass itemWithTitle:nil
        titleDescription:@"Github"
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:github];
    */ 

    // Section 1
    // Navigation bar
    YTSettingsSectionItem *navbar = [YTSettingsSectionItemClass itemWithTitle:nil
        titleDescription:LOC(@"NAVBAR")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:navbar];

    // Hide YT logo
    YTSettingsSectionItem *hideytlogo = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_YT_LOGO")
        titleDescription:LOC(@"HIDE_YT_LOGO_DESC") // Hide the logo
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideYTLogo)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideYTLogo];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hideytlogo];

    // Center YT logo
    YTSettingsSectionItem *centerytlogo = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"CENTER_YT_LOGO")
        titleDescription:LOC(@"CENTER_YT_LOGO_DESC") // Set center logo
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(CenterYTLogo)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:CenterYTLogo];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:centerytlogo];

    // YT Premium logo
    YTSettingsSectionItem *ytpremium = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"PREMIUM_LOGO")
        titleDescription:LOC(@"PREMIUM_LOGO_DESC") // Change to premium logo
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(YTPremiumLogo)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:YTPremiumLogo];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:ytpremium];

    // Hide Notification button
    YTSettingsSectionItem *hidenoti = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_NOTIFICATION_BUTTON")
        titleDescription:LOC(@"HIDE_NOTIFICATION_BUTTON_DESC") // Hide the button from the nav bar
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideNoti)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideNoti];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidenoti];

    // Hide Search button
    YTSettingsSectionItem *hidesearch = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SEARCH_BUTTON")
        titleDescription:LOC(@"HIDE_SEARCH_BUTTON_DESC") // Hide the button from the nav bar
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideSearch)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideSearch];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidesearch];

    // Hide Voice Search button
    YTSettingsSectionItem *hidevoicesearch = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_VOICE_SEARCH_BUTTON")
        titleDescription:LOC(@"HIDE_VOICE_SEARCH_BUTTON_DESC") // Hide the button from the nav bar
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideVoiceSearch)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideVoiceSearch];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidevoicesearch];

    // Hide Cast button
    YTSettingsSectionItem *hidecast = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CAST_BUTTON")
        titleDescription:LOC(@"HIDE_CAST_BUTTON_DESC") // Hide the button from the nav bar + NOTE for cast button in vid overlay
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideCast)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideCast];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidecast];

    // Section 2
    // Feed
    YTSettingsSectionItem *feed = [YTSettingsSectionItemClass itemWithTitle:nil
        titleDescription:LOC(@"NAVBAR")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:feed];

    // Hide Mix Playlists
    YTSettingsSectionItem *hidemixplaylists = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_MIX_PLAYLISTS")
        titleDescription:LOC(@"HIDE_MIX_PLAYLISTS_DESC") // Hide from the feed
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideMixPlayLists)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideMixPlayLists];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidemixplaylists];

    // Hide Horizonal Shelf
    YTSettingsSectionItem *hidehorishelf = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HORIZONAL_SHELF")
        titleDescription:LOC(@"HIDE_HORIZONAL_SHELF_DESC") // Hide from the feed
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideHoriShelf)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideHoriShelf];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidehorishelf];

    // Hide Music Playlist Generator
    YTSettingsSectionItem *hidemusicgen = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_MUSIC_PLAYLISTS")
        titleDescription:LOC(@"HIDE_MUSIC_PLAYLISTS_DESC") // Hide from the feed
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideGenMusicShelf)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideGenMusicShelf];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidemusicgen];

    // Hide Shorts Shelf
    YTSettingsSectionItem *hideshortsself = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_SHELF")
        titleDescription:LOC(@"HIDE_SHORTS_SHELF_DESC") // Hide from the feed
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideShortsShelf)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideShortsShelf];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hideshortsself];

    // Hide Subbar
    YTSettingsSectionItem *hidesubbar = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SUBBAR")
        titleDescription:LOC(@"HIDE_SUBBAR_DESC") // Hide from the feed
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(HideSubbar)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:HideSubbar];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:hidesubbar];

    // Section 3
    // Player
    YTSettingsSectionItem *player = [YTSettingsSectionItemClass itemWithTitle:nil
        titleDescription:LOC(@"PLAYER")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:player];

    // More coming soon...

    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = YT_TUNE;
        [settingsViewController setSectionItems:sectionItems forCategory:TweakSection title:TweakName icon:icon titleDescription:nil headerHidden:NO];
    } else
        [settingsViewController setSectionItems:sectionItems forCategory:TweakSection title:TweakName titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == TweakSection) {
        [self updateYouModSectionWithEntry:entry];
        return;
    }
    %orig;
}

%end
