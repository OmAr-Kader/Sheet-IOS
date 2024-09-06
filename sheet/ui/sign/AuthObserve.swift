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
    func signIn(invoke: @MainActor @escaping (UserBase) -> Unit, failed: @MainActor @escaping () -> Unit) {
        setMainProcess(true)
        googleSignIn { it in
            self.setMainProcess(false)
            invoke(it)
        } failed: {
            self.setMainProcess(false)
            failed()
        }
    }
    
    private func setProcess(_ isProcess: Bool) {
        scope.launchMain {
            self.state = self.state.copy(isProcess: isProcess)
        }
    }
    
    @MainActor private func setMainProcess(_ isProcess: Bool) {
        self.state = self.state.copy(isProcess: isProcess)
    }
    
    struct State {
        
        private(set) var isProcess: Bool = false
        
        @MainActor
        mutating func copy(
            isProcess: Bool? = nil
        ) -> Self {
            self.isProcess = isProcess ?? self.isProcess
            return self
        }
    }
}
