#import <React/RCTUtils.h>

#import <CommonCrypto/CommonDigest.h>
#import "RNAppleAuth.h"
#import "AuthDelegates.h"
#import "AuthenticationServices/ASAuthorizationAppleIDCredential.h"
#import "AuthenticationServices/ASAuthorizationAppleIDProvider.h"
#import "AuthUtils.h"

@implementation RNAppleAuth

#pragma mark - Module Setup

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"RNAppleAuth.onCredentialRevoked"];
}

- (NSDictionary *)constantsToExport {
  return @{
      @"isSupported": @available(iOS 13.0, macOS 10.15, *) ? @(YES) : @(NO),
      @"isSignUpButtonSupported": @available(iOS 13.2, macOS 10.15.1, *) ? @(YES) : @(NO),
  };
}

- (void)startObserving {
  [
      [NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(onCredentialRevoked)
             name:ASAuthorizationAppleIDProviderCredentialRevokedNotification
           object:nil
  ];
}

- (void)stopObserving {
  [
      [NSNotificationCenter defaultCenter]
      removeObserver:self
                name:ASAuthorizationAppleIDProviderCredentialRevokedNotification
              object:nil
  ];
}

#pragma mark - Module Methods

RCT_EXPORT_METHOD(getCredentialStateForUser:
  (NSString *) user
    :(RCTPromiseResolveBlock) resolve
    :(RCTPromiseRejectBlock) reject
) {
  ASAuthorizationAppleIDProvider *appleIdProvider = [[ASAuthorizationAppleIDProvider alloc] init];
  id completionBlock = ^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError *_Nullable error) {
    if (error) {
      return reject([@(error.code) stringValue], error.localizedDescription, error);
    } else {
      resolve(@(credentialState));
    }
  };
  [appleIdProvider getCredentialStateForUserID:user completion:completionBlock];
}

RCT_EXPORT_METHOD(performRequest:
  (ASAuthorizationAppleIDRequest *) appleIdRequest
    :(RCTPromiseResolveBlock) resolve
    :(RCTPromiseRejectBlock) reject
) {
  ASAuthorizationController *authorizationController = [
      [ASAuthorizationController alloc] initWithAuthorizationRequests:@[
          appleIdRequest
      ]
  ];

  NSString *rawNonce = nil;
  if (appleIdRequest.nonce) {
    rawNonce = appleIdRequest.nonce;
    appleIdRequest.nonce = [AuthUtils stringBySha256HashingString:rawNonce];
  }

  __block AuthDelegates *delegates = [
      [AuthDelegates alloc]
      initWithCompletion:^(NSError *error, NSDictionary *authorizationCredential) {
        if (error) {
          reject([@(error.code) stringValue], error.localizedDescription, error);
        } else {
          resolve(authorizationCredential);
        }
        delegates = nil;
      }
      andNonce:rawNonce
  ];

  [delegates performRequestsForAuthorizationController:authorizationController];
}

- (void)onCredentialRevoked {
  [self sendEventWithName:@"RNAppleAuth.onCredentialRevoked" body:[NSNull null]];
}

@end
