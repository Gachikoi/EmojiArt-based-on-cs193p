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
                .font(nil)
        }
        .navigationDestination(for:Palette.ID.self){ paletteID in
            if let index=store.palettes.firstIndex(where: {$0.id==paletteID}){
                PaletteEditor(palette: $store.palettes[index],isFromList:true)
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
}
