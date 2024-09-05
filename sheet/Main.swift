import SwiftUI

struct Main: View {
    @StateObject var app: AppObserve
    
    @Inject
    private var theme: Theme
        
    var body: some View {
        //let isSplash = app.state.homeScreen == Screen.SPLASH_SCREEN_ROUTE
        NavigationStack(path: $app.navigationPath) {
            targetScreen(
                app.state.homeScreen, app
            ).navigationDestination(for: Screen.self) { route in
                targetScreen(route, app)//.toolbar(.hidden, for: .navigationBar)
            }
        }/*.prepareStatusBarConfigurator(
            isSplash ? theme.background : theme.primary, isSplash, theme.isDarkStatusBarText
        )*/
    }
}

struct SplashScreen : View {
    
    @Inject
    private var theme: Theme
    
    @StateObject var app: AppObserve
    
    @State private var scale: Double = 1
    @State private var width: CGFloat = 50
    var body: some View {
        FullZStack {
            Image(
                uiImage: UIImage(
                    named: "AppIcon"
                )?.withTintColor(
                    UIColor(theme.textColor)
                ) ?? UIImage()
            ).resizable()
                .scaleEffect(scale)
                .frame(width: width, height: width, alignment: .center)
                .onAppear {
                    withAnimation() {
                        width = 150
                    }
                    //https://github.com/mipar52/google-examples-swift/blob/master/google-examples-swift/Controllers/SpredsheetsController.swift
                    /*GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if let error = error {
                            
                            return
                        }
                        
                        func checkStatus(){
                            if(GIDSignIn.sharedInstance.currentUser != nil){
                                let user = GIDSignIn.sharedInstance.currentUser
                                guard let user = user else { return }
                                let givenName = user.profile?.givenName
                                let profilePicUrl = user.profile!.imageURL(withDimension: 100)!.absoluteString
                                self.givenName = givenName ?? ""
                                self.profilePicUrl = profilePicUrl
                                self.isLoggedIn = true
                            }else{
                                self.isLoggedIn = false
                                self.givenName = "Not Logged In"
                                self.profilePicUrl =  ""
                            }
                        }
                    }
                    
                    app.findUserBase { it in
                        guard let it else {
                            app.navigateHome(.SIGN_ROUTE)
                            return
                        }
                        app.navigateHome(.HOME_ROUTE())
                    }*/
                }
        }.background(theme.background)
    }
}
