//
//  HomeScreen.swift
//  sheet
//
//  Created by OmAr on 06/09/2024.
//

import SwiftUI

struct HomeScreen : View {
    
    var navigateToScreen: @MainActor (ScreenConfig, Screen) -> Unit
    
    @StateObject private var obs: HomeObserve = HomeObserve()

    @Inject
    private var theme: Theme
    
    @State private var toast: Toast? = nil

    @State private var isSheetPresented: Bool = false

    var body: some View {
        let state = obs.state
        ZStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(state.sheets.enumerated()), id: \.offset) { index, data in
                        VStack {
                            Text("\(data.name)").foregroundStyle(theme.textColor).multilineTextAlignment(.leading).lineLimit(nil).onStart()
                            Divider().foregroundStyle(theme.textHintAlpha).padding(start: 20, end: 20)
                        }.padding(all: 3).onTapGesture {
                            navigateToScreen(SheetConfig(sheetFile: data), Screen.SHEET_SCREEN_ROUTE)
                        }
                    }
                }
            }.onTop().onStart()
            LoadingScreen(isLoading: state.isProcess)
        }.sheet(isPresented: $isSheetPresented) {
            SheetNameInputSheet { name in
                isSheetPresented = false
                obs.addSheetFile(name: name)
            }
        }.background(theme.background).toastView(toast: $toast).onAppear {
            obs.loadData { sheets in
                withAnimation {
                    obs.updateSheets(sheets: sheets)
                }
            }
        }.toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        isSheetPresented = true
                    }) {
                        Label("Create a file", systemImage: "doc").background(theme.backDark).foregroundStyle(theme.textColor)
                    }.background(theme.backDark).foregroundStyle(theme.textColor)
                    Button {
                        obs.signOut {
                            exit(0)
                        } _: {
                            toast = Toast(style: .error, message: "Failed")
                        }
                    } label: {
                        Label("Sign Out", systemImage: "door.right.hand.open").background(theme.backDark).foregroundStyle(theme.textColor)
                    }.background(theme.backDark).foregroundStyle(theme.textColor)
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Sheet").font(.headline).foregroundStyle(theme.textColor)
                }
            }
        }
    }
}



struct SheetNameInputSheet: View {

    @State private var fileName: String = ""

    var onSave: (String) -> Void

    @Inject
    private var theme: Theme

    var body: some View {
        ZStack {
            VStack() {
                Text("Enter Sheet Name")
                    .foregroundStyle(theme.textColor)
                    .font(.headline)
                
                TextField("Sheet Name", text: $fileName)
                    .foregroundStyle(theme.textColor)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    onSave(fileName)
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }.padding()
        }.background(theme.backDark)
            .presentationDetents([.medium, .custom(CommentSheetDetent.self)])
            .presentationDragIndicator(.visible)
            .presentationBackground(theme.backDark)
    }
}

struct CommentSheetDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        if context.dynamicTypeSize.isAccessibilitySize {
            return context.maxDetentValue
        } else {
            return context.maxDetentValue * 0.8
        }
    }
}
