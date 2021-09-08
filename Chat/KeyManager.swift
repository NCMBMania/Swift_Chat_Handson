//
//  KeyManager.swift
//  forum
//
//  Created by Atsushi on 2021/08/02.
//  参考：API keyを.plistにStringで保存して隠す(例: Google Maps Api) - Qiita
//  https://qiita.com/Saayaman/items/c50000e6103358c8c4d6
//

import Foundation

struct KeyManager {

    private let keyFilePath = Bundle.main.path(forResource: "APIKey", ofType: "plist")

    func getKeys() -> NSDictionary? {
        guard let keyFilePath = keyFilePath else {
            return nil
        }
        return NSDictionary(contentsOfFile: keyFilePath)
    }

    func getValue(key: String) -> AnyObject? {
        guard let keys = getKeys() else {
            return nil
        }
        return keys[key]! as AnyObject
    }
}
