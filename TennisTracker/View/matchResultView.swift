//
//  addSetsView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-25.
//

import SwiftUI
import SDWebImageSwiftUI

struct matchResultView: View {
    @StateObject var matchVM: MatchViewModel
    @Environment(\.dismiss) var dismiss
    @State var settingTapped = false
    @State var confirmDeleteAlert = false
    @EnvironmentObject var userVm: UserViewModel
    @State var isLeague = true
    var body: some View {
            VStack{
                if matchVM.finishedLoading {
                    HStack{
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.left").font(.title3)
                            Text("Back").font(.title3)
                        }.padding()
                        Spacer()
                        if isLeague{
                            if matchVM.admin == userVm.user!.uid {
                                Button {
                                    settingTapped.toggle()
                                } label: {
                                    Image(systemName: "gear").font(.title3)
                                }.padding([.top, .horizontal])
                            }
                        }
                    }.padding()
                    
                    
                    HStack {
                        Text("Match Result")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                    }.padding(.bottom)
                    vsSection
                    HStack{
                        Spacer()
                        Text("Set Scores")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                    }.padding(.bottom)
                    ScrollView {
                        ForEach(matchVM.currentSets, id: \.id) { set in
                            HStack{
                                Spacer()
                                Text("\(set.player1Points)").font(.system(size: 40, weight: .black))
                                Spacer()
                                Text("-").font(.system(size: 40, weight: .black))
                                Spacer()
                                Text("\(set.player2Points)").font(.system(size: 40, weight: .black))
                                Spacer()
                            }
                            Divider().padding()
                        }
                    }
                    Spacer()
                } else {
                    ProgressView()
                }
            }
            .task {
                await matchVM.getCurrentMatch()
            }
            .confirmationDialog("Settings", isPresented: $settingTapped) {
                Button(role: .destructive) {
                    confirmDeleteAlert.toggle()
                } label: {
                    Text("Delete match")
                }

            }
            .alert(isPresented: $confirmDeleteAlert) {
                Alert(title: Text("Delete match"), message: Text("Are you sure you want to delete this match?"), primaryButton: .destructive(Text("Delete")){
                    Task {
                        if isLeague {
                            await matchVM.deleteMatch()
                            dismiss()
                        }
                    }
                    
                }, secondaryButton: .cancel())
            }
    }
}

//struct addSetsView_Previews: PreviewProvider {
//    static var previews: some View {
//        matchResultView()
//    }
//}

extension matchResultView{
    
    private var vsSection: some View{
        HStack{
            VStack
            {
                if matchVM.player1?.profilePicUrl ?? "" != ""{
                    WebImage(url: URL(string: matchVM.player1!.profilePicUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                        .padding(.top)
                        
                }
                else {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                }
                Text(matchVM.player1?.displayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
                
            }
            Text("VS")
                .font(.system(size: 20, weight: .bold))
                .offset(y: -25)
            
            VStack{
                if matchVM.player2?.profilePicUrl ?? "" != ""{
                    WebImage(url: URL(string: matchVM.player2!.profilePicUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                        .padding(.top)
                        
                }
                else {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                }
                Text(matchVM.player2?.displayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
        }.padding(.vertical)
    }
}
