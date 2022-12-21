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
    @StateObject var vm = OnboardingViewModel()
    @FocusState private var focusEmail: Bool
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
                            .KeyboardModifier()
                            .keyboardType(.emailAddress)
                            .focused($focusEmail)
                        Image(systemName: "at")
                            .foregroundColor(.black)
                    }.padding(.horizontal)
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .padding(.horizontal)
                        .foregroundColor(.black)
                        .padding(.vertical)
                    Button {
                        Task {
                            if await vm.resetPassword(email: email) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        VStack{
                            Text("Send Reset Link")
                                .fontWeight(.heavy)
                                .ButtonModifier()
                        }
                    }
                    if vm.message != "" {
                        Text(vm.message)
                            .fontWeight(.semibold)
                            .MessageModifier()
                    }
                }
            }.navigationTitle("Reset Password")
        }.onAppear{
            focusEmail.toggle()
        }
    }
}

struct resetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        resetPasswordView()
    }
}
