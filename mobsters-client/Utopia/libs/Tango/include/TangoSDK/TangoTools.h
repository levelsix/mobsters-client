//
//  TangoTools.h
//  
//
//  Created by Li Geng on 9/24/13.
//
//

#ifndef ____TangoTools__
#define ____TangoTools__

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

/// Status code for receipt validation.
enum ValidationStatus
{
  VALIDATION_SUCCESS = 0,
  VALIDATION_FAILURE,
  VALIDATION_ERROR,
};

/// Callback handler type for Tango receipt validation. It's possible that validation will fail
/// because Tango's servers cannot be reached, so you cannot just check for VALIDATION_SUCCESS alone.
/// @param status The validation status code.
/// @param error The reason validation failed or returned an error. Check the error code against the
/// enumeration in error_codes.h.
typedef void (^ReceiptValidationHandler)(enum ValidationStatus status, NSError *error);


/** TangoTools is a collection of utilities that are too small for their own classes and don't
    belong anywhere else.
    */
@interface TangoTools : NSObject

/// Validate a transaction receipt from StoreKit via Tango's servers.
/// @param transaction The StoreKit transaction you want to validate.
/// @param handler A callback to handle the results of receipt validation.
///
+ (void)validateTransaction:(SKPaymentTransaction *)transaction withHandler:(ReceiptValidationHandler) handler;

/// Validate a transaction receipt that you already have in NSData form.
/// @param receipt The receipt data.
/// @param productId The product identifier.
/// @param handler Your callback handler.
+ (void)validateReceipt:(NSData *)receipt forProduct:(NSString *)productId withHandler:(ReceiptValidationHandler) handler;
@end

#endif /* defined(____TangoTools__) */
