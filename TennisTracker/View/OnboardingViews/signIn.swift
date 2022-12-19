//
//  signIn.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-04-28.
//

import SwiftUI

struct signIn: View {
    init(){
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
    }
    @AppStorage("email") var email = ""
    @AppStorage("password") var password = ""
    @State var isUserSignedIn = false
    @State var showPassword = false
    @State var result = ""
    @State var forgotPassSheet = false
    var body: some View {
        if isUserSignedIn{
            mainPage()
        }
        else {
            signInScreen
        }
    }
}

struct signIn_Previews: PreviewProvider {
    static var previews: some View {
        signIn()
    }
}

extension signIn {
    
    private var signInScreen: some View {
        NavigationView{
            ZStack{
                Image("back")
                    .resizable()
                    .ignoresSafeArea()
                    .blur(radius: 2.0, opaque: true)
                    .opacity(0.85)
                VStack{
                    VStack{
                        Spacer()
                            emailField
                            passwordField
                        Button {
                            forgotPassSheet.toggle()
                        } label: {
                            Text("Forgot Password?")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .font(.body)
                                .padding(.horizontal)
                        }
                            submitButton
                        Spacer()
                            
                    }
                    Spacer()
                    HStack {
                        Text("Don't have an Account?").foregroundColor(Color.black)
                        NavigationLink("Sign Up") {
                            signUp().navigationTitle("Sign Up")
                        }
                    }
                }
            }.navigationTitle("Sign In")
        }.navigationViewStyle(StackNavigationViewStyle())
            .sheet(isPresented: $forgotPassSheet) {
               resetPasswordView()
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
                FirebaseManager.shared.logIn(email: email, password: password, completionHandler: { data in
                    if data == "Sign In"{
                        isUserSignedIn.toggle()
                    }
                    else{
                        result = data
                    }
                })
            } label: {
                VStack {
                    Text("Sign In")
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
                    if result != "" {
                        errorField
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
}