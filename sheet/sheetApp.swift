//
//  sheetApp.swift
//  sheet
//
//  Created by OmAr on 05/09/2024.
//

import SwiftUI
import GoogleSignIn

@main
struct sheetApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            Main(app: delegate.app).onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
                //GIDSignIn.sharedInstance.signOut()
              }
        }
    }
}
