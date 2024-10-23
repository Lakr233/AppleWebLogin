// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct AppleWebLoginUI: NSViewRepresentable {
    let onFirstLoadComplete: () -> Void
    let onCredentialUpdate: (String) -> Void

    public init(
        onFirstLoadComplete: @escaping () -> Void,
        onCredentialUpdate: @escaping (String) -> Void
    ) {
        self.onFirstLoadComplete = onFirstLoadComplete
        self.onCredentialUpdate = onCredentialUpdate
    }

    public func makeCoordinator() -> CoordinateCore {
        .init()
    }

    public func makeNSView(context: Context) -> NSView {
        context.coordinator.core.installFirstLoadCompleteTrap(onFirstLoadComplete)
        context.coordinator.core.installCredentialPopulationTrap(onCredentialUpdate)
        return context.coordinator.core.webView
    }

    public func updateNSView(_: NSView, context _: Context) {}
}
