//
//  RNCWebViewAssetSchemeHandler.m
//  react-native-webview
//
//  Created by JYOONG on 2022/11/08.
//

#import <Foundation/Foundation.h>
#import "RNCWebViewAssetSchemeHandler.h"
#import <WebKit/WebKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@implementation RNCWebViewAssetSchemeHandler

- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask {
    NSURL *requestURL = [[urlSchemeTask request] URL];

    if (requestURL == nil) {
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:400 userInfo:nil];
        return;
    }

    NSString *pathExtension = [requestURL pathExtension];
    NSString *path = [[[requestURL path] substringFromIndex:1] stringByDeletingPathExtension];

    if (path == nil || pathExtension == nil) {
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:400 userInfo:nil];
        return;
    }

    NSURL *assetURL = [[NSBundle mainBundle] URLForResource:path withExtension:pathExtension];

    if (assetURL == nil) {
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:404 userInfo:nil];
        [urlSchemeTask didFailWithError:error];
        return;
    }

    NSString *mimeType = [UTType typeWithFilenameExtension:[assetURL pathExtension]].preferredMIMEType;
    NSData *data = [[NSData alloc] initWithContentsOfURL:assetURL];

    if(mimeType == nil || data == nil) {
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:404 userInfo:nil];
        [urlSchemeTask didFailWithError:error];
        return;
    }

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:requestURL MIMEType:mimeType expectedContentLength:data.length textEncodingName:nil];

    [urlSchemeTask didReceiveResponse:response];
    [urlSchemeTask didReceiveData:data];
    [urlSchemeTask didFinish];
}


- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask {

}

@end
