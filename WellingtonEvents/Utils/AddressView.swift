import SwiftUI
import DesignLibrary

struct AddressView: View {
    let venue: String

    var body: some View {
        HStack(alignment: .top) {
            Text("Address:")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textSecondary)
            Text(venue)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.all, .small)
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(.cardBackground)
                .roundedCorner(8, corners: [.bottomLeft, .bottomRight])
        }
    }
}
