//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/2/28.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var defaultDoucment=EmojiArtDoucment()
    @StateObject var defaultPaletteChooser=PaletteStore(name: "Main")
    var body: some Scene {
        WindowGroup {
            EmojiArtDoucmentView(doucment: defaultDoucment)
                .environmentObject(defaultPaletteChooser)
        }
    }
}
