//
//  HomeObserve.swift
//  sheet
//
//  Created by OmAr on 06/09/2024.
//

import Foundation

class HomeObserve : ObservableObject {
    
    @Inject
    private var project: Project
    
    private var scope = Scope()
    
    @MainActor
    @Published var state = State()
    
    @MainActor
    func loadData() {
        self.scope.launchBack {
            self.project.sheet.getAllSheetsFile { sheets in
                self.scope.launchMain {
                    self.state = self.state.copy(sheets: sheets)
                }
            }
        }
    }
    
    struct State {
        
        private(set) var sheets: [SheetFile] = []
        private(set) var search: String = ""
        private(set) var isProcess: Bool = false
        
        @MainActor
        mutating func copy(
            sheets: [SheetFile]? = nil,
            search: String? = nil,
            isProcess: Bool? = nil
        ) -> Self {
            self.sheets = sheets ?? self.sheets
            self.search = search ?? self.search
            self.isProcess = isProcess ?? self.isProcess
            return self
        }
    }

}
