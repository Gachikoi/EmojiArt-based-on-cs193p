//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/3/20.
//

import SwiftUI

struct PaletteChooser:View {
    @EnvironmentObject var store:PaletteStore

    var body: some View {
        HStack{
            chooser
            HStack{
                Text(store.palettes[store.paletteIndex].name)
                ScrollingEmojis
            }
            .id(store.palettes[store.paletteIndex].id)
            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
        }
        .padding(.horizontal)
        .clipped()
    }
    
    var chooser:some View{
        AnimatedActionButton(systemImage: "paintpalette"){
            store.paletteIndex+=1
        }
        .contextMenu{
            AnimatedActionButton(title:"New",systemImage:"plus"){
                store.insert(name: "Another", emojis: "⎍")
            }
            AnimatedActionButton(title:"Delete",systemImage: "minus.circle",role: .destructive){
                store.palettes.remove(at: store.paletteIndex)
            }
        }
    }
    
    var ScrollingEmojis:some View{
        ScrollView(.horizontal){
            HStack{
                ForEach(store.palettes[store.paletteIndex].emojis.uniqued.map(String.init),id:\.self){ emoji in
                    Text(emoji)
                        .draggable(emoji)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    PaletteChooser()
        .environmentObject(PaletteStore(name: "preview"))
}
