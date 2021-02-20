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
    @State var entries = [Entry]()
    
    // Create Date Formatter
    var dateFormatter = DateFormatter()
    
    var body: some View {
        List {
            ForEach(self.entries, id: \.id) { entry in
                HStack {
                    if let image = imageCache[(entry.pictures?[0])!] {
                        Image(uiImage: image!)
                            .resizable()
                            .frame(width: 128.0, height: 96.0)
                    }
                    Spacer()
                    VStack (alignment: .trailing){
                        //padding()
                        Text(entry.locomotiveId).font(.headline)
                        Text(entry.details).font(.subheadline)
                        Spacer()
                        let createdAt = entry.createdAt.foundationDate
                        Text(dateFormatter.string(from: createdAt)).font(.footnote)
                    }
                }
            }
        }
        .onAppear(){
            // Set Date Format
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            entries.removeAll()
            
            getEntries()
            observeEntries()
        }
    }

    func getEntries() {
        Amplify.DataStore.query(Entry.self){
            result in
            
            switch result{
            case .success(let entries):
                self.entries.append(contentsOf: entries)
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

//struct EntryViewer_Previews: PreviewProvider {
//
//    static var previews: some View {
//        EntryViewer()
//    }
//}
//
