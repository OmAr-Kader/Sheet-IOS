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
    private var preferences: [Preference] = []
    private var prefsTask: Task<Void, Error>? = nil
    private var sinkPrefs: AnyCancellable? = nil

    init() {
        prefsTask?.cancel()
        sinkPrefs?.cancel()
        prefsTask = scope.launchBack {
            self.sinkPrefs = await self.project.preference.prefsBack { list in
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
    func backPress() {
        if !self.navigationPath.isEmpty {
            self.navigationPath.removeLast()
        }
    }
    
    private func inti(invoke: @BackgroundActor @escaping ([Preference]) -> Unit) {
        scope.launchBack {
            await self.project.preference.prefs { list in
                invoke(list)
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
    
    
    @MainActor
        func signOut(_ invoke: @escaping @MainActor () -> Unit,_ failed: @escaping @MainActor () -> Unit) {
            scope.launchBack {
                guard let result = try? await self.project.preference.deletePrefAll() else {
                    self.scope.launchMain {
                        failed()
                    }
                    return
                }
                if result == REALM_SUCCESS {
                    self.scope.launchMain {
                        invoke()
                    }
                } else {
                    self.scope.launchMain {
                        failed()
                    }
                }
            }
        }
    
    @MainActor
    func findUserBase(
        invoke: @escaping @MainActor (UserBase?) -> Unit
    ) {
        guard self.project.realmApi.realmApp.currentUser != nil else {
            invoke(nil)
            return
        }
        if (self.preferences.isEmpty) {
            self.inti { it in
                self.scope.launchBack {
                    let userBase = await self.fetchUserBase(it)
                    try? await Task.sleep(nanoseconds: 350000000) // 0.35 Seconds
                    self.scope.launchMain {
                        self.preferences = it
                        invoke(userBase)
                    }
                }
            }
        } else {
            self.scope.launchBack {
                let userBase = await self.fetchUserBase(self.preferences)
                try? await Task.sleep(nanoseconds: 350000000) // 0.35 Seconds
                self.scope.launchMain {
                    invoke(userBase)
                }
            }
        }
    }

    @BackgroundActor
    private func fetchUserBase(_ list: [Preference]) async -> UserBase? {
        let id = list.last { it in it.ketString == PREF_USER_ID }?.value
        let name = list.last { it in it.ketString == PREF_USER_NAME }?.value
        let email = list.last { it in it.ketString == PREF_USER_EMAIL }?.value
        let userType = list.last { it in it.ketString == PREF_USER_TYPE }?.value
        if (id == nil || name == nil || email == nil || userType == nil) {
            return nil
        }
        return UserBase(id: id!, name: name!, email: email!, accountType: Int(userType!)!)
    }

    func updateUserBase(userBase: UserBase, invoke: @escaping @MainActor () -> Unit) {
        scope.launchBack {
            var list : [Preference] = []
            list.append(Preference(ketString: PREF_USER_ID, value: userBase.id))
            list.append(Preference(ketString: PREF_USER_NAME, value: userBase.name))
            list.append(Preference(ketString: PREF_USER_EMAIL, value: userBase.email))
            list.append(Preference(ketString: PREF_USER_TYPE, value: String(userBase.accountType)))
            await self.project.preference.insertPref(list) { newPref in
                self.inti { it in
                    self.scope.launchMain {
                        self.preferences = it
                        invoke()
                    }
                }
            }
        }
    }

    func findPrefString(
        key: String,
        value: @escaping (String?) -> Unit
    ) {
        if (preferences.isEmpty) {
            inti { it in
                let preference = it.first { it1 in it1.ketString == key }?.value
                self.scope.launchMain {
                    self.preferences = it
                    value(preference)
                }
            }
        } else {
            scope.launchBack {
                let preference = self.preferences.first { it1 in it1.ketString == key }?.value
                self.scope.launchMain {
                    value(preference)
                }
            }
        }
    }
    
    @BackgroundActor
    private func updatePref(
        _ key: String,
        _ newValue: String,
        _ invoke: @escaping () async -> Unit
    ) async {
        await self.project.preference.insertPref(
            Preference(
                ketString: key,
                value: newValue
            )) { _ in
                await invoke()
            }
    }
    
    func updatePref(key: String, newValue: String, _ invoke: @escaping () -> ()) {
        scope.launchBack {
            await self.updatePref(key, newValue) {
                invoke()
            }
        }
    }
    

    struct State {
        var homeScreen: Screen = .SPLASH_SCREEN_ROUTE
        var userBase: UserBase? = nil
        var args = [Screen : any ScreenConfig]()

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
    
    struct UserBase {
        let id: String
        let name: String
        let email: String
        let accountType: Int
    }
    
    
    deinit {
        prefsTask?.cancel()
        sinkPrefs?.cancel()
        sinkPrefs = nil
        prefsTask = nil
        scope.deInit()
    }
    
}
