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
                    self.state = self.state.copy(sheets: sheets, isProcess: false)
                }
            }
        }
    }
    
    @MainActor
    func addSheetFile(name: String) {
        setMainProcess(true)
        self.scope.launchBack {
            self.project.sheet.createSheetsFile(name: name) { sheet in
                self.scope.launchMain {
                    let sheets = [sheet] + self.state.sheets
                    self.state = self.state.copy(sheets: sheets, isProcess: false)
                }
            } failed: {
                self.setProcess(false)
            }
        }
    }
    
    
    @MainActor
    func signOut(_ invoke: @escaping @MainActor () -> Unit,_ failed: @escaping @MainActor () -> Unit) {
        scope.launchBack {
            let result = await self.project.pref.deletePrefAll()
            if result == REALM_SUCCESS {
                await signOutGoogle()
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
    
    private func setProcess(_ isProcess: Bool) {
        scope.launchMain {
            self.state = self.state.copy(isProcess: isProcess)
        }
    }
    
    @MainActor private func setMainProcess(_ isProcess: Bool) {
        self.state = self.state.copy(isProcess: isProcess)
    }
    
    struct State {
        
        private(set) var sheets: [SheetFile] = []
        private(set) var search: String = ""
        private(set) var isProcess: Bool = true
        
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
