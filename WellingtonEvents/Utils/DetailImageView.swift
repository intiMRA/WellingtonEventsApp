import SwiftUI
import DesignLibrary

struct DetailImageView: View {
    let url: String

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray)
                    .overlay {
                        ProgressView()
                            .foregroundStyle(.text)
                    }
                    .frame(height: 250)
            case .success(let image):
                image
                    .resizable()
            case .failure(let error):
                Image(.noImageAtTime)
                    .resizable()
                    .foregroundStyle(.textSecondary)
                    .onAppear {
                        print(error)
                    }
            @unknown default:
                Rectangle()
                    .fill(.gray)
                    .frame(height: 250)
            }
        }
        .frame(maxWidth: .infinity)
        .scaledToFill()
        .roundedShadow()
    }
}
