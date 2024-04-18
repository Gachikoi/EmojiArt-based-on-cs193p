//
//  PaletteList.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/4/10.
//

import SwiftUI

struct PaletteList: View {
    @EnvironmentObject var store:PaletteStore
    
    @State private var showEditor=false
    @State private var showAlert=false
    @Binding var showList:Bool
    var isFromManager:Bool
    
    init(showList: Binding<Bool> = .constant(true),isFromManager:Bool = false) {
        _showList=showList
        self.isFromManager=isFromManager
    }
    
    var body: some View {
        List{
            ForEach(store.palettes){ palette in
                NavigationLink(value:palette.id){
                    VStack(alignment:.leading){
                        Text(palette.name)
                        Text(palette.emojis).lineLimit(1)
                    }
                }
            }
            .onDelete{ indexSet in
                if indexSet.count != store.palettes.count{
                    store.palettes.remove(atOffsets: indexSet)
                    if indexSet.first! < store.paletteIndex {
                        store.paletteIndex-=1
                    }
                }else{
                    showAlert=true
                }
            }
            .onMove{ indices, newOffset in
                store.palettes.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .navigationDestination(isPresented: $showEditor){
            PaletteStoreEditor(store: store,isFromList: true)
                .id(store.palettes[store.paletteIndex].id)
                .font(nil)
                .onDisappear{
                    if store.palettes[store.paletteIndex].name.isEmpty && store.palettes[store.paletteIndex].emojis.isEmpty{
                        store.palettes[store.paletteIndex].name=getCurrentTime()
                        print(true)
                    }
                }
        }
        .navigationDestination(for:Palette.ID.self){ paletteID in
            if let index=store.palettes.firstIndex(where: {$0.id==paletteID}){
                PaletteEditor(palette: $store.palettes[index],isFromList:true)
                    .id(paletteID)
                    .font(nil)
            }
        }
        .navigationTitle(store.name+" "+"PaletteStore")
        .toolbar{
            if !isFromManager&&UIDevice.current.userInterfaceIdiom == .phone{
                ToolbarItem(placement: .topBarLeading){
                    Button(role:.cancel){
                        showList=false
                    }label:{
                        Text("Cancel")
                    }
                }
            }
            ToolbarItem(placement:.topBarTrailing){
                Button{
                    store.insert(name: "", emojis: "",at:0)
                    store.paletteIndex=0
                    showEditor=true
                }label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert(
            "Delete Palette",
            isPresented: $showAlert){
                Button("OK", role: .cancel){}
            }message:{
                Text("We need at least one Palette Remained")
            }
    }
    
    func getCurrentTime() -> String {
        let now = Date() // 获取当前时间
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 设置日期格式
        let formattedTime = formatter.string(from: now) // 将时间转换为指定格式的字符串
        return formattedTime
    }
}
