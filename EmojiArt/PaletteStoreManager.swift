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
    @State private var showTextField=false
    
    var body: some View {
        NavigationSplitView(columnVisibility:$splitViewVisibility,preferredCompactColumn: $preferredCompactColumn){   
            List(selection: $selectedStore){
                ForEach(paletteStoreStore.stores){ store in
                    Group{
                        if !showTextField{
                            PaletteStoreNameView(
                                store: store,
                                currentPaletteStoreID: paletteStoreStore.currentPaletteStore.id,
                                showTextField: $showTextField
                            )
                            .tag(store)
                            .contextMenu{
                                Button{
                                    paletteStoreStore.currentPaletteStore=store
                                }label: {
                                    Text("Use this PaletteStore")
                                }
                            }
                        }else{
                            PaletteStoreNameView(
                                store: store,
                                currentPaletteStoreID: paletteStoreStore.currentPaletteStore.id,
                                showTextField: $showTextField
                            )
                        }
                    }
                }
                .onDelete{ indexSet in
                    paletteStoreStore.stores.remove(atOffsets:indexSet)
                }
                .onMove{ indices, newOffset in
                    paletteStoreStore.stores.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            .navigationTitle("Manager")
            .toolbar{
                    HStack{
                        if !showTextField{
                            Button{
                                showTextField=true
                            }label: {
                                Text("Rename")
                            }
                        }else{
                            Button{
                                showTextField=false
                            }label: {
                                Text("Done Rename")
                            }
                        }
                        Button{
                            paletteStoreStore.stores.append(PaletteStore(name: "New"))
                        }label: {
                            Image(systemName: "plus")
                        }
                    }
            }
        }content: {
            if let store=selectedStore {
                PaletteList(isFromManager: true)
                    .environmentObject(store)
            }else{
                Text("choose a store")
            }
        }detail: {
            Text("choose a palette")
        }
    }
    
    @State private var paletteListID=0
    
    struct PaletteStoreNameView:View{
        @ObservedObject var store:PaletteStore
        let currentPaletteStoreID:UUID
        @Binding var showTextField:Bool
        
        var body: some View {
            HStack{
                if showTextField{
                    TextField(store.name, text: $store.name).lineLimit(1)
                }else{
                    Text(store.name).lineLimit(1)
                    Spacer()
                    if currentPaletteStoreID == store.id {
                        Circle().fill(.orange).frame(maxWidth: 10,maxHeight: 10)
                    }
                }
            }
        }
    }
}
