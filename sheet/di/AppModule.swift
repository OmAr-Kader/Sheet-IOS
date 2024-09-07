import Foundation
import RealmSwift
import SwiftUI
import Swinject

struct Project : ScopeFunc {
    let realmApi: RealmApi
    let pref: PreferenceBase
    let sheet: SpredsheetsBase
}

func buildContainer() -> Container {
    let container = Container()
    
    let realmApi = RealmApi()
    let pro = Project(
        realmApi: realmApi,
        pref: PreferenceBase(repository: PrefRepoImp(realmApi: realmApi)),
        sheet: SpredsheetsBase()
    )
    let theme = Theme(isDarkMode: UITraitCollection.current.userInterfaceStyle.isDarkMode)
    container.register(RealmApi.self) { _  in
        return realmApi
    }.inObjectScope(.container)
    container.register(Project.self) { _  in
        return pro
    }.inObjectScope(.container)
    container.register(Theme.self) { _  in
        return theme
    }.inObjectScope(.container)
    return container
}


class Resolver {
    static let shared = Resolver()

    private var container = buildContainer()
    
    func resolve<T>(_ type: T.Type) -> T {
        container.resolve(T.self)!
    }
}

@propertyWrapper
struct Inject<I> {
    let wrappedValue: I
    init() {
        self.wrappedValue = Resolver.shared.resolve(I.self)
    }
}




