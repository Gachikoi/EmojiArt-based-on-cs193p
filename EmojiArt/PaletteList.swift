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
    
    //用于在list中新建palette时，临时存储改变前的paletteIndex，方便在此palette为空，自动删除自己后，重置paletteIndex回以前的位置
    @State private var tempPaletteIndex=0
    
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
                store.palettes.remove(atOffsets: indexSet)
            }
            .onMove{ indices, newOffset in
                store.palettes.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .navigationDestination(for:Palette.ID.self){ paletteID in
            if let index=store.palettes.firstIndex(where: {$0.id==paletteID}){
                PaletteEditor(palette: $store.palettes[index])
                    .font(nil)
            }
        }
        .navigationDestination(isPresented: $showEditor){
            PaletteEditor(palette: $store.palettes[store.paletteIndex])
                .font(nil)
        }
        .navigationTitle(store.name+" "+"PaletteStore")
        .toolbar{
            Button{
                store.insert(name: "", emojis: "",at:0)
                tempPaletteIndex=store.paletteIndex
                store.paletteIndex=0
                showEditor=true
            }label: {
                Image(systemName: "plus")
            }
        }
    }
}

#Preview {
    let store=PaletteStore(name: "preview")
    return PaletteList()
        .environmentObject(store)
}
