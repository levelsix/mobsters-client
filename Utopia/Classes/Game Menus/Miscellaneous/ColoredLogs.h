//
//  ColoredLogs.h
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#define XCODE_COLORS_ESCAPE @"\033["

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

//#define COLORED_LOGS

#ifdef COLORED_LOGS

#define NSLogRed(frmt, ...)  LNLog((XCODE_COLORS_ESCAPE @"bg220,0,0;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)
#define NSLogGreen(frmt, ...)  LNLog((XCODE_COLORS_ESCAPE @"bg0,220,0;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)
#define NSLogBlue(frmt, ...)  LNLog((XCODE_COLORS_ESCAPE @"bg0,0,220;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)
#define NSLogYellow(frmt, ...)  LNLog((XCODE_COLORS_ESCAPE @"bg160,160,0;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)

#else

#define NSLogRed(...)  LNLog(__VA_ARGS__)
#define NSLogGreen(...)  LNLog(__VA_ARGS__)
#define NSLogBlue(...)  LNLog(__VA_ARGS__)
#define NSLogYellow(...)  LNLog(__VA_ARGS__)

#endif