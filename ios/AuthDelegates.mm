#import "AuthDelegates.h"

#import <AuthenticationServices/AuthenticationServices.h>

@implementation AuthDelegates

- (instancetype)initWithCompletion:(void (^)(NSError *error, NSDictionary *authorizationCredential))completion andNonce:(NSString *)nonce {
  if (self = [super init]) {
    _completion = completion;
    _nonce = nonce;
  }
  return self;
}

#pragma mark - ASAuthorizationControllerPresentationContextProviding Methods

- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller {
    return [[UIApplication sharedApplication] keyWindow];
}

#pragma mark - ASAuthorizationControllerDelegate Methods

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization {
  NSLog(@"RNAppleAuth -> didCompleteWithAuthorization");
  ASAuthorizationAppleIDCredential *appleIdCredential = authorization.credential;
  _completion(nil, [self buildDictionaryFromAppleIdCredential:appleIdCredential]);
  _completion = nil;
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error {
  NSLog(@"RNAppleAuth -> didCompleteWithError");
  NSLog(error.localizedDescription);
  _completion(error, nil);
  _completion = nil;
}

#pragma mark - ASAuthorizationController Methods

- (void)performRequestsForAuthorizationController:(ASAuthorizationController *)authorizationController {
  authorizationController.delegate = self;
  authorizationController.presentationContextProvider = self;
  [authorizationController performRequests];
}

#pragma mark - ASAuthorizationController Methods

- (NSDictionary *)buildDictionaryFromAppleIdCredential:(ASAuthorizationAppleIDCredential *)appleIdCredential {
  NSString *identityToken;
  if ([appleIdCredential valueForKey:@"identityToken"] != nil) {
    identityToken = [
        [NSString alloc] initWithData:[appleIdCredential valueForKey:@"identityToken"] encoding:NSUTF8StringEncoding
    ];
  }

  NSString *authorizationCode;
  if ([appleIdCredential valueForKey:@"authorizationCode"] != nil) {
    authorizationCode = [
        [NSString alloc] initWithData:[appleIdCredential valueForKey:@"authorizationCode"] encoding:NSUTF8StringEncoding
    ];
  }

  NSMutableDictionary *fullName;
  if ([appleIdCredential valueForKey:@"fullName"] != nil) {
    fullName = [[appleIdCredential.fullName dictionaryWithValuesForKeys:@[
        @"namePrefix",
        @"givenName",
        @"middleName",
        @"familyName",
        @"nameSuffix",
        @"nickname",
    ]] mutableCopy];
    [fullName enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      if (obj == nil) {
        fullName[key] = [NSNull null];
      }
    }];
  }

  return @{
      @"nonce": _nonce ? _nonce : (id) [NSNull null],
      @"user": appleIdCredential.user,
      @"fullName": fullName ? fullName : (id) [NSNull null],
      @"realUserStatus": @(appleIdCredential.realUserStatus),
      @"authorizedScopes": appleIdCredential.authorizedScopes,
      @"identityToken": identityToken ? identityToken : (id) [NSNull null],
      @"email": appleIdCredential.email ? appleIdCredential.email : (id) [NSNull null],
      @"state": appleIdCredential.state ? appleIdCredential.state : (id) [NSNull null],
      @"authorizationCode": authorizationCode ? authorizationCode : (id) [NSNull null],
  };
}

@end
