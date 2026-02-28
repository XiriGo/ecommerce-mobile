import SwiftUI

// MARK: - XGLoadingView

struct XGLoadingView: View {
    var body: some View {
        VStack(spacing: XGSpacing.base) {
            ProgressView()
                .controlSize(.large)

            Text(String(localized: "common_loading"))
                .font(XGTypography.bodyMedium)
                .foregroundStyle(XGColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - XGLoadingIndicator

struct XGLoadingIndicator: View {
    var body: some View {
        ProgressView()
            .controlSize(.regular)
            .frame(maxWidth: .infinity)
            .padding(.vertical, XGSpacing.md)
    }
}

// MARK: - Previews

#Preview("XGLoadingView Full Screen") {
    XGLoadingView()
}

#Preview("XGLoadingIndicator Inline") {
    VStack {
        Text("List content above")
        XGLoadingIndicator()
    }
}
