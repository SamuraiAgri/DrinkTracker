//
//  AdMobManager.swift
//  DrinkTracker
//
//  Created on 2025/12/17.
//

import Foundation
import GoogleMobileAds

/// AdMobの初期化と広告IDを管理するクラス
class AdMobManager {
    static let shared = AdMobManager()
    
    // MARK: - App ID
    static let appID = "ca-app-pub-8001546494492220~2824472839"
    
    // MARK: - Ad Unit IDs
    struct AdUnitID {
        // バナー広告
        static let banner = "ca-app-pub-8001546494492220/4738397687"
        
        // インタースティシャル広告
        static let interstitial = "ca-app-pub-8001546494492220/5120722828"
    }
    
    private init() {}
    
    /// AdMobを初期化
    func initialize() {
        GADMobileAds.sharedInstance().start { status in
            print("AdMob initialized with status: \(status.adapterStatusesByClassName)")
        }
    }
}
