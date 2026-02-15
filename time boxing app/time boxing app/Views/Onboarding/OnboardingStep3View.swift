//
//  OnboardingStep3View.swift
//  time boxing app
//
//  Created by 奥川皓大 on 2026/02/13.
//

import SwiftUI
import UniformTypeIdentifiers

struct OnboardingStep3View: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var settingsService = UserSettingsService.shared
    @State private var currentMission: Int = 0
    @State private var timeBlocks: [TutorialTimeBlock] = []
    @State private var availableTasks: [TutorialTask] = []
    @State private var slotMinutes: Int = 30
    @State private var currentPalette: ColorPalette = ColorPalette.allPalettes[0]
    @State private var showCelebration = false
    
    var onNext: () -> Void
    var onBack: (() -> Void)?
    
    private let missions: [TutorialMission] = [
        TutorialMission(
            id: 1,
            title: "タスクを配置する",
            description: "左のタスクをカレンダーにドラッグ＆ドロップ",
            requiredAction: .placeTask
        ),
        TutorialMission(
            id: 2,
            title: "時間を調整する",
            description: "右下のハンドルをドラッグして時間を調整",
            requiredAction: .resizeTask
        ),
        TutorialMission(
            id: 3,
            title: "位置を移動する",
            description: "長押ししてドラッグで時間をずらす",
            requiredAction: .moveTask
        )
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            // ミッション表示（コンパクト）
            CompactMissionCard(mission: missions[currentMission])
                .padding(.horizontal, 20)
                .padding(.top, 16)
            
            // メインコンテンツ
            GeometryReader { geometry in
                HStack(spacing: 12) {
                    // 左: タスクリスト
                    VStack(alignment: .leading, spacing: 8) {
                        Text("タスク")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(availableTasks) { task in
                                    TaskItemView(task: task)
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width * 0.25)
                    
                    // 右: カレンダー
                    TimelineCalendarView(
                        timeBlocks: $timeBlocks,
                        currentMission: missions[currentMission],
                        onMissionComplete: handleMissionComplete,
                        slotMinutes: slotMinutes,
                        availableTasks: availableTasks
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            
            // ボタン
            VStack(spacing: 12) {
                Button(action: {
                    onNext()
                }) {
                    Text("次へ")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                if let onBack = onBack {
                    Button(action: onBack) {
                        Text("戻る")
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .onAppear {
            loadSlotMinutes()
        }
    }
    
    private func loadSlotMinutes() {
        if let userId = authService.currentUser?.id,
           let settings = settingsService.loadSettings(for: userId) {
            if let settingsSlotMinutes = settings.slotMinutes {
                slotMinutes = settingsSlotMinutes
            }
            
            if let paletteId = settings.paletteId {
                currentPalette = ColorPalette.getPalette(id: paletteId)
            }
        }
        
        availableTasks = TutorialTask.createDemoTasks(palette: currentPalette, slotMinutes: slotMinutes)
    }
    
    private func handleMissionComplete() {
        withAnimation(.spring()) {
            if currentMission < missions.count - 1 {
                currentMission += 1
            } else {
                showCelebration = true
            }
        }
    }
}

// MARK: - コンパクトなミッションカード

struct CompactMissionCard: View {
    let mission: TutorialMission
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Text("\(mission.id)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(mission.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(mission.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - タスクアイテムビュー

struct TaskItemView: View {
    let task: TutorialTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("\(task.duration)分")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [task.color, task.color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: task.color.opacity(0.3), radius: 3, x: 0, y: 2)
        .onDrag {
            NSItemProvider(object: task.id as NSString)
        }
    }
}

// MARK: - タイムラインカレンダービュー

struct TimelineCalendarView: View {
    @Binding var timeBlocks: [TutorialTimeBlock]
    let currentMission: TutorialMission
    let onMissionComplete: () -> Void
    let slotMinutes: Int
    let availableTasks: [TutorialTask]
    
    @State private var isDraggingOver = false
    @State private var dragTargetSlotIndex: Int?
    @State private var movingBlockTargetSlot: Int?
    @State private var movingBlockId: String?
    
    private let fixedSlotCount: CGFloat = 8
    private let startHour = 9
    
    /// グリッド線のオフセット（背景テキスト高さの半分 — グリッド線がテキスト中央に描画されるため）
    private let gridLineOffset: CGFloat = UIFont.preferredFont(forTextStyle: .caption2).lineHeight / 2
    
    var body: some View {
        GeometryReader { geometry in
            let slotHeight = geometry.size.height / fixedSlotCount
            
            ZStack(alignment: .topLeading) {
                // 背景グリッド
                TimelineBackgroundView(
                    slotMinutes: slotMinutes,
                    startHour: startHour,
                    fixedSlotCount: fixedSlotCount
                )
                
                // ドラッグ中の落下位置ガイド（新規タスク）
                if isDraggingOver, let targetSlot = dragTargetSlotIndex {
                    let yPosition = CGFloat(targetSlot) * slotHeight + gridLineOffset
                    
                    // 青い横線（落下予定位置）- 横幅いっぱい
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width - 58, height: 2)
                        .offset(x: 58, y: yPosition)
                    
                    // ゴースト枠（半透明の点線）
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        )
                        .frame(width: geometry.size.width - 70, height: slotHeight)
                        .offset(x: 60, y: yPosition)
                        .animation(.easeInOut(duration: 0.15), value: targetSlot)
                }
                
                // 配置済みボックスの移動ガイド
                if let movingBlockId = movingBlockId,
                   let movingBlock = timeBlocks.first(where: { $0.id == movingBlockId }),
                   let targetMinutes = movingBlockTargetSlot {
                    let minuteHeight = slotHeight / CGFloat(slotMinutes)
                    let blockHeight = minuteHeight * CGFloat(movingBlock.duration)
                    let yPosition = minuteHeight * CGFloat(targetMinutes) + gridLineOffset
                    
                    // 青い横線（落下予定位置）- 横幅いっぱい
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width - 58, height: 2)
                        .offset(x: 58, y: yPosition)
                    
                    // ゴーストボックス（半透明）
                    RoundedRectangle(cornerRadius: 10)
                        .fill(movingBlock.task.color.opacity(0.3))
                        .frame(width: geometry.size.width - 70, height: blockHeight)
                        .offset(x: 60, y: yPosition)
                        .animation(.easeInOut(duration: 0.15), value: targetMinutes)
                }
                
                // 配置済みタイムブロック
                ForEach(timeBlocks) { block in
                    TimeBlockView(
                        block: block,
                        containerHeight: geometry.size.height,
                        containerWidth: geometry.size.width,
                        slotMinutes: slotMinutes,
                        fixedSlotCount: fixedSlotCount,
                        startHour: startHour,
                        currentMission: currentMission,
                        onResize: { newDuration in
                            handleResize(blockId: block.id, newDuration: newDuration)
                        },
                        onMove: { newStartMinutes in
                            handleMove(blockId: block.id, newStartMinutes: newStartMinutes)
                        },
                        onDelete: {
                            handleDelete(blockId: block.id)
                        },
                        onDragUpdate: { blockId, targetMinutes in
                            movingBlockId = blockId
                            movingBlockTargetSlot = targetMinutes
                        },
                        onDragEnd: {
                            movingBlockId = nil
                            movingBlockTargetSlot = nil
                        }
                    )
                }
            }
            // タイムライン全体をドロップゾーンとして DropDelegate を使用
            .onDrop(of: [.text], delegate: TimelineDropDelegate(
                slotHeight: slotHeight,
                slotMinutes: slotMinutes,
                fixedSlotCount: Int(fixedSlotCount),
                onDragUpdate: { slotIndex in
                    isDraggingOver = true
                    dragTargetSlotIndex = slotIndex
                },
                onDragExit: {
                    isDraggingOver = false
                    dragTargetSlotIndex = nil
                },
                onPerformDrop: { taskId, slotIndex in
                    handleDrop(taskId: taskId, slotIndex: slotIndex, availableTasks: availableTasks)
                }
            ))
        }
    }
    
    private func handleDrop(taskId: String, slotIndex: Int, availableTasks: [TutorialTask]) {
        guard let task = availableTasks.first(where: { $0.id == taskId }) else {
            return
        }
        
        // スロットインデックスから開始分数を計算（スロットの先頭にスナップ）
        let startMinutes = slotIndex * slotMinutes
        
        let newBlock = TutorialTimeBlock(
            id: UUID().uuidString,
            task: task,
            startMinutes: startMinutes,
            duration: task.duration
        )
        
        timeBlocks.append(newBlock)
        isDraggingOver = false
        dragTargetSlotIndex = nil
        
        // ミッション1完了チェック
        if currentMission.requiredAction == .placeTask {
            onMissionComplete()
        }
    }
    
    private func handleResize(blockId: String, newDuration: Int) {
        if let index = timeBlocks.firstIndex(where: { $0.id == blockId }) {
            timeBlocks[index].duration = newDuration
            
            if currentMission.requiredAction == .resizeTask {
                onMissionComplete()
            }
        }
    }
    
    private func handleMove(blockId: String, newStartMinutes: Int) {
        if let index = timeBlocks.firstIndex(where: { $0.id == blockId }) {
            timeBlocks[index].startMinutes = newStartMinutes
            
            if currentMission.requiredAction == .moveTask {
                onMissionComplete()
            }
        }
    }
    
    private func handleDelete(blockId: String) {
        withAnimation {
            timeBlocks.removeAll(where: { $0.id == blockId })
        }
    }
}

// MARK: - タイムラインドロップデリゲート

struct TimelineDropDelegate: DropDelegate {
    let slotHeight: CGFloat
    let slotMinutes: Int
    let fixedSlotCount: Int
    let onDragUpdate: (Int) -> Void
    let onDragExit: () -> Void
    let onPerformDrop: (String, Int) -> Void
    
    /// ドロップ位置からスロットインデックスを計算（slotMinutes にスナップ）
    private func calculateSlotIndex(from location: CGPoint) -> Int {
        let targetSlot = Int(location.y / slotHeight)
        return max(0, min(targetSlot, fixedSlotCount - 1))
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.text])
    }
    
    func dropEntered(info: DropInfo) {
        onDragUpdate(calculateSlotIndex(from: info.location))
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        onDragUpdate(calculateSlotIndex(from: info.location))
        return DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        onDragExit()
    }
    
    func performDrop(info: DropInfo) -> Bool {
        let slotIndex = calculateSlotIndex(from: info.location)
        
        guard let provider = info.itemProviders(for: [.text]).first else { return false }
        
        provider.loadObject(ofClass: NSString.self) { taskId, _ in
            if let taskId = taskId as? String {
                DispatchQueue.main.async {
                    onPerformDrop(taskId, slotIndex)
                }
            }
        }
        return true
    }
}

// MARK: - タイムブロックビュー

struct TimeBlockView: View {
    let block: TutorialTimeBlock
    let containerHeight: CGFloat
    let containerWidth: CGFloat
    let slotMinutes: Int
    let fixedSlotCount: CGFloat
    let startHour: Int
    let currentMission: TutorialMission
    let onResize: (Int) -> Void
    let onMove: (Int) -> Void
    let onDelete: () -> Void
    var onDragUpdate: ((String, Int) -> Void)?
    var onDragEnd: (() -> Void)?
    
    /// グリッド線のオフセット（背景テキスト高さの半分）
    private let gridLineOffset: CGFloat = UIFont.preferredFont(forTextStyle: .caption2).lineHeight / 2
    
    @GestureState private var dragState: DragState = .inactive
    @GestureState private var resizeDragState: CGFloat = 0
    @State private var blockHeight: CGFloat = 0
    @State private var dragOffset: CGSize = .zero
    @State private var longPressStarted = false
    @State private var isResizing = false
    @State private var resizeInitialHeight: CGFloat? = nil
    @State private var lastSnappedMoveMinutes: Int = 0
    
    private enum DragState {
        case inactive
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive: return .zero
            case .dragging(let t): return t
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive: return false
            case .dragging: return true
            }
        }
    }
    
    var body: some View {
        let slotHeight = containerHeight / fixedSlotCount
        let minuteHeight = slotHeight / CGFloat(slotMinutes)
        let calculatedBlockHeight = minuteHeight * CGFloat(block.duration)
        let blockYPosition = minuteHeight * CGFloat(block.startMinutes)
        
        // リサイズ中の高さを計算（GestureStateを使用してスムーズに）
        let minHeight = minuteHeight * CGFloat(slotMinutes)
        let currentResizeHeight = isResizing ? max(minHeight, (resizeInitialHeight ?? blockHeight) + resizeDragState) : blockHeight
        
        // 時刻の計算（startHour からの経過分数で正確に算出）
        let startHourValue = startHour + block.startMinutes / 60
        let startMinuteValue = block.startMinutes % 60
        let endTotalMinutes = block.startMinutes + block.duration
        let endHourValue = startHour + endTotalMinutes / 60
        let endMinuteValue = endTotalMinutes % 60
        
        ZStack(alignment: .topLeading) {
            // メインブロック（移動ジェスチャーはここに配置）
            VStack(alignment: .leading, spacing: 4) {
                Text(block.task.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(String(format: "%d:%02d - %d:%02d", startHourValue, startMinuteValue, endHourValue, endMinuteValue))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("\(block.duration)分")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [block.task.color, block.task.color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: block.task.color.opacity(0.3), radius: 5, x: 0, y: 2)
            .contentShape(Rectangle())
            .gesture(moveGesture(slotHeight: slotHeight, blockYPosition: blockYPosition))
            .animation(.none, value: blockHeight)
            
            // 削除ボタン（右上）
            HStack {
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "minus")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .padding(4)
            }
            
            // リサイズハンドル（右下）- 当たり判定を 44x44 に拡大
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Color.clear
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .overlay(
                            Image(systemName: "arrow.down.right")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(7)
                                .background(Circle().fill(Color.black.opacity(0.3)))
                        )
                        .gesture(resizeGesture(slotHeight: slotHeight))
                }
            }
        }
        .frame(width: containerWidth - 70, height: currentResizeHeight)
        .offset(x: 60, y: blockYPosition + gridLineOffset + dragOffset.height)
        .scaleEffect(longPressStarted && dragState.isDragging ? 1.05 : (longPressStarted ? 0.98 : 1.0))
        .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.88, blendDuration: 0), value: currentResizeHeight)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: longPressStarted)
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.85), value: dragOffset)
        .onAppear {
            blockHeight = calculatedBlockHeight
        }
        .onChange(of: block.duration) { _, _ in
            let newHeight = slotHeight * CGFloat(block.duration) / CGFloat(slotMinutes)
            blockHeight = newHeight
        }
    }
    
    // MARK: リサイズジェスチャー（右下ハンドル専用）
    
    private func resizeGesture(slotHeight: CGFloat) -> some Gesture {
        let minuteHeight = slotHeight / CGFloat(slotMinutes)
        let minHeight = minuteHeight * CGFloat(slotMinutes) // 最小1スロット分
        
        return DragGesture(minimumDistance: 0)
            .updating($resizeDragState) { value, state, _ in
                state = value.translation.height
            }
            .onChanged { value in
                if !isResizing {
                    isResizing = true
                    resizeInitialHeight = blockHeight
                }
            }
            .onEnded { value in
                let startHeight = resizeInitialHeight ?? blockHeight
                let finalHeight = max(minHeight, startHeight + value.translation.height)
                let totalMinutes = Int(round(finalHeight / minuteHeight))
                // slotMinutes 刻みにスナップ
                let snappedMinutes = max(slotMinutes, (totalMinutes / slotMinutes) * slotMinutes)
                
                onResize(snappedMinutes)
                blockHeight = minuteHeight * CGFloat(snappedMinutes)
                resizeInitialHeight = nil
                isResizing = false
            }
    }
    
    // MARK: 移動ジェスチャー（長押し→ドラッグ）
    
    private func moveGesture(slotHeight: CGFloat, blockYPosition: CGFloat) -> some Gesture {
        let minuteHeight = slotHeight / CGFloat(slotMinutes)
        let totalMinutes = Int(fixedSlotCount) * slotMinutes
        
        return LongPressGesture(minimumDuration: 0.15)
            .onChanged { _ in
                guard !isResizing else { return }
                longPressStarted = true
            }
            .sequenced(before: DragGesture())
            .updating($dragState) { value, state, _ in
                switch value {
                case .first(true):
                    state = .inactive
                case .second(true, let drag):
                    if let dragValue = drag {
                        state = .dragging(translation: dragValue.translation)
                    }
                default:
                    state = .inactive
                }
            }
            .onChanged { value in
                guard !isResizing else { return }
                switch value {
                case .first(true):
                    // 長押し認識時に現在位置を記録
                    lastSnappedMoveMinutes = block.startMinutes
                case .second(true, let drag):
                    if let dragValue = drag {
                        dragOffset = dragValue.translation
                        
                        // slotMinutes 刻みでスナップ位置を計算
                        let currentY = blockYPosition + dragValue.translation.height
                        let targetMinutes = Int(round(currentY / minuteHeight))
                        let snappedMinutes = (targetMinutes / slotMinutes) * slotMinutes
                        let clampedMinutes = max(0, min(snappedMinutes, totalMinutes - block.duration))
                        lastSnappedMoveMinutes = clampedMinutes
                        onDragUpdate?(block.id, clampedMinutes)
                    }
                default:
                    break
                }
            }
            .onEnded { value in
                guard !isResizing else {
                    longPressStarted = false
                    return
                }
                
                switch value {
                case .second(true, _):
                    // ガイドで表示していた位置と完全一致させるため lastSnappedMoveMinutes を使用
                    onMove(lastSnappedMoveMinutes)
                    onDragEnd?()
                    dragOffset = .zero
                    longPressStarted = false
                default:
                    longPressStarted = false
                }
            }
    }
}

// MARK: - タイムライン背景ビュー

struct TimelineBackgroundView: View {
    let slotMinutes: Int
    let startHour: Int
    let fixedSlotCount: CGFloat
    
    /// スロット分数に基づいた時間計算
    private func calculateTime(for index: Int) -> (hour: Int, minute: Int) {
        let totalMinutes = (startHour * 60) + (index * slotMinutes)
        let hour = (totalMinutes / 60) % 24
        let minute = totalMinutes % 60
        return (hour, minute)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let slotHeight = geometry.size.height / fixedSlotCount
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                
                VStack(spacing: 0) {
                    ForEach(0..<Int(fixedSlotCount), id: \.self) { index in
                        let (hour, minute) = calculateTime(for: index)
                        
                        HStack(spacing: 0) {
                            Text(String(format: "%d:%02d", hour, minute))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: 50, alignment: .trailing)
                                .padding(.trailing, 8)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            
                            Spacer()
                        }
                        // ★ 修正: alignment: .top でラベルとグリッド線をスロット上端に配置
                        // これにより表示時間とタイムライン位置が一致する
                        .frame(height: slotHeight, alignment: .top)
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingStep3View(onNext: {}, onBack: {})
}
