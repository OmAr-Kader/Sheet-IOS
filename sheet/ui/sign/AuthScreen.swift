//
//  AuthScreen.swift
//  sheet
//
//  Created by OmAr on 05/09/2024.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

struct AuthScreen : View {

    @StateObject var app: AppObserve

    @StateObject private var obs: AuthObserve = AuthObserve()
    @State private var toast: Toast? = nil

    @Inject
    private var theme: Theme
    
    var body: some View {
        ZStack {
            VStack {
                Text("Hi there").foregroundStyle(theme.textColor).font(.headline)
                Spacer().frame(height: 50)
                GoogleSignInButton(scheme: theme.isDarkMode ? .dark : .light, style: .wide, state: .normal) {
                    obs.signIn { userBase in
                        app.updateUserBase(userBase: userBase)
                    } failed: {
                        toast = Toast(style: .error, message: "Failed")
                    }
                }.accessibilityIdentifier("GoogleSignInButton")
                    .accessibility(hint: Text("Sign in with Google button."))
                    .padding()
            }
        }.toastView(toast: $toast)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
                //GIDSignIn.sharedInstance.signOut()
            }
    }
}
