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
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(Array(state.sheet.rows.enumerated()), id: \.element) { indexRow, row in
                            LazyHStack(spacing: 10) {
                                ForEach(Array(row.values.enumerated()), id: \.element.idTextField) { indexCol, value in
                                    let value = value as SheetItemValue
                                    SheetListItem(value: value, theme: theme) { str in
                                        obs.onChange(indexRow: indexRow, indexCol: indexCol, text: str)
                                    }
                                }
                                if indexRow == 0 {
                                    AddSheetItemButton(title: "Add Column") {
                                        obs.addColumn { it in
                                            withAnimation { obs.updateSheet(newSheet: it) }
                                        }
                                    }
                                }
                            }
                        }
                        AddSheetItemButton(title: "Add Row") {
                            obs.addRow { it in
                                withAnimation { obs.updateSheet(newSheet: it) }
                            }
                        }
                    }
                }
            }
            LoadingScreen(isLoading: state.isProcess)
        }.background(theme.background).toastView(toast: $toast).onAppear {
            guard let args = screenConfig(Screen.SHEET_SCREEN_ROUTE) as? SheetConfig else {
                return
            }
            title = args.sheetFile.name
            obs.loadData(args.sheetFile)
        }.toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(title).font(.headline).foregroundStyle(theme.textColor)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    obs.onSave {
                        
                    } failed: { it in
                        toast = Toast(style: .error, message: it)
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
                .frame(minHeight: 25)
                .frame(width: value.itemWidth == 0 ? 150 : value.itemWidth, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(1)
                .preferredColorScheme(theme.isDarkMode ? .dark : .light)
                .autocapitalization(.none)
                .background(Color.clear)
            if value.isChanged { // The height of the whole Row doesn't change if not the first item is "isChanged", to handel that you cane create a mode for the whole row, if any item's height changed, the inside Height changed included the blue background, and the whole row's high only change from outside
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



struct AddSheetItemButton : View {
 
    let title: String
    let action: () -> Unit
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "plus")  // "Add" icon
                .font(.system(size: 18, weight: .bold))
            Text(title)
                .fontWeight(.bold)
                .font(.system(size: 18))
        }.padding(top: 5, start: 15, bottom: 5, end: 15)
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(10).onTapGesture(perform: action)
    }
}

