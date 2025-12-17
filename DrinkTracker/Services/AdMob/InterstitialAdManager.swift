//
//  InterstitialAdManager.swift
//  DrinkTracker
//
//  Created on 2025/12/17.
//

import Foundation
import GoogleMobileAds
import UIKit

/// インタースティシャル広告を管理するクラス
/// 頻度制限機能付き（3回に1回程度表示）
class InterstitialAdManager: NSObject, ObservableObject {
    static let shared = InterstitialAdManager()
    
    @Published var isAdReady = false
    
    private var interstitialAd: GADInterstitialAd?
    private var adDisplayCount = 0
    private let displayFrequency = 3 // 3回に1回表示
    
    private override init() {
        super.init()
        loadAd()
    }
    
    /// 広告を読み込む
    func loadAd() {
        print("📡 Interstitial: Loading ad...")
        print("📱 Interstitial: Using ad unit ID: \(AdMobManager.AdUnitID.interstitial)")
        
        let request = GADRequest()
        
        GADInterstitialAd.load(
            withAdUnitID: AdMobManager.AdUnitID.interstitial,
            request: request
        ) { [weak self] ad, error in
            if let error = error {
                print("❌ Interstitial: Failed to load ad")
                print("❌ Error: \(error.localizedDescription)")
                print("❌ Error Code: \((error as NSError).code)")
                print("❌ Error Domain: \((error as NSError).domain)")
                self?.isAdReady = false
                return
            }
            
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
            self?.isAdReady = true
            print("✅ Interstitial: Ad loaded successfully")
        }
    }
    
    /// 広告を表示（頻度制限付き）
    /// - Returns: 広告が表示されたかどうか
    @discardableResult
    func showAdIfAvailable() -> Bool {
        adDisplayCount += 1
        
        print("🎲 Interstitial: Show attempt #\(adDisplayCount)")
        
        // 頻度制限: displayFrequency回に1回だけ表示
        guard adDisplayCount % displayFrequency == 0 else {
            print("⏭️ Interstitial: Skipped (frequency limit \(adDisplayCount)/\(displayFrequency))")
            return false
        }
        
        print("🎯 Interstitial: Frequency check passed")
        
        guard isAdReady else {
            print("❌ Interstitial: Ad not ready")
            loadAd() // 次回のために読み込み
            return false
        }
        
        guard let interstitialAd = interstitialAd else {
            print("❌ Interstitial: Ad object is nil")
            loadAd()
            return false
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ Interstitial: No root view controller")
            loadAd()
            return false
        }
        
        print("🎬 Interstitial: Presenting ad...")
        interstitialAd.present(fromRootViewController: rootViewController)
        return true
    }
    
    /// 表示カウントをリセット（テスト用）
    func resetDisplayCount() {
        adDisplayCount = 0
    }
}

// MARK: - GADFullScreenContentDelegate
extension InterstitialAdManager: GADFullScreenContentDelegate {
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("📊 Interstitial: Impression recorded")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Interstitial: Failed to present")
        print("❌ Error: \(error.localizedDescription)")
        loadAd() // 失敗したら再読み込み
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("🎬 Interstitial: Will present full screen content")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("✋ Interstitial: Ad dismissed")
        isAdReady = false
        loadAd() // 次の広告を読み込む
    }
}
