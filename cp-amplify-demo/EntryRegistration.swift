//
//  EntryRegistration.swift
//  cp-amplify-demo
//
//  Created by Rocha Silva, Fernando on 2021-02-19.
//

import Amplify
import SwiftUI

struct EntryRegistration: View {
    
    @State var imageCache = [UIImage?]()
    
    @State var shouldShowImagePicker = false
    //@State var image: UIImage?
    @State var locomotiveId: String
    @State var details: String
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(spacing: 10){
                    ForEach(self.imageCache, id: \.self) { cachedImage in
                            Image(uiImage: cachedImage!)
                                .resizable()
                                .frame(width: 128.0, height: 96.0)
                    }
                }
            }.padding()
            
            Spacer()
            TextField("Locomotive Id", text: $locomotiveId).pretty().padding()
            TextField("Details", text: $details).pretty().padding()
            Spacer()
            Button(action: cameraButtonTapped, label:{
                Image(systemName: "camera")
                    .font(.largeTitle)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            })
            .sheet(isPresented: $shouldShowImagePicker, content: {
                ImagePicker(imageCache: $imageCache)
            })
            Spacer()
            Button("Upload", action: {
                hideKeyboard()
                if imageCache.count > 0 {
                    upload(imageCache)
                } else{
                    print("Pick an image")
                }
            })
            .pretty()
            .padding()
        }
    }
    
    func cameraButtonTapped(){
        hideKeyboard()
        shouldShowImagePicker.toggle()
    }
    
    func upload(_ images: [UIImage?]){
        var success = true
        var imageKeys = [String]()
        
        let group = DispatchGroup()
        for image in images {
            group.enter()

            guard let imageData = image!.jpegData(compressionQuality: 0.5) else {return}
            let key = UUID().uuidString + ".jpg"
            
            _ = Amplify.Storage.uploadData(key: key, data: imageData) {
                result in
                
                switch result {
                case .success:
                    imageKeys.append(key)
                    print("Uploaded image")
                case .failure(let error):
                    print("Failed to upload ", error)
                    
                    success = false
                }
                
                group.leave()
            }

        }

        group.notify(queue: .main) {
            if success {
                let entry = Entry(
                    id: UUID().uuidString,
                    locomotiveId: locomotiveId,
                    details: details,
                    pictures: imageKeys,
                    createdAt: getCurrentTime(),
                    updatedAt: getCurrentTime())
                
                //Save image to entry
                save(entry)
            } else {
                print("will not save, picture upload failed")
            }
        }
        
    }
    
    func save(_ entry: Entry){
        Amplify.DataStore.save(entry){ result in
            switch result {
            case .success:
                print("Saved entry")

                self.imageCache.removeAll()
                self.locomotiveId = ""
                self.details = ""
                
            case .failure(let error):
                print("Failed to save entry ", error)
            }
        }
    }
    
    func getCurrentTime() -> Temporal.DateTime{
        let now = Temporal.DateTime.now()
        return now
    }
    
    func hideKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//struct EntryRegistration_Previews: PreviewProvider {
//    private struct DummyEntry: Entry {
//        let locomotiveId: String = "1"
//        let details: String = "dummy"
//    }
//    static var previews: some View {
//        EntryRegistration(entry: DummyEntry())
//    }
//}
