//
//  RoutineDetail.swift
//
//
//  Created by Reed Esau on 12/25/22.
//

import os
import SwiftUI

import GroutLib
import TrackerUI

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                            category: "RoutineDetail")

public struct RoutineDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var router: GroutRouter

    // MARK: - Parameters

    @ObservedObject private var routine: Routine

    public init(routine: Routine) {
        self.routine = routine
    }

    // MARK: - Locals

    #if os(watchOS)
        @SceneStorage("routine-detail-tab") private var selectedTab: Int = 0
    #endif

    // MARK: - Views

    public var body: some View {
        content
            .symbolRenderingMode(.hierarchical)
            .onDisappear(perform: onDisappearAction)
    }

    private var content: some View {
        #if os(watchOS)
            TabView(selection: $selectedTab) {
                Form {
                    Section("Name") {
                        TextFieldWithPresets($routine.wrappedName,
                                             prompt: "Enter routine name",
                                             // color: routineColor,
                                             presets: routinePresets) { _, _ in
                            // nothing to set other than the name
                        } label: {
                            Text($0)
                        }
                    }

                    Section("Image") {
                        ImageStepper(initialName: routine.imageName, imageNames: systemImageNames) {
                            routine.imageName = $0
                        }
                        .imageScale(.small)
                    }
                }
                .tabItem {
                    Text("Properties")
                }
                .tag(0)

                FakeSection(title: "Exercises") {
                    ExerciseList(routine: routine)
                }
                .tabItem {
                    Text("Exercises")
                }
                .tag(1)
            }
            .tabViewStyle(.page)
            .navigationTitle {
                Text("Routine")
                    .foregroundColor(routineColor)
            }
        #elseif os(iOS)
            Form {
                Section("Name") {
                    TextFieldWithPresets($routine.wrappedName,
                                         prompt: "Enter routine name",
                                         // color: routineColor,
                                         presets: routinePresets) { _, _ in
                        // nothing to do other than set routine name
                    } label: {
                        Text($0)
                    }
                }

                Section("Image") {
                    ImageStepper(initialName: routine.imageName,
                                 imageNames: systemImageNames) {
                        routine.imageName = $0
                    }
                    .imageScale(.large)
                }

                Button(action: exerciseListAction) {
                    HStack {
                        Text("Exercises")
                        Spacer()
                        Text(exerciseCount > 0 ? String(format: "%d", exerciseCount) : "none")
                    }
                }
            }
            .navigationTitle("Routine")
            .onDisappear(perform: onDisappearAction)
        #endif
    }

    // MARK: - Properties

    #if os(iOS)
        private var exerciseCount: Int {
            routine.exercises?.count ?? 0
        }
    #endif

    // MARK: - Actions

    #if os(iOS)
        private func exerciseListAction() {
            router.path.append(GroutRoute.exerciseList(routine.uriRepresentation))
        }
    #endif

    private func onDisappearAction() {
        do {
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }
}

struct RoutineDetail_Previews: PreviewProvider {
    struct TestHolder: View {
        var routine: Routine
        var body: some View {
            NavigationStack {
                RoutineDetail(routine: routine)
            }
        }
    }

    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = Routine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let exercise = Exercise.create(ctx, userOrder: 0)
        exercise.name = "Lat Pulldown"
        exercise.routine = routine
        return TestHolder(routine: routine)
            .environment(\.managedObjectContext, ctx)
    }
}
