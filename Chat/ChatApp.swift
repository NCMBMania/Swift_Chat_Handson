//
//  ChatApp.swift
//  Chat
//
//  Created by Atsushi on 2021/09/07.
//

import SwiftUI
import NCMB

@main
struct ChatApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { scene in
            switch scene {
            case .active:
                // キーの設定
                let applicationKey = KeyManager().getValue(key: "ApplicationKey") as! String
                let clientKey = KeyManager().getValue(key: "ClientKey") as! String
                // 認証チェック
                checkAuth()
                // セッションの有効性チェック
                if checkSession() == false {
                    // セッションが不正なら再度認証チェック
                    checkAuth()
                }
            case .background: break
            case .inactive: break
            default: break
            }
        }
    }
    
    func checkAuth() -> Void {
    }
    
    // セッションの有効性をチェックする関数
    func checkSession() -> Bool {
        return true
    }
}
