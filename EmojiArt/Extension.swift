//
//  Extension.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/3/20.
//

import SwiftUI

typealias CGOffset=CGSize

extension CGOffset{
    static func +(lhs:CGOffset,rhs:CGOffset)->CGOffset{
        CGOffset(width: lhs.width+rhs.width, height: lhs.height+rhs.height)
    }
    
    static func +=(lhs:inout CGOffset,rhs:CGOffset){
        lhs=lhs+rhs
    }
}

// find center of CGRect
extension CGRect{
    var center:CGPoint{
        CGPoint(x: midX, y: midY)
    }
}

extension String{
    var uniqued:String{
        reduce(into: ""){ result , element in
            if !result.contains(element){
                result.append(element)
            }
        }
    }
    
    mutating func remove(_ emoji:Character){
       removeAll(where: {$0 == emoji})
    }
}

extension Character{
    var isEmoji:Bool{
        if let firstScalar=self.unicodeScalars.first,firstScalar.properties.isEmoji{
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        }
        else{
            return false
        }
    }
}

extension Collection {
    // this will crash if after >= endIndex
    func suffix(after: Self.Index) -> Self.SubSequence {
        suffix(from: index(after: after))
    }
}


struct UndoButton:View {
    @Environment(\.undoManager) private var undoManager
    
    @State private var showUndoPopover=false
    @State private var showRedoPopover=false
    
    var body: some View {
        if let undoManager {
            HStack{
                Image(systemName: "arrow.uturn.backward.circle")
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        undoManager.undo()
                    }
                    .onLongPressGesture(minimumDuration: 0.05,maximumDistance: 100){
                        showUndoPopover=true
                    }
                    .popover(isPresented: $showUndoPopover){
                        VStack{
                            if !undoManager.canUndo {
                                Text("Nothing to Undo")
                            }else{
                                Button{
                                    undoManager.undo()
                                    showUndoPopover=false
                                }label: {
                                    Text("Undo "+undoManager.undoActionName)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: 280)
                    }
                Image(systemName: "arrow.uturn.forward.circle")
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        undoManager.redo()
                    }
                    .onLongPressGesture(minimumDuration: 0.05,maximumDistance: 100){
                        showRedoPopover=true
                        print(showRedoPopover)
                    }
                    .popover(isPresented: $showRedoPopover){
                        VStack{
                            if !undoManager.canRedo {
                                Text("Nothing to Redo")
                            }else{
                                Button{
                                    undoManager.redo()
                                    showRedoPopover=false
                                }label: {
                                    Text("Redo "+undoManager.redoActionName)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: 280)
                    }
            }
        }
    }
}

struct AnimatedActionButton:View {
    var title:String?
    var systemImage:String?
    var role:ButtonRole?
    let action:(()->Void)?
    
    init(title: String? = nil, systemImage: String? = nil, role: ButtonRole? = nil, action: ( () -> Void)? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }

    
    var body: some View {
        Button(role:role){
            withAnimation{
                if let action{
                    action()
                }
            }
        }label: {
            if let title,let systemImage{
                Label(title, systemImage: systemImage)
            }else if let title{
                Text(title)
            }else if let systemImage{
                Image(systemName: systemImage)
            }
        }
    }
}

//MARK: - about Sturldata
// a type which represents either a String, a URL or a Data
// it implements Transferable by proxy

enum Sturldata: Transferable {
    case string(String)
    case url(URL)
    case data(Data)
    case uiImage(UIImage)
    
    init(url: URL) {
        // some URLs have the data for an image directly embedded in the URL itself
        // (i.e. they are NOT a REFERENCE to the data somewhere else like most are)
        // these sorts of URLs are called "data scheme" URLs
        // (they will have "image/jpeg" or some such as the mime type)
        if let imageData = url.dataSchemeImageData {
            self = .data(imageData)
        } else {
            self = .url(url.imageURL)
        }
    }
    
    init(string: String) {
        // if the string looks like a URL, we're treat it like one
        if string.hasPrefix("http"), let url = URL(string: string) {
            self = .url(url.imageURL)
        } else {
            self = .string(string)
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { Sturldata(string: $0) }
        ProxyRepresentation { Sturldata(url: $0) }
        ProxyRepresentation { Sturldata.data($0) }
    }
}

// the extensions below are just helpers for Sturldata

extension URL {
    // some search engines give out a url which has yet another reference to the actual image url embedded in it
    // (e.g. https://searchresult.searchengine.com?imgurl=https://actualimageurl.jpg)
    // this property returns the first embedded url it finds (if any)
    // if there is no embedded url, it returns self
    
    var imageURL: URL {
        if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems {
            for queryItem in queryItems {
                if let value = queryItem.value, value.hasPrefix("http"), let imgurl = URL(string: value) {
                    return imgurl
                }
            }
        }
        return self
    }

    // returns the image data for data scheme url (if applicable)
    // for example, "data:image/jpeg;base64,<base 64 encoded image data>"
    // (this is as opposed to, for example, "https://stanford.edu/image.jpg")
    // images are rarely passed around using data schemes
    // it generally only makes sense for small images (thumbnails, etc.)
    
    var dataSchemeImageData: Data? {
        let urlString = absoluteString
        // is this a data scheme url with some sort of image as the mime type?
        if urlString.hasPrefix("data:image") {
            // yes, find the comma that separates the meta info from the image data
            if let comma = urlString.firstIndex(of: ","), comma < urlString.endIndex {
                let meta = urlString[..<comma]
                // we can only handle base64 encoded data
                if meta.hasSuffix("base64") {
                    let data = String(urlString.suffix(after: comma))
                    // get the data
                    if let imageData = Data(base64Encoded: data) {
                        return imageData
                    }
                }
            }
        }
        // not a data scheme or the data doesn't seem to be a base64 encoded image
        return nil
    }
}
