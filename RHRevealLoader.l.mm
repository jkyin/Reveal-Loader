//
//  RHRevealLoader.xm
//  RHRevealLoader
//
//  Created by Richard Heard on 21/03/2014.
//  Copyright (c) 2014 Richard Heard. All rights reserved.
//

#include <dlfcn.h>

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *prefs = [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rheard.RHRevealLoader.plist"] retain];
    NSString *libraryPath = @"/Library/MobileSubstrate/RevealServer";

    if([[prefs objectForKey:[NSString stringWithFormat:@"RHRevealEnabled-%@", [[NSBundle mainBundle] bundleIdentifier]]] boolValue]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:libraryPath]){
            if ([[NSFileManager defaultManager] fileExistsAtPath:libraryPath]){
                void *handle = dlopen([libraryPath UTF8String], RTLD_NOW);
                if(handle){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStart" object:nil];
                    NSLog(@"Successed, path %p", libraryPath);
                } else{
                    NSLog(@"Failed,  error: %s", dlerror());
                }
            }
        }
    }

    [pool drain];
}
