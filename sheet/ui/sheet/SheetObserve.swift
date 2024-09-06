//
//  SheetObserve.swift
//  sheet
//
//  Created by OmAr on 06/09/2024.
//

import Foundation

class SheetObserve : ObservableObject {
    
    @Inject
    private var project: Project
    
    private var scope = Scope()
    
    @MainActor
    @Published var state = State()
    
    @MainActor
    func loadData(_ sheet: SheetFile) {
        self.scope.launchBack {
            
        }
    }
    
    struct State {
        
        private(set) var sheet: Sheet = Sheet()
        private(set) var search: String = ""
        private(set) var isProcess: Bool = false
        
        @MainActor
        mutating func copy(
            sheet: Sheet? = nil,
            search: String? = nil,
            isProcess: Bool? = nil
        ) -> Self {
            self.sheet = sheet ?? self.sheet
            self.search = search ?? self.search
            self.isProcess = isProcess ?? self.isProcess
            return self
        }
    }

}

