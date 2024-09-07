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
            self.project.sheet.getSheet(sheet) { sheet in
                self.scope.launchMain {
                    self.state = self.state.copy(sheet: sheet, isProcess: false)
                }
            } failed: {
                self.setProcess(false)
            }
        }
    }
    
    @MainActor
    func onChange(indexRow: Int, indexCol: Int, text: String) {
        let sheet = self.state.sheet
        var rows = sheet.rows
        var row = sheet.rows[indexRow]
        var values = row.values
        
        let editValue = values[indexCol].copy(value: text)
        values[indexCol] = editValue
        let editRow = row.copy(values: values)
        rows[indexRow] = editRow
        let newSheet = sheet.copy(rows: rows)
        self.state = self.state.copy(sheet: newSheet, isChanged: true)
    }
    
    @MainActor
    func onSave(invoke: @MainActor @escaping () -> Unit, failed: @MainActor @escaping () -> Unit) {
        let sheet = self.state.sheet
        self.setMainProcess(true)
        scope.launchBack {
            print("==> 1")
            self.project.sheet.updateSheet(sheet) {
                print("==> 2")
                let newSheet = self.aftetOnChanged(sheet: sheet)
                print("==> 3")
                self.scope.launchMain {
                    print("==> 4")
                    self.state = self.state.copy(sheet: newSheet, isChanged: false, isProcess: false)
                    invoke()
                }
            } failed: {
                self.scope.launchMain {
                    self.setMainProcess(false)
                    failed()
                }
            }

        }
    }
    
    @BackgroundActor
    private func aftetOnChanged(sheet: Sheet) -> Sheet {
        let rows = sheet.rows.map { it in
            var it = it
            return it.copy(values: it.values.map { value in
                value.afterSave()
            })
        }
        return sheet.copy(rows: rows)
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
        
        private(set) var sheet: Sheet = Sheet()
        private(set) var search: String = ""
        private(set) var isChanged: Bool = false
        private(set) var isProcess: Bool = true
                
        @MainActor
        mutating func copy(
            sheet: Sheet? = nil,
            search: String? = nil,
            isChanged: Bool? = nil,
            isProcess: Bool? = nil
        ) -> Self {
            self.sheet = sheet ?? self.sheet
            self.search = search ?? self.search
            self.isChanged = isChanged ?? self.isChanged
            self.isProcess = isProcess ?? self.isProcess
            return self
        }
    }

}

