//
//  SheetScreen.swift
//  sheet
//
//  Created by OmAr on 06/09/2024.
//

import SwiftUI

struct SheetScreen : View {
    
    var screenConfig: @MainActor (Screen) -> (any ScreenConfig)?
    
    @StateObject private var obs: SheetObserve = SheetObserve()

    @Inject
    private var theme: Theme

    var body: some View {
        let state = obs.state
        ZStack(alignment: .topLeading) {
            ScrollView([.horizontal, .vertical]) {
                LazyVStack {
                    ForEach(Array(state.sheet.rows.enumerated()), id: \.element.id) { indexC, row in
                        LazyHStack {
                            ForEach(Array(row.values.enumerated()), id: \.element) { indexR, value in
                                Text(value)
                                    .frame(width: 100, height: 50)
                                    .background(Color.blue.opacity(0.1))
                                    .border(Color.gray)
                            }
                        }
                    }
                }
            }
        }.onAppear {
            guard let args = screenConfig(Screen.SHEET_SCREEN_ROUTE) as? SheetConfig else {
                return
            }
            obs.loadData(args.sheetFile)
        }
    }
}
