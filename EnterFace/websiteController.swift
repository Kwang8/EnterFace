//
//  websiteController.swift
//  EnterFace
//
//  Created by Kevin Wang on 10/25/20.
//  Copyright © 2020 Kevin Wang. All rights reserved.
//

import Foundation
import WebKit

class websiteController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://enterface-aebfa.web.app/")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}
