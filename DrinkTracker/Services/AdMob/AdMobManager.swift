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
    
    // MARK: - 開発モード（テスト広告を使用）
    static let isDevelopmentMode = true
    
    // MARK: - Ad Unit IDs
    struct AdUnitID {
        // バナー広告
        static let banner: String = {
            if isDevelopmentMode {
                return "ca-app-pub-3940256099942544/2934735716" // テスト用
            }
            return "ca-app-pub-8001546494492220/4738397687" // 本番用
        }()
        
        // インタースティシャル広告
        static let interstitial: String = {
            if isDevelopmentMode {
                return "ca-app-pub-3940256099942544/4411468910" // テスト用
            }
            return "ca-app-pub-8001546494492220/5120722828" // 本番用
        }()
    }
    
    private init() {}
    
    /// AdMobを初期化
    func initialize() {
        // テストデバイスとしてシミュレータを追加
        let testDeviceIdentifiers = [GADSimulatorID]
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = testDeviceIdentifiers
        
        GADMobileAds.sharedInstance().start { status in
            print("✅ AdMob initialized successfully")
            print("📱 Test mode: \(AdMobManager.isDevelopmentMode)")
            for (adapter, adapterStatus) in status.adapterStatusesByClassName {
                print("  - \(adapter): \(adapterStatus.state.rawValue)")
            }
        }
    }
}
