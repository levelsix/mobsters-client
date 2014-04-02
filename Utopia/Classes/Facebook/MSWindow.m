//
//  MSWindow.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MSWindow.h"
#import "FBDialog.h"

@implementation FacebookWebViewDelegate

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  if ([self.realDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
    [self.realDelegate webView:webView didFailLoadWithError:error];
  }
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
  if ([self.realDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
    [self.realDelegate webViewDidFinishLoad:webView];
  }
  [self performSelector:@selector(autoClickSend:) withObject:webView afterDelay:1.f];
}

- (void) autoClickSend:(UIWebView *)webView {
  NSString *req = @"document.getElementsByName(\"__CONFIRM__\")[0].click()";
  [webView stringByEvaluatingJavaScriptFromString:req];
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
  if ([self.realDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
    [self.realDelegate webViewDidStartLoad:webView];
  }
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if ([self.realDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType]) {
    return [self.realDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
  }
  return YES;
}

@end

@implementation MSWindow

- (UIView *) viewInHierarchy:(UIView *)v class:(Class)class {
  if ([v isKindOfClass:class]) {
    return v;
  }
  for (UIView *s in v.subviews) {
    UIView *r = [self viewInHierarchy:s class:class];
    if (r) {
      return r;
    }
  }
  return nil;
}

- (void) addSubview:(UIView *)view {
  // Check if there is an FBDialog
  if (self.silentlyAcceptFacebookRequests && [self viewInHierarchy:view class:[FBDialog class]]) {
    // Find the web view
    UIWebView *web = (UIWebView *)[self viewInHierarchy:view class:[UIWebView class]];
    if (!self.facebookDelegates) {
      self.facebookDelegates = [NSMutableArray array];
    }
    FacebookWebViewDelegate *delegate = [[FacebookWebViewDelegate alloc] init];
    delegate.realDelegate = web.delegate;
    web.delegate = delegate;
    [self.facebookDelegates addObject:delegate];
    
    [self insertSubview:view atIndex:0];
  } else {
    [super addSubview:view];
  }
  
  for (UIView *view in self.omnipresentViews) {
    [self bringSubviewToFront:view];
  }
}

- (void) displayOmnipresentView:(UIView *)v {
  if (!self.omnipresentViews) self.omnipresentViews = [NSMutableArray array];
  [self.omnipresentViews addObject:v];
  [self addSubview:v];
}

- (void) removeOmniPresentView:(UIView *)v {
  [self.omnipresentViews removeObject:v];
  [v removeFromSuperview];
}

@end
