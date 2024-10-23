//
//  AppleWebLoginCore.swift
//  AppleWebLogin
//
//  Created by 秋星桥 on 2024/10/23.
//

import Combine
import WebKit

private let loginURL = URL(string: "https://account.apple.com/sign-in")!

public class AppleWebLoginCore: NSObject, WKUIDelegate, WKNavigationDelegate {
    var webView: WKWebView {
        associatedWebView
    }

    private let associatedWebView: WKWebView
    private var dataPopulationTimer: Timer? = nil
    private var firstLoadComplete = false

    public private(set) var onFirstLoadComplete: (() -> Void)?
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
        associatedWebView.isHidden = true

        super.init()

        associatedWebView.uiDelegate = self
        associatedWebView.navigationDelegate = self

        associatedWebView.load(.init(url: loginURL))

        #if DEBUG
            if associatedWebView.responds(to: Selector(("setInspectable:"))) {
                associatedWebView.perform(Selector(("setInspectable:")), with: true)
            }
        #endif

        let dataPopulationTimer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            removeUnwantedElements()
            populateData()
        }
        RunLoop.main.add(dataPopulationTimer, forMode: .common)
        self.dataPopulationTimer = dataPopulationTimer
    }

    deinit {
        dataPopulationTimer?.invalidate()
        onCredentialPopulation = nil
    }

    public func webView(_: WKWebView, didFinish _: WKNavigation!) {
        guard !firstLoadComplete else { return }
        defer { firstLoadComplete = true }
        associatedWebView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.onFirstLoadComplete?()
            self.onFirstLoadComplete = nil
        }
    }

    public func installFirstLoadCompleteTrap(_ block: @escaping () -> Void) {
        onFirstLoadComplete = block
    }

    public func installCredentialPopulationTrap(_ block: @escaping (String) -> Void) {
        onCredentialPopulation = block
    }

    private func removeUnwantedElements() {
        let removeElements = """
        Element.prototype.remove = function() {
            this.parentElement.removeChild(this);
        }
        NodeList.prototype.remove = HTMLCollection.prototype.remove = function() {
            for(var i = this.length - 1; i >= 0; i--) {
                if(this[i] && this[i].parentElement) {
                    this[i].parentElement.removeChild(this[i]);
                }
            }
        }
        document.getElementById("globalheader").remove();
        document.getElementById("ac-localnav").remove();
        document.getElementById("ac-globalfooter").remove();
        document.getElementsByClassName('landing__animation').remove();
        """
        associatedWebView.evaluateJavaScript(removeElements) { _, _ in
        }
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
