//
//  Extension.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/3/20.
//

import SwiftUI
import UniformTypeIdentifiers

//MARK: - extensions to types

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

//MARK: - extensions to views

extension View {
    // L15 modifier which replaces uses of .toolbar
    // L15 in horizontally compact environments, it puts a single button in the toolbar
    // L15 with a context menu containing the items
    // L15 (only works on ViewBuilder content, not ToolbarItems content)
    func compactableToolbar<Content>(@ViewBuilder content: () -> Content) -> some View where Content: View {
        self.toolbar {
            content().modifier(CompactableIntoContextMenu())
        }
    }
}

struct CompactableIntoContextMenu: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var compact: Bool { horizontalSizeClass == .compact }
    
    func body(content: Content) -> some View {
        if compact {
            Button {
                
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .contextMenu {
                content
            }
        } else {
            content
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

//MARK: - about Droppable
//Anything can be dropped in .emojiart

enum Droppable:Transferable{
    case emoji(Emoji)
    case sturldata(Sturldata)
    
    init(emoji:Emoji) {
        self = .emoji(emoji)
    }
    
    init(sturldata:Sturldata){
        self = .sturldata(sturldata)
    }
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { Droppable(emoji: $0) }
        ProxyRepresentation { Droppable(sturldata: $0) }
    }
}

//MARK: - Emoji to implement Transferable Protocol

extension Emoji:Transferable{
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .emoji)
    }
}

extension UTType{
    static let emoji=UTType(exportedAs: "Gach1koi.emoji")
}

//MARK: - about Sturldata
// a type which represents either a String, a URL or a Data
// it implements Transferable by proxy
// can't intergate Emoji in Sturldata because string, url and data conflict with Emoji.

enum Sturldata: Transferable {
    case string(String)
    case url(URL)
    case data(Data)
    
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
        ProxyRepresentation { Sturldata.url( $0) }
        ProxyRepresentation { Sturldata.data($0) }
    }
}

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
