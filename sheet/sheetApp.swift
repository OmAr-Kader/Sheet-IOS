//
//  sheetApp.swift
//  sheet
//
//  Created by OmAr on 05/09/2024.
//

import SwiftUI

@main
struct sheetApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State var isInjected: Bool = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isInjected {
                    Main(app: delegate.app)
                } else {
                    SplashScreen().task {
                        let _ = await Task { @MainActor in
                            delegate.app.findUserBase { it in
                                if !isInjected {
                                    withAnimation {
                                        delegate.app.navigateHomeNoAnimation(it != nil ? .HOME_SCREEN_ROUTE : .AUTH_SCREEN_ROUTE)
                                        isInjected.toggle()
                                    }
                                }
                            }
                        }.result
                    }
                }
            }
        }
    }
}
