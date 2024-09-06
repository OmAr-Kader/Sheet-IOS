//
//  Sheet.swift
//  sheet
//
//  Created by OmAr on 06/09/2024.
//

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
    let rows: [SheetItem]
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
}

struct SheetItem {
    let isChanged: Bool
    let values: [String]
    let rowNumber: Int
    
    var id: String {
        String(rowNumber) + String(isChanged) + String(values.count)
    }
}
