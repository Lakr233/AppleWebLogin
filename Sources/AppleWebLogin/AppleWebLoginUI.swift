// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct AppleWebLoginUI: NSViewRepresentable {
    let onCredentialUpdate: (String) -> Void
    public init(onCredentialUpdate: @escaping (String) -> Void) {
        self.onCredentialUpdate = onCredentialUpdate
    }

    public func makeCoordinator() -> CoordinateCore {
        .init()
    }
    
    public func makeNSView(context: Context) -> NSView {
        context.coordinator.core.installCredentialPopulationTrap(onCredentialUpdate)
        return context.coordinator.core.webView
    }

    public func updateNSView(_: NSView, context _: Context) {}
}

