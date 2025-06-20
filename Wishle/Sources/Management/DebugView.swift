import SwiftData
import SwiftUI

struct DebugView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var isGenerateAlertPresented = false
    @State private var isResetAlertPresented = false
    @State private var isDeleteAlertPresented = false

    var body: some View {
        Form {
            Section("Data") {
                Button("Generate Sample Data") {
                    isGenerateAlertPresented = true
                }
                .confirmationDialog(
                    "Generate sample data?",
                    isPresented: $isGenerateAlertPresented
                ) {
                    Button("Generate", role: .destructive) {
                        Task {
                            try? generateSampleData()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }

                Button("Delete All Data") {
                    isDeleteAlertPresented = true
                }
                .confirmationDialog(
                    "Delete all data?",
                    isPresented: $isDeleteAlertPresented
                ) {
                    Button("Delete", role: .destructive) {
                        Task {
                            try? deleteAllData()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            Section("App") {
                Button("Reset Onboarding") {
                    isResetAlertPresented = true
                }
                .confirmationDialog(
                    "Reset onboarding flow?",
                    isPresented: $isResetAlertPresented
                ) {
                    Button("Reset", role: .destructive) {
                        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
        .navigationTitle("Debug")
    }

    private func generateSampleData() throws {
        let generator = SampleDataGenerator(modelContext: modelContext)
        try generator.generate()
    }

    private func deleteAllData() throws {
        let generator = SampleDataGenerator(modelContext: modelContext)
        try generator.removeAll()
    }
}

#Preview {
    DebugView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
