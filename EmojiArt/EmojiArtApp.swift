//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/2/28.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    
    var body: some Scene {
        DocumentGroup(newDocument: {EmojiArtDocument()} ) { config in
            EmojiArtDocumentView(document:config.document )
        }
    }
}
