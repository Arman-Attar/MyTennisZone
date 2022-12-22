//
//  EventBannerView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-10-25.
//

import SwiftUI
import SDWebImageSwiftUI

struct EventBannerView: View {
    var leagueEvent: League? = nil
    var tournamentEvent: Tournament? = nil
    @State var pos: Int?
    var body: some View {
        VStack{
            if leagueEvent != nil{
               leagueImageField
                leagueSummaryField
                Divider().padding(.horizontal)
            }
            else if tournamentEvent != nil {
                tournyImageField
                tournySummaryField
                Divider().padding(.horizontal)
            }
        }
    }
}

//struct EventBannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventBannerView()
//    }
extension EventBannerView {
    private var leagueImageField: some View {
        VStack{
            if leagueEvent!.bannerURL == "" {
                Image("league")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.height/4)
                    .clipShape(Rectangle())
                    .padding(.horizontal)
            }
            else {
                WebImage(url: URL(string: leagueEvent!.bannerURL!))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.height/4)
                    .clipShape(Rectangle())
                    .padding(.horizontal)
            }
        }
    }
    private var leagueSummaryField: some View{
        HStack {
            Text(leagueEvent?.name.capitalized ?? "")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "person.fill")
                .foregroundColor(.gray)
            Text("\(leagueEvent!.players.count)")
                .foregroundColor(.black)
            Rectangle().frame(width: 1, height: 20)
            Text("Position: \(pos!)")
                .foregroundColor(.black)
        }
        .padding()
    }
    private var tournyImageField: some View {
        VStack{
            if tournamentEvent!.bannerURL == ""{
            Image("league")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.height/4)
                .clipShape(Rectangle())
                .padding(.horizontal)
            }
            else {
                WebImage(url: URL(string: tournamentEvent!.bannerURL!))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.height/4)
                    .clipShape(Rectangle())
                    .padding(.horizontal)
            }
    }
    }
    private var tournySummaryField: some View {
        HStack {
            Text(tournamentEvent?.name.capitalized ?? "")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "person.fill")
                .foregroundColor(.gray)
            Text("\(tournamentEvent!.players.count)")
                .foregroundColor(.black)
            Rectangle().frame(width: 1, height: 20)
            Text("\(tournamentEvent!.mode)")
                .foregroundColor(.black)
        }
        .padding()
    }
}
