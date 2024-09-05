//
//  AuthObserve.swift
//  sheet
//
//  Created by OmAr on 05/09/2024.
//

import Foundation
import GoogleSignIn

class AuthObserve : ObservableObject {
    
    @Inject
    private var project: Project
    
    private var scope = Scope()
    
    @MainActor
    @Published var state = State()
    
    @MainActor
    func googleSignIn(invoke: @escaping (String, String, String) -> Unit, failed: @escaping () -> Unit) {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
        let signInConfig = GIDConfiguration.init(clientID: CLIENT_ID)
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController,
            hint: "Sign",
            additionalScopes: ["https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile"], completion: { signInResult, error in
                if let error {
                    logger("GOOGLE SIGN IN", error.localizedDescription)
                    failed()
                    return
                }
                guard let profile = signInResult?.user.profile else {
                    logger("GOOGLE SIGN IN", "Invalid user profile")
                    invoke("", "", "")
                    return
                }
                invoke(profile.email, profile.name , profile.hasImage ? (profile.imageURL(withDimension: 100)?.absoluteString ?? "") : "")
            }
        )
    }
    
    
    struct State {
        
        private(set) var name: String = ""
        private(set) var email: String = ""
        private(set) var password: String = ""
        private(set) var isLoginScreen: Bool = false
        private(set) var isProcess: Bool = false
        private(set) var isErrorPressed: Bool = false
        
        @MainActor
        mutating func copy(
            name: String? = nil,
            email: String? = nil,
            password: String? = nil,
            isLoginScreen: Bool? = nil,
            isProcess: Bool? = nil,
            isErrorPressed: Bool? = nil
        ) -> Self {
            self.name = name ?? self.name
            self.email = email ?? self.email
            self.password = password ?? self.password
            self.isLoginScreen = isLoginScreen ?? self.isLoginScreen
            self.isProcess = isProcess ?? self.isProcess
            self.isErrorPressed =  isErrorPressed ?? self.isErrorPressed
            return self
        }
    }
}
