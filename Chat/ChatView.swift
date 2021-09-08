//
//  ChatView.swift
//  Chat
//
//  Created by Atsushi on 2021/09/07.
//

import SwiftUI
import NCMB

struct ChatView: View {
    @State private var message = ""
    @ObservedObject var chat = ChatScreenModel()

    var body: some View {
        VStack {
            // Chat history.
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(spacing: 8) {
                        ForEach(chat.messages, id: \.objectId ) { message in
                            ChatMessageRow(message: message)
                        }
                    }
                    .onChange(of: chat.messages.count) { _ in
                        scrollToLastMessage(proxy: proxy)
                    }
                }
            }

            // Message field.
            HStack {
                TextField("Message", text: $message) // 2
                    .padding(10)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(5)
                
                Button(action: {
                    send()
                }) { // 3
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.system(size: 20))
                }
                .padding()
                .disabled(message.isEmpty) // 4
            }
            .padding()
        }
        .onAppear() {
            chat.connect()
            getPastMessages()
        }
    }
    
    func getMessage(message: NCMBObject) -> String {
        if let body: String = message["body"] {
            return body
        }
        return ""
    }
    
    func getPastMessages() {
        var query = NCMBQuery.getQuery(className: "Chat")
        query.order = ["createDate"]
        query.limit = 20
        query.findInBackground(callback: { result in
            switch result {
            case let .success(ary):
                DispatchQueue.main.async {
                    chat.messages = ary
                }
                break
            case .failure(_): break
            }
        })
    }
    
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        if let lastMessage = chat.messages.last { // 4
            withAnimation(.easeOut(duration: 0.4)) {
                proxy.scrollTo(lastMessage.objectId, anchor: .bottom) // 5
            }
        }
    }
    
    func send() {
        let obj = NCMBObject(className: "Chat")
        obj["body"] = message
        let user = NCMBUser.currentUser
        obj["userId"] = user!.objectId
        
        var acl = NCMBACL.empty
        acl.put(key: "*", readable: true, writable: false)
        acl.put(key: user!.objectId!, readable: true, writable: true)
        obj.acl = acl
        if let displayName: String = user!["displayName"] {
            obj["displayName"] = displayName
        }
        _ = obj.save()
        message = ""
        chat.send(obj: obj)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
