import SwiftUI
import UIKit

struct PhotoCover: View {
    let image: UIImage
    let title: String?
    let size: CardSize

    private var titleSize: CGFloat { size == .small ? 15 : 18 }

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
            .overlay(alignment: .bottom) {
                if let title {
                    caption(title)
                }
            }
            .clipped()
    }

    private func caption(_ title: String) -> some View {
        Text(title)
            .dasto(titleSize)
            .foregroundStyle(Color.white)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(16)
            .padding(.top, 28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [Color.black.opacity(0), Color.black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
            )
    }
}
