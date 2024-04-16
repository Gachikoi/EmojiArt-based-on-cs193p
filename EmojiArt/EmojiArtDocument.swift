//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/2/28.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let emojiart=UTType(exportedAs: "Gach1koi.emojiart")
}

class EmojiArtDocument:ReferenceFileDocument{
    func snapshot(contentType: UTType) throws -> Data {
        try JSONEncoder().encode(emojiArt)
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    static var readableContentTypes: [UTType]{
        [.emojiart]
    }
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt=try JSONDecoder().decode(EmojiArt.self, from: data)
        }else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    // firstly initiaize an EmojiArtDocument.
    init(){
        
    }
    
    @Published private var emojiArt=EmojiArt(){
        didSet{
            if emojiArt.background != oldValue.background {
                Task{
                    await fetchBackground()
                }
            }
        }
    }
    
    var emojis:[Emoji]{
        emojiArt.emojis
    }
    
    var id:UUID{
        emojiArt.id
    }
    
    @Published var showSetBackgroundAlert=false
    
    @Published var background=Background.none{
        didSet{
            switch oldValue {
            case .found:
                oldBackground=oldValue
            default:
                break
            }
            switch background {
            case .failed:
                setBackground(oldBackground.url)
            default:
                break
            }
        }
    }
    
    @Published var oldBackground=Background.none
    
    // MARK: - background fetching
    
    enum Background{
        case none
        case fetching(URL)
        case found(UIImage,URL)
        case failed(String)
        
        var uiImage:UIImage?{
            switch self {
            case .found(let uiImage,_):
                return uiImage
            default :
                return nil
            }
        }
        
        var url:URL?{
            switch self {
            case .found( _,let url):
                return url
            default :
                return nil
            }
        }
        
        var isFetching:Bool{
            switch self {
            case .fetching:
                return true
            default :
                return false
            }
        }
        
        var failedReason:String?{
            switch self {
            case .failed(let reason):
                return reason
            default:
                return nil
            }
        }
    }
    
    enum FetchingError:Error{
        case FetchUIImageError
    }
    
    @MainActor
    func fetchBackground() async {
        if let url=emojiArt.background {
            background = .fetching(url)
            do{
                let uiImage=try await fetchUIImage(url:url)
                if url==emojiArt.background {
                    background = .found(uiImage,url)
                }
            }catch{
                background = .failed(error.localizedDescription)
            }
        }else {
            background = .none
        }
    }
    
    func fetchUIImage(url:URL) async throws -> UIImage{
        let ( data , _ ) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data){
            return uiImage
        }else {
            throw FetchingError.FetchUIImageError
        }
    }
    
    //MARK: - Undo
    func undoablyPerform(_ action:String,with undoManager:UndoManager? = nil,doit:()->Void){
        let oldEmojiArt = emojiArt
        doit()
        //这里target自动使用unowned进行self的引用，帮助我们避免了循环强引用
        undoManager?.registerUndo(withTarget: self){ myself in
            self.undoablyPerform(action, with: undoManager){
                self.emojiArt=oldEmojiArt
            }
        }
        undoManager?.setActionName(action)
    }
    
    //MARK: - Intent
    func addEmoji(_ emoji:String,at position:Emoji.Position,size:CGFloat,with undoManager:UndoManager? = nil){
        undoablyPerform("Add \(emoji)", with: undoManager){
            emojiArt.addEmoji(emoji,at: position,size: Int(size))
        }
    }
    
    func removeEmoji(_ emoji:String,with undoManager:UndoManager? = nil){
        undoablyPerform("Remove \(emoji)", with: undoManager){
            emojiArt.removeEmoji(emoji)
        }
    }
    
    func setBackground(_ background:URL?,with undoManager:UndoManager? = nil){
        undoablyPerform("Set Background", with: undoManager){
            emojiArt.setBackground(background)
        }
    }
}

extension Emoji.Position{
    func `in` (_ gemoetry:GeometryProxy)->CGPoint{
        let center=gemoetry.frame(in: .local).center
        return CGPoint(x: center.x+CGFloat(self.x), y: center.y-CGFloat(self.y))
    }
}
