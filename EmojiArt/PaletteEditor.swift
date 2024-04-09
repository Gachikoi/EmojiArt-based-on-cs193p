//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/4/9.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette:Palette
    
    @State private var emojisToAdd=""
    

    private let emojiFont=Font.system(size: 40)
    private let sectionTextFont=Font.system(size: 35)
    private let sectionHeaderFont=Font.system(size: 20)
    
    @State private var showSection=false
    @State private var showAlertOfInputNonEmojiElement=false
    
    
    enum Focused{
        case name
        case add
    }
    
    @FocusState private var focused:Focused?
    
    var body: some View {
        Form{
            Section{
                TextField(palette.name,text: $palette.name)
                    .font(sectionTextFont)
                    .focused($focused,equals: Focused.name)
            }header:{
                headerOfSectionOfNameView
            }
            Section{
                TextField("Add Emojis Here", text: $emojisToAdd)
                    .font(sectionTextFont)
                    .focused($focused,equals: Focused.add)
                emojiDisplay
            }header: {
                headerOfSectionOfEmojisView
            }
            .onChange(of:emojisToAdd){
                let filteredEmojisToAdd=emojisToAdd.filter({$0.isEmoji})
                guard filteredEmojisToAdd == emojisToAdd else{
                    showAlertOfInputNonEmojiElement=true
                    emojisToAdd=filteredEmojisToAdd
                    return
                }
            }
            .onSubmit {
                palette.emojis=(emojisToAdd+palette.emojis).uniqued
                emojisToAdd=""
            }
            .alert("Cation!", isPresented: $showAlertOfInputNonEmojiElement){
                Text("Please only add emojis here")
            }
        }
        .onAppear{
            if palette.name.isEmpty{
                focused = .name
            }else {
                focused = .add
            }
        }
        .onDisappear{
            if palette.name.isEmpty && !palette.emojis.isEmpty{
                palette.name="Default"+" "+getCurrentTime()
            }
        }
    }
    
    func getCurrentTime() -> String {
        let now = Date() // 获取当前时间
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 设置日期格式
        let formattedTime = formatter.string(from: now) // 将时间转换为指定格式的字符串
        return formattedTime
    }
    
    var headerOfSectionOfNameView : some View {
        Text("name")
            .font(sectionHeaderFont)
    }
    
    var headerOfSectionOfEmojisView : some View {
        Text("emojis")
            .font(sectionHeaderFont)
    }
    
    var emojiDisplay:some View{
        VStack(alignment:.trailing){
            Text("Tap To Remove Emoji")
                .foregroundStyle(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]){
                ForEach(palette.emojis.uniqued.map(String.init),id:\.self){emoji in
                    Text(emoji)
                        .font(emojiFont)
                        .onTapGesture {
                            withAnimation{
                                palette.emojis.remove(emoji.first!)
                                emojisToAdd.remove(emoji.first!)
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    struct Preview:View {
        @State private var palette=PaletteStore(name: "paletteeditor").palettes.first!
        var body:some View{
            PaletteEditor(palette: $palette)
        }
    }
    
    return Preview()
}
