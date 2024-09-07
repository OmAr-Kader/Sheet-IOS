import Foundation
import SwiftUI
import Combine

class AppObserve : ObservableObject {

    @Inject
    private var project: Project
        
    private var scope = Scope()

    @Published var navigationPath = NavigationPath()
    
    @Published var state = State()
            
    private var preff: Preference? = nil
    private var preferences: [PreferenceData] = []
    private var prefsTask: Task<Void, Error>? = nil
    private var sinkPrefs: AnyCancellable? = nil

    init() {
        prefsTask?.cancel()
        sinkPrefs?.cancel()
        prefsTask = scope.launchBack {
            self.sinkPrefs = await self.project.pref.prefsRealTime { list in
                self.preferences = list
            }
        }
    }
    
    @MainActor
    var navigateHome: (Screen) -> Unit {
        return { screen in
            withAnimation {
                self.state = self.state.copy(homeScreen: screen)
            }
            return ()
        }
    }
    
    @MainActor
    func navigateTo(_ screen: Screen) {
        self.navigationPath.append(screen)
    }
    
    @MainActor
    func navigateHomeNoAnimation(_ screen: Screen) -> Unit {
        self.state = self.state.copy(homeScreen: screen)
    }
        
    @MainActor
    func backPress() {
        if !self.navigationPath.isEmpty {
            self.navigationPath.removeLast()
        }
    }
    
    private func inti(invoke: @BackgroundActor @escaping ([PreferenceData]) -> Unit) {
        scope.launchBack {
            await self.project.pref.prefs { list in
                invoke(list)
            }
        }
    }

    
    @MainActor
    func findUserBase(
        invoke: @escaping @MainActor (UserBase?) -> Unit
    ) {
        scope.launchBack {
            restorePreviousSignIn { userBase in
                self.scope.launchMain {
                    if let userBase {
                        self.state = self.state.copy(userBase: userBase)
                    }
                    invoke(userBase)
                }
            }
        }
    }

    @MainActor
    func updateUserBase(userBase: UserBase) {
        self.state = self.state.copy(userBase: userBase)
    }

    func findPrefString(
        key: String,
        value: @escaping (String?) -> Unit
    ) {
        if (preferences.isEmpty) {
            inti { it in
                let preference = it.first { it1 in it1.keyString == key }?.value
                self.scope.launchMain {
                    self.preferences = it
                    value(preference)
                }
            }
        } else {
            scope.launchBack {
                let preference = self.preferences.first { it1 in it1.keyString == key }?.value
                self.scope.launchMain {
                    value(preference)
                }
            }
        }
    }
    
    func updatePref(key: String, newValue: String, _ invoke: @MainActor @escaping () -> ()) {
        scope.launchBack {
            await self.project.pref.updatePref(
                PreferenceData(
                    keyString: key,
                    value: newValue
                ), newValue
            ) { _ in
                self.scope.launchMain {
                    invoke()
                }
            }
        }
    }
    
    
    @MainActor
    func findArg(screen: Screen) -> (any ScreenConfig)? {
        return state.argOf(screen)
    }
    
    @MainActor
    func writeArguments(_ route: Screen,_ screenConfig: ScreenConfig) {
        state = state.copy(route, screenConfig)
    }
    
    private func cancelSession() {
        prefsTask?.cancel()
        prefsTask = nil
    }

    struct State {

        private(set) var homeScreen: Screen = .AUTH_SCREEN_ROUTE
        private(set) var userBase: UserBase? = nil
        private(set) var args = [Screen : any ScreenConfig]()
    
        @MainActor
        mutating func copy(
            homeScreen: Screen? = nil,
            userBase: UserBase? = nil,
            args: [Screen : any ScreenConfig]? = nil
        ) -> Self {
            self.homeScreen = homeScreen ?? self.homeScreen
            self.userBase = userBase ?? self.userBase
            self.args = args ?? self.args
            return self
        }
        
        mutating func argOf(_ screen: Screen) -> (any ScreenConfig)? {
            return args.first { (key: Screen, value: any ScreenConfig) in
                key == screen
            }?.value
        }
        
        mutating func copy<T : ScreenConfig>(_ screen: Screen, _ screenConfig: T) -> Self {
            args[screen] = screenConfig
            return self
        }
    }
    
    deinit {
        prefsTask?.cancel()
        sinkPrefs?.cancel()
        sinkPrefs = nil
        prefsTask = nil
        scope.deInit()
    }
    
}
