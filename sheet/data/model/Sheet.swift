//
//  Sheet.swift
//  sheet
//
//  Created by OmAr on 06/09/2024.
//
import Foundation

struct SheetFile {
    let id: String
    let createdTime: Int
    let name: String
    let driveId: String
    let webContentLink: String
    let thumbnailLink: String
    
    init() {
        id = ""
        createdTime = 0
        name = ""
        driveId = ""
        webContentLink = ""
        thumbnailLink = ""
    }
    
    init(id: String, createdTime: Int, name: String, driveId: String, webContentLink: String, thumbnailLink: String) {
        self.id = id
        self.createdTime = createdTime
        self.name = name
        self.driveId = driveId
        self.webContentLink = webContentLink
        self.thumbnailLink = thumbnailLink
    }
}

struct Sheet {
    
    let file: SheetFile
    var rows: [SheetItem]
    let range: String?
    
    init() {
        file = SheetFile()
        self.rows = []
        self.range = ""
    }

    init(file: SheetFile, rows: [SheetItem], range: String?) {
        self.file = file
        self.rows = rows
        self.range = range
    }
    
    func copy(rows: [SheetItem]) -> Sheet {
        return Sheet(file: file, rows: rows, range: range)
    }
}

struct SheetItem : Hashable {
    var values: [SheetItemValue]
    let rowNumber: Int
        
    var id: String
    
    @BackgroundActor
    init(values: [SheetItemValue], rowNumber: Int) {
        self.values = values
        self.rowNumber = rowNumber
        self.id = String(rowNumber) + values.map({ it in
            it.valueNative
        }).joined()
    }
    
    mutating func copy(values: [SheetItemValue]) -> Self {
        self.values = values
        self.id = String(rowNumber) + values.map({ it in
            it.valueNative
        }).joined()
        return self
    }
}


class SheetItemValue : ObservableObject, Hashable, Equatable {
    
    @Published var value: String
    var valueNative: String
    let itemWidth: CGFloat
    let rowCol: String
    var isChanged: Bool

    var id: String {
        value + rowCol
    }
    
    var idTextField: String {
        valueNative + rowCol
    }
    
    init(value: String, itemWidth: CGFloat, rowCol: String) {
        self.value = value
        self.valueNative = value
        self.itemWidth = itemWidth
        self.rowCol = rowCol
        self.isChanged = false
        //print("-----> " + id)
    }
    
    @MainActor
    func copy(value: String) -> Self {
        self.value = value
        self.isChanged = true
        return self
    }

    @BackgroundActor
    func afterSave() -> Self {
        self.valueNative = value
        self.isChanged = false
        return self
    }
    
    static func == (lhs: SheetItemValue, rhs: SheetItemValue) -> Bool {
          return lhs.valueNative == rhs.valueNative
      }
      
      func hash(into hasher: inout Hasher) {
          hasher.combine(valueNative)
      }
}
