#import <Foundation/Foundation.h>
#import <React/RCTUtils.h>
#import <React/RCTBridgeModule.h>
#import "AuthenticationServices/ASAuthorizationController.h"

@interface AuthDelegates : NSObject <ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>

@property(nonatomic, strong, nullable) NSString *nonce;
@property(nonatomic, strong, nullable) void (^completion)(NSError *, NSDictionary *);

- (instancetype)initWithCompletion:(void (^)(NSError *error, NSDictionary *authorizationCredential))completion andNonce:(NSString *)nonce;

- (void)performRequestsForAuthorizationController:(ASAuthorizationController *)authorizationController;

@end
