//
//  AuthScreen.swift
//  sheet
//
//  Created by OmAr on 05/09/2024.
//

import SwiftUI
import GoogleSignInSwift

struct AuthScreen : View {
    
    @StateObject private var obs: AuthObserve = AuthObserve()
    @State private var toast: Toast? = nil

    @Inject
    private var theme: Theme
    
    var body: some View {
        ZStack {
        
            GoogleSignInButton(scheme: theme.isDarkMode ? .dark : .light, style: .wide, state: .normal) {
                obs.googleSignIn { email, name, imageUrl in
                    
                } failed: {
                    toast = Toast(style: .error, message: "Failed")
                }
            }.accessibilityIdentifier("GoogleSignInButton")
                 .accessibility(hint: Text("Sign in with Google button."))
                 .padding()
        }.toastView(toast: $toast)
    }
}
