//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/3/20.
//

import SwiftUI

struct PaletteChooser:View {
    @EnvironmentObject var store:PaletteStore

    @State private var showEditor=false
    @State private var showList=false
    @State private var showAlert=false
    
    @ScaledMetric private var paletteNameSize:CGFloat=30

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
        .sheet(isPresented: $showEditor){
            PaletteEditor(palette:$store.palettes[store.paletteIndex],showEditor: $showEditor)
                .font(nil)
        }
        .sheet(isPresented: $showList){
            NavigationStack{
                PaletteList(showList: $showList)
                    .font(nil)
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
    
    var chooser:some View{
        AnimatedActionButton(systemImage: "paintpalette"){
            store.paletteIndex+=1
        }
        .contextMenu{
            gotoButton
            AnimatedActionButton(title:"New",systemImage:"plus"){
                store.insert(name: "", emojis: "")
                showEditor=true
            }
            AnimatedActionButton(title: "Edit", systemImage: "pencil"){
                showEditor=true
            }
            AnimatedActionButton(title: "List", systemImage: "list.bullet.rectangle.portrait"){
                showList=true
            }
            AnimatedActionButton(title:"Delete",systemImage: "minus.circle",role: .destructive){
                if store.palettes.count>1{
                    store.palettes.remove(at: store.paletteIndex)
                }else{
                    showAlert=true
                }
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
        .menuActionDismissBehavior(.disabled)
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
