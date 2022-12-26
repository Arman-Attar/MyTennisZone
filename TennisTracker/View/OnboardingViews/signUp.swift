//
//  signUp.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-04-28.
//

import SwiftUI

struct signUp: View {
    
    @Binding var email: String
    @Binding var password: String
    @State var userName = ""
    @State var showPassword = false
    @State var showError = false
    @State var showSuccess = false
    @StateObject var vm = OnboardingViewModel()
    @Environment(\.dismiss) var dismiss
    @State var isLoading = false
    
    //    init(email: String, password: String){
    //        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
    //        self.email = email
    //        self.password = password
    //    }
    
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
            }.ignoresSafeArea(.keyboard)
            
            if isLoading {
                LoadingView().ignoresSafeArea()
            }
        }
    }
}

//struct signUp_Previews: PreviewProvider {
//    static var previews: some View {
//        signUp()
//    }
//}

extension signUp {
    
    private var userNameField: some View{
        VStack{
            Text("User Name*")
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            HStack{
                TextField("User Name", text: $userName)
                    .KeyboardModifier()
                Image(systemName: "person")
                    .foregroundColor(.black)
            }.padding(.horizontal)
            CustomDivider()
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
                showError = false
                isLoading = true
                Task {
                    if await vm.register(email: email, password: password, username: userName) {
                        isLoading = false
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            dismiss()
                        }
                    } else {
                        isLoading = false
                        showError = true
                    }
                }
            } label: {
                VStack {
                    Text("Sign Up")
                        .fontWeight(.heavy)
                        .ButtonModifier()
                    if showError {
                        errorField
                    } else if showSuccess {
                        success
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
    
    private var success: some View{
        HStack {
            Text("User Created Succesfully!")
                .fontWeight(.semibold)
                .MessageModifier()
        }
    }
}

