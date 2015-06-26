//
//  ClientProperties.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#include "OpenUDID.h"

#ifdef APPSTORE

#define USE_PROD
#define UDID [OpenUDID value]

#elif !defined(DEBUG)

#define USE_STAGING
#define UDID [OpenUDID value]

#else

#define UDID [OpenUDID value]

#define CLIENT_BRANCH @"master"

//#define USE_PROD
#define USE_STAGING
//#define USE_LOCAL

//#define FORCE_TUTORIAL TutorialStepGuideGreeting
//#define FORCE_TUTORIAL TutorialStepEnteredBattle

//#define DEBUG_BATTLE_MODE

#endif















































































// DON'T TOUCH THESE ANYMORE, CHANGE ABOVE VALUES

#ifdef USE_PROD

#define HOST_NAME @"ws://prodmobsters-%@.lvl6.com/client/connection"
#define SERVER_ID @"prod"

//For amqp
//#define HOST_NAME @"amqpprodmobsters.lvl6.com"
//#define HOST_PORT 5671
//#define USE_SSL 1
//#define MQ_USERNAME @"lvl6client"
//#define MQ_PASSWORD @"LvL6Pr0dCl!3nT"
//#define MQ_VHOST @"prodmobsters"

#elif defined(USE_STAGING)

#define HOST_NAME @"ws://stagingmobsters-%@.lvl6.com/client/connection"
#define SERVER_ID @"stage"

//For amqp
//#define HOST_NAME @"amqpstagingmobsters.lvl6.com"
//#define HOST_PORT 5671
//#define USE_SSL 1
//#define MQ_USERNAME @"lvl6client"
//#define MQ_PASSWORD @"devclient"
//#define MQ_VHOST @"devmobsters"

#elif defined(USE_LOCAL)

#define HOST_NAME @"ws://10.0.1.183/client/connection"
#define HOST_PORT 5672
#define USE_SSL 0
#define MQ_USERNAME @"lvl6client"
#define MQ_PASSWORD @"devclient"
#define MQ_VHOST @"devmobsters"
#define SERVER_ID @"local"

#else

#define HOST_NAME @"ws://dev2mobsters.lvl6.com:8080/client/connection"
#define SERVER_ID @"dev"

//For amqp
//#define HOST_NAME @"dev2mobsters.lvl6.com"
//#define HOST_PORT 5672
//#define USE_SSL 0
//#define MQ_USERNAME @"lvl6client"
//#define MQ_PASSWORD @"devclient"
//#define MQ_VHOST @"devmobsters"

#endif
