//
//  SignUpView.swift
//  cp-amplify-demo
//
//  Created by Rocha Silva, Fernando on 2021-02-19.
//

import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    
    @State var username = ""
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("Username", text: $username).pretty()
            TextField("Email", text: $email).pretty()
            SecureField("Password", text: $password).pretty()
            Button("Sign Up", action: {
                sessionManager.signUp(
                    username: username,
                    email: email,
                    password: password
                )
            }).pretty()
            
            Spacer()
            Button("Already have an account? Log in.", action: sessionManager.showLogin)
        }
        .padding()
    }
    
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
