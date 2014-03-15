/*!
 *
 * Kamcord-C-Interface.h
 * Copyright (c) 2013 Kamcord. All rights reserved.
 *
 */

#ifndef __KAMCORD_C_INTERFACE_H__
#define __KAMCORD_C_INTERFACE_H__

#ifdef __cplusplus
extern "C" {
#endif
    /*******************************************************************
     *
     * Kamcord config
     *
     */
    
    /*
     *
     * Returns a C string which is the Kamcord version. You *must*
     * strdup this return value if you want to use it later.
     *
     */
    const char * Kamcord_Version();
    
    /*
     *
     * Automatically disable Kamcord on certain devices. Disabling Kamcord
     * on a device makes all medthod calls on those devices turn into NO-OPs.
     * Call this method before you call any other Kamcord methods.
     *
     * @param   disableiPod4G           Disable Kamcord on iPod1G, 2G, 3G, and 4G.
     * @param   disableiPod5G           Disable Kamcord on iPod5G.
     * @param   disableiPhone3GS        Disable Kamcord on iPhone 3GS.
     * @param   disableiPhone4          Disable Kamcord on iPhone 4.
     * @param   disableiPhone4S         Disable Kamcord on iPhone 4S.
     * @param   disableiPhone5          Disable Kamcord on iPhone 5.
     * @param   disableiPhone5S         Disable Kamcord on iPhone 5S.
     * @param   disableiPad1            Disable Kamcord on iPad 1.
     * @param   disableiPad2            Disable Kamcord on iPad 2.
     * @param   disableiPadMini         Disable Kamcord on iPad Mini.
     * @param   disableiPad3            Disable Kamcord on iPad 3.
     * @param   disableiPad4            Disable Kamcord on iPad 4.
     * @param   disableiPadAir          Disable Kamcord on iPad Air.
     *
     */
    void Kamcord_SetDeviceBlacklist(bool disableiPod4G,
                                    bool disableiPod5G,
                                    bool disableiPhone3GS,
                                    bool disableiPhone4,
                                    bool disableiPhone4S,
                                    bool disableiPhone5,
                                    bool disableiPhone5S,
                                    bool disableiPad1,
                                    bool disableiPad2,
                                    bool disableiPadMini,
                                    bool disableiPad3,
                                    bool disableiPad4,
                                    bool disableiPadAir);
    
    /*
     *
     * Kamcord initialization. Must be called before you can start recording.
     *
     * @param   developerKey            Your Kamcord developer key.
     * @param   developerSecret         Your Kamcord developerSecret.
     * @param   appName                 The name of your application.
     * @param   parentViewController    The view controller that will present the Kamcord UI.
     *                                  This object must be an instance of UIViewController.
     *
     */
    void Kamcord_Init(const char * developerKey,
                      const char * developerSecret,
                      const char * appName,
                      void * parentViewController);
    
    
    /*
     *
     * Returns true if and only if Kamcord is enabled. Kamcord is by default
     * enabled, but is disabled if any of the following conditions are met:
     *
     *  - The version of iOS is < 5.0
     *  - The device has been blacklisted by Kamcord_SetDeviceBlacklist(...);
     *
     */
    bool Kamcord_IsEnabled();
    
    /*
     *
     * Enable or disable the live voice overlay. Note: enabling Voice Overlay only
     * enables the users to activate voice overlay in the Kamcord settings UI.
     * To activate Voice Overlay on behalf of the user (after you've enabled it with
     * this method), please use Kamcord_ActivateVoiceOverlay(...) below.
     *
     * @param   enabled             Whether to enable or disable the live voiced overlay feature.
     *                              By default, this is disabled.
     *
     */
    void Kamcord_SetVoiceOverlayEnabled(bool eanbled);
    
    /*
     *
     * Returns true if live voice overlay has been enabled.
     *
     */
    bool Kamcord_VoiceOverlayEnabled();
    
    /*
     *
     * Once the voice overlay is enabled, the user can go to the Kamcord UI
     * and activate the voice overlay. You can also do activate/deactivate voice
     * overlay for the user by calling the following method.
     *
     * @param   bool                Whether or not to activate voice overlay recording.
     *
     */
    void Kamcord_ActivateVoiceOverlay(bool activate);
    
    /*
     *
     * Returns true if the user's voice is being recorded on every video.
     *
     */
    bool Kamcord_VoiceOverlayActivated();

    /*******************************************************************
     *
     * Video recording
     *
     */
    
    /*
     *
     * Start video recording.
     *
     */
	void Kamcord_StartRecording();
    
    /*
     *
     * Stop video recording.
     *
     */
    void Kamcord_StopRecording();
    
    /*
     *
     * Pause video recording.
     *
     */
    void Kamcord_Pause();
    
    /*
     *
     * Resume video recording.
     *
     */
    void Kamcord_Resume();
    
    /*
     *
     * Returns true if the video is recording. Note that there might be a slight
     * delay after you call Kamcord_StartRecording() before this method returns true.
     *
     */
    bool Kamcord_IsRecording();
    
    /*
     *
     * Returns true if video recording is currently paused.
     *
     */
    bool Kamcord_IsPaused();
    
    
    /*
     *
     * After every video is recorded (i.e. after you call StopRecording()), you should
     * call this method to set the title for the video in case it is shared.
     *
     * We suggest you set the title to contain some game-specific information such as
     * the level, score, and other relevant game metrics.
     *
     * @param   title   The title of the last recorded video.
     *
     */
    void Kamcord_SetVideoTitle(const char * title);
    
    /*
     *
     * Set the level and score for the recorded video.
     * This metadata is used to rank videos in the watch view.
     *
     * @param   level   The level for the last recorded video.
     * @param   score   The score the user just achieved on the given level.
     *
     */
    void Kamcord_SetLevelAndScore(const char * level,
                                  double score);
    
    typedef enum
    {
        KC_LEVEL = 0,       // For a level played in the video.
        KC_SCORE,           // For a score for the video.
        KC_LIST,            // For a ',' delimited list of values to apply to a key, numerical value if given will apply to all.
        KC_OTHER = 1000,    // For arbitrary key to value metadata.
    } KC_METADATA_TYPE;
    
    /*
     *
     * Set a piece of metadata for the recorded video
     * All metadata is cleared with the start of a recorded video
     *
     * @param       metadataType       The type of metaData (see KC_METADATA_TYPE for more info)
     * @param       displayKey         Describe what the metadata is
     * @param       displayValue       A string representation of the value for this metadata
     * @param       numericValue       A numeric representation of the value for this metadata
     *
     */
    void Kamcord_SetDeveloperMetadata(KC_METADATA_TYPE metadataType,
                                      const char * displayKey,
                                      const char * displayValue);
    
    void Kamcord_SetDeveloperMetadataWithNumericValue(KC_METADATA_TYPE metadataType,
                                                      const char * displayKey,
                                                      const char * displayValue,
                                                      double numericValue);
    
    /*
     * Returns true if there is at least one video matching the constraints
     *
     * @param      jsonDictionary           A json serialized dictionary of metadataDisplayKey ->
     *                                      value. A value is either a displayValue or a numericValue
     *                                      see Kamcord_SetDeveloperMetadata* for info
     *
     */
    bool Kamcord_VideoExistsWithMetadataConstraints(const char * jsonDictionary);
    
    
    /*
     * Used to play a video that conforms to the given constraints
     *
     * @param       jsonDictionary        see Kamcord_VideoExistsWithMetadataConstraints for explanation
     * @param     title                  An optional title to be displayed for the video.
     *                                   If NULL is passed in, the title that was shared with the
     *                                   video will be used.
     *
     */
    void Kamcord_ShowVideoWithMetadataConstraints(const char * jsonDictionary, const char * title);
    
    /*
     * Used to play the video with id 'videoID'
     *  
     * @param     videoID                The videoID for the desired video
     * @param     title                  An optional title to be displayed for the video.
     *                                   If NULL is passed in, the title that was shared with the
     *                                   video will be used.
     */
    void Kamcord_ShowVideoWithVideoID(const char * videoID, const char * title);
    
    /*
     *
     * Use this to record the OpenGL frame to video in its currently rendered state.
     * You can use this, for instance, after you draw your game scene but before
     * you draw your HUD. This will result in the recorded video only having
     * the scene without the HUD.
     *
     */
    void Kamcord_CaptureFrame();
    
    /*
     *
     * Set the video quality to standard or trailer. Please do *NOT* release your game
     * with trailer quality, as it makes immensely large videos with only a slight
     * video quality improvement over standard.
     *
     * The default and recommended quality seting is KC_STANDARD_VIDEO_QUALITY.
     *
     * @param   quality     The desired video quality.
     *
     */
    typedef enum
    {
        KC_STANDARD_VIDEO_QUALITY   = 0,
        KC_TRAILER_VIDEO_QUALITY    = 1,    // Should only be used to make trailers. Do *NOT* release your game with this setting.
    } KC_VIDEO_QUALITY;
    
    void Kamcord_SetVideoQuality(KC_VIDEO_QUALITY videoQuality);
    
    /*
     *
     * Set the recorded audio quality. We recommend you use the defaults, which are:
     *
     *     - Num Channels: 2
     *     - Frequency: 44100
     *     - Bitrate: 64000
     *
     * The audio recording settings for single core devices cannot be changed due
     * to performance reasons.
     *
     * @param   numChannels     The number of audio channels in the recording. Can be 1 or 2.
     * @param   frequency       The recording frequency in Hz.
     * @param   bitrate         The recording bitrate in bits per second.
     *
     */
    void Kamcord_SetAudioRecordingProperties(unsigned int numChannels,
                                             unsigned int frequency,
                                             unsigned int bitrate);
    
    /*******************************************************************
     *
     * Kamcord UI
     *
     */
    
    /*
     *
     * Show the Kamcord view, which will let the user share the most
     * recently recorded video.
     *
     */
    void Kamcord_ShowView();
    
    /*
     *
     * Show the watch view, which has a feed of videos shared by other users.
     *
     */
    void Kamcord_ShowWatchView();
    
    /*
     *
     * Shows the Gameplay of the Week view in the default view controller.
     *
     */
    void Kamcord_ShowPushNotifView();
    
    /*******************************************************************
     *
     * Share settings
     *
     */
    
    /*
     *
     * For native iOS 6 Facebook integration, set your Facebook App ID
     * so all Facebook actions will happen through your game's Facebook app.
     *
     * @param   facebookAppID   Your app's Facebook App ID.
     *
     */
    void Kamcord_SetFacebookAppID(const char * facebookAppID);
    
    /*
     *
     * Set the description for when the user shares to Facebook.
     *
     * @param   description     Your app's description when a user shares a video on Facebook.
     *
     */
    void Kamcord_SetFacebookDescription(const char * description);
    
    /*
     *
     * Set the video description and tags for YouTube.
     *
     * @param   description     The video's description when it's shared on YouTube.
     * @param   tags            The video's tags when it's shared on YouTube.
     *
     */
    void Kamcord_SetYouTubeSettings(const char * description,
                                    const char * tags);

    /*
     *
     * Set the default tweet.
     *
     * @param   tweet           The default tweet.
     *
     */
    void Kamcord_SetDefaultTweet(const char * tweet);
    
    /*
     *
     * The Twitter description for the embedded video.
     *
     * @param   twitterDescription  The twitter description for the embedded video.
     *
     */
    void Kamcord_SetTwitterDescription(const char * twitterDescription);

    /*
     *
     * Set the default email subject.
     *
     * @param   subject         The default subject if the user shares via email.
     *
     */
    void Kamcord_SetDefaultEmailSubject(const char * subject);

    /*
     *
     * Set the default email body.
     *
     * @param   body            The default email body if the user shares via email.
     *
     */
    void Kamcord_SetDefaultEmailBody(const char * body);
    
    
    /*******************************************************************
     * 
     * Sundry Methods
     *
     */
    
    /*
     *
     * Set the FPS of the recorded video. Valid values are 30 and 60 FPS.
     * The default setting is 30 FPS.
     *
     * @param   videoFPS        The recorded video's FPS.
     *
     */
    void Kamcord_SetVideoFPS(int videoFPS);
    
    /*
     *
     * Returns the FPS of the recorded video.
     *
     */
    int Kamcord_VideoFPS();
    
    /*
     *
     * To prevent videos from becoming too long, you can use this method
     * and Kamcord will only record the last given seconds of the video.
     *
     * For instance, if you set seconds to 300, then only the last 5 minutes
     * of video will be recorded and shared. The default setting is 300 seconds
     * with a maximum of up to 1 hour = 60 * 60 = 3600 seconds.
     *
     * @param   seconds         The maximum length of a recorded video.
     *
     */
    void Kamcord_SetMaximumVideoLength(unsigned int seconds);
    
    /*
     *
     * Returns the maximum video length.
     *
     */
    unsigned int Kamcord_MaximumVideoLength();
    
    /*******************************************************************
     *
     * Gameplay of the week
     *
     */
    
    /*
     *
     * Enable automatic gameplay of the week push notifications.
     *
     * @param   notificationsEnabled    Enable video push notifications?
     *
     */
    void Kamcord_SetNotificationsEnabled(bool notificationsEnabled);
    
    /*
     *
     * Fire a test gameplay of the week push notfication.
     *
     */
    void Kamcord_FireTestNotification();
    
    /*******************************************************************
     *
     * OpenGL (if using KamcordRecorder and a custom game engine)
     *
     */
    
    /*
     *
     * Returns the current framebuffer that the engine should render to if it wants
     * the results of that render to appear on the screen.
     *
     * @returns The active framebuffer.
     *
     */
    int KamcordRecorder_ActiveFramebuffer();
    
    /*******************************************************************
     *
     * Private API
     *
     */
    void Kamcord_SetMode(long long unsigned mode);
    
#ifdef __cplusplus
}
#endif

#endif
