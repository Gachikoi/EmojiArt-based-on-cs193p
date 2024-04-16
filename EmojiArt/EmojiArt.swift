//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/3/19.
//

import Foundation
import SwiftUI

typealias Emoji=EmojiArt.Emoji

struct EmojiArt:Codable{
    private(set) var emojis=[Emoji]()
    private(set) var background=Background.blank
    var id=UUID()
    
    struct Emoji:Identifiable,Codable{
        var string:String
        var position:Position
        var size:Int
        var id:Int
        
        struct Position:Codable{
            var x:Int
            var y:Int
            
            static let zero=Position(x: 0, y: 0)
        }
    }
    
    enum Background:Codable,Equatable{
        case blank
        case url(URL)
        case imageData(Data)
        
        var url:URL?{
            switch self {
            case .url(let url):
                return url
            default:
                return nil
            }
        }
        
        var imageData:Data?{
            switch self {
            case .imageData(let imageData):
                return imageData
            default:
                return nil
            }
        }
    }
    
    //MARK: - Intent
    private var emojiID=0
    
    mutating func addEmoji(_ emoji:String,at position:Emoji.Position,size:Int){
        emojis.append(Emoji(string: emoji, position: position, size: size, id: emojiID))
        emojiID+=1
    }
    
    mutating func removeEmoji(_ emoji:String){
        emojis.remove(at: 0)
    }
    
    mutating func setBackground(_ background:Background){
        self.background=background
    }
    
    mutating func resize(){
        
    }
    
    mutating func move(){
        
    }
}
