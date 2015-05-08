//
//  CFunctions.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "CFunctions.h"
#import "TLFileLocation+Extensions.h"
#import "NSStringCategory.h"
#import "NSData+Extensions.h"
@implementation CFunctions


BOOL checkFileSize(NSString *path, int size) {
    long fs = fileSize(path);
    return fs > 0 && fs >= size;
}

unsigned long fileSize(NSString *path) {
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath:path error: NULL];
    return [attrs fileSize];
}

BOOL fileExists(TLFileLocation *location) {
    return [[NSFileManager defaultManager] fileExistsAtPath:locationFilePath(location, @"jpg")];
}

BOOL isPathExists(NSString *path) {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

BOOL check_file_size(NSString *path) {
    return fileSize(path) < MAX_FILE_SIZE;
}

NSString* locationFilePath(TLFileLocation *location, NSString *extension) {
    return [NSString stringWithFormat:@"%@/%@.%@",path(),location.cacheKey,extension];
}

NSString* locationFilePathWithPrefix(TLFileLocation *location, NSString *prefix, NSString *extension) {
    return [NSString stringWithFormat:@"%@/%@_%@.%@",path(),location.cacheKey,prefix,extension];
}


NSString* path() {
    static NSString* path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        path = @"";
        if ([paths count]) {
            NSString *bundleName =
            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
            
            path = [[paths objectAtIndex:0] stringByAppendingString:@"/"];
            path = [path stringByAppendingString:bundleName];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:path
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
            
            path = [path stringByAppendingString:@"/cache"];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:path
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
    });
    return path;
}

BOOL NSSizeNotZero(NSSize size) {
    return size.width > 0 || size.height > 0;
}

BOOL NSContainsSize(NSSize size1, NSSize size2) {
    return size1.width == size2.width && size1.height == size2.height;
}

BOOL NSStringIsValidEmail(NSString *checkString) {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


NSArray *mediaTypes() {
    return @[@"png", @"tiff", @"jpeg", @"jpg", @"mp4",@"mov",@"avi"];
}

NSArray *videoTypes() {
    return @[@"mp4",@"mov",@"avi"];
}

NSArray *imageTypes() {
    return @[@"png", @"tiff", @"jpeg", @"jpg"];
}

NSString *fileMD5(NSString * path) {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle == nil)
        return [@"ERROR GETTING FILE MD5" md5]; // file didnt exist
    
    NSUInteger size = fileSize(path);
    
    NSUInteger seek = size - MIN(4096,size);
    
    NSData *fileData = [[NSData alloc] initWithData:[handle readDataOfLength:MIN(size, 4096)]];
    
    [handle seekToFileOffset:seek];
    
    fileData = [fileData dataWithData:[handle readDataToEndOfFile]];
    
    
    NSString *md5 = [[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding] md5];
    return [[NSString stringWithFormat:@"MD5_%@_%lu", md5, (unsigned long)size] md5];
}

static NSMutableDictionary *extensions;
static NSMutableDictionary *mimeTypes;

+(void)initialize {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *types = [[NSMutableDictionary alloc] init];
        
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"mime-types.txt"]];
        
        NSString *mimefile = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        NSArray* mimes = [mimefile componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
        
        NSMutableDictionary *ex = [[NSMutableDictionary alloc] init];
        
        for (NSString *line in mimes) {
            NSArray* single = [line componentsSeparatedByCharactersInSet:
                               [NSCharacterSet characterSetWithCharactersInString:@":"]];
            
            [types setObject:[single objectAtIndex:1] forKey:[single objectAtIndex:0]];
            [ex setObject:[single objectAtIndex:0] forKey:[single objectAtIndex:1]];
        }
        
       extensions = ex;
        
        mimeTypes = types;
    });
    
}

NSString *mimetypefromExtension(NSString *extension) {
    
    [CFunctions initialize];
    
    NSString *mimeType = [mimeTypes objectForKey:extension];
    if(!mimeType)
        mimeType = [mimeTypes objectForKey:@"*"];
    return mimeType;
}

NSString* extensionForMimetype(NSString *mimetype) {
    
     [CFunctions initialize];
    
     return extensions[mimetype];
}


@end
