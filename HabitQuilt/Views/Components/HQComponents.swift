import SwiftUI

struct HQText: View {
    enum Style {
        case title, headline, body, callout, caption
    }

    let draft: DraftString
    var style: Style = .body

    var body: some View {
        Text(draft)
            .font(font)
            .foregroundStyle(DesignTokens.PaperUI.textPrimary)
            .draftHighlight()
    }

    private var font: Font {
        switch style {
        case .title: DesignTokens.TypeScale.title
        case .headline: DesignTokens.TypeScale.headline
        case .body: DesignTokens.TypeScale.body
        case .callout: DesignTokens.TypeScale.callout
        case .caption: DesignTokens.TypeScale.caption
        }
    }
}

struct HQButton: View {
    enum Kind {
        case primary
        case secondary
    }

    let title: DraftString
    var kind: Kind = .primary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignTokens.TypeScale.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Space.sm)
                .padding(.horizontal, DesignTokens.Space.md)
                .background(background)
                .foregroundStyle(foreground)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                        .stroke(DesignTokens.PaperUI.border, lineWidth: kind == .secondary ? 1 : 0)
                )
                .draftHighlight()
        }
        .buttonStyle(.plain)
    }

    private var background: Color {
        switch kind {
        case .primary: DesignTokens.PaperUI.accent
        case .secondary: DesignTokens.PaperUI.surface
        }
    }

    private var foreground: Color {
        switch kind {
        case .primary: Color.white
        case .secondary: DesignTokens.PaperUI.textPrimary
        }
    }
}

struct HQIconButton: View {
    let systemName: String
    var accessibilityLabel: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.body.weight(.semibold))
                .foregroundStyle(DesignTokens.PaperUI.textPrimary)
                .frame(width: 44, height: 44)
                .background(DesignTokens.PaperUI.surface)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                        .stroke(DesignTokens.PaperUI.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct HQTextField: View {
    let placeholder: DraftString
    @Binding var text: String

    var body: some View {
        TextField(placeholder.text, text: $text)
            .font(DesignTokens.TypeScale.body)
            .padding(DesignTokens.Space.sm)
            .background(DesignTokens.PaperUI.surface)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .stroke(DesignTokens.PaperUI.border, lineWidth: 1)
            )
            .draftHighlight()
    }
}

struct HQToggle: View {
    let title: DraftString
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(DesignTokens.TypeScale.body)
                .foregroundStyle(DesignTokens.PaperUI.textPrimary)
                .draftHighlight()
        }
        .tint(DesignTokens.PaperUI.accent)
    }
}

struct HQListRow: View {
    let title: DraftString
    var subtitle: DraftString? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Space.xxs) {
                    Text(title)
                        .font(DesignTokens.TypeScale.body)
                        .foregroundStyle(DesignTokens.PaperUI.textPrimary)
                        .draftHighlight()
                    if let subtitle {
                        Text(subtitle)
                            .font(DesignTokens.TypeScale.caption)
                            .foregroundStyle(DesignTokens.PaperUI.textSecondary)
                            .draftHighlight()
                    }
                }
                Spacer()
                if action != nil {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(DesignTokens.PaperUI.textSecondary)
                }
            }
            .padding(.vertical, DesignTokens.Space.sm)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}
