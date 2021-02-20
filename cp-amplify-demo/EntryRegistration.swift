//
//  EntryRegistration.swift
//  cp-amplify-demo
//
//  Created by Rocha Silva, Fernando on 2021-02-19.
//

import Amplify
import SwiftUI

struct EntryRegistration: View {
    
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    @State var locomotiveId: String
    @State var details: String
    
    var body: some View {
        VStack {
            if let image = self.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
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
                ImagePicker(image: $image)
            })
            Spacer()
            Button("Upload", action: {
                hideKeyboard()
                if let image = self.image {
                    upload(image)
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
    
    func upload(_ image: UIImage){
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {return}
        let key = UUID().uuidString + ".jpg"
        
        _ = Amplify.Storage.uploadData(key: key, data: imageData) {
            result in
            
            switch result {
            case .success:
                print("Uploaded image")
                
                let entry = Entry(
                    id: UUID().uuidString,
                    locomotiveId: locomotiveId,
                    details: details,
                    pictures: [key],
                    createdAt: getCurrentTime(),
                    updatedAt: getCurrentTime())
                
                //Save image to entry
                save(entry)
                
            case .failure(let error):
                print("Failed to upload ", error)
            }
        }
    }
    
    func save(_ entry: Entry){
        Amplify.DataStore.save(entry){ result in
            switch result {
            case .success:
                print("Saved entry")
                //TODO: fix for multiple images
                //self.entry = Entry()
                self.image = nil
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
