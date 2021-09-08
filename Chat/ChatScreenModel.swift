//
//  ChatScreenModel.swift
//  Chat
//
//  Created by Atsushi on 2021/09/07.
//

import Combine
import Foundation
import NCMB

final class ChatScreenModel: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    @Published var messages: [NCMBObject] = []
    
    // WebSocket（今回はPieSocket）への接続を行います
    func connect() {
        let channelId = "1"
        let url = URL(string: "wss://free3.piesocket.com/v3/\(channelId)?api_key=\(KeyManager().getValue(key: "PieSocketApiKey")!)&notify_self")!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        // メッセージを受け取った時に呼ばれるハンドラ
        webSocketTask?.receive(completionHandler: onReceive)
        webSocketTask?.resume()
    }
    
    // 接続解除時に実行する関数
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    // メッセージを受け取った時に呼ばれる関数
    private func onReceive(incoming: Result<URLSessionWebSocketTask.Message, Error>) {
        switch incoming {
        case let .success(message): // 正しく受け取れている場合
            // メッセージの種類に応じて処理分け（今回はテキストのみ）
            switch message {
            case let .string(msg):
                // テキストをデータ化
                let data: Data =  msg.data(using: String.Encoding.utf8)!
                do {
                    // JSONとしてパース
                    let params = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, String>
                    // NCMBObjectとして作り直し
                    let obj = NCMBObject(className: "Chat")
                    obj["displayName"] = params["displayName"]
                    obj.objectId = params["objectId"]
                    obj["userId"] = params["userId"]
                    obj["body"] = params["body"]
                    obj["createDate"] = params["createDate"]
                    DispatchQueue.main.async {
                        self.messages.append(obj) // メッセージの配列に追加
                    }
                } catch {
                }
                break
            case let .data(data):
                print(data)
            @unknown default:
                print("unknown \(message)")
            }
            break
        case let .failure(err):
            print(err)
            break
        }
        webSocketTask?.receive(completionHandler: onReceive)
    }
    
    // NCMBObjectをDictionaryにして、JSON文字列にする関数
    private func makeMessage(obj: NCMBObject) -> String {
        // Dictionaryの準備
        var json = Dictionary<String, String>()
        json["objectId"] = obj.objectId! // チャットメッセージのobjectId
        if let body: String = obj["body"] { // チャットメッセージ
            json["body"] = body
        }
        if let userId: String = obj["userId"] { // チャットの送信者
            json["userId"] = userId
        }
        if let displayName: String = obj["displayName"] { // 表示名
            json["displayName"] = displayName
        }
        // 投稿日時
        let formatter = ISO8601DateFormatter()
        json["createDate"] = formatter.string(from: Date())
        do {
            // Dictionaryを文字列化
            let jsonData = try JSONSerialization.data(withJSONObject: json)
            return String(bytes: jsonData, encoding: .utf8)!
        } catch (let e) {
            print(e)
        }
        return "" // エラーの場合
    }
    
    // チャットメッセージを送信する関数
    func send(obj: NCMBObject) {
        // NCMBObjectからメッセージを作成して、送信
        webSocketTask?.send(.string(makeMessage(obj: obj)), completionHandler: { error in
            if error != nil {
                // エラーの場合
                print(error)
            }
        })
    }
}
