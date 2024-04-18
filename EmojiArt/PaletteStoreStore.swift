//
//  PaletteStoreStore.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/4/15.
//

import SwiftUI

extension UserDefaults{
    //扩展UserDefaults.standard获取存储值的方法
    func stores(forKey key:String) -> [PaletteStore] {
        if let jsonData = data(forKey: key),
           let decodedStores=try? JSONDecoder().decode([PaletteStore].self, from: jsonData){
            return decodedStores
        }else{
            return []
        }
    }
    
    //扩展UserDefaults.standard存储值的方法（查看set的doucment，发现不试用于自定义结构）
    func set(_ stores:[PaletteStore],forKey key:String){
        let data=try? JSONEncoder().encode(stores)
        set(data,forKey:key)
    }
    
    func currentPaletteStore(forKey key:String) -> PaletteStore {
        if let jsonData = data(forKey: key),
           let decodedCurrentPaletteStore=try? JSONDecoder().decode(PaletteStore.self, from: jsonData){
            return decodedCurrentPaletteStore
        }else{
            return UserDefaults.standard.stores(forKey:"PaletteStoreStore").first!
        }
    }
    
    //扩展UserDefaults.standard存储值的方法（查看set的doucment，发现不试用于自定义结构）
    func set(_ currentPaletteStore:PaletteStore,forKey key:String){
        let data=try? JSONEncoder().encode(currentPaletteStore)
        set(data,forKey:key)
    }
}

class PaletteStoreStore:ObservableObject{
    let documentID:UUID
    
    var stores:[PaletteStore]{
        get{
            UserDefaults.standard.stores(forKey:"PaletteStoreStore")
        }
        set{
            if !newValue.isEmpty{
                UserDefaults.standard.set(newValue, forKey: "PaletteStoreStore")
                objectWillChange.send()
            }
        }
   }
    var currentPaletteStore:PaletteStore{
        get{
            UserDefaults.standard.currentPaletteStore(forKey: "\(documentID)")
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "\(documentID)")
            objectWillChange.send()
        }
   }
    
    init(documentID:UUID) {
        self.documentID=documentID
        if stores.isEmpty{
            self.stores=PaletteStore.builtins
            self.currentPaletteStore=PaletteStore.builtins.first!
        }
        
    }
}
