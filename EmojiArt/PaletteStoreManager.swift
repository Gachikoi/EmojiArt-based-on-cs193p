//
//  PaletteStoreManagerView.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/4/10.
//

import SwiftUI

struct PaletteStoreManager: View {
    @ObservedObject var paletteStoreStore:PaletteStoreStore
    
    @State private var selectedStore:PaletteStore?
    @State private var splitViewVisibility=NavigationSplitViewVisibility.all
    @State private var preferredCompactColumn=NavigationSplitViewColumn.sidebar
    @State private var showEditor=false
    
    var body: some View {
        NavigationSplitView(columnVisibility:$splitViewVisibility,preferredCompactColumn: $preferredCompactColumn){
            ZStack(alignment:.bottom){
                List(paletteStoreStore.stores,selection: $selectedStore){ store in
    //              Text(store.name) // bad!!
                    // this is "bad" because store is not an @ObservedObject in this View
                    // instead, pass the store onto another View's @ObservedObject (as below)
                    // this is not ACTUALLY a problem for PaletteStore's name var
                    // because it's not @Published anyway (and furthermore is a let constant)
                    // but be careful of this case where an ObservableObject
                    // is passed to a View not via @ObservableObject or @EnvironmentObject
                    // (it's passed to PaletteManager via an [PaletteStore])
                    PaletteStoreNameView(store: store,currentPaletteStoreID: paletteStoreStore.currentPaletteStore.id)
                        .tag(store)
                        .contextMenu{
                            Button{
                                paletteStoreStore.setCurrentPaletteStore(to: store)
                            }label: {
                                Text("Use this PaletteStore")
                            }
                        }
                }
                .navigationTitle("Manager")
                Text("Long Press To Set Current PaletteStore")
                    .foregroundStyle(.gray)
            }
        }content: {
            if let store=selectedStore {
                PaletteList()
                    .environmentObject(store)
            }else{
                Text("choose a store")
            }
        }detail: {
            Text("choose a palette")
        }
    }
    
    struct PaletteStoreNameView:View {
        @ObservedObject var store:PaletteStore
        let currentPaletteStoreID:String
        
        var body: some View {
            HStack{
                Text(store.name)
                Spacer()
                if currentPaletteStoreID == store.id {
                    Circle().fill(.orange).frame(maxWidth: 10,maxHeight: 10)
                }
            }
        }
    }
}
