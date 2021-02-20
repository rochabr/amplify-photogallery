//
//  EntryViewer.swift
//  cp-amplify-demo
//
//  Created by Rocha Silva, Fernando on 2021-02-19.
//

import Amplify
import SwiftUI
import Combine

struct EntryViewer: View {
    @State var imageCache = [String: UIImage?]()
    
    var body: some View {
        List(imageCache.sorted(by: {$0.key > $1.key }), id: \.key) {key, image in
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear(){
            //deleteAll()
            getEntries()
            observeEntries()
        }
    }
    
    func getEntries() {
        Amplify.DataStore.query(Entry.self){
            result in
            
            switch result{
            case .success(let entries):
                //print(entries)
                
                //download Images
                downloadImages(for: entries)
            
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func downloadImages(for entries: [Entry]){
        for entry in entries {
            if let firstImage = entry.pictures?[0]{
                _ = Amplify.Storage.downloadData(key: firstImage) {
                    result in
                    switch result {
                    case .success(let imageData):
                        let image = UIImage(data: imageData)
                        
                        DispatchQueue.main.async {
                            imageCache[firstImage] = image
                        }
                    case .failure(let error):
                        print("Failed to download image data ", error)
                    }
                }
            }
        }
    }
    
    @State var token: AnyCancellable?
    func observeEntries() {
        token = Amplify.DataStore.publisher(for: Entry.self).sink(
            receiveCompletion: { print($0) },
            receiveValue: {
                event in
                do{
                    let entry = try event.decodeModel(as: Entry.self)
                    downloadImages(for: [entry])
                } catch {
                    print(error)
                }
            }
        )
    }
}

struct EntryViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        EntryViewer()
    }
}

