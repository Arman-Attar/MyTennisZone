//
//  ContentView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-04-28.
//

import SwiftUI

struct ContentView: View {
    @State var isSignedIn = false
    var body: some View {
        ZStack{
            //if isSignedIn { SHOW HOMEPAGE }
            //else 
            signIn().colorScheme(.light)
        }
      
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
