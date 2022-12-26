//
//  signIn.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-04-28.
//

import SwiftUI

struct signIn: View {
    
    //    init(){
    //        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
    //    }
    @AppStorage("email") var email = ""
    @AppStorage("password") var password = ""
    @State var showPassword = false
    @State var forgotPassSheet = false
    @StateObject var vm = OnboardingViewModel()
    @State var isLoading = false
    var body: some View {
        ZStack {
            if vm.isSignedIn{
                mainPage()
            }
            else {
                signInScreen
            }
            if isLoading {
                LoadingView().ignoresSafeArea()
            }
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
                VStack(spacing: 20){
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
                    HStack {
                        Text("Don't have an Account?").foregroundColor(Color.black)
                        NavigationLink("Sign Up") {
                            signUp(email: $email, password: $password).navigationTitle("Sign Up")
                        }
                    }
                    Spacer()
                }.ignoresSafeArea(.keyboard)
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
                    .KeyboardModifier()
                    .keyboardType(.emailAddress)
                Image(systemName: "at")
                    .foregroundColor(.black)
            }.padding(.horizontal)
            CustomDivider()
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
                        .KeyboardModifier()
                } else {
                    SecureField("Password", text: $password)
                        .KeyboardModifier()
                }
                Button {
                    self.showPassword.toggle()
                } label: {
                    Image(systemName: "eye.slash")
                        .foregroundColor(.black)
                }
            }.padding(.horizontal)
            CustomDivider()
        }
    }
    
    private var submitButton: some View {
        VStack{
            Button {
                isLoading = true
                Task{
                    await vm.logIn(email: email, password: password)
                    isLoading = false
                }
            } label: {
                VStack {
                    Text("Sign In")
                        .fontWeight(.heavy)
                        .ButtonModifier()
                    if vm.message != "" {
                        errorField
                    }
                }
            }
        }
    }
    private var errorField: some View{
        Text(vm.message)
            .fontWeight(.semibold)
            .MessageModifier()
    }
}
