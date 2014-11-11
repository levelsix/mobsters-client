// Copyright 2012-2013, TangoMe Inc ("Tango").  The SDK provided herein includes 
// software and other technology provided by Tango that is subject to copyright and 
// other intellectual property protections. All rights reserved.  Use only in 
// accordance with the Evaluation License Agreement provided to you by Tango.
// 
// Please read Tango_SDK_Evaluation_License_agreement_v1-2.docx
//

#ifndef _TANGO_SDK_MESSAGE_H_
#define _TANGO_SDK_MESSAGE_H_

#include <string>
#include <map>

/*  This file describes the data structures for the Advanced Messaging API.
    Use it in combination with Session::send_message_to_receipients().
    */

namespace tango_sdk {

class MessageImpl;

/** Platform is used together with Action and PlatformToActionMap, enabling you to
    specify actions to be taken when a user taps on a message in Tango. Please read
    the codedocs for PlatformToActionMap to understand how these are used.
    */
typedef enum {
  PLATFORM_ANY = 0,       ///< @deprecated Renamed to PLATFORM_FALLBACK for clarity.
  
  PLATFORM_FALLBACK = 0,  ///< Fallback for unsupported platforms.
  PLATFORM_IOS,           ///< Apple iOS.
  PLATFORM_ANDROID,       ///< Google Android.
  
  PLATFORM_UNKNOWN        ///< Not a real platform. Use if you need to iterate over the entire enum.
} Platform;


/** An Action describes what to do when the user taps on a message in Tango. You provide an
    Action for each supported platform (through PlatformToActionMap) when setting up a
    Message object.
    
    You must set action_url and action_url_mime_type, or the action is invalid and will not
    be run by the Tango client. The action_prompt is optional, but highly recommended. It
    will be displayed with your message in Tango, and should read like a "call to action".
    */
class Action {
public:
  /// The default constructor is useful when you want to use Actions in a map.
  Action();
  
  /// This is the primary constructor for Action. You must specify a valid URL and mime
  /// type, but may leave action_prompt blank.
  /// @param action_prompt        Short text to encourage the user to tap on the message.
  /// @param action_url           The URL to launch when the user taps on the message.
  /// @param action_url_mime_type The mime type of the URL. Mime types starting with "image/"
  ///                             and "video/" will cause the URL to be loaded in an appropriate
  ///                             Tango client content player. Other types will be handed off to
  ///                             the normal system facilities.
  Action(const std::string& action_prompt,
         const std::string& action_url,
         const std::string& action_url_mime_type);
  
  /// Retrieve the action_url.
  /// @return A string containing the full URL.
  std::string action_url() const;
  
  /// Retrieve the Action's prompt.
  /// @return A string containing the action_prompt text you provided in the constructor.
  std::string action_prompt() const;
  
  /// Retrieve the mime type for the Action's URL. Tango uses this to determine if it
  /// should try to open the content and play it internally. As of this writing, Tango
  /// will try to play all video/* and image/* content. Other types will be launched using
  /// standard system APIs.
  /// @return The mime type you provided in the constructor.
  std::string action_url_mime_type() const;
  
  /// Check if the action is valid.
  /// @return true if the action is valid, false otherwise.
  bool valid() const;
    
private:
  std::string m_action_prompt;
  std::string m_action_url;
  std::string m_action_url_mime_type;
};


/** PlatformToActionMap holds one Action for each Platform that you need to support in the
    message. You MUST specify an action for PLATFORM_FALLBACK for the action map to be
    considered valid. Specifying a platform-specific action will override the action for
    PLATFORM_FALLBACK when the message is viewed on that platform.

    Note that if you want to send a message that launches your app when the user taps on it,
    you cannot use PLATFORM_FALLBACK by itself. Launch actions are platform-specific, so you
    should write the action map like this:

    - FALLBACK  - A URL which takes the user to a website about your app. (Future proofing for
                  platforms that are not supported yet).
    - IOS       - A URL which launches your app on iOS (if needed).
    - ANDROID   - A URL which launches your app on Android (if needed).
    
    If the action URL cannot be opened, your provisioned install URL will be launched
    instead. This behavior is provided by Tango, and is only done for platform-specific
    actions. Install URLs may be provisioned by sending e-mail to tangosdk-support@tango.me.
    Provide one install URL for each platform that you support.
        
    If you are doing something common to all platforms, like playing a video or opening
    a page in the device's web-browser, you only need to specify an action for
    PLATFORM_FALLBACK.
    */
class PlatformToActionMap {
public:
  /// Insert an Action into the map for the specified platform, overwriting the previous entry, if any.
  /// @param platform The platform that you want to specify an action for.
  /// @param action The action that you want Tango to take when the user taps on the message.
  void insert(Platform platform, const Action& action);
  
  /// Find returns an invalid Action if no action is specified for the platform.
  /// @param  platform The platform you want to retrieve the action for.
  /// @return The relevant action, or an invalid "empty" action if an action matching the requested
  ///         platform could not be found.
  Action find(Platform platform) const;
  
  /// Erase an action for a platform, if it exists in the map.
  /// @param The platform whose action you want to remove.
  void erase(Platform platform);
  
  /// Clear all entries in the map.
  void clear();
  
private:
  std::map<Platform, Action> m_actions;
};


/** This is a basic key-value map to be used with ContentUploadResponseToActionMapConverter.
    Translate the data provided into a PlatformToActionMap to be embedded in the message.
    Use the constants below (CONTENT_URL, etc.) to index into ContentUploadDetails.
    */
typedef std::map<std::string, std::string> ContentUploadDetails;

/// This is the URL where your content can be downloaded from the Tango content server.
extern const std::string CONTENT_URL;
/// This is the URL where the thumbnail for your content can be downloaded.
extern const std::string CONTENT_THUMBNAIL_URL;
/// This is the MIME type of the content.
extern const std::string CONTENT_MIME_TYPE;
/// This is the MIME type of the thumbnail.
extern const std::string CONTENT_THUMBNAIL_MIME_TYPE;


/** You subclass ContentUploadResponseToActionMapConverter to provide a callback to translate
    a URL from the Tango content server into a form that your app can understand. You need
    to do this if, for instance, you want to open a content URL directly in your app. This is
    how you overcome the problem of not knowing the content URL before data has finished
    uploading to the Tango servers.
    
    Note that actions generated by your ContentUploadResponseToActionMapConverter subclass
    will supercede any existing actions that were set in the message.
    
    An example of when you might use this class is if you want to upload a leaderboard graphic
    to be displayed as a message thumbnail, but have taps on that message direct the user to
    your own app, such that the download URL for the leaderboard image is embedded in the
    message action.
    */
class ContentUploadResponseToActionMapConverter {
public:
  virtual ~ContentUploadResponseToActionMapConverter() { }
  
  /// Implement this and fill map using data from upload_details. It is called once per message.
  /// Return false on error, or return true if you successfully filled map. If you could not fill
  /// the map, default actions will be embedded (based upon the content mime type), and the
  /// message will still be sent.
  virtual bool fill_action_map(const ContentUploadDetails& upload_details,
                               PlatformToActionMap& map) = 0;
};

  
/// Return this from AsyncDataSource.read() on successful completion.
extern const ssize_t READ_FINISHED;
/// Return this from AsyncDataSource.read() on failure to read/append data.
/// The message will not be sent.
extern const ssize_t READ_FAILED;

/** AsyncDataSource is an interface for providing data to be uploaded to the Tango content server
    in an asynchronous (stream) manner. By using this mechanism, you do not need to keep all of
    the data in memory.
    
    WARNING: This functionality is incomplete and unsupported.
    */
class AsyncDataSource {
public:
  virtual ~AsyncDataSource() { }
  
  /** Fill buffer with data, blocking until more data is available or you are finished. You
      should attempt to fill the buffer completely each time read() is called. Return
      READ_FINISHED when you are done. Return READ_FAILED if there was a non-recoverable
      error, in which case the message will not be sent.
   
      After returning READ_FINISHED or READ_FAILED, a final call will be made with a NULL
      buffer indicating that it is safe to clean up your data structures.
      */
  virtual ssize_t read(unsigned char *buffer, size_t buffer_size) = 0;
};


/// Specify a rotation to apply to your video content to correct for the orientation that it
/// was captured in. Use with Message::set_content_metadata(). Rotation of image content is
/// not supported. The transformation is applied by the Tango content servers.
/// Value: int degrees clockwise (0/90/180/270 only)
extern const std::string CONTENT_ROTATION;

/// Key-value map to specify metadata about your content so that it can be manipulated for
/// proper display. You would use this, for instance, if you have a video from the iOS media
/// library that was not captured in the landscape-right orientation. The video has to be
/// transformed so that it plays right-side-up.
typedef std::map<std::string, std::string> ContentMetadata;


/** Message objects represent all the details about a message you might send to your user(s), using
    the Advanced messaging API. You use this with Session::send_message_to_recipients(), together
    with a context and a list of Tango account IDs.
    
    In order for a message to be displayed in the Tango client, it must contain either message_text,
    or have a thumbnail. Text can be set by calling set_message_text, but there are many ways for a
    thumbnail to appear in the message.
    
    First, you may specify a thumbnail by using the URL-based setter, in which case the Tango client
    will download the thumbnail and try to display it. If it cannot, a placeholder will be shown
    instead.
    
    The second way for a thumbnail to appear is for you to upload one to the Tango content
    servers using the byte-buffer setter.
    
    The third way that a thumbnail can be attached to the message is if you upload content that
    the Tango servers understand. In this case, a thumbnail will be generated for you and inserted
    into the message. You may override the auto-generated thumbnail by calling one of the thumbnail
    setter methods.
 
    If you rely on the auto-generated thumbnail and do not specify message_text, it is possible
    that the thumbnail failed to be generated. In that case, a failure response will be fired to
    your session callback handler and the message will not be sent.
    
    Note that specifying "content" to be opened by Tango (or in your own application) will cause
    any actions that you specify via set_platform_to_action_map to be overridden.
    
    Use set_content_upload_response_converter if you would like to upload content to the Tango
    servers but still have that content open in your application, even if it can be played inside
    Tango. You may also have content that would normally open inside Tango play in the web browser
    if you specify text/url for the content's mime type, instead of image/ * or video/ *.
 
    See the <a href="/ApiDetails/advancedmessaging.html">Advanced Messaging API Details</a>
    page for more information.
    */
class Message {
public:
  Message();
  ~Message();
  
  /// Set the text to be shown to users in push notifications and summaries. (Required).
  /// This should be a short description of the contents of the message. This may read
  /// like "Come play with me in <App>", or "Beat my best score in <App>!". You should
  /// not attempt to insert the user's name in the message, as it is automatically
  /// included in notifications, and should otherwise read like a message from the user.
  void set_description_text(const std::string& description_text);
  
  /// Set the text to be shown to users as part of the message. This is the body of the
  /// message, and it may span multiple lines, but there are client-side limits on how
  /// much space a message may take up. The current limitation is 10 lines of text.
  void set_message_text(const std::string& message_text);

  /// Set arbitrary user data. Right now this data is only used for internal analytics.
  /// It is not displayed to the recipient (or sender).
  void set_user_data(const std::string& user_data);
  
  /// Set a thumbnail to be shown to users as part of the message using a web URL.
  void set_thumbnail(const std::string& url);
  
  /// Set a thumbnail to upload to Tango content servers from a byte array. The mime type
  /// should match the thumbnail data to assist the content servers in auto-generating a
  /// thumbnail.
  void set_thumbnail(const std::string& bytes, const std::string& mime_type);
  
  /// Set content to upload from a byte array. The mime_type should match the data. In addition
  /// to making life easier for the content servers, the mime_type is used to selectively play
  /// content inside Tango (instead of in a browser) for a much better user experience. Specify
  /// an action_prompt as a "call to action" to entice the user into tapping the message. A basic
  /// example is "Tap to see the score!"
  void set_content(const std::string& bytes, const std::string& mime_type,
                   const std::string& action_prompt);
  
  /// Set the content to upload from an async data source. The mime type should match the data.
  /// Specify a length if able, otherwise specify zero length. Specify an action_prompt as a
  /// "call to action" to entice the user into tapping the message. A basic example is "Tap to
  /// see the score!"
  ///
  /// WARNING: This functionality is incomplete and unsupported.
  ///
  void set_content(AsyncDataSource *data_source, const std::string& mime_type, size_t length_hint,
                   const std::string& action_prompt);
  
  /// Set metadata regarding the content you want to upload. An example use case is when you are
  /// uploading a video and need to specify a transformation so that it is rendered correctly on
  /// the Tango client (or in your own app).
  void set_content_metadata(const ContentMetadata& metadata);
  
  /// Set a ContentUploadResponseToActionMapConverter to translate content server URLs into a
  /// PlatformToActionMap for the message. Since you do not know the URLs until after the content
  /// is uploaded to Tango, this is necessary in cases where you want Tango to open your app
  /// instead of taking a default action to view the content. This also gives you an opportunity
  /// to attach any necessary tokens that you want to pass to your application.
  void set_content_upload_response_converter(ContentUploadResponseToActionMapConverter *converter);
  
  /// Set a PlatformToActionMap for the message to specify what Tango should do when the
  /// user taps on the message. Set it to an empty PlatformToActionMap to clear any existing
  /// actions. If you set content using one of the set_content methods, the actions specified by
  /// this method are ignored. See the codedocs for PlatformToActionMap for information about
  /// how message actions work.
  void set_platform_to_action_map(const PlatformToActionMap &map);
  
  std::string description_text() const;
  std::string message_text() const;
  std::string user_data() const;
  
  std::string thumbnail_url() const;
  std::string thumbnail_bytes() const;
  AsyncDataSource * thumbnail_data_source() const;
  std::string thumbnail_mime_type() const;
  size_t thumbnail_length_hint() const;
  
  std::string content_bytes() const;
  AsyncDataSource * content_data_source() const;
  std::string content_mime_type() const;
  size_t content_length_hint() const;
  std::string content_action_prompt() const;
  
  ContentMetadata content_metadata() const;
  ContentUploadResponseToActionMapConverter * content_upload_response_converter() const;
  const PlatformToActionMap& platform_to_action_map() const;
  
  /// @internal
  MessageImpl * _impl() const;
  
private:
  // This class is non-copyable.
  Message(const Message&);
  Message& operator=(const Message&);
  
  MessageImpl *m_impl;
};

} // namespace tango_sdk

#endif // _TANGO_SDK_MESSAGE_H_
