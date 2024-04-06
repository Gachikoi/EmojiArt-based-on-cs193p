//
//  EmojiArtDoucmentView.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/2/28.
//

import SwiftUI

extension Emoji:Transferable{
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { Emoji(string: $0.string, position: $0.position, size: $0.size, id: $0.id) }
    }
}

struct EmojiArtDoucmentView: View {
    @ObservedObject var doucment:EmojiArtDoucment
    
    private let emojisSize:CGFloat=40
    
    var body: some View {
        VStack(spacing:0) {
            doucmentBody
            PaletteChooser()
                .font(.system(size: emojisSize))
        }
    }
    
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
    
    var doucmentBody:some View{
        GeometryReader{ geometry in
            ZStack{
                Color.white
                doucmentContents(in: geometry)
                .scaleEffect(zoom*gestureZoom)
                .offset(pan+gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: Sturldata.self){ sturldatas,location in
                drop(sturldatas,at:location,in:geometry)
            }
        }
    }
    
    private func drop(_ sturldatas:[Sturldata],at location:CGPoint,in geometry:GeometryProxy)->Bool{
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                doucment.setBackground(url)
                return true
            case .string(let emoji):
                doucment.addEmoji(emoji,at:emojiPosition(at:location,in:geometry),size:emojisSize/zoom)
                return true
            default:
                break
            }
        }
        return false
    }
    
    @ViewBuilder
    private func doucmentContents(in geometry:GeometryProxy)->some View{
        //display background and show "Loading.." when EmojiArtDoucment is downloading Image
        ZStack{
            if doucment.background != nil{
                AsyncImage(url: doucment.background){ phase in
                    if let image=phase.image{
                        image
                    }else{
                        ProgressView()
                    }
                }
            }
        }
        .position(Emoji.Position.zero.in(geometry))
        //display emojis dragged into doucmentBody
        ForEach(doucment.emojis){ emoji in
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

#Preview {
    EmojiArtDoucmentView(doucment: EmojiArtDoucment())
        .environmentObject(PaletteStore(name: "preview1"))
}
