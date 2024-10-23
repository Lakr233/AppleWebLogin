//
//  main.swift
//  ALExample
//
//  Created by 秋星桥 on 2024/10/23.
//

import SwiftUI
import AppleWebLogin
import WindowAnimation

struct User: Codable, Equatable {
    let fullName: String
    let firstName: String
    let lastName: String
    let emailAddress: String
    let prsId: String
}

struct ALExample: App {
    @State var user: User?
    @State var openLoginAlert = false
    @State var openLoginSheet = false
    @State var openProgress = false
    
    var body: some Scene {
        WindowAnimationResizeGroup {
            VStack {
                if let user {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Login Complete")
                            .bold()
                        Text(user.fullName)
                        Text(user.emailAddress)
                        Text(user.prsId).monospaced()
                        Divider()
                        Button("Log Out") { self.user = nil }
                    }
                    .transition(.opacity.combined(with: .scale(0.95)))
                } else {
                    VStack(alignment: .center, spacing: 16) {
                        Image(systemName: "applelogo")
                            .font(.largeTitle)
                        Button("Sign In with Apple") {
                            openLoginAlert = true
                        }
                        .alert(isPresented: $openLoginAlert) {
                            Alert(
                                title: Text("Notice"),
                                message: Text("Please sign in within the web view."),
                                dismissButton: .default(Text("Got it!"), action: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        openLoginSheet = true
                                    }
                                })
                            )
                        }
                        .sheet(isPresented: $openLoginSheet) {
                            AppleWebLoginUI { populateOlympus(token: $0) }
                                .frame(width: 800, height: 500)
                        }
                        .sheet(isPresented: $openProgress) {
                            ProgressView()
                                .padding(32)
                        }
                    }
                    .transition(.opacity.combined(with: .scale(0.95)))
                }
            }
            .frame(width: 250)
            .animation(.spring, value: user)
            .padding(32)
        }
        .windowStyle(.hiddenTitleBar)
    }
    
    func populateOlympus(token: String) {
        openLoginSheet = false
        openProgress = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            var request = URLRequest(url: URL(string: "https://appstoreconnect.apple.com/olympus/v1/session")!)
            request.setValue("myacinfo=\(token);", forHTTPHeaderField: "Cookie")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else { return }
                guard let dic = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
                guard let userData = dic["user"] as? [String: Any] else { return }
                guard let userDataRaw = try? JSONSerialization.data(withJSONObject: userData) else { return }
                guard let user = try? JSONDecoder().decode(User.self, from: userDataRaw) else { return }
                
                DispatchQueue.main.async {
                    openProgress = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.user = user
                }
            }.resume()
        }
    }
}

ALExample.main()
