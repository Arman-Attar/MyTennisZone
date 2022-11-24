//
//  resetPasswordView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-11-09.
//

import SwiftUI

struct resetPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State var email = ""
    @State var result = ""
    var body: some View {
        NavigationView {
            ZStack{
                Image("back")
                    .resizable()
                    .ignoresSafeArea()
                    .blur(radius: 2.0, opaque: true)
                    .opacity(0.65)
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
                Button {
                    FirebaseManager.shared.resetPassword(email: email) { data in
                        if data == "" {
                            result = "Password reset email has been sent!"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                dismiss()
                            }
                        } else {
                            result = data
                        }
                    }
                } label: {
                    VStack{
                        Text("Send Reset Link")
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
                    }
                }
                if result != "" {
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
            }.navigationTitle("Reset Password")
        }
    }
}

struct resetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        resetPasswordView()
    }
}
