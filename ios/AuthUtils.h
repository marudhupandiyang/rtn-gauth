#ifndef AuthUtils_h
#define AuthUtils_h

#import <Foundation/Foundation.h>

@interface AuthUtils : NSObject

#pragma mark - Methods

+ (NSString *)randomNonce:(NSInteger)length;

+ (NSString *)stringBySha256HashingString:(NSString *)input;

@end

#endif
