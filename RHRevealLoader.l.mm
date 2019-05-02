//
//  RHRevealLoader.xm
//  RHRevealLoader
//
//  Created by Richard Heard on 21/03/2014.
//  Copyright (c) 2014 Richard Heard. All rights reserved.
//

#include <dlfcn.h>
#import "CaptainHook.h"

CHConstructor // code block that runs immediately upon load
{
    @autoreleasepool
    {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rheard.RHRevealLoader.plist"];
        NSString *libraryPath = @"/Library/MobileSubstrate/DynamicLibraries/RevealServer";
        if([[prefs objectForKey:[NSString stringWithFormat:@"RHRevealEnabled-%@", [[NSBundle mainBundle] bundleIdentifier]]] boolValue]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:libraryPath]){
                void *addr = dlopen([libraryPath UTF8String], RTLD_NOW);
                if(addr){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStart" object:nil];
                    NSLog(@"RevealLoader2 loaded %@ successed, address %p", libraryPath,addr);
                } else{
                    NSLog(@"RevealLoader2 loaded %@ failed, error %s", libraryPath,dlerror());
                }
            }
        }
    }
}

