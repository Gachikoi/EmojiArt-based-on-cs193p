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
    //MARK: - Persistence
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
    
    //MARK: - firstly initiaize an EmojiArtDocument.
    init(){}
    
    //MARK: - injected UndoManager
    func injectUndoManager(_ undoManager: UndoManager?) {
        self.undoManager = undoManager
    }
    
    private var undoManager:UndoManager?
    
    //MARK: - Variables
    @Published private var emojiArt=EmojiArt(){
        didSet {
            if emojiArt.background != oldValue.background {
                Task{
                    await fetchBackgroundImage()
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
    
    @Published var backgroundImage:UIImage?
    @Published var backgroundFetchStatus=BackgroundFetchStatus.none
    
    // MARK: - Background Image
    @MainActor
    private func fetchBackgroundImage() async {
        switch emojiArt.background {
        case .blank:
            backgroundImage=nil
            backgroundFetchStatus = .none
        case .url(let url):
            backgroundFetchStatus = .fetching(url)
            do{
                let image=try await fetchUIImage(from: url)
                if url == emojiArt.background.url{
                    backgroundImage=image
                    backgroundFetchStatus = .found(image)
                }
            }catch{
                backgroundFetchStatus = .failed(error.localizedDescription)
            }
        case .imageData(let data):
            backgroundImage=UIImage(data: data)
            backgroundFetchStatus = .found(backgroundImage!)
        }
    }
    
    private func fetchUIImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            throw FetchError.badImageData
        }
    }
    
    enum FetchError: Error {
        case badImageData
    }
    
    enum BackgroundFetchStatus{
        case none
        case fetching(URL)
        case found(UIImage)
        case failed(String)
        
        var uiImage: UIImage? {
            switch self {
            case .found(let uiImage): return uiImage
            default: return nil
            }
        }
        
        var urlBeingFetched: URL? {
            switch self {
            case .fetching(let url): return url
            default: return nil
            }
        }
        
        var isFetching: Bool { urlBeingFetched != nil }
        
        var failureReason: String? {
            switch self {
            case .failed(let reason): return reason
            default: return nil
            }
        }
    }
    
    
    //MARK: - Undo
    func undoablyPerform(_ action:String,doit:()->Void){
        let oldEmojiArt = emojiArt
        doit()
        //这里target自动使用unowned进行self的引用，帮助我们避免了循环强引用
        self.undoManager?.registerUndo(withTarget: self){ myself in
            self.undoablyPerform(action){
                self.emojiArt=oldEmojiArt
            }
        }
        self.undoManager?.setActionName(action)
    }
    //MARK: - Intent
    func addEmoji(_ emoji:String,at position:Emoji.Position,size:CGFloat){
        undoablyPerform("Add \(emoji)"){
            emojiArt.addEmoji(emoji,at: position,size: Int(size))
        }
    }
    
    func removeEmoji(_ emoji:Emoji){
        undoablyPerform("Remove \(emoji.string)"){
            emojiArt.removeEmoji(emoji)
        }
    }
    
    func setBackground(_ background: EmojiArt.Background) {
        undoablyPerform("Set Background") {
            emojiArt.setBackground(background)
        }
    }
    
    func removeBackground(){
        undoablyPerform("Remove Background") {
            emojiArt.removeBackground()
        }
    }
    
    func resize(_ emoji:Emoji,by zoom:CGFloat){
        undoablyPerform("Resize \(emoji.string)") {
            emojiArt.resize(emoji,by:zoom)
        }
    }
    
    func move(_ emoji:Emoji,by pan:CGOffset){
        undoablyPerform("Move \(emoji.string)") {
            emojiArt.move(emoji,by:pan)
        }
    }
}

extension Emoji.Position{
    func `in` (_ gemoetry:GeometryProxy)->CGPoint{
        let center=gemoetry.frame(in: .local).center
        return CGPoint(x: center.x+CGFloat(self.x), y: center.y-CGFloat(self.y))
    }
}
