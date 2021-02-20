//
//  SessionView.swift
//  cp-amplify-demo
//
//  Created by Rocha Silva, Fernando on 2021-02-19.
//

import Amplify
import SwiftUI

struct SessionView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    
    let user: AuthUser
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Sign Out", action: sessionManager.signOut)
                    .padding()
            }
            TabView {
                EntryRegistration(locomotiveId: "", details: "")
                    .tabItem { Image(systemName: "camera") }
                EntryViewer()
                    .tabItem { Image(systemName: "photo.on.rectangle") }
            }
//            .onAppear(){
//                deleteAll()
//            }
        }
    }
    
    func deleteAll (){
        Amplify.DataStore.query(Entry.self){
            result in
            
            switch result{
            case .success(let entries):
                //print(entries)
                for entry in entries {
                //delete
                    Amplify.DataStore.delete(entry){
                        switch $0 {
                        case .success:
                            print("Entry deleted!")
                        case .failure(let error):
                            print("Error deleting entry - \(error.localizedDescription)")
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
}

struct SessionView_Previews: PreviewProvider {
    private struct DummyUser: AuthUser {
        let userId: String = "1"
        let username: String = "dummy"
    }
    
    static var previews: some View {
        SessionView(user: DummyUser())
    }
}
