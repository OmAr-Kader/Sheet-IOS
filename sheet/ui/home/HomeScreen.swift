//
//  HomeScreen.swift
//  sheet
//
//  Created by OmAr on 06/09/2024.
//

import SwiftUI

struct HomeScreen : View {
    
    @StateObject private var obs: HomeObserve = HomeObserve()

    @Inject
    private var theme: Theme
    

    var body: some View {
        let state = obs.state
        ZStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(state.sheets.enumerated()), id: \.offset) { index, data in
                        Text("\(data.name)").foregroundStyle(theme.textColor)
                        Divider().foregroundStyle(theme.textHintAlpha).padding(start: 20, end: 20)
                    }
                }
            }
        }.onAppear {
            obs.loadData()
        }
    }
}