// Copyright 2012-2014, TangoMe Inc ("Tango").  The SDK provided herein includes
// software and other technology provided by Tango that is subject to copyright and
// other intellectual property protections. All rights reserved.  Use only in
// accordance with the Evaluation License Agreement provided to you by Tango.
//
// Please read Tango_SDK_Evaluation_License_agreement_v1-2.docx
//

#ifndef _INCLUDED_tango_sdk_event_codes_h
#define _INCLUDED_tango_sdk_event_codes_h

// Keep this file plain C because we use it in our Objective C code.
// NOTE: Dont change the order or values.  Always add new entries at the end.

/// Tango SDK event codes
enum EventCode
{
  TANGO_SDK_EVENT_GENERIC = 0,              ///< Generic event type.
  TANGO_SDK_EVENT_CONTACTS_CHANGED = 1,     ///< The user's contacts have changed.
};

#endif // _INCLUDED_tango_sdk_event_codes_h
