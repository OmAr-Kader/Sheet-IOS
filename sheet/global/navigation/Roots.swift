import SwiftUI

extension View {
    
    @ViewBuilder func targetScreen(
        _ target: Screen,
        _ app: AppObserve,
        navigateTo: @MainActor @escaping (Screen) -> Unit,
        navigateToScreen: @MainActor @escaping (ScreenConfig, Screen) -> Unit,
        navigateHome: @MainActor @escaping (Screen) -> Unit,
        backPress: @MainActor @escaping () -> Unit,
        screenConfig: @MainActor @escaping (Screen) -> (any ScreenConfig)?
    ) -> some View {
        switch target {
        case .AUTH_SCREEN_ROUTE:
            AuthScreen(app: app)
        case .HOME_SCREEN_ROUTE:
            HomeScreen()
        case .SHEET_SCREEN_ROUTE:
            SheetScreen(screenConfig: screenConfig)
        }
    }
}

enum Screen : Hashable {
    
    case AUTH_SCREEN_ROUTE
    case HOME_SCREEN_ROUTE
    case SHEET_SCREEN_ROUTE
}


protocol ScreenConfig {}

struct SheetConfig: ScreenConfig {
    let sheetFile: SheetFile
}
