import Foundation
import SwiftUI
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    private(set) var appSet: AppObserve! = nil
    
    var app: AppObserve {
        guard let appSet else {
            let app = AppObserve()
            self.appSet = app
            return app
        }
        return appSet
    }
    
    func application(
        _ app: UIApplication,
        open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        var handled: Bool
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: CLIENT_ID)
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        // Handle other custom URL types.
        
        // If not handled by this app, return false.
        return false
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        appSet = nil
    }
    
}
