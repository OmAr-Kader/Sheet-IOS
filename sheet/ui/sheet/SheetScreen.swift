//
//  SheetScreen.swift
//  sheet
//
//  Created by OmAr on 06/09/2024.
//

import SwiftUI

struct SheetScreen : View {
    
    var screenConfig: @MainActor (Screen) -> (any ScreenConfig)?
    
    var backPress: @MainActor () -> Unit
    
    @StateObject private var obs: SheetObserve = SheetObserve()
    
    @State private var title: String = ""

    @State private var toast: Toast? = nil

    @Inject
    private var theme: Theme

    var body: some View {
        let state = obs.state
        ZStack {
            VStack {
                ScrollView([.horizontal, .vertical]) {
                    LazyVStack {
                        ForEach(Array(state.sheet.rows.enumerated()), id: \.element) { indexRow, row in
                            LazyHStack {
                                ForEach(Array(row.values.enumerated()), id: \.element.idTextField) { indexCol, value in
                                    let value = value as SheetItemValue
                                    SheetListItem(value: value, theme: theme) { str in
                                        obs.onChange(indexRow: indexRow, indexCol: indexCol, text: str)
                                    }.id(value.idTextField)
                                }
                            }
                        }
                    }
                }
            }
            LoadingScreen(isLoading: state.isProcess)
        }.toastView(toast: $toast).onAppear {
            guard let args = screenConfig(Screen.SHEET_SCREEN_ROUTE) as? SheetConfig else {
                return
            }
            title = args.sheetFile.name
            obs.loadData(args.sheetFile)
        }.toolbar {
            ToolbarItem(placement: .principal) { // <3>
                VStack {
                    Text(title).font(.headline)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    obs.onSave {
                        
                    } failed: {
                        
                    }
                }.disabled(!state.isChanged)
            }
        }
    }
}

struct SheetListItem : View {
    
    @ObservedObject var value: SheetItemValue
    let theme: Theme

    let onChange: (String) -> Unit
    
    var body: some View {
        VStack {
            TextField(
                "",
                text: Binding(get: {
                    value.value
                }, set: { it, t in
                    if it != value.value {
                        onChange(it)
                    }
                }),
                axis: Axis.horizontal
            ).foregroundStyle(theme.textColor)
                .font(.system(size: 17))
                .padding(all: 0)
                .frame(width: value.itemWidth, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(1)
                .preferredColorScheme(theme.isDarkMode ? .dark : .light)
                .autocapitalization(.none)
                .background(Color.clear)
            if value.isChanged {
                Divider().padding(start: 5, end: 5)
                Text(value.valueNative)
                    .foregroundStyle(theme.textHintColor)
                    .lineLimit(1)
                    .font(.system(size: 17))
                    .frame(width: value.itemWidth, alignment: .leading)
                    .truncationMode(.tail)
            }
        }.padding(all: 5)
            .background(Color.blue.opacity(0.1))
            .border(Color.gray)
    }
}
