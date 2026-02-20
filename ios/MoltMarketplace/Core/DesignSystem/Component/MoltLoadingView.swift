import SwiftUI

// MARK: - MoltLoadingView

struct MoltLoadingView: View {
    var body: some View {
        VStack(spacing: MoltSpacing.base) {
            ProgressView()
                .controlSize(.large)

            Text(String(localized: "common_loading"))
                .font(MoltTypography.bodyMedium)
                .foregroundStyle(MoltColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - MoltLoadingIndicator

struct MoltLoadingIndicator: View {
    var body: some View {
        ProgressView()
            .controlSize(.regular)
            .frame(maxWidth: .infinity)
            .padding(.vertical, MoltSpacing.md)
    }
}

// MARK: - Previews

#Preview("MoltLoadingView Full Screen") {
    MoltLoadingView()
}

#Preview("MoltLoadingIndicator Inline") {
    VStack {
        Text("List content above")
        MoltLoadingIndicator()
    }
}
