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
    @State var notValid = false
    @ObservedObject var fb = FirebaseManager()
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
        }.alert(isPresented: $notValid) {
            Alert(title: Text("Error"), message: Text("Username already exists"), dismissButton: .default(Text("Got It!")))
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
                    .keyboardType(.emailAddress)
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
            Text("Email ID*")
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            HStack{
                TextField("Email", text: $email)
                    .foregroundColor(.black)
                    .keyboardType(.emailAddress)
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
                SecureField("Password", text: $password)
                    .foregroundColor(.black)
                Image(systemName: "eye.slash")
                    .foregroundColor(.black)
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
                //SEND DATA
                validateUserName { (result) in
                    if result {
                register(email: email, password: password)
                if self.result == "DONE"{
                    dismiss()
                }
                }
                else {
                    notValid = true
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
                    
                    if result != "" && result != "DONE" {
                        errorField
                    }
                    else if result == "DONE"{
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
    
    private func register(email: String, password: String) {
        fb.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                self.result = "Unable to Create User: \(err.localizedDescription)"
            }
            else{
                self.result = "DONE"
                userName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
                createUser(email: email, userName: userName)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    dismiss()
                }
            }
        }
    }
    
    private func createUser(email: String, userName: String){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let userData = ["email" : email.lowercased(), "uid": uid, "profilePicUrl" : "", "username" : userName.lowercased(), "displayName" : userName, "matchesPlayed" : 0, "matchesWon": 0, "trophies" : 0, "friendsUid" : 0] as [String : Any]
        FirebaseManager.shared.firestore.collection("users").document(uid).setData(userData) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
        }
    }
    
    private func validateUserName(completionHandler: @escaping (_ data: Bool) -> Void) {
        //var validate = false
        FirebaseManager.shared.firestore.collection("users").whereField("username", isEqualTo: userName.lowercased()).getDocuments { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                completionHandler(false)
            }
            if snapshot!.isEmpty {
                completionHandler(true)
            }
            else{
                completionHandler(false)
            }
        }
    }
}

