import SwiftUI
import UIKit
import HabitQuiltDomain

/// Quilt grid — oldest top, newest bottom; Photos-style column snaps.
struct QuiltView: View {
    @Bindable var store: AppStore
    @State private var columns: QuiltColumnCount = .three
    @State private var pinchColumns: CGFloat = 3

    private var tiles: [QuiltTile] {
        guard let habit = store.habit else { return [] }
        let start = DayKey(
            date: habit.createdAt,
            timeZone: .current
        )
        let end = DayKey.today(timeZone: .current)
        let offset = TimeZone.current.secondsFromGMT()
        let records = QuiltMapping.recordsByDay(
            from: store.quiltDays,
            utcOffsetSeconds: offset
        )
        return QuiltLayout.tiles(
            from: start,
            through: end,
            recordsByDay: records,
            columns: columns,
            hideBlanks: store.hideBlankDays
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Space.md) {
            HQText(draft: Copy.quiltTitle, style: .headline)

            HQToggle(title: Copy.quiltHideBlanks, isOn: Binding(
                get: { store.hideBlankDays },
                set: { store.setHideBlankDays($0) }
            ))

            if tiles.isEmpty {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(DesignTokens.PaperUI.surface)
                    .overlay {
                        HQText(draft: Copy.quiltEmpty, style: .body)
                            .padding(DesignTokens.Space.md)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                GeometryReader { geo in
                    let gap = DesignTokens.Space.xs
                    let cols = CGFloat(columns.rawValue)
                    let side = max(8, (geo.size.width - gap * (cols - 1)) / cols)
                    ScrollView {
                        LazyVGrid(
                            columns: Array(
                                repeating: GridItem(.fixed(side), spacing: gap),
                                count: columns.rawValue
                            ),
                            spacing: gap
                        ) {
                            ForEach(tiles) { tile in
                                QuiltTileView(tile: tile, side: side)
                            }
                        }
                        .padding(.bottom, DesignTokens.Space.lg)
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { scale in
                                let proposed = pinchColumns / scale
                                columns = snapColumns(proposed)
                            }
                            .onEnded { _ in
                                pinchColumns = CGFloat(columns.rawValue)
                            }
                    )
                }
            }
        }
        .padding(DesignTokens.Space.lg)
        .background(DesignTokens.PaperUI.background.ignoresSafeArea())
        .navigationTitle(Copy.quiltTitle.text)
        .navigationBarTitleDisplayMode(.inline)
        .hqPaperChrome()
        .onAppear {
            store.refresh()
            pinchColumns = CGFloat(columns.rawValue)
        }
    }

    private func snapColumns(_ value: CGFloat) -> QuiltColumnCount {
        let snaps = QuiltColumnCount.snaps
        let nearest = snaps.min(by: {
            abs(CGFloat($0.rawValue) - value) < abs(CGFloat($1.rawValue) - value)
        })
        return nearest ?? .three
    }
}

private struct QuiltTileView: View {
    let tile: QuiltTile
    let side: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                .fill(DesignTokens.PaperUI.surface)
            if let path = tile.dayRecord?.thumbPath,
               let data = ThumbnailStore.loadPNG(at: path),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            } else if tile.isBlank {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                    .stroke(DesignTokens.PaperUI.border, lineWidth: 1)
            } else {
                // Doodle exists but thumbnail missing — soft filled tile.
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                    .fill(DesignTokens.PaperUI.accent.opacity(0.15))
            }
        }
        .frame(width: side, height: side)
        .accessibilityLabel(tile.day.rawValue)
    }
}
