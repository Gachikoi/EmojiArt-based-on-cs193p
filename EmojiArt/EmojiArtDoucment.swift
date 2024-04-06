//
//  EmojiArtDoucment.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/2/28.
//

import SwiftUI

class EmojiArtDoucment:ObservableObject {    
    @Published private var emojiArt=EmojiArt(){
        didSet{
            autosave()
        }
    }
    
    private var autosaveURL:URL=URL.documentsDirectory.appendingPathComponent("Autosaved.emojiArt")
    
    private func autosave(){
        do{
            let data=try JSONEncoder().encode(emojiArt)
            try data.write(to: autosaveURL)
        }catch let error{
            print("EmojiDoucment: error while autosave \(error.localizedDescription)")
        }
    }
    
    init() {
        if let data=try? Data(contentsOf: autosaveURL){
            if let decoded=try? JSONDecoder().decode(EmojiArt.self, from: data){
                emojiArt=decoded
            }
        }
    }
    
    var emojis:[Emoji]{
        emojiArt.emojis
    }
    
    var background:URL?{
        emojiArt.background
    }
    
    //MARK: - Intent
    func addEmoji(_ emoji:String,at position:Emoji.Position,size:CGFloat){
        emojiArt.addEmoji(emoji,at: position,size: Int(size))
    }
    
    func removeEmoji(_ emoji:String){
        emojiArt.removeEmoji(emoji)
    }
    
    func setBackground(_ background:URL?){
        emojiArt.setBackground(background)
    }
}

extension Emoji.Position{
    func `in` (_ gemoetry:GeometryProxy)->CGPoint{
        let center=gemoetry.frame(in: .local).center
        return CGPoint(x: center.x+CGFloat(self.x), y: center.y-CGFloat(self.y))
    }
}
