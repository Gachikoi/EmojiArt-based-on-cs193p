//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/3/20.
//

import SwiftUI

struct PaletteChooser:View {
    @EnvironmentObject var store:PaletteStore

    @State private var showEdit=false
    @State private var showList=false
    
    private let paletteNameSize:CGFloat=30

    var body: some View {
        HStack{
            chooser
            HStack{
                Text(store.palettes[store.paletteIndex].name).lineLimit(1)
                    .font(.system(size: paletteNameSize))
                ScrollingEmojis
            }
            .id(store.palettes[store.paletteIndex].id)
            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
        }
        .padding(.horizontal)
        .clipped()
        .sheet(isPresented: $showEdit){
            PaletteEditor(palette:$store.palettes[store.paletteIndex])
                .font(nil)
                .onDisappear{
                    if store.palettes[store.paletteIndex].name.isEmpty && store.palettes[store.paletteIndex].emojis.isEmpty{
                        store.palettes.remove(at: store.paletteIndex)
                    }
                }
        }
    }
    
    var chooser:some View{
        AnimatedActionButton(systemImage: "paintpalette"){
            store.paletteIndex+=1
        }
        .contextMenu{
            gotoButton
            AnimatedActionButton(title:"New",systemImage:"plus"){
                store.insert(name: "", emojis: "")
                showEdit=true
            }
            AnimatedActionButton(title: "Edit", systemImage: "pencil"){
                showEdit=true
            }
            AnimatedActionButton(title: "List", systemImage: "list.bullet.rectangle.portrait"){
                showList=true
            }
            AnimatedActionButton(title:"Delete",systemImage: "minus.circle",role: .destructive){
                store.palettes.remove(at: store.paletteIndex)
            }
        }
    }
    
    var gotoButton : some View {
        Menu{
            ForEach(store.palettes){ palette in
                AnimatedActionButton(title: palette.name){
                    if let index=store.palettes.firstIndex(where: {$0.id==palette.id}){
                        store.paletteIndex=index
                    }
                }
            }
        }label:{
            Label("Go To", systemImage: "text.insert")
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

#Preview(traits: .landscapeLeft) {
    PaletteChooser()
        .environmentObject(PaletteStore(name: "preview"))
        .font(.system(size: 40))
}
