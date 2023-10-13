//
//  GBRelatedInformationView.m
//  GBAnnotationViewDemo
//
//  Created by Adam Barrett on 2013-09-26.
//  Copyright (c) 2013 GB Internet Solutions. All rights reserved.
//

#import "GBRelatedInformationView.h"

#define OBSERVE_CONTENT_SIZE @"contentSize"

@interface GBRelatedInformationView()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, assign) BOOL webViewloaded;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSURLRequest *initialRequest;

@end

@implementation GBRelatedInformationView
#pragma mark - Property Accessors
@synthesize webView = _webView;

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.frame];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.opaque = NO;
        _webView.delegate = self;
        _webView.scrollView.scrollEnabled = NO;
        _webView.scalesPageToFit = NO;
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew;
        [_webView.scrollView addObserver:self forKeyPath:OBSERVE_CONTENT_SIZE options:options context:nil];
        [self addSubview:_webView];
    }
    return _webView;
}

- (void)setWebView:(UIWebView *)webView
{
    if (_webView != webView) {
        [_webView.scrollView removeObserver:self forKeyPath:OBSERVE_CONTENT_SIZE];
        _webView = webView;
    }
}

- (void)setSpinner:(UIActivityIndicatorView *)spinner
{
    if (_spinner != spinner) {
        [_spinner removeFromSuperview];
        if (spinner) {
            [self addSubview:spinner];
        }
        _spinner = spinner;
    }
}

- (void)setSubject:(NSString *)subject
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner startAnimating];
    
    if (![_subject isEqualToString:subject]) {
        _subject = subject;
        NSString *urlString = [NSString stringWithFormat:@"http://bigab.net/%@", [self urlEncode:subject]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        self.initialRequest = request;
        [self.webView loadRequest:request];
    }
}

#pragma mark - LifeCycle
- (void)dealloc
{
    self.spinner = nil;
    self.webView = nil;
}

#pragma mark - String stuff
- (NSString *)urlEncode:(NSString *)string
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:OBSERVE_CONTENT_SIZE] && [object isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        if (scrollView.superview == self.webView) {
            [self changeWebViewSize:scrollView.contentSize];
        }
    }
}

- (void)changeWebViewSize:(CGSize)size
{
    UIWebView *webView = self.webView;
    CGSize webViewSize = webView.bounds.size;
    
    if ( ! CGSizeEqualToSize(webViewSize, size) ) {
        CGRect f = webView.frame;
        f.size = size;
        webView.frame = f;
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    self.webViewloaded = YES;
    self.spinner = nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType != UIWebViewNavigationTypeOther) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

#pragma mark - Layout
- (void)layoutSubviews
{
    CGRect f = self.frame;
    __block CGFloat y = 0.0;
    __block CGRect wrapRect = CGRectZero;
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        if (subview == self.webView && !self.webViewloaded) return;
        CGRect sf = subview.frame;
        subview.frame = subview.bounds;
        y += sf.size.height;
        wrapRect = CGRectUnion(wrapRect, sf);
    }];
    
    if (!CGRectEqualToRect(wrapRect, CGRectZero)) {
        self.frame = CGRectMake(f.origin.x, f.origin.y, wrapRect.size.width, wrapRect.size.height);
    }
}

@end
