//
//  signUp.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-04-28.
//

import SwiftUI

struct signUp: View {
    
    init(){
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    @State var email = ""
    @State var password = ""
    @State var userName = ""
    @State var result = ""
    @State var showPassword = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack{
            Image("back")
                .resizable()
                .ignoresSafeArea()
                .blur(radius: 2.0, opaque: true)
                .opacity(0.85)
            VStack {
                Spacer()
                VStack{
                    userNameField
                    emailField
                    passwordField
                    submitButton
                }
                Spacer()
            }
        }
    }
}

struct signUp_Previews: PreviewProvider {
    static var previews: some View {
        signUp()
    }
}

extension signUp {
    
    private var userNameField: some View{
        VStack{
            Text("User Name*")
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            HStack{
                TextField("User Name", text: $userName)
                    .foregroundColor(.black)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                Image(systemName: "person")
                    .foregroundColor(.black)
            }.padding(.horizontal)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .padding(.horizontal)
                .foregroundColor(.black)
                .padding(.vertical)
        }
    }
    
    private var emailField: some View{
        VStack{
            Text("Email*")
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            HStack{
                TextField("Email", text: $email)
                    .foregroundColor(.black)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                Image(systemName: "at")
                    .foregroundColor(.black)
            }.padding(.horizontal)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .padding(.horizontal)
                .foregroundColor(.black)
                .padding(.vertical)
        }
    }
    
    private var passwordField: some View{
        VStack{
            Text("Password*")
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            HStack{
                if showPassword {
                    TextField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .foregroundColor(.black)
                } else {
                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .foregroundColor(.black)
                }
                Button {
                    self.showPassword.toggle()
                } label: {
                    Image(systemName: "eye.slash")
                        .foregroundColor(.black)
                }
            }.padding(.horizontal)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight:1)
                .padding(.horizontal)
                .foregroundColor(.black)
                .padding(.vertical)
        }
    }
    
    private var submitButton: some View {
        VStack{
            Button {
                FirebaseManager.shared.validateUserName(userName: userName) { (result) in
                    if result {
                        FirebaseManager.shared.register(email: email, password: password, userName: userName) { result in
                            self.result = result
                            if result == "done"{
                                dismiss()
                            }
                        }
                    } else {
                        self.result = "Username already exists"
                    }
                }
            } label: {
                VStack {
                    Text("Sign Up")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .padding()
                        .foregroundColor(.black)
                        .frame(maxWidth: UIScreen.main.bounds.size.width / 1.25, maxHeight: 20)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 100)
                            .stroke(Color.black, lineWidth: 0.8))
                        .padding()
                        .offset(y: 9)
                    
                    if result != "" && result != "done" {
                        errorField
                    }
                    else if result == "done"{
                        success
                    }
                }
                
            }
            
        }
    }
    
    private var errorField: some View{
        Text(result)
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(Color.black)
            .multilineTextAlignment(.center)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(21)
            .padding()
    }
    
    private var success: some View{
        HStack {
            Text("User Created Succesfully!")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
                .multilineTextAlignment(.center)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(21)
                .padding()
        }
    }
}

