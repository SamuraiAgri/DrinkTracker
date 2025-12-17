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
        let request = GADRequest()
        
        GADInterstitialAd.load(
            withAdUnitID: AdMobManager.AdUnitID.interstitial,
            request: request
        ) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                self?.isAdReady = false
                return
            }
            
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
            self?.isAdReady = true
            print("Interstitial ad loaded successfully")
        }
    }
    
    /// 広告を表示（頻度制限付き）
    /// - Returns: 広告が表示されたかどうか
    @discardableResult
    func showAdIfAvailable() -> Bool {
        adDisplayCount += 1
        
        // 頻度制限: displayFrequency回に1回だけ表示
        guard adDisplayCount % displayFrequency == 0 else {
            print("Ad skipped due to frequency limit (\(adDisplayCount))")
            return false
        }
        
        guard let interstitialAd = interstitialAd,
              isAdReady,
              let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            print("Interstitial ad not ready or no root view controller")
            loadAd() // 次回のために読み込み
            return false
        }
        
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
        print("Interstitial ad recorded impression")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Failed to present interstitial ad: \(error.localizedDescription)")
        loadAd() // 失敗したら再読み込み
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Interstitial ad will present")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Interstitial ad dismissed")
        isAdReady = false
        loadAd() // 次の広告を読み込む
    }
}
