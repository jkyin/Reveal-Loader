//
//  RHDownloadReveal.m
//  RHDownloadReveal
//
//  Created by Richard Heard on 21/03/2014.
//  Copyright (c) 2014 Richard Heard. All rights reserved.
//

#include <unistd.h>
#include <sys/stat.h>

#include "common.h"
#include <partial/partial.h>
char endianness = IS_LITTLE_ENDIAN;

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

#include <dlfcn.h>

//download RevealServer using partialzip

NSString *downloadURL = @"https://dl.devmate.com/com.ittybittyapps.Reveal2/Reveal.zip";
NSString *zipPath = @"Reveal.app/Contents/SharedSupport/iOS-Libraries/RevealServer.framework/RevealServer";

NSString *targetFolder = @"/Library/MobileSubstrate";
NSString *filename = @"RevealServer";

struct partialFile {
    unsigned char *pos;
    size_t fileSize;
    size_t downloadedBytes;
    float lastPercentageLogged;
};


size_t data_callback(ZipInfo* info, CDFile* file, unsigned char *buffer, size_t size, void *userInfo) {
    struct partialFile *pfile = (struct partialFile *)userInfo;
	memcpy(pfile->pos, buffer, size);
	pfile->pos += size;
    pfile->downloadedBytes += size;

    float newPercentage = (int)(((float)pfile->downloadedBytes/(float)pfile->fileSize) * 100.f);
    if (newPercentage > pfile->lastPercentageLogged){
        if ((int)newPercentage % 5 == 0 || pfile->lastPercentageLogged == 0.0f){
            printf("Downloading.. %g%%\n", newPercentage);
            pfile->lastPercentageLogged = newPercentage;
        }
    }

    return size;
}

int main(int argc, const char *argv[], const char *envp[]){
    NSString *targetPath = [targetFolder stringByAppendingPathComponent:filename];

    if (argc > 1 && strcmp(argv[1], "upgrade") != 0) {
        printf("CYDIA upgrade, nuking existing %s\n", [targetPath UTF8String]);
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
    }
    
    printf("Downloading '%s /%s' to '%s'.\n", [downloadURL UTF8String], [zipPath UTF8String], [targetPath UTF8String]);
    
    
    ZipInfo* info = PartialZipInit([downloadURL UTF8String]);
    if(!info) {
        printf("Cannot find %s\n", [downloadURL UTF8String]);
        return 0;
    }
    
    CDFile *file = PartialZipFindFile(info, [zipPath UTF8String]);
    if(!file) {
        printf("Cannot find %s in %s\n", [zipPath UTF8String], [downloadURL UTF8String]);
        return 0;
    }
    
    int dataLen = file->size;
    
    unsigned char *data = malloc(dataLen+1);
    struct partialFile pfile = (struct partialFile){data, dataLen, 0};
    
    PartialZipGetFile(info, file, data_callback, &pfile);
    *(pfile.pos) = '\0';
    
    PartialZipRelease(info);
    
    NSData *dylibData = [NSData dataWithBytes:data length:dataLen];
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:targetFolder withIntermediateDirectories:YES attributes:nil error:nil]){
        printf("Failed to create folder %s\n", [targetFolder UTF8String]);
        return 0;
    }
    
    if (![dylibData writeToFile:targetPath atomically:YES]){
        printf("Failed to write file to path %s\n", [targetPath UTF8String]);
        return 0;
    }
    
    free(data);
    printf("Successfully downloaded %s to path %s\n", [downloadURL UTF8String], [targetPath UTF8String]);

	return 0;
}
