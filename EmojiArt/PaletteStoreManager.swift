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
    @State private var showAlert=false
    
    var body: some View {
        NavigationSplitView(columnVisibility:$splitViewVisibility,preferredCompactColumn: $preferredCompactColumn){   
            List(selection: $selectedStore){
                ForEach($paletteStoreStore.stores){ $store in
                    Group{
                        if !showTextField{
                            PaletteStoreNameView(
                                store: $store,
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
                                store: $store,
                                currentPaletteStoreID: paletteStoreStore.currentPaletteStore.id,
                                showTextField: $showTextField
                            )
                        }
                    }
                }
                .onDelete{ indexSet in
                    if paletteStoreStore.currentPaletteStore != paletteStoreStore.stores[indexSet.first!]{
                        paletteStoreStore.stores.remove(atOffsets:indexSet)
                    }else{
                        showAlert=true
                    }
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
                            paletteStoreStore.stores.append(PaletteStore(name: getCurrentTime()))
                        }label: {
                            Image(systemName: "plus")
                        }
                    }
            }
            .alert(
                "Delete Store",
                isPresented: $showAlert){
                    Button("OK", role: .cancel){}
                }message:{
                    Text("Can't remove this store, it's used now.")
                }
        }content: {
            if let store=selectedStore {
                PaletteList(isFromManager: true)
                    .environmentObject(store)
                    .id(store.id)
            }else{
                Text("choose a store")
            }
        }detail: {
            Text("choose a palette")
        }
    }
    
    func getCurrentTime() -> String {
        let now = Date() // 获取当前时间
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 设置日期格式
        let formattedTime = formatter.string(from: now) // 将时间转换为指定格式的字符串
        return formattedTime
    }
    
    struct PaletteStoreNameView:View{
        @Binding var store:PaletteStore
        let currentPaletteStoreID:UUID
        @Binding var showTextField:Bool
        
        var body: some View {
            HStack{
                if showTextField{
                    TextField("Edit Name Here", text: $store.name).lineLimit(1)
                }else{
                    if !store.name.isEmpty{
                        Text(store.name).lineLimit(1)
                    }else{
                        Text("Empty Name").lineLimit(1).foregroundStyle(.gray).opacity(0.5)
                    }
                    Spacer()
                    if currentPaletteStoreID == store.id {
                        Circle().fill(.orange).frame(maxWidth: 10,maxHeight: 10)
                    }
                }
            }
        }
    }
}
