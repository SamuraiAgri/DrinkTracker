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
    
    var body: some View {
        VStack(spacing: 0) {
            if bannerHeight > 0 {
                BannerViewRepresentable(bannerHeight: $bannerHeight)
                    .frame(height: bannerHeight)
            }
        }
        .background(Color(.systemBackground))
    }
}

/// UIViewRepresentableでGADBannerViewをSwiftUIに統合
struct BannerViewRepresentable: UIViewRepresentable {
    @Binding var bannerHeight: CGFloat
    
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = AdMobManager.AdUnitID.banner
        
        // ルートビューコントローラーを取得
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
        }
        
        bannerView.delegate = context.coordinator
        bannerView.load(GADRequest())
        
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
            print("Banner ad loaded successfully")
            DispatchQueue.main.async {
                self.bannerHeight = bannerView.adSize.size.height
            }
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("Banner ad failed to load: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.bannerHeight = 0
            }
        }
    }
}

#Preview {
    AdBannerView()
}
