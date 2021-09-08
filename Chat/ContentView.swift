//
//  ContentView.swift
//  Chat
//
//  Created by Atsushi on 2021/09/07.
//

import SwiftUI
import NCMB

struct ContentView: View {
    private var user = NCMBUser.currentUser
    @State private var displayName = ""
    
    var body: some View {
        VStack {
            if displayName != "" {
                ChatView()
            } else {
                NameView(displayName: $displayName)
            }
        }.onAppear() {
            setDisplayName()
        }
    }
    
    func setDisplayName() -> Void {
        if let name: String = user!["displayName"] {
            displayName = name
        }
    }
}
