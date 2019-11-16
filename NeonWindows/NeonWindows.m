//
//  NeonWindows.m
//  NeonWindows
//
//  Created by Rens Breur on 06/11/2019.
//  Copyright © 2019 Rens Breur. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <objc/runtime.h>

@interface NeonWindows: NSObject

@end

@interface NSThemeFrame: NSObject

- (id)initWithFrame:(struct CGRect)arg1 styleMask:(unsigned long long)arg2 owner:(id)arg3;
- (id)_cuiOptionsForCornerMaskForWindowType:(struct __CFString *)arg1;

@end

@implementation NeonWindows

+ (void)load {
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        // Border around window
        [self on:[NSThemeFrame class] change:@selector(initWithFrame:styleMask:owner:) to:@selector(_initWithFrame:styleMask:owner:)];
        [self on:[NSThemeFrame class] change:@selector(_cuiOptionsForCornerMaskForWindowType:) to:@selector(__cuiOptionsForCornerMaskForWindowType:)];

        // No window shadow
        [self on:[NSWindow class] change:@selector(hasShadow) to:@selector(_hasShadow)];

        // Controls color
        [self onClass:[NSColor class] change:@selector(controlAccentColor) to:@selector(_color)];
        [self onClass:[NSColor class] change:@selector(currentControlTint) to:@selector(_color)];
        [self onClass:[NSColor class] change:@selector(selectedControlColor) to:@selector(_color)];
        [self onClass:[NSColor class] change:@selector(highlightColor) to:@selector(_color)];
        [self onClass:[NSColor class] change:@selector(selectedContentBackgroundColor) to:@selector(_color)];
        [self onClass:[NSColor class] change:@selector(controlHighlightColor) to:@selector(_color)];
        [self onClass:[NSColor class] change:@selector(controlColor) to:@selector(_color)];

        [self onClass:[NSColor class] change:@selector(currentControlTint) to:@selector(_currentControlTint)];

    });
}

+ (void)on:(Class)class
    change:(SEL)from
        to:(SEL)to
{
    Method orig = class_getInstanceMethod(class, from);
    Method hook = class_getInstanceMethod([self class], to);

    class_addMethod(class, to, method_getImplementation(orig), method_getTypeEncoding(orig));
    class_replaceMethod(class, from, method_getImplementation(hook), method_getTypeEncoding(hook));
}

+ (void)onClass:(Class)class
         change:(SEL)from
             to:(SEL)to
{
    Method orig = class_getClassMethod(class, from);
    Method hook = class_getClassMethod([self class], to);

    class_addMethod(object_getClass((id)class), to, method_getImplementation(orig), method_getTypeEncoding(orig));
    class_replaceMethod(object_getClass((id)class), from, method_getImplementation(hook), method_getTypeEncoding(hook));
}

NSColor *neonWindowsReadColorFromDefaults()
{
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    return [NSColor colorWithRed:[defaults floatForKey:@"cr"] green:[defaults floatForKey:@"cg"] blue:[defaults floatForKey:@"cb"] alpha:1];
}

static NSColor *_neonWindowsColor;

NSColor *neonWindowsColor()
{
    if (!_neonWindowsColor) {
        _neonWindowsColor = neonWindowsReadColorFromDefaults();
    }
    return _neonWindowsColor;
}

- (id)_initWithFrame:(struct CGRect)arg1 styleMask:(unsigned long long)arg2 owner:(id)arg3;
{
    self = [self _initWithFrame:arg1 styleMask:arg2 owner:arg3];

    NSView *frame = (NSView *)self;
    frame.wantsLayer = YES;
    frame.layer.borderColor = neonWindowsColor().CGColor;
    frame.layer.borderWidth = 1.5;

    return self;
}

- (id)__cuiOptionsForCornerMaskForWindowType:(struct __CFString *)arg1;
{
    return nil;
}

- (BOOL)_hasShadow {
    return NO;
}

+ (NSColor *)_color {
    return neonWindowsColor();
}

+ (NSControlTint)_currentControlTint {
    return NSBlueControlTint;
}

@end
