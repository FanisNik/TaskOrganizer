//
//  Home.swift
//  TaskOrganizer
//  Created by Theofanis Nikolaou on 3/8/25.
//

import SwiftUI
import PhotosUI

// MARK: - Models

struct UserTask: Identifiable, Hashable {
    let id: UUID = UUID()
    var title: String
    var startTime: Date
    var endTime: Date
    var location: String
}

class TaskStore: ObservableObject {
    static let shared = TaskStore()
    @Published var tasks: [Date: [UserTask]] = [:]
    
    func add(task: UserTask, for date: Date) {
        tasks[date, default: []].append(task)
    }
    
    func remove(task: UserTask, for date: Date) {
        tasks[date]?.removeAll(where: { $0.id == task.id })
    }
    
    func update(task: UserTask, for date: Date) {
        guard let index = tasks[date]?.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[date]?[index] = task
    }
}

// MARK: - Home View

struct Home: View {
    
    @State private var currentWeek: [Date.Day] = Date.currentWeek
    @State private var selectedDate: Date?
    @Namespace private var namespace
    @ObservedObject private var taskStore = TaskStore.shared
    @State private var currentWeekOffset = 0
    
    // MARK: - Profile image
    @State private var profileImage: Image = Image("pic")
    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
                .environment(\.colorScheme, .dark)
            
            // Week navigation buttons
            HStack {
                Button {
                    currentWeekOffset -= 1
                    updateCurrentWeek()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                
                Spacer()
                
                Button {
                    currentWeekOffset += 1
                    updateCurrentWeek()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 5)

            GeometryReader { geo in
                let size = geo.size
                ScrollView(.vertical) {
                    LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                        ForEach(currentWeek) { day in
                            DaySection(day: day, size: size)
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.all, 20, for: .scrollContent)
                .contentMargins(.vertical, 20, for: .scrollIndicators)
                .scrollPosition(id: .init(get: {
                    return currentWeek.first(where: { $0.date.isSame(selectedDate) })?.id
                }, set: { newValue in
                    selectedDate = currentWeek.first(where: { $0.id == newValue })?.date
                }), anchor: .top)
            }
            .background(.background)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
            .environment(\.colorScheme, .light)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .background(.mainBackground)
        .onAppear {
            guard selectedDate == nil else { return }
            selectedDate = currentWeek.first(where: { $0.date.isSame(.now) })?.date
        }
    }

    // MARK: - Update Week
    private func updateCurrentWeek() {
        currentWeek = Date.currentWeek(offset: currentWeekOffset)
        selectedDate = currentWeek.first?.date
    }

    // MARK: - Subviews

    @ViewBuilder
    func DaySection(day: Date.Day, size: CGSize) -> some View {
        let date = day.date
        let isLast = currentWeek.last?.id == day.id

        Section {
            HStack(alignment: .top, spacing: 0) {
                // Left date column
                VStack(spacing: 4) {
                    Text(date.string("EEE"))
                        .font(.caption)
                    Text(date.string("dd"))
                        .font(.largeTitle.bold())
                }
                .frame(width: 55)
                .padding(.top, 10)

                // Right tasks column
                VStack(alignment: .leading, spacing: 15) {
                    let dayTasks = taskStore.tasks[date] ?? []
                    
                    if dayTasks.isEmpty {
                        TaskRow(isEmpty: true)
                    } else {
                        ForEach(dayTasks) { task in
                            TaskRow(task: task, date: date)
                        }
                    }
                    
                    // + icon for adding a task
                    Button {
                        addDummyTask(for: date)
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                    }
                    
                }
                .padding(.leading, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .frame(minHeight: isLast ? size.height - 110 : nil, alignment: .top)
        } header: {
            Color.clear.frame(height: 0)
        }
    }

    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // "This Week" button
                Button {
                    currentWeekOffset = 0
                    currentWeek = Date.currentWeek
                    selectedDate = currentWeek.first?.date
                } label: {
                    Text("This Week")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }

                Spacer(minLength: 0)

                // Profile picture with image picker
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    profileImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 1))
                }
                .onChange(of: selectedItem) { newItem in
                    guard let newItem = newItem else { return }
                    loadProfileImage(item: newItem)
                }
            }

            
            HStack(spacing: 0) {
                ForEach(currentWeek) { day in
                    let date = day.date
                    let isSameDate = date.isSame(selectedDate)

                    VStack(spacing: 6) {
                        Text(date.string("EEE"))
                            .font(.caption)

                        Text(date.string("dd"))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(isSameDate ? .black : .white)
                            .frame(width: 38, height: 38)
                            .background {
                                if isSameDate {
                                    Circle()
                                        .fill(.white)
                                        .matchedGeometryEffect(id: "ACTIVEDATE", in: namespace)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.2, extraBounce: 0)) {
                            selectedDate = date
                        }
                    }
                }
            }
            .animation(.snappy(duration: 0.25, extraBounce: 0), value: selectedDate)
            .frame(height: 80)
            .padding(.vertical, 5)
            .offset(y: 5)

            let monthText = selectedDate?.string("MMM") ?? ""
            let yearText = selectedDate?.string("YYYY") ?? ""

            HStack {
                Text(monthText)
                Spacer()
                Text(yearText)
            }
            .font(.caption2)
        }
        .padding([.horizontal, .top], 15)
        .padding(.bottom, 10)
    }

    // MARK: - Async profile image loader
    func loadProfileImage(item: PhotosPickerItem) {
        Task { @MainActor in
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                profileImage = Image(uiImage: uiImage)
            }
        }
    }

    // MARK: - Task helpers

    func addDummyTask(for date: Date) {
        let start = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: date)!
        let end = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: date)!
        let newTask = UserTask(title: "New Task", startTime: start, endTime: end, location: "Madrid")
        taskStore.add(task: newTask, for: date)
    }
}

// MARK: - TaskRow

struct TaskRow: View {
    @State private var showEditSheet = false
    var task: UserTask?
    var isEmpty: Bool = false
    var date: Date?

    var body: some View {
        Group {
            if isEmpty {
                VStack(spacing: 8) {
                    Text("No task found on this day!")
                    Text("Try adding some new tasks ")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
                .frame(height: 70)
                .frame(maxWidth: .infinity)
            } else if let task = task {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(.red)
                            .frame(width: 5, height: 5)
                        Text(task.title)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .onTapGesture {
                                showEditSheet = true
                            }
                        Spacer()
                        Button(role: .destructive) {
                            if let date = date {
                                TaskStore.shared.remove(task: task, for: date)
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack {
                        Text(taskTimeString(task))
                            .onTapGesture { showEditSheet = true }
                        Spacer(minLength: 0)
                        Text(task.location)
                            .onTapGesture { showEditSheet = true }
                    }
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, 5)
                }
                .lineLimit(1)
                .padding(15)
                .sheet(isPresented: $showEditSheet) {
                    if let date = date {
                        TaskEditView(task: task, date: date)
                    }
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
                .shadow(color: .black.opacity(0.35), radius: 1)
        }
    }

    func taskTimeString(_ task: UserTask) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: task.startTime)) - \(formatter.string(from: task.endTime))"
    }
}

// MARK: - Task Edit View

struct TaskEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State var task: UserTask
    var date: Date

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Task Title", text: $task.title)
                }
                Section("Time") {
                    DatePicker("Start", selection: $task.startTime, displayedComponents: [.hourAndMinute])
                    DatePicker("End", selection: $task.endTime, displayedComponents: [.hourAndMinute])
                }
                Section("Location") {
                    TextField("Location", text: $task.location)
                }
            }
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        TaskStore.shared.update(task: task, for: date)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    Home()
}
