//
//  ChangeDisplayNameView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import SwiftUI

struct ChangeDisplayNameView: View {
    
    @EnvironmentObject private var vm: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var changeDisplayName: Bool
    @State var displayName = ""
    @State var invalidDisplayName = false
    
    var body: some View {
        VStack{
            Text("Change Display Name").font(.title3).fontWeight(.bold).padding()
            TextField(" Enter your new display name", text: $displayName).padding().background(Color.gray.opacity(0.3)).cornerRadius(20)
            HStack{
                Button {
                    if displayName.isEmpty {
                        invalidDisplayName = true
                    }
                    else{
                        Task{
                            displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                            await vm.updateDisplayName(username: displayName)
                            changeDisplayName.toggle()
                        }
                    }
                } label: {
                    VStack{
                        Text("Update")
                            .padding()
                            .foregroundColor(Color.white)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(20)
                    }
                }
                Button {
                    changeDisplayName.toggle()
                } label: {
                    VStack{
                        Text("Cancel")
                            .padding()
                            .foregroundColor(Color.white)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(20)
                    }
                }
            }.padding()
        }
        .padding()
        .frame(width: UIScreen.main.bounds.midX * 1.5, height: UIScreen.main.bounds.midY / 2)
        .background(Color.white)
        .cornerRadius(30)
    }
}

//struct ChangeDisplayNameView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeDisplayNameView()
//    }
//}
