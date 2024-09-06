import Foundation
import RealmSwift

class RealmApi : ScopeFunc {
    
    let realmApp: App
    private var realmLocal: Realm? = nil
    
    init(realmApp: App) {
        self.realmApp = realmApp
    }
    
    @BackgroundActor
    func local() async -> Realm? {
        guard let realmLocal else {
            do {
                var config = Realm.Configuration.defaultConfiguration
                config.objectTypes = listOfOnlyLocalSchemaRealmClass
                config.schemaVersion = 1
                config.deleteRealmIfMigrationNeeded = false
                config.shouldCompactOnLaunch = { _,_ in
                    true
                }
                let realm = try await Realm(
                    configuration: config,
                    actor: BackgroundActor.shared
                )
                realmLocal = realm
                return realm
            } catch {
                return nil
            }
        }
        return realmLocal
    }
    
}
