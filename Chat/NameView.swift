//
//  NameView.swift
//  Chat
//
//  Created by Atsushi on 2021/09/07.
//

import SwiftUI
import NCMB

struct NameView: View {
    @Binding var displayName: String
    @State var name = ""
    var body: some View {
        VStack {
            TextField("お名前", text: $name) // 2
                .padding(10)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(5)
            Button("登録する", action: {
                update()
            })
        }
    }
    
    func update() {
        let user = NCMBUser.currentUser
        user?["displayName"] = name
        _ = user?.save()
        displayName = name
    }
}
