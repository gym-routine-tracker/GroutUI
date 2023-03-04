//
//  RoutineControl.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import os
import SwiftUI

import GroutLib
import TrackerUI

public struct RoutineControl: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: GroutRouter

    // MARK: - Parameters

    private var routine: Routine
    private let onAdd: () -> Void
    private let onStop: () -> Void
    private let onNextIncomplete: (Int16?) -> Void
    private var onRemainingCount: () -> Int
    private var startedAt: Date

    public init(routine: Routine,
                onAdd: @escaping () -> Void,
                onStop: @escaping () -> Void,
                onNextIncomplete: @escaping (Int16?) -> Void,
                onRemainingCount: @escaping () -> Int,
                startedAt: Date)
    {
        self.routine = routine
        self.onAdd = onAdd
        self.onStop = onStop
        self.onNextIncomplete = onNextIncomplete
        self.onRemainingCount = onRemainingCount
        self.startedAt = startedAt
    }

    // MARK: - Locals

    #if os(watchOS)
        let minTitleHeight: CGFloat = 25
        let maxButtonHeight: CGFloat = 60
    #elseif os(iOS)
        let minTitleHeight: CGFloat = 60
        let maxButtonHeight: CGFloat = 150
    #endif

    // MARK: - Views

    public var body: some View {
        GeometryReader { _ in
            VStack(spacing: 15) {
                TitleText(routine.wrappedName)
                    .foregroundColor(titleColor)
                    .frame(minHeight: minTitleHeight)
                Group {
                    middle
                    bottom
                }
                .frame(maxHeight: maxButtonHeight)
                #if os(iOS)
                    Spacer()
                #endif
            }
            .frame(maxHeight: .infinity)
//             .border(.red)
            #if os(iOS)
            // NOTE padding needed on iPhone 8, 12, and possibly others (visible in light mode)
            .padding(.horizontal)
            #endif
        }
        // NOTE no .ignoresSafeArea for watch, as there needs to be space for tab indicator
    }

    private var middle: some View {
        HStack(alignment: .bottom) {
            ActionButton(onShortPress: onStop,
                         imageSystemName: "xmark",
                         buttonText: "Stop",
                         tint: stopColor,
                         onLongPress: nil)
            ElapsedSinceView(startedAt: startedAt)
        }
    }

    private var bottom: some View {
        HStack(alignment: .bottom) {
            ActionButton(onShortPress: onAdd,
                         imageSystemName: "plus", // plus.circle.fill
                         buttonText: "Add",
                         tint: exerciseColorDarkBg,
                         onLongPress: nil)
            ActionButton(onShortPress: { onNextIncomplete(nil) },
                         imageSystemName: "arrow.forward",
                         buttonText: "Next",
                         tint: onNextIncompleteColor,
                         onLongPress: nil)
                .disabled(!hasRemaining)
        }
    }

    // MARK: - Properties

    private var onNextIncompleteColor: Color {
        hasRemaining ? exerciseNextColor : disabledColor
    }

    private var hasRemaining: Bool {
        onRemainingCount() > 0
    }
}

struct RoutineControl_Previews: PreviewProvider {
    struct TestHolder: View {
        var routine: Routine
        @State var selectedTab: URL? = .init(string: "blah")!
        var startedAt = Date.now.addingTimeInterval(-1200)
        var body: some View {
            RoutineControl(routine: routine,
                           onAdd: {},
                           onStop: {},
                           onNextIncomplete: { _ in },
                           onRemainingCount: { 3 },
                           startedAt: startedAt)
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Chest & Shoulder"
        let e1 = Exercise.create(ctx, routine: routine, userOrder: 0)
        e1.name = "Lat Pulldown"
        //try? ctx.save()
        return NavigationStack {
            TestHolder(routine: routine)
        }
    }
}
