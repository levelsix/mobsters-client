// Copyright 2012-2014, TangoMe Inc ("Tango").  The SDK provided herein includes
// software and other technology provided by Tango that is subject to copyright and
// other intellectual property protections. All rights reserved.  Use only in
// accordance with the Evaluation License Agreement provided to you by Tango.
//
// Please read Tango_SDK_Evaluation_License_agreement_v1-2.docx
//

#ifndef _INCLUDED_tango_sdk_error_codes_h
#define _INCLUDED_tango_sdk_error_codes_h

// Keep this file plain C because we use it in our Objective C code.
// NOTE: Dont change the order or values.  Always add new entries at the end.

/// Tango SDK error codes. Note that TANGO_SDK_MESSAGE_SEND_PROGRESS is unique. It's not actually
/// an error code, and your error handler for messaging should not treat it as an error.
enum ErrorCode
{
  TANGO_SDK_SUCCESS = 0,                      ///< The operation succeeded.
  TANGO_SDK_MESSAGE_SEND_PROGRESS = 1,        ///< Not an error. Progress for sending a message with uploadable content.
  TANGO_SDK_NO_SESSION = 2,                   ///< Session has not been created/initialized.
  TANGO_SDK_INVALID_APP_ID = 3,               ///< App ID is invalid.
  TANGO_SDK_INVALID_SECRET = 4,               ///< Secret is invalid.
  TANGO_SDK_SRV_ERROR = 5,                    ///< There was an internal server error.
  TANGO_SDK_SRV_INVALID_JSON = 6,             ///< Server reported JSON payload was invalid.
  TANGO_SDK_SRV_NO_TOKEN = 7,                 ///< Server reported there was no auth token.
  TANGO_SDK_SRV_NO_CALLBACK_SCHEME = 8,       ///< Server reported no callback scheme was provisioned.
  TANGO_SDK_USER_DENIAL = 9,                  ///< User denied access (usually for address book).
  TANGO_SDK_WRONG_STATE = 10,                 ///< SDK is in wrong state. Internal error.
  TANGO_SDK_INVALID_TOKEN_FORMAT = 11,        ///< Auth token is in an invalid format.
  TANGO_SDK_SRV_CANT_CONNECT = 12,            ///< Could not connect to server.
  TANGO_SDK_TANGO_APP_NOT_INSTALLED = 13,     ///< Tango is not installed.
  TANGO_SDK_TANGO_APP_NO_SDK_SUPPORT = 14,    ///< Tango is installed but does not support this version of the SDK. You should offer to install the latest version.
  TANGO_SDK_CANT_SEND_REQUEST_TO_TANGO = 15,  ///< SDK could not successfully send a request to the Tango app.
  TANGO_SDK_TANGO_AUTH_TIMEOUT = 16,          ///< Authentication timed out.
  TANGO_SDK_TANGO_DEVICE_NOT_VALIDATED = 17,  ///< Tango app indicated that the device is not validated with servers.
  TANGO_SDK_ADDRESS_BOOK_NOT_READY = 18,      ///< The user's address book is not ready and they need to go back to Tango to finish contact filtering.
  TANGO_SDK_MESSAGE_SEND_CANCELLED = 19,      ///< Message send was cancelled.
  TANGO_SDK_INVALID_ARGUMENTS = 20,           ///< The arguments supplied to an SDK method were invalid.
  TANGO_SDK_SHUTTING_DOWN = 21,               ///< The SDK is shutting down.
  TANGO_SDK_INTERNAL_ERROR = 22,              ///< There was an internal SDK error.
  TANGO_SDK_SYNC_TIMEOUT = 23,                ///< A synchronization operation timed out.
  TANGO_SDK_WRAPPER_INVALID_JSON = 24,        ///< Invalid JSON was encountered in an SDK binding.
  TANGO_SDK_ADDRESS_BOOK_ACCESS_DENIED = 25,  ///< The user denied access to the device's address book.
  TANGO_SDK_ADDRESS_BOOK_SAVE_DENIED = 26,    ///< The user did not allow the Tango app to save their address book to Tango's servers.
  TANGO_SDK_ADDRESS_BOOK_TIMEOUT = 27,        ///< The server timed out while trying to retrieve the user's address book. Temporary condition.
  TANGO_SDK_ADDRESS_BOOK_BUSY = 28,           ///< The server was too busy to retrieve the user's address book. (Usually due to an outage of some kind).
  TANGO_SDK_PURCHASE_VALIDATION_TIMEOUT = 29, ///< The server timed out while trying to validate purchases.
  TANGO_SDK_PURCHASE_VALIDATION_BUSY = 30,    ///< The server was too busy to validate purchases. (Usually due to an outage of some kind).
  TANGO_SDK_PURCHASE_VALIDATION_ERROR = 31,   ///< There was an error while validating purchases.
  TANGO_SDK_TANGO_AUTH_CANCELLED = 32,        ///< Authentication was cancelled.
  TANGO_SDK_OPERATION_NOT_ALLOWED = 33,       ///< The operation was not allowed. (Make sure you requested access to the appropriate services at provisioning time).
  TANGO_SDK_OPERATION_VALIDATION_FAILED = 34, ///< Your request failed validation by Tango servers. Check that the parameters you supplied meet requirements.
  TANGO_SDK_INVALID_REQUEST = 35,             ///< The request sent to the server was invalid.
  TANGO_SDK_REQUEST_IN_PROGRESS = 36,         ///< Future use.
  TANGO_SDK_UPLOAD_FAILED = 37,               ///< Uploading content failed.
};

#endif // _INCLUDED_tango_sdk_error_codes_h
