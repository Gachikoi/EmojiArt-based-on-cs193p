//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/2/28.
//

import SwiftUI
import SwiftData

extension Emoji:Transferable{
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { Emoji(string: $0.string, position: $0.position, size: $0.size, id: $0.id) }
    }
}

struct EmojiArtDocumentView: View {
    @ObservedObject var document:EmojiArtDocument
    @ObservedObject var paletteStoreStore:PaletteStoreStore
    
    init(document: EmojiArtDocument) {
        self.document=document
        self.paletteStoreStore=PaletteStoreStore(documentID:document.id)
    }
    
    @ScaledMetric private var emojisSize:CGFloat=40
    
    @Environment(\.undoManager) private var undoManager
    
    @State private var showManager=false
    
    var body: some View {
        VStack(spacing:0) {
            documentBody
            PaletteChooser()
                .environmentObject(paletteStoreStore.currentPaletteStore)
                .font(.system(size: emojisSize))
        }
        .toolbar{
            AnimatedActionButton(title:"PaletteStore Manager"){
                showManager=true
            }
            UndoButton()
        }
        .fullScreenCover(isPresented:$showManager){
            PaletteStoreManager(paletteStoreStore: paletteStoreStore)
        }
    }
    
    @State private var showSetBackgroundFailedAlert=false
    
    @State var zoom:CGFloat=1
    @State var pan:CGOffset = .zero
    @GestureState var gestureZoom:CGFloat=1
    @GestureState var gesturePan:CGOffset = .zero
    
    var zoomGesture:some Gesture{
        MagnificationGesture()
            .updating($gestureZoom){ value ,gestureZoom, _ in
                gestureZoom=value
            }
            .onEnded{ value in
                zoom*=value
            }
    }
    
    var panGesture:some Gesture{
        DragGesture()
            .updating($gesturePan){ value, gesturePan, _ in
                gesturePan=value.translation
            }
            .onEnded{ value in
                pan+=value.translation
            }
    }
    
    var documentBody:some View{
        GeometryReader{ geometry in
            ZStack{
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom*gestureZoom)
                    .offset(pan+gesturePan)
                if document.background.isFetching {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.cyan)
                        .position(Emoji.Position.zero.in(geometry))
                }
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: Sturldata.self){ sturldatas,location in
                drop(sturldatas,at:location,in:geometry)
            }
            .onTapGesture(count: 2){
                zoomToFit(document.background.uiImage?.size, in: geometry)
            }
            //can't be onChange(of:document.background), bacause we only want to perform zoomToFit when uiImage changes.
            .onChange(of: document.background.uiImage,initial: true){ oldUIImage,newUIImage  in
                zoomToFit(newUIImage?.size,in:geometry)
            }
            .onChange(of: document.background.failedReason){
                showSetBackgroundFailedAlert = (document.background.failedReason != nil)
            }
            .alert("Set Background",
                   isPresented: $showSetBackgroundFailedAlert,
                   presenting: document.background.failedReason
            ){ reason in
                Button("OK",role:.cancel){}
            }message: { reason in
                Text(reason)
            }
        }
    }
    
    private func zoomToFit(_ size:CGSize? , in geometry:GeometryProxy){
        if let size {
            //origin start from up-left point.
            zoomToFit(CGRect(origin: .zero, size: size), in: geometry)
        }
    }
    
    private func zoomToFit(_ rect: CGRect, in geometry: GeometryProxy) {
        withAnimation {
            if rect.size.width > 0, rect.size.height > 0,
               geometry.size.width > 0, geometry.size.height > 0 {
                let hZoom = geometry.size.width / rect.size.width
                let vZoom = geometry.size.height / rect.size.height
                zoom = min(hZoom, vZoom)
                pan = CGOffset(
                    width: 0,
                    height: 0
                )
            }
        }
    }
    
    private func drop(_ sturldatas:[Sturldata],at location:CGPoint,in geometry:GeometryProxy)->Bool{
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url,with: undoManager)
                return true
            case .string(let emoji):
                document.addEmoji(emoji,at:emojiPosition(at:location,in:geometry),size:emojisSize/zoom,with: undoManager)
                return true
            default:
                break
            }
        }
        return false
    }
    
    @ViewBuilder
    private func documentContents(in geometry:GeometryProxy)->some View{
        //display background and show "Loading.." when EmojiArtDocument is downloading Image
        Group{
            if let uiImage=document.background.uiImage{
                Image(uiImage: uiImage)
            }else if let uiImage=document.oldBackground.uiImage, document.background.failedReason != nil {
                Image(uiImage: uiImage)
            }
        }
        .position(Emoji.Position.zero.in(geometry))
        //display emojis dragged into doucmentBody
        ForEach(document.emojis){ emoji in
            Text(emoji.string)
                .font(.system(size: CGFloat(emoji.size)))
                .position(emoji.position.in(geometry))//transfer emoji.position to the View's true position
                .draggable(emoji.string)
        }
    }
    
    //center.x+emoji.x+pan.x=location.x center.y-emoji.y+pan.y=location.y
    //transfer the View's position to Emoji.Position
    private func emojiPosition(at location:CGPoint,in geometry:GeometryProxy)->Emoji.Position{
        let center=geometry.frame(in: .local).center
        return Emoji.Position(
            x: Int((location.x-center.x-pan.width)/zoom),
            y: Int((center.y-location.y+pan.height)/zoom)
        )
    }
}

#Preview(traits: .landscapeRight) {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(name: "preview1"))
}
