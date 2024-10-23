//
//  AppleWebLoginView.swift
//  AppleWebLogin
//
//  Created by 秋星桥 on 2024/10/23.
//

import SwiftUI

public struct AppleWebLoginView: View {
    let onCredentialUpdate: (String) -> Void

    public init(onCredentialUpdate: @escaping (String) -> Void) {
        self.onCredentialUpdate = onCredentialUpdate
    }

    @State var showProgressOverlay = true

    public var body: some View {
        AppleWebLoginUI {
            showProgressOverlay = false
        } onCredentialUpdate: { credential in
            onCredentialUpdate(credential)
        }
        .overlay(loadingIndicator)
    }

    @ViewBuilder
    var loadingIndicator: some View {
        if showProgressOverlay {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        }
    }
}
