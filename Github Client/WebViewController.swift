//
//  WebViewController.swift
//  Github Client
//
//  Created by Artem Misesin on 3/17/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import OAuthSwift
import UIKit

typealias WebView = UIWebView

class WebViewController: OAuthWebViewController {
    
    var targetURL: URL?
    let webView: WebView = WebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.frame = UIScreen.main.bounds
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        //loadAddressURL()
    }
    
    override func handle(_ url: URL) {
        targetURL = url
        super.handle(url)
        self.loadAddressURL()
    }
    
    func loadAddressURL() {
        guard let url = targetURL else {
            return
        }
        let req = URLRequest(url: url)
        self.webView.loadRequest(req)
    }
}

// MARK: delegate
extension WebViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.url!.absoluteString
        let redirectUri = "http://oauthswift.herokuapp.com/callback/github_client"
        if let tokenStart =  urlString.range(of: "\(redirectUri)?code=") {
            OAuthSwift.handle(url: request.url!)
            self.dismissWebViewController()
        }
        return true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {

        if error.localizedDescription == "The Internet connection appears to be offline."{
            let alert = UIAlertController(title: "Error", message: "Check your internet connection and try again", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: {_ in self.dismissWebViewController()}))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
