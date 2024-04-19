//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/4/9.
//

import SwiftUI

struct PaletteStoreEditor: View {
    @Binding var showEditor:Bool
    var isFromList:Bool
    @State var palette:Palette
    
    init(store:PaletteStore, showEditor: Binding<Bool> = .constant(true), isFromList:Bool = false) {
        _showEditor=showEditor
        self.isFromList=isFromList
        self.palette=store.palettes[store.paletteIndex]
    }
    
    @State private var emojisToAdd=""
    

    @ScaledMetric private var emojiSize=40
    @ScaledMetric private var sectionTextSize=35
    @ScaledMetric private var sectionHeaderSize=20
    
    @State private var showSection=false
    @State private var showAlertOfInputNonEmojiElement=false
    
    
    enum Focused{
        case name
        case add
    }
    
    @FocusState private var focused:Focused?
    
    var body: some View {
        ZStack(alignment:.topTrailing){
            Form{
                Section{
                    TextField(palette.name,text: $palette.name)
                        .font(.system(size: sectionTextSize))
                        .focused($focused,equals: Focused.name)
                }header:{
                    headerOfSectionOfNameView
                }
                Section{
                    TextField("Add Emojis Here", text: $emojisToAdd)
                        .font(.system(size: sectionTextSize))
                        .focused($focused,equals: Focused.add)
                    emojiDisplay
                }header: {
                    headerOfSectionOfEmojisView
                }
                .onChange(of:emojisToAdd){
                    palette.emojis=(emojisToAdd.filter({$0.isEmoji})+palette.emojis).uniqued
                }
                .onSubmit {
                    emojisToAdd=""
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
                if palette.name.isEmpty && palette.emojis.isEmpty{
                    palette.name=getCurrentTime()
                }
            }
            if !isFromList{
                Button(role:.cancel){
                    showEditor=false
                }label:{
                    Text("Cancel")
                }
                .padding(.top)
                .padding(.horizontal)
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
            .font(.system(size: sectionHeaderSize))
    }
    
    var headerOfSectionOfEmojisView : some View {
        Text("emojis")
            .font(.system(size: sectionHeaderSize))
    }
    
    var emojiDisplay:some View{
        VStack(alignment:.trailing){
            Text("Tap To Remove Emoji")
                .foregroundStyle(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]){
                ForEach(palette.emojis.uniqued.map(String.init),id:\.self){emoji in
                    Text(emoji)
                        .font(.system(size: emojiSize))
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


struct PaletteEditor: View {
    @Binding var palette:Palette
    @Binding var showEditor:Bool
    var isFromList:Bool
    
    init(palette:Binding<Palette>, showEditor: Binding<Bool> = .constant(true), isFromList:Bool = false) {
        _palette=palette
        _showEditor=showEditor
        self.isFromList=isFromList
    }
    
    @State private var emojisToAdd=""
    

    @ScaledMetric private var emojiSize=40
    @ScaledMetric private var sectionTextSize=35
    @ScaledMetric private var sectionHeaderSize=20
    
    @State private var showSection=false
    @State private var showAlertOfInputNonEmojiElement=false
    
    
    enum Focused{
        case name
        case add
    }
    
    @FocusState private var focused:Focused?
    
    var body: some View {
        ZStack(alignment:.topTrailing){
            Form{
                Section{
                    TextField(palette.name,text: $palette.name)
                        .font(.system(size: sectionTextSize))
                        .focused($focused,equals: Focused.name)
                }header:{
                    headerOfSectionOfNameView
                }
                Section{
                    TextField("Add Emojis Here", text: $emojisToAdd)
                        .font(.system(size: sectionTextSize))
                        .focused($focused,equals: Focused.add)
                    emojiDisplay
                }header: {
                    headerOfSectionOfEmojisView
                }
                .onChange(of:emojisToAdd){
                    palette.emojis=(emojisToAdd.filter({$0.isEmoji})+palette.emojis).uniqued
                }
                .onSubmit {
                    emojisToAdd=""
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
                if palette.name.isEmpty && palette.emojis.isEmpty{
                    print(false)
                    palette.name=getCurrentTime()
                }
            }
            if !isFromList&&UIDevice.current.userInterfaceIdiom == .phone{
                Button(role:.cancel){
                    showEditor=false
                }label:{
                    Text("Cancel")
                }
                .padding(.top)
                .padding(.horizontal)
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
            .font(.system(size: sectionHeaderSize))
    }
    
    var headerOfSectionOfEmojisView : some View {
        Text("emojis")
            .font(.system(size: sectionHeaderSize))
    }
    
    var emojiDisplay:some View{
        VStack(alignment:.trailing){
            Text("Tap To Remove Emoji")
                .foregroundStyle(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]){
                ForEach(palette.emojis.uniqued.map(String.init),id:\.self){emoji in
                    Text(emoji)
                        .font(.system(size: emojiSize))
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
