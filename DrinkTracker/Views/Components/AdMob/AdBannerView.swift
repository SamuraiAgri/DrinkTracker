//
//  AdBannerView.swift
//  DrinkTracker
//
//  Created on 2025/12/17.
//

import SwiftUI
import GoogleMobileAds

/// バナー広告を表示するSwiftUIビュー
struct AdBannerView: View {
    @State private var bannerHeight: CGFloat = 0
    
    init() {
        print("🎯 AdBannerView: Initialized")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 常にBannerViewを表示し、高さが0の場合は見えないだけにする
            BannerViewRepresentable(bannerHeight: $bannerHeight)
                .frame(height: max(50, bannerHeight)) // 最小50ポイントを確保
                .background(Color.gray.opacity(0.1)) // デバッグ用の背景色
        }
        .onAppear {
            print("🎯 AdBannerView: Appeared in view hierarchy")
        }
    }
}

/// UIViewRepresentableでGADBannerViewをSwiftUIに統合
struct BannerViewRepresentable: UIViewRepresentable {
    @Binding var bannerHeight: CGFloat
    
    func makeUIView(context: Context) -> GADBannerView {
        print("🎯 AdBanner: Creating banner view")
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = AdMobManager.AdUnitID.banner
        
        print("📱 AdBanner: Using ad unit ID: \(AdMobManager.AdUnitID.banner)")
        
        // ルートビューコントローラーを取得
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
            print("✅ AdBanner: Root view controller set")
        } else {
            print("❌ AdBanner: Failed to get root view controller")
        }
        
        bannerView.delegate = context.coordinator
        
        let request = GADRequest()
        print("📡 AdBanner: Loading ad request...")
        bannerView.load(request)
        
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // 更新処理は不要
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(bannerHeight: $bannerHeight)
    }
    
    class Coordinator: NSObject, GADBannerViewDelegate {
        @Binding var bannerHeight: CGFloat
        
        init(bannerHeight: Binding<CGFloat>) {
            _bannerHeight = bannerHeight
        }
        
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("✅ AdBanner: Banner ad loaded successfully!")
            print("📏 AdBanner: Banner height: \(bannerView.adSize.size.height)")
            DispatchQueue.main.async {
                self.bannerHeight = bannerView.adSize.size.height
            }
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ AdBanner: Failed to load banner ad")
            print("❌ Error: \(error.localizedDescription)")
            print("❌ Error Code: \((error as NSError).code)")
            print("❌ Error Domain: \((error as NSError).domain)")
            DispatchQueue.main.async {
                self.bannerHeight = 0
            }
        }
        
        func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
            print("📊 AdBanner: Impression recorded")
        }
        
        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
            print("🎬 AdBanner: Will present screen")
        }
        
        func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
            print("👋 AdBanner: Will dismiss screen")
        }
        
        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
            print("✋ AdBanner: Did dismiss screen")
        }
    }
}

#Preview {
    AdBannerView()
}
