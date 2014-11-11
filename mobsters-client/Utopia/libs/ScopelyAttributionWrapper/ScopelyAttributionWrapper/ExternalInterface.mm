#import "ScopelyAttributionWrapper.h"

//#########################################################################
// --- MAT --- >>>
extern "C" void mat_initWithAdvertiserId(const char* advertiserId, const char* conversionKey, bool useIFA)
{
    [ScopelyAttributionWrapper mat_initWithAdvertiserId:[NSString stringWithUTF8String:advertiserId] andConversionKey:[NSString stringWithUTF8String:conversionKey] enableIFA:useIFA];
}

extern "C" void mat_startSession()
{
    [ScopelyAttributionWrapper mat_startSession];
}

extern "C" void mat_setUserInfoForUserId(const char* userId, const char* userName, const char* userEmail)
{
    [ScopelyAttributionWrapper mat_setUserInfoForUserId:[NSString stringWithUTF8String:userId] withNameUser:[NSString stringWithUTF8String:userName] withEmail:[NSString stringWithUTF8String:userEmail]];
}

extern "C" void mat_newAccountCreated()
{
    [ScopelyAttributionWrapper mat_newAccountCreated];
}

extern "C" void mat_tutorialComplete()
{
    [ScopelyAttributionWrapper mat_tutorialComplete];
}

extern "C" void mat_appOpen_002()
{
    [ScopelyAttributionWrapper mat_appOpen_002];
}

extern "C" void mat_appOpen_020()
{
    [ScopelyAttributionWrapper mat_appOpen_020];
}

extern "C" void mat_inviteFacebook()
{
    [ScopelyAttributionWrapper mat_inviteFacebook];
}

extern "C" void mat_inviteSms()
{
    [ScopelyAttributionWrapper mat_inviteSms];
}

extern "C" void mat_iap(const char* productName, const char* productId, float productPrice, int quantity, float revenueAmount, const char* currencyCode)
{
    [ScopelyAttributionWrapper mat_iapWithProdcutName:[NSString stringWithUTF8String:productName] productId:[NSString stringWithUTF8String:productId] productPrice:productPrice purchasedQuantity:quantity revenueAmount:revenueAmount currencyCode:[NSString stringWithUTF8String:currencyCode]];
}
// --- MAT --- <<<
//#########################################################################


//#########################################################################
// --- Adjust --- >>>
extern "C" void adjust_initWithApptoken(const char* appToken, bool useSandbox)
{
    [ScopelyAttributionWrapper adjust_initWithApptoken:[NSString stringWithUTF8String:appToken] usingSandboxMode:useSandbox];
}

extern "C" void adjust_setUserId(const char* userId)
{
    [ScopelyAttributionWrapper adjust_setUserId:[NSString stringWithUTF8String:userId]];
}

extern "C" void adjust_customVersion(const char* customVersion)
{
    [ScopelyAttributionWrapper adjust_customVersion:[NSString stringWithUTF8String:customVersion]];
}

extern "C" void adjust_trackEvent(const char* eventToken)
{
    [ScopelyAttributionWrapper adjust_trackEvent:[NSString stringWithUTF8String:eventToken]];
}
// --- Adjust --- <<<
//#########################################################################