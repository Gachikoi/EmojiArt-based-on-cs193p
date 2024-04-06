//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/3/20.
//

import SwiftUI

extension UserDefaults{
    //扩展UserDefaults.standard获取存储值的方法
    func palettes(forKey key:String) -> [Palette] {
        if let jsonData = data(forKey: key),
           let decodedPalettes=try? JSONDecoder().decode([Palette].self, from: jsonData){
            return decodedPalettes
        }else{
            return []
        }
    }
    
    //扩展UserDefaults.standard存储值的方法（查看set的doucment，发现不试用于自定义结构）
    func set(_ palettes:[Palette],forKey key:String){
        let data=try? JSONEncoder().encode(palettes)
        set(data,forKey:key)
    }
}

class PaletteStore:ObservableObject{
    let name:String
    
    var palettes:[Palette]{
         get{
             UserDefaults.standard.palettes(forKey: name)
         }
         set{
             if !newValue.isEmpty{
                 UserDefaults.standard.set(newValue, forKey: name)
                 objectWillChange.send()
             }
             print(newValue)
         }
    }
    
    init(name: String) {
        self.name = name
        if palettes.isEmpty{
            palettes=Palette.builtins
        }
    }
    
    @Published private var _paletteIndex=0
    
    var paletteIndex:Int{
        set{
            if newValue>=palettes.count{
                _paletteIndex=newValue%palettes.count
            }
            if newValue<0{
                _paletteIndex = -newValue
            }
            _paletteIndex=newValue
        }
        get{
            if _paletteIndex>=palettes.count{
                return _paletteIndex%palettes.count
            }
            if _paletteIndex<0{
                return  -_paletteIndex
            }
            return _paletteIndex
        }
    }
    
    // MARK: - Adding Palettes
    
    // these functions are the recommended way to add Palettes to the PaletteStore
    // since they try to avoid duplication of Identifiable-ly identical Palettes
    // by first removing/replacing any Palette with the same id that is already in palettes
    // it does not "remedy" existing duplication, it just does not "cause" new duplication
    
    func insert(_ palette: Palette, at insertionIndex: Int? = nil) { // "at" default is cursorIndex
        let insertionIndex = insertionIndex ?? paletteIndex
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            palettes.move(fromOffsets: IndexSet([index]), toOffset: insertionIndex)
            palettes.replaceSubrange(insertionIndex...insertionIndex, with: [palette])
        } else {
            palettes.insert(palette, at: insertionIndex)
        }
    }
    
    func insert(name: String, emojis: String) {
        insert(Palette(name: name, emojis: emojis), at: nil)
    }
    
    func append(_ palette: Palette) { // at end of palettes
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            if palettes.count == 1 {
                palettes = [palette]
            } else {
                palettes.remove(at: index)
                palettes.append(palette)
            }
        } else {
            palettes.append(palette)
        }
    }
    
    func append(name: String, emojis: String) {
        append(Palette(name: name, emojis: emojis))
    }
}
