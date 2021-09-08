//
//  ChatMessageRow.swift
//  Chat
//
//  Created by Atsushi on 2021/09/07.
//

import SwiftUI
import NCMB

struct ChatMessageRow: View {
    @State var message: NCMBObject
    // 日付のフォーマット（時刻のみ）
    static private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter
        }()
    
    var body: some View {
        HStack {
            if isMe() {
                Spacer()
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(displayName())
                        .fontWeight(.bold)
                        .font(.system(size: 12))
                    
                    Text(Self.dateFormatter.string(from: createDate()))
                        .font(.system(size: 10))
                        .opacity(0.7)
                }
                
                Text(chatMessage())
            }
            .foregroundColor(isMe() ? .white : .black)
            .padding(10)
            .background(isMe() ? Color.blue : Color(white: 0.95))
            .cornerRadius(5)
            
            if !isMe() {
                Spacer()
            }
        }
    }
    
    func isMe() -> Bool {
        if let userId: String = message["userId"] {
            let user = NCMBUser.currentUser
            return userId == user!.objectId
        }
        return false
    }
    
    func displayName() -> String {
        if let displayName: String = message["displayName"] {
            return displayName
        }
        return ""
    }
    
    func createDate() -> Date {
        if let createDate: String = message["createDate"] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return dateFormatter.date(from: createDate)!
        }
        return Date()
    }
    
    func chatMessage() -> String {
        if let body: String = message["body"] {
            return body
        }
        return ""
    }
}
