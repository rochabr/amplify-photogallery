//
//  cp_amplify_demoApp.swift
//  cp-amplify-demo
//
//  Created by Rocha Silva, Fernando on 2021-02-19.
//

import SwiftUI

import Amplify
import AmplifyPlugins

@main
struct cp_amplify_demoApp: App {
    
    @ObservedObject var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            switch sessionManager.authState {
            case .login:
                LoginView()
                    .environmentObject(sessionManager)
            
            case .signUp:
                SignUpView()
                    .environmentObject(sessionManager)
            
            case .confirmCode(let username):
                ConfirmationView(username: username)
                    .environmentObject(sessionManager)
                
            case .session(let user):
                SessionView(user: user)
                    .environmentObject(sessionManager)
            }
        }
    }

    init() {
        configureAmplify()
        
        //gets current authenticated user
        sessionManager.getCurrentAuthUser()
    }
    
    //configure Amplify
    func configureAmplify(){
        do{
            //storage
            try Amplify.add(plugin:AWSCognitoAuthPlugin())
            try Amplify.add(plugin:AWSS3StoragePlugin())
            
            //DataStore
            let models = AmplifyModels()
            try Amplify.add(plugin:AWSAPIPlugin(modelRegistration: models))
            try Amplify.add(plugin:AWSDataStorePlugin(modelRegistration: models))
            
            //configure plugins
            try Amplify.configure()
            print("Amplify succesfully configured")
        } catch {
            print("could not initialize amplify", error)
        }
    }
}

