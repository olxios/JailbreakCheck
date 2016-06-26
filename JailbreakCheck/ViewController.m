//
//  ViewController.m
//  JailbreakCheck
//
//  Created by olxios on 26/06/16.
//  Copyright © 2016 olxios. All rights reserved.
//

#import "ViewController.h"
#import "LOOCryptString.h"

// Defines
#define FORCE_INLINE inline __attribute__((always_inline))

// Jailbreak checks
#import <sys/stat.h>

// Inline functions
FORCE_INLINE void checkJailbreakSymlinks();
FORCE_INLINE void checkJailbreakSymLink(NSString *checkPath);

FORCE_INLINE void checkJailbreakFiles();
FORCE_INLINE void checkJailbreakFile(NSString *checkPath);

FORCE_INLINE void checkReadWritePermissions();

FORCE_INLINE void foundJailbrokenDevice();

@implementation ViewController

#pragma mark - Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    checkJailbreakSymlinks();
    checkJailbreakFiles();
    checkReadWritePermissions();
}

#pragma mark - Jailbreak checks

void checkJailbreakSymlinks()
{
    NSArray *linksChecks = @[LOO_CRYPT_STR_N("/Applications", 13),
                             LOO_CRYPT_STR_N("/usr/libexec", 12),
                             LOO_CRYPT_STR_N("/usr/share", 10),
                             LOO_CRYPT_STR_N("/Library/Wallpaper", 18),
                             LOO_CRYPT_STR_N("/usr/include", 12)];
    
    for (NSString *checkPath in linksChecks)
    {
        checkJailbreakSymLink(checkPath);
    }
}

void checkJailbreakFiles()
{
    NSArray *fileChecks = @[LOO_CRYPT_STR_N("/bin/bash", 9),
                            LOO_CRYPT_STR_N("/etc/apt", 8),
                            LOO_CRYPT_STR_N("/usr/sbin/sshd", 14),
                            LOO_CRYPT_STR_N("/Library/MobileSubstrate/MobileSubstrate.dylib", 46),
                            LOO_CRYPT_STR_N("/Applications/Cydia.app", 23),
                            LOO_CRYPT_STR_N("/bin/sh", 7),
                            LOO_CRYPT_STR_N("/var/cache/apt", 14),
                            LOO_CRYPT_STR_N("/var/tmp/cydia.log", 18)];
    
    for (NSString *checkPath in fileChecks)
    {
        checkJailbreakFile(checkPath);
    }
}

void checkReadWritePermissions()
{
    if([[UIApplication sharedApplication] canOpenURL:
        [NSURL URLWithString:LOO_CRYPT_STR_N("cydia://package/com.com.com", 27)]])
    {
        foundJailbrokenDevice();
    }
    
    NSError *error;
    NSString *stringToBeWritten = @"0";
    [stringToBeWritten writeToFile:LOO_CRYPT_STR_N("/private/jailbreak.test", 23)
                        atomically:YES
                          encoding:NSUTF8StringEncoding error:&error];
    if (error == nil)
    {
        foundJailbrokenDevice();
    }
}

void checkJailbreakSymLink(NSString *checkPath)
{
    struct stat s;
    
    if (lstat([checkPath UTF8String], &s) == 0)
    {
        if (S_ISLNK(s.st_mode) == 1)
        {
            foundJailbrokenDevice();
        }
    }
}

void checkJailbreakFile(NSString *checkPath)
{
    struct stat s;
    
    if (stat([checkPath UTF8String], &s) == 0)
    {
        foundJailbrokenDevice();
    }
}

#pragma mark - Found jailbroken device

void foundJailbrokenDevice()
{
    exit(-1);
}

@end
