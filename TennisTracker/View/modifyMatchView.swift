//
//  modifyMatchView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-31.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct modifyMatchView: View {
    @StateObject var matchVM: MatchViewModel
    @EnvironmentObject var userVm: UserViewModel
    @State var isLeague = true
    @Environment(\.dismiss) var dismiss
    @State var matchOngoing = true
    @State var winner = ""
    @State var showWinnerSheet = false
    @State var player1SetScore = 0
    @State var player2SetScore = 0
    @State var showSetSheet = false
    @State var set: [Set] = []
    @State var showAlert = false
    @State var deleteTapped = false
    @State var confirmDeleteAlert = false
    var body: some View {
        ZStack{
            VStack{
                Form{
                    Text("Modify Match")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    vsSection
                    HStack{
                        Text("Match Date:")
                        Spacer()
                        Text("\(matchVM.currentMatch?.date ?? "")")
                    }.padding()
                    HStack{
                        Text("First To:")
                        Spacer()
                        Text("\(matchVM.currentMatch?.setsToWin ?? 2)")
                    }.padding()
                    Toggle("Match Ongoing?", isOn: $matchOngoing).padding()
                    setResultField
                    if !matchOngoing {
                        HStack{
                            Text("Match Winner:").padding()
                            Spacer()
                            if winner == "" {
                                Image("profile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .shadow(radius: 20)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        showWinnerSheet.toggle()
                                    }
                            }
                            else {
                                WebImage(url: URL(string: winner == matchVM.currentMatch!.player1DisplayName ? matchVM.currentMatch!.player1Pic : matchVM.currentMatch!.player2Pic))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .shadow(radius: 20)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        showWinnerSheet.toggle()
                                    }
                            }
                        }
                    }
                    Group{
                        buttons
                        if isLeague{
                            if matchVM.admin == userVm.user!.uid{
                                deleteButton
                            }
                        }
                    }
                }.alert(isPresented: $showAlert){
                    Alert(title: Text("Error!"), message: Text("Required number of sets not reached"), dismissButton: .default(Text("Got it!")))
                }
                .confirmationDialog("Settings", isPresented: $deleteTapped) {
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
                            }
                            dismiss()
                        }
                    }, secondaryButton: .cancel())
                }
            }.task {
                await matchVM.getCurrentMatch()
            }
            if showSetSheet{
                Rectangle().ignoresSafeArea().opacity(0.5)
                addSetBottomSheet
            }
            if showWinnerSheet{
                Rectangle().ignoresSafeArea().opacity(0.5)
                addWinnerBottomSheet
            }
        }
    }
}

//struct modifyMatchView_Previews: PreviewProvider {
//    static var previews: some View {
//        modifyMatchView()
//    }
//}

extension modifyMatchView{
    
    private var vsSection: some View{
        HStack{
            VStack
            {
                if matchVM.currentMatch?.player1Pic ?? "" != "" {
                    WebImage(url: URL(string: matchVM.currentMatch!.player1Pic))
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
                
                Text(matchVM.currentMatch?.player1DisplayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
            Text("VS")
                .font(.system(size: 20, weight: .bold))
                .offset(y: -25)
            
            VStack{
                if matchVM.currentMatch?.player2Pic ?? "" != "" {
                    WebImage(url: URL(string: matchVM.currentMatch!.player2Pic))
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
                
                
                Text(matchVM.currentMatch?.player2DisplayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
        }.padding(.vertical)
    }
    
    private var setPicker: some View {
        HStack{
            Text("First To:").padding()
            ForEach(0..<2) { index in
                HStack {
                    Image(systemName: matchVM.currentMatch!.setsToWin == 2*index+3 ? "circle.circle.fill" : "circle.circle").font(.system(size: 20, weight: .semibold)).foregroundColor(Color.black)
                    Text("\(2*index+3) Sets").font(.system(size: 15, weight: .regular))
                }.padding(.leading)
            }
        }
    }
    
    private var setResultField: some View {
        VStack {
            HStack{
                Text("Add Set Results").padding(.horizontal)
                Spacer()
                Button {
                    player1SetScore = 0
                    player2SetScore = 0
                    showSetSheet.toggle()
                } label: {
                    Image(systemName: "plus").padding(.horizontal)
                }
            }
            HStack{
                if !matchVM.currentSets.isEmpty {
                    ForEach(matchVM.currentSets, id: \.id) { set in
                        Text("\(set.player1Points)-\(set.player2Points)").font(.headline).fontWeight(.bold)
                        Divider()
                    }
                }
            }
        }
    }
    
    private var addSetBottomSheet: some View {
        ZStack {
            NavigationView {
                Form{
                    Text("Enter Set Result").fontWeight(.bold).padding().zIndex(1.0)
                    HStack{
                        if matchVM.currentMatch?.player1Pic ?? "" != ""{
                            WebImage(url: URL(string: matchVM.currentMatch!.player1Pic))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                            
                        }
                        else {
                            Image("profile")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                            
                        }
                        
                        Text("VS")
                            .font(.system(size: 20, weight: .bold)).zIndex(1.0)
                        
                        
                        if matchVM.currentMatch?.player2Pic ?? "" != "" {
                            WebImage(url: URL(string: matchVM.currentMatch!.player2Pic))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                        }
                        else {
                            Image("profile")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                            
                        }
                    }
                    Picker("\(matchVM.currentMatch?.player1DisplayName ?? "Oponent") Score:", selection: $player1SetScore) {
                        ForEach(0..<8){ set in
                            Text("\(set)")
                        }
                    }.padding()
                    
                    Picker("\(matchVM.currentMatch?.player2DisplayName ?? "Oponent") Score:", selection: $player2SetScore) {
                        ForEach(0..<8){ set in
                            Text("\(set)")
                        }
                    }.padding()
                    
                    HStack{
                        Text("Cancel")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: UIScreen.main.bounds.size.width/4)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                            .onTapGesture {
                                showSetSheet.toggle()
                            }
                        Spacer()
                        Text("Add")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: UIScreen.main.bounds.size.width/4)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                            .onTapGesture {
                                Task{
                                    await matchVM.addSet(p1Points: player1SetScore, p2Points: player2SetScore, set: nil)
                                    showSetSheet.toggle()
                                }
                            }
                    }.padding()
                }.navigationBarHidden(true)
            }
            
        }.cornerRadius(20)
            .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 1.7)
            .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 300)
    }
    
    private var addWinnerBottomSheet: some View {
        ZStack {
            Form{
                Text("Select The Winner").fontWeight(.bold).padding()
                HStack{
                    if matchVM.currentMatch?.player1Pic ?? "" != "" {
                        WebImage(url: URL(string: matchVM.currentMatch!.player1Pic))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                            .padding()
                    }
                    else {
                        Image("profile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                            .padding()
                    }
                    Text(matchVM.currentMatch?.player2DisplayName ?? "").font(.headline).padding()
                }.onTapGesture {
                    winner = matchVM.currentMatch!.player1DisplayName
                    showWinnerSheet.toggle()
                }
                HStack{
                    if matchVM.currentMatch?.player2Pic ?? "" != "" {
                        WebImage(url: URL(string: matchVM.currentMatch!.player2Pic))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                            .padding()
                        
                    }
                    else {
                        Image("profile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                            .padding()
                        
                    }
                    Text(matchVM.currentMatch?.player2DisplayName ?? "").font(.headline).padding()
                }.onTapGesture {
                    winner = matchVM.currentMatch!.player2DisplayName
                    showWinnerSheet.toggle()
                }
                HStack{
                    Spacer()
                    Text("Cancel")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(width: UIScreen.main.bounds.size.width/1.5)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                        .onTapGesture {
                            showWinnerSheet.toggle()
                        }
                }
            }.cornerRadius(20)
                .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 1.7)
                .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 300)
        }
    }
    
    private var buttons: some View{
        HStack{
            Text("Cancel")
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: UIScreen.main.bounds.size.width/4)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                .onTapGesture {
                    dismiss()
                }
            Spacer()
            Text("Update")
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: UIScreen.main.bounds.size.width/4)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                .onTapGesture {
                    if !matchOngoing && !verifyScore(){
                        showAlert = true
                    }
                    else{
                        Task {
                            await matchVM.updateMatch(ongoing: matchOngoing, player1DisplayName: matchVM.currentMatch!.player1DisplayName, player2DisplayName: matchVM.currentMatch!.player2DisplayName, matchID: matchVM.currentMatch!.id, matchType: matchVM.currentMatch!.matchType)
                            dismiss()
                        }
                    }
                }
        }.padding()
    }
    
    private func verifyScore() -> Bool{
        var player1Score = 0
        var player2Score = 0
        for set in matchVM.currentSets{
            if set.player1Points > set.player2Points {
                player1Score += 1
            }
            else{
                player2Score += 1
            }
        }
        let setsToWin = matchVM.currentMatch!.setsToWin
        if player1Score == setsToWin || player2Score == setsToWin {
            return true
        }
        else {
            return false
        }
    }
    
    private var deleteButton: some View {
        HStack{
            Spacer()
            Text("Delete Match")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.red)
                .frame(width: UIScreen.main.bounds.size.width/3)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                .onTapGesture {
                    deleteTapped.toggle()
                }
            Spacer()
        }.padding()
    }
}

