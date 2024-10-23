//
//  AppleWebLoginView.swift
//  AppleWebLogin
//
//  Created by 秋星桥 on 2024/10/23.
//

import Combine
import WebKit

private let loginURL = URL(string: "https://appleid.apple.com/")!

public class AppleWebLoginCore: NSObject, WKUIDelegate, WKNavigationDelegate {
    internal var webView: WKWebView {
        associatedWebView
    }
    
    private let associatedWebView: WKWebView
    private var dataPopulationTimer: Timer? = nil
    private var firstLoadComplete = true

    public private(set) var onCredentialPopulation: ((String) -> Void)?

    override public init() {
        let contentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.userContentController = contentController
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        configuration.websiteDataStore = .nonPersistent()

        associatedWebView = .init(
            frame: CGRect(x: 0, y: 0, width: 1920, height: 1080),
            configuration: configuration
        )

        super.init()

        associatedWebView.uiDelegate = self
        associatedWebView.navigationDelegate = self

        associatedWebView.load(.init(url: loginURL))

        #if DEBUG
            if associatedWebView.responds(to: Selector(("setInspectable:"))) {
                associatedWebView.perform(Selector(("setInspectable:")), with: true)
            }
        #endif

        let dataPopulationTimer = Timer(timeInterval: 3, repeats: true) { [weak self] _ in
            guard let self else { return }
            populateData()
        }
        RunLoop.main.add(dataPopulationTimer, forMode: .common)
        self.dataPopulationTimer = dataPopulationTimer
    }

    deinit {
        dataPopulationTimer?.invalidate()
        onCredentialPopulation = nil
    }

    public func installCredentialPopulationTrap(_ block: @escaping (String) -> Void) {
        onCredentialPopulation = block
    }

    private func populateData() {
        guard let onCredentialPopulation else { return }
        associatedWebView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies where cookie.name == "myacinfo" {
                let value = cookie.value
                onCredentialPopulation(value)
                self.onCredentialPopulation = nil
            }
        }
    }
}
