// Copyright 2012-2014, TangoMe Inc ("Tango").  The SDK provided herein includes 
// software and other technology provided by Tango that is subject to copyright and 
// other intellectual property protections. All rights reserved.  Use only in 
// accordance with the Evaluation License Agreement provided to you by Tango.
// 
// Please read Tango_SDK_Evaluation_License_agreement_v1-2.docx
//
#ifndef _INCLUDED_tango_sdk_session_h
#define _INCLUDED_tango_sdk_session_h

#include <string>
#include <vector>
#include <map>
#include <ostream>
#include <map>
#include <tango_sdk/error_codes.h>
#include <tango_sdk/event_codes.h>
#include <tango_sdk/message.h>


namespace tango_sdk {

/// Basic key-value map (dictionary) used in several places in this file.
typedef std::map<std::string, std::string> KeyValueMap;

/// Initialize Tango SDK.
/// This function must be called before any other call, and you must call it from your
/// main thread.
///
/// @param app_id           The app id from Tango SDK provisioning.
/// @param callback_scheme  The callback scheme from Tango SDK provisioning.
/// @param optional_config  Optional configuration encoded as a json string.
///
/// @return True if the Tango SDK initialized successfully
///         False if app_id or callback_scheme are empty strings or if the
///         optional json config is invalid
///
bool init(const std::string & app_id, const std::string & callback_scheme, const std::string & optional_config = "");

/// Check if the SDK is initialized.
///
/// @return true if the SDK is initialized, false otherwise.
///
bool is_initialized();

/// Uninitialize the SDK in preparation for shutdown. This call blocks until uninitialization is
/// complete, and all pending operations have been cancelled.
///
void uninit();

/// Retrieve the SDK version. If you need to compare to another version, make sure to decompose the
/// string into its subcomponents.
///
/// @return The version string in major.minor.revision form. Ex: "1.0.12345".
///
std::string get_version();

/// Return the current environment of the SDK as a string for debugging purposes. You should not
/// generally display the environment to the user.
///
/// @return The environment name, ex: "partnerdev". This is an empty string for the Production environment.
///
std::string get_environment_name();

/// An enumeration describing the reason that your app was asked to handle a URL when you call
/// handle_url().
///
enum HandleURLResultType {
  /// The URL was invalid or there was an internal error.
  HANDLE_URL_RESULT_ERROR = 0,
  /// The SDK handled the URL and there was no useful data for your app.
  HANDLE_URL_RESULT_NO_ACTION_NEEDED = 1,
  /// You must process a URL that has been stripped of any SDK-related information. Do
  /// not just use the URL that you passed into handle_url because it may have been a wrapper
  /// for the URL that you are actually interested in. URLs for messages sent via
  /// Session::send_message_to_recipients() [message.h] will also show up under this type.
  HANDLE_URL_RESULT_USER_URL = 2,
  /// Your app was asked to handle a tap on a message sent by Session::send_gift_message().
  HANDLE_URL_RESULT_GIFT_MESSAGE_RECEIVED = 3,
  /// Your app was asked to handle data sent via Session::share().
  HANDLE_URL_RESULT_SHARED_DATA_RECEIVED = 4,
	/// The SDK received a URL that it could parse but it does not understand the encoded
  /// action. It's possible that you've received a URL that can only be understood by a newer
  /// version of the SDK. (You might ask the user to upgrade your app).
  HANDLE_URL_RESULT_UNKNOWN_ACTION = 5,
};

// Keys to index into HandleURLResult.sdk_parameters:
extern const std::string RESULT_KEY_USER_URL;    ///< For HANDLE_URL_RESULT_USER_URL; "user_url"
extern const std::string RESULT_KEY_GIFT_TYPE;   ///< For HANDLE_URL_RESULT_GIFT_MESSAGE_RECEIVED; "gift_type"
extern const std::string RESULT_KEY_GIFT_ID;     ///< For HANDLE_URL_RESULT_GIFT_MESSAGE_RECEIVED; "gift_id"


/// Result structure returned by handle_url().
///
struct HandleURLResult {
  /// Reason that your app was asked to handle a URL. See HandleURLResultType.
  HandleURLResultType type;
  /// Additional parameters, as a string:string map. See the above string constants for keys.
  KeyValueMap sdk_parameters;
  /// Additional key-value parameters that you wanted to pass through.
  KeyValueMap user_parameters;
};

/// Pass a URL to the Tango SDK for processing. You should call this each time the OS presents
/// you with a URL, and check the return value before trying to process the URL yourself.
/// For example (on iOS), call this when your application delegate's
/// application:openURL:sourceApplication:annotation: (or similar) callback is triggered.
/// 
/// @param url              The URL for the Tango SDK to process.
/// @param sourceAppID      The identifier of the application that sent the URL to your app, if known.
///
/// @return A HandleURLResult structure that you should inspect for data pertinent to your app.
///
HandleURLResult handle_url(const std::string& url, const std::string& sourceAppID);

/// Call this function instead of handle_url if a JSON result string is more convenient for your app.
/// This is especially convenient if you are writing bindings for the Tango SDK in another language.
///
/// @param url              See handle_url().
/// @param sourceAppID      See handle_url().
/// @return A HandleURLResult struct as a JSON string. Ex:
///
/// {
///   "handle_url_result_type" : 3,
///   "sdk_parameters": {
///              "gift_id" :"71354b946f69bd2fe931d43978659cdd",
///              "gift_type" :"simplegift"
///   }
/// }
///
/// See HandleURLResultType for appropriate type codes, and the list of string constants
/// for sdk_parameters keys. Your own custom keys will appear in a field called user_parameters.
///
std::string handle_url_json(const std::string& url, const std::string& sourceAppID);

/// The type for the common request identifier returned by most SDK operations. Use this to
/// identify the result for a particular operation, in combination with context.
///
typedef unsigned int RequestID;

/// Asynchronous callback from the SDK.
/// The semantics of the fields depends on the type of the Reply.
///
/// type         id               content (JSON)                    ctx
///
/// RESULT       request_id       result of a successful request    context passed with the request
/// ERROR        request_id       error code and description        context passed with the request
/// PROGRESS     request_id       progress message                  context passed with the request
/// EVENT        event_code       event message                     context passed in Session::create()
///
enum CallbackType { RESULT=0, ERROR=1, PROGRESS=2, EVENT=3 };

/// The CallbackInfo structure contains the information that is passed from SDK back to the user.
/// See the chart for CallbackType to determine which parameters you need to read.
///
struct CallbackInfo
{
  CallbackType  type;           ///< the type of the CallbackInfo
  union
  {
    RequestID     request_id;   ///< unique request id is assigned at the request generation
    EventCode     event_code;   ///< numeric code that identifies an event
  }             id;
  std::string   content;        ///< JSON string with the content of the reply, see the table above
  void *        ctx;            ///< callback or event context
};

/// Callback handler type for request/response/event callback registered in Session::create().
typedef void (*CallbackHandler)(CallbackInfo *);

/// @deprecated Use CallbackInfo instead.
///
/// Old-style response for an asynchronous request.
struct Response
{
  RequestID     request_id;     ///< unique request id is assigned at the request generation
  ErrorCode     error_code;     ///< error code, SUCCESS if no errors
  std::string   error_text;     ///< optional error message
  std::string   result;         ///< result as JSON string or empty string in case of an errors
  void *        context;        ///< callback user data
};

/// @deprecated Use CallbackHandler instead.
///
/// Response handler type for old-style SDK request/response callback.
typedef void (*ResponseHandler)(Response *);


/// Convenience function to retrieve the error code from a CallbackInfo structure.
ErrorCode   error_code(const CallbackInfo * info);
  
/// Convenience function to retrieve the error text from a CallbackInfo structure.
std::string error_text(const CallbackInfo * info);


/// The interface to send messages accepts a list of acount ids to send
/// the message to. We use a vector to represent that list. This is also
/// used for several other APIs in Session.
///
/// Each item in the vector should be a ciphered Tango account ID
/// representing the user you want to send the message to.
///
/// Usually, you get these ciphered account ids from the response to get_friends_profiles().
///
typedef std::vector<std::string> AccountIdVector;

// SessionImplInterface is the delegate of Session. Forward declaration.
class SessionImplInterface;

/// The information about a purchased item that needs to be verified.
struct PurchasedItem
{
  std::string   item_id;    ///< An identification of the item
  std::string   receipt;    ///< The receipt obtained from the platform purchase API
  std::string   public_key; ///< Google Only.  public key obtained from the platform purchase API.
};


/// In the C++ API, Session is the main interface to interact with the Tango SDK. You use it to do
/// everything from authentication to verifying a user's purchases. Most methods follow a consistent
/// pattern, where they accept a JSON string payload if arguments are required, and an optional
/// context pointer that will be returned to you in the CallbackInfo structure. All asynchronous
/// calls return a RequestID that you can use to identify the operation that executed the callback.
///
/// Use create(CallbackHandler, void *) to instantiate a Session object.
///
/// See the <a href="/ApiDetails/session.html">Session API Details</a> page for more information.
///
class Session
{
public:
  /// Create the session.
  ///
  /// @param handler        Your callback handler.
  /// @param event_context  A context pointer you want passed back with all event-related calls to
  ///                       your handler.
  ///
  /// @return A pointer to the session object, ready for authentication.
  ///
  static Session *  create(CallbackHandler handler, void * event_context = NULL);

  /// Destroys the session.
  ///
  /// @param s The session object you want to destroy.
  ///
  static void       destroy(Session * s);

  /// Request an authentication token from Tango and store it internally for follow-on SDK calls.
  /// See <a href="/ApiDetails/authentication.html">Authentication API Details</a> for more information.
  ///
  RequestID         authenticate(void * context = NULL);

  /// Cancels any pending authentication requests and clears the data related to the user account.
  ///
  RequestID         reset_authentication(void * context = NULL);

  /// Check if the session is already authenticated.
  /// @return true if the session is authenticated and there is an SDK token in local storage that
  ///         has not expired, false otherwise.
  ///
  bool              is_authenticated();

  /// Retrieve an access token that you can use to retrieve a TangoID from Tango SSO.
  ///
  RequestID         get_access_token(void * context = NULL);

  /// Determine if the installed version of Tango supports this version of the SDK. If this returns
  /// false, you should call Session::tango_is_installed() to determine if you should indicate that
  /// Tango needs to be "upgraded", or "installed".
  ///
  /// @return true if Tango is installed and supports this version of the SDK, false otherwise.
  ///
  bool              tango_has_sdk_support();

  /// Determine if Tango is installed. This does not mean that the installed version of Tango
  /// supports the SDK. If Tango is installed but does not support the SDK, you should run a UI
  /// flow that encourages the user to upgrade their Tango client.
  ///
  /// @return true if Tango is installed.
  ///
  bool              tango_is_installed();

  /// This runs the Tango install flow, taking the user to the app store page appropriate for their
  /// platform so that they can upgrade to or install the latest Tango client. No prompt will be
  /// shown to the user.
  ///
  /// @return true if the user could be taken to the app store page successfully, false on error.
  ///
  bool              install_tango();

  // The following functions are the feature APIs.

  /// Get the user's own profile. (My Profile API).
  /// See <a href="/ApiDetails/myprofile.html">My Profile API Details</a> for more information.
  ///
  RequestID         get_my_profile(void * context = NULL);

  /// Get a list of the user's friends, automatically caching the results locally. (Get Contacts API).
  /// See <a href="/ApiDetails/getcontacts.html">Get Contacts API Details</a> for more information.
  ///
  RequestID         get_cached_friends(void * context = NULL);

  /// Get a list of all the user's possessions. (Possessions API).
  /// See <a href="/ApiDetails/possessions.html">Possessions API Details</a> for more information.
  ///
  RequestID         get_all_possessions(void * context = NULL);

  /// Set one or more of the user's possessions. (Possessions API).
  /// This is the JSON structure to use as input:
  ///        {
  ///          "Possessions":[
  ///            {
  ///              "LastModified":1366998173,
  ///              "ItemId":"coins",
  ///              "Value":"100",
  ///              "Version":"5",
  ///            },
  ///            {
  ///              "LastModified":1366998173,
  ///              "ItemId":"gems",
  ///              "Value":"2",
  ///              "Version":"5",
  ///            }
  ///            {
  ///              "ItemId":"a_new_item",
  ///              "Value":"1",
  ///            }
  ///          ]
  ///        }
  ///
  /// See <a href="/ApiDetails/possessions.html">Possessions API Details</a> for more information.
  ///
  RequestID         set_possessions(const std::string& possessions, void * context = NULL);

  /// User's Metrics
  
  /// Retrieve computed metrics (statistics) for a set of Tango users. (Metrics API).
  /// The JSON structure to use as input looks like this:
  ///
  ///        {
  ///          "EncodedAccountIds":[
  ///             "a2NTygSrZjFiGdrDrbz4RA",
  ///             "MWGjTGUI75rWt5W5TH_5vw"
  ///          ],
  ///          "ComputedMetrics":[
  ///            {
  ///              "MetricId":"score",
  ///              "RollUps":[
  ///                "MAX_THIS_WEEK",
  ///                "MAX"
  ///              ]
  ///            },
  ///            {
  ///              "MetricId":"beastiesKilled",
  ///              "RollUps":[
  ///                "MAX_THIS_WEEK",
  ///                "MIN"
  ///              ]
  ///            }
  ///          ]
  ///        }
  ///
  /// See <a href="/ApiDetails/metrics.html">Metrics API Details</a> for more information.
  ///
  RequestID         get_computed_metrics(const std::string& metrics, void * context = NULL);

  /// Send new metrics (statistics) data for the current Tango user. (Metrics API).
  /// The JSON structure to use as input looks like this:
  ///
  ///        {
  ///          "RawMetrics":[
  ///            {
  ///              "MetricId":"score",
  ///              "Value":"1000",
  ///              "RollUps":[
  ///                "MAX_LAST_WEEK",
  ///                "MAX_THIS_WEEK",
  ///                "MAX",
  ///                "AVE",
  ///                "SUM",
  ///                "COUNT",
  ///                "MIN"
  ///              ]
  ///            },
  ///            {
  ///              "MetricId":"beastiesKilled",
  ///              "Value":"20",
  ///              "RollUps":[
  ///                "MAX_LAST_WEEK",
  ///                "MAX_THIS_WEEK",
  ///                "MAX",
  ///                "MIN"
  ///              ]
  ///            }
  ///          ]
  ///        }
  ///
  /// See <a href="/ApiDetails/metrics.html">Metrics API Details</a> for more information.
  ///
  RequestID         set_raw_metrics(const std::string& metrics, void * context = NULL);
  
  /// Retrieve a leaderboard of the user's friends who have used your app based upon
  /// metrics that you provide. (Leaderboard API). See the SDK documentation Client API Details
  /// section on Leaderboards for more information.
  ///
  /// See <a href="/ApiDetails/leaderboards.html">Leaderboards API Details</a> for more information.
  ///
  RequestID         get_leaderboard(const std::string& metrics, void * context = NULL);
  
  
  /** Share custom content through Tango. The location it appears in is determined by the number
      of recipients and the content. Some parameters may not be supported for all possible
      display targets. Check the online documentation for details.
   
      This method provides access to the Share API.
   
      You pass the necessary data as a JSON string in the following format, pre-localized in
      the user's preferred language. All strings are UTF-8. You must specify display_target. The
      other fields are optional except for recipients (when you are sharing to "chat_*"). You
      should at least include some kind of text to give your content some meaning.

      {
        "display_target" : "my_feed"           // Post to the user's own feed.
                           "chat_from_user"    // Send through chat.
                           "chat_from_app"     // Send through chat as if from the app itself.
   
        "intent" : Ex: "invite", "brag", "gift", "content" // Optional string to indicate where content originated from in your app.
   
        "recipients" : [ "accountID1",  // List of recipients to send content to (for chat target).
                         "accountID2",
                         ...
                       ]
        
        "notification_text" : A string containing a short description of the content you are sharing.

        "caption_text"    : A string containing larger body text for the event you want to share.
                            Ex: "I got a score of 432, can you do better?".
        "link_text"       : A string containing a short label that prompts the user to act on the event.
                            Ex: "Claim 3 tokens!" If this is not provided, a placeholder button will
                            be used instead.
        "parameters"      : { // These parameters will be passed back to your app via handle_url in
                              // the user_parameters field of HandleURLResultType.
                              "custom1" : "Custom parameter string 1..."
                              "custom2" : "Custom parameter string 2..."
                              "picksomename" : "Pick some content..."
                            }
        "attachment"     : {  // The file referenced by URLs can be deleted after the callback returns.
                              main :      { "mime" : "image/jpeg", "url" : "file://path.jpg" },
                              thumbnail : { "mime" : "image/jpeg", "url" : "file://path.jpg" }
                           }
      }
   
      @param json_data    A JSON structure containing the data pertinent to the event. The contents
                          are described above.
      @param context      A context pointer that will be passed back to you in the SDK response.
      @return   Returns a request ID that you can use to identify callbacks or events for this request.
   
      See <a href="/ApiDetails/share.html">Share API Details</a> for more information.
      */
  RequestID share(const std::string& json_data, void *context = NULL);

  /// Validate a purchase made by the application via Tango's servers. See the SDK documentation
  /// for more information.
  ///
  ///    @param context         Operation context
  ///    @param purchased_item  Information about one purchased item
  ///
  ///    output : validation status in JSON
  ///
  ///        {
  ///          "IsValid" : true
  ///        }

  RequestID validate_purchase(const PurchasedItem& purchase, void * context = NULL);

  /// Returns approximation of time on Tango servers.
  /// The time is estimated based on a timestamp returned in server response. The accuracy
  /// is not guaranteed because of network delays. Current implementation is not affected
  /// by device local clock settings. However it will be affected by user changing local
  /// clock after synchronization was performed.
  /// In the current implementation the synchronization occurs when one of the following
  /// request completes successfully:
  ///
  ///   get_computed_metrics
  ///   set_raw_metrics
  ///   get_all_possessions
  ///   set_possessions
  ///
  /// Until the synchronization occurs, the function will return 0.
  ///
  /// @return Estimated time on Tango server. The time is elapsed number of seconds
  ///         since Unix epoch in GMT (01 Jan 1970, 00:00:00 GMT).
  ///         If synchronization with Tango server did not occur yet, 0 will be returned
  unsigned int get_server_time();
  
  /// Request an advertisement.  The callback handler response will be in
  /// this form
  ///
  /// {
  ///   "banner" : "http://sdk.tango.me/assets2/Tango/Ext_Ads_V4.jpg",
  ///   "link" : "http://install.tango.net?id=xyz&source=sdk"
  /// }
  ///
  /// "banner" is the graphic for the ad banner.  "link" is the link to
  /// activate when the banner is clicked.
  RequestID         get_advertisement(void * context = NULL);
  
  
  /////////////////////////
  // Deprecated methods. //
  /////////////////////////
  
  /// @deprecated Use Session::get_cached_friends(void *) instead.
  ///
  /// Get a list of the user's friends without automatic caching. (Get Contacts API).
  ///
  RequestID         get_friends_profiles(void * context = NULL);
  
  /// @deprecated Launch context/intent are unused and will be removed at a later date.
  ///
  /// @return true if launch intent is known
  ///
  bool        has_launch_intent();
  
  /// @deprecated Launch context/intent are unused and will be removed at a later date.
  ///
  /// Launch intent value.
  ///
  /// @return Currently the only values being supported are:
  ///         open_message - if the app was opened because user opened a message
  ///         previously sent with send_message_to_recipients
  ///         open - if user opened the app from a catalog or some promotional link
  ///
  ///         The intent value will be available only if Tango launch context is
  ///         passed to the external app by having LAUNCH_CONTEXT substring
  ///         in the URL.
  std::string get_launch_intent();
  
  /// @deprecated Launch context/intent are unused and will be removed at a later date.
  ///
  /// @return true if conversation context exists
  bool            has_launch_context_conversation_participants();
  
  /// @deprecated Launch context/intent are unused and will be removed at a later date.
  ///
  /// Returns list of participants in a conversation if your app was opened from a launch context.
  ///
  /// @return The list contains account ids. These ids may be used to send
  ///         messages using send_message_to_recipients method calls.
  ///         The list will be available only if Tango launch context is
  ///         passed to the external app by having LAUNCH_CONTEXT substring
  ///         in the URL.
  AccountIdVector get_launch_context_conversation_participants();
  
  /// @deprecated Use Session::create(CallbackHandler) instead.
  ///
  /// Creates a Session instance using the old-style ResponseHandler callback.
  static Session *  create(ResponseHandler handler);
  
  /** @deprecated Use share() instead.
      Send a simple invite message to one or more recipients. When the user taps on the message,
      your app will be launched automatically if they have it installed. Otherwise, they will be
      taken to your provisioned install URL for that user's OS.
   
      This method is part of the Simple Messaging API.

      @param recipients         The list of Tango account IDs you want to send the message to.
      @param notification_text  The text that appears in push notifications and in the conversation
      summary page in Tango. Keep this very short. Do not include
      the sender or recipient's name in this string. This information is
      already presented by other means.
      @param link_text  The "link" text you want to show, encouraging users to tap on the message.
      @param context    An arbitrary context pointer that will be passed back to your
      Session callback handler when the SDK is done processing your message.

      @return The request ID that identifies this message for your callback handler, both for
      progress updates and cancellation/success/failure.

      See <a href="/ApiDetails/simplemessaging.html">Simple Messaging API Details</a> for more
      information.
      */
  RequestID send_invite_message(const AccountIdVector& recipients,
                                const std::string& notification_text,
                                const std::string& link_text,
                                void * context = NULL);
  
  /** @deprecated Use share() instead.
      Same as send_invite_message, but use this specifically for "brag" messages, where you want
      to encourage users to use your app because of something that their friend achieved.
   
      This method is part of the Simple Messaging API.
   
      See <a href="/ApiDetails/simplemessaging.html">Simple Messaging API Details</a> for more
      information.
      */
  RequestID send_brag_message(const AccountIdVector& recipients,
                              const std::string& notification_text,
                              const std::string& link_text,
                              void * context = NULL);
  
  /** @deprecated Use share() instead.
      Same as send_invite_message, but includes automatic "gift" tracking. This version also
      accepts parameters that will be passed to your application in the result data for
      handle_url. The Tango SDK will handle de-duplication of gifts internally. Note however that
      we do not make any effort to prevent users from spoofing gifts by issuing fake URLs to your
      app. If this is a concern, you may implement your own security mechanism via the gift_type
      parameter.

      This method is part of the Simple Messaging API.

      @param recipients         See send_invite_message().
      @param notification_text  See send_invite_message().
      @param link_text          See send_invite_message().
      @param gift_type    An identifier you provide to identify the type of gift. Passed back in
      handle_url sdk_parameters as "gift_type". This should be a string token
      that identifies the gift you are sending, ex "1000 coins". You may use
      any format you wish, like "item=socks&color=red&qty=30&security=19348".
      @param context      See send_invite_message().

      @return See send_invite_message().

      See <a href="/ApiDetails/simplemessaging.html">Simple Messaging API Details</a> for more
      information.
      */
  RequestID send_gift_message(const AccountIdVector& recipients,
                              const std::string& notification_text,
                              const std::string& link_text,
                              const std::string& gift_type,
                              void * context = NULL);
  
  /// @deprecated Use share() instead.
  /// Send a message to a list of Tango users using the more powerful API from message.h.
  /// The message will appear in the recipients's Tango client as if it was sent from your user,
  /// attributed with information identifying your app.
  ///
  /// WARNING: This messaging API provides a great deal of power at the cost of complexity. If
  /// your needs are met by the flat send_*_message functions above, you should use those instead.
  ///
  /// This method provides access to the Advanced Messaging API.
  ///
  ///    @param context      Custom contextual information that you can use to identify events
  ///                        from the SDK.
  ///    @param recipients   A vector of ciphered Tango account IDs representing the users you
  ///                        want to send the message to. Call get_friends_profiles to retreive
  ///                        a list of account IDs.
  ///    @param message      The message that you want to send. See the Message class in message.h.
  ///
  ///    See <a href="/ApiDetails/advancedmessaging.html">Avanced Messaging API Details</a> for more information.
  ///
  RequestID send_message_to_recipients(const AccountIdVector& recipients,
                                       const Message& message,
                                       void * context = NULL);
  
  /////////////////////////
  //  Internal methods.  //
  /////////////////////////
  
  /// @internal
  /// Clears the local cache for internal unit tests.
  void clear_cache();

private:
  Session(SessionImplInterface * impl);
  ~Session();

  // Forbid copying and assignment
  Session(const Session & rhs);
  const Session & operator=(const Session & rhs);

private:
  SessionImplInterface * _impl;
};


/// @deprecated Use handle_url instead.
///
/// Pass the URL to Tango SDK.
/// Call this function whenever the application receives an URL from the scheme 'callback_scheme'.
///
///  @param url                     An URL that was used to launch the app
///  @param user_url                Out parameter: returns the value of url parameter, except for
///                                 a case when user tried to launch the URL from Tango, but the
///                                 application was not installed. See following Remarks section.
///
///  Remarks:
///
///    using user_url parameter:
///
///    Assume the following scenario: my friend wants to play "Cool Chess" game with me.
///    He has the game installed on his device. He sends me his first move (e.g. E2->E4) using
///    send_message_to_recipients function call, while the move is encoded as a part of the URL.
///    I don't have "Cool Chess" installed, so a link from my chat window takes me to the
///    app store. I install the "Cool Chess" and open it. The url from the chat message describing
///    the move will be returned in userUrl parameter.
///
bool accept_url(const std::string & url, std::string * user_url = NULL);

/// @deprecated Use handle_url instead.
///
/// Pass the URL to Tango SDK.
/// Call this function whenever the application receives an URL from the scheme 'callback_scheme'
/// and you know the application ID of the sender application, for instance, iOS bundle ID.
///
/// For parameters see previous function.
///
bool accept_url(const std::string & url, const std::string & sourceAppID, std::string * user_url = NULL);

} // namespace tango_sdk


// Useful operators.

/// Stream operator for CallbackInfo structure for easier debugging.
std::ostream & operator<<(std::ostream & os, const tango_sdk::CallbackInfo & obj);

/// @deprecated Use CallbackInfo instead.
std::ostream & operator<<(std::ostream & os, const tango_sdk::Response & obj);

#endif // _INCLUDED_tango_sdk_session_h
