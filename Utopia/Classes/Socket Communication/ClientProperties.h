//
//  ClientProperties.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#include "OpenUDID.h"

#ifndef DEBUG

#define USE_PROD

#define UDID [OpenUDID value]

#else

//#define USE_PROD

#define UDID @"adfwea"//[OpenUDID value]
//#define FORCE_TUTORIAL

#endif

#ifdef USE_PROD

#define HOST_NAME @"staging.mobsters.lvl6.com"
#define HOST_PORT 5672
#define MQ_USERNAME @"lvl6client"
#define MQ_PASSWORD @"devclient"
#define MQ_VHOST @"devmobsters"

#else

#define HOST_NAME @"staging.mobsters.lvl6.com"
#define HOST_PORT 5672
#define MQ_USERNAME @"lvl6client"
#define MQ_PASSWORD @"devclient"
#define MQ_VHOST @"devmobsters"

#endif
