//
//  PaletteStoreEditor.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/4/10.
//

import SwiftUI

struct PaletteStoreEditor: View {
    @EnvironmentObject var store:PaletteStore
    
    @State private var showEditor=false
    
    var body: some View {
        NavigationStack{
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
                        .onDisappear{
                            if store.palettes[store.paletteIndex].name.isEmpty && store.palettes[store.paletteIndex].emojis.isEmpty{
                                store.palettes.remove(at: store.paletteIndex)
                            }
                        }
                }
            }
            .navigationDestination(isPresented: $showEditor){
                PaletteEditor(palette: $store.palettes[store.paletteIndex])
                    .onDisappear{
                        if store.palettes[store.paletteIndex].name.isEmpty && store.palettes[store.paletteIndex].emojis.isEmpty{
                            store.palettes.remove(at: store.paletteIndex)
                        }
                    }
            }
            .navigationTitle(store.name+" "+"PaletteStore")
            .toolbar{
                TextField(store.name, text: $store.name)
                Button{
                    store.insert(Palette(name: "", emojis: ""))
                    showEditor=true
                }label: {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
}

#Preview {
    @State var paletteStore=PaletteStore()
    return PaletteStoreEditor().environmentObject(paletteStore)
}
