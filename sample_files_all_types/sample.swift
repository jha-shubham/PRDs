import Foundation
import UIKit

// PRD Management System - Swift Implementation
// Version: 1.2.0 | Last Updated: July 25, 2025

// MARK: - Enums

enum PRDStatus: Int, CaseIterable, Codable {
    case draft = 0
    case inReview = 1
    case approved = 2
    case inDevelopment = 3
    case testing = 4
    case implemented = 5
    case archived = 6
    
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .inReview: return "In Review"
        case .approved: return "Approved"
        case .inDevelopment: return "In Development"
        case .testing: return "Testing"
        case .implemented: return "Implemented"
        case .archived: return "Archived"
        }
    }
}

enum Priority: Int, CaseIterable, Codable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
    
    var color: UIColor {
        switch self {
        case .low: return .systemGreen
        case .medium: return .systemYellow
        case .high: return .systemOrange
        case .critical: return .systemRed
        }
    }
}

// MARK: - Models

struct PRD: Codable, Identifiable, Equatable {
    let id: String
    var title: String
    var description: String
    var author: String
    var status: PRDStatus
    var priority: Priority
    let createdAt: Date
    var updatedAt: Date
    var completionPercentage: Int
    var tags: [String]
    
    init(title: String, description: String, author: String) {
        self.id = "PRD-\(UUID().uuidString.prefix(8))-\(Int(Date().timeIntervalSince1970))"
        self.title = title
        self.description = description
        self.author = author
        self.status = .draft
        self.priority = .medium
        self.createdAt = Date()
        self.updatedAt = Date()
        self.completionPercentage = 0
        self.tags = []
    }
    
    mutating func updateStatus(_ newStatus: PRDStatus) {
        status = newStatus
        updatedAt = Date()
    }
    
    mutating func setCompletionPercentage(_ percentage: Int) {
        completionPercentage = max(0, min(100, percentage))
        updatedAt = Date()
    }
    
    mutating func addTag(_ tag: String) {
        let cleanTag = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !cleanTag.isEmpty && !tags.contains(cleanTag) {
            tags.append(cleanTag)
            updatedAt = Date()
        }
    }
    
    mutating func setPriority(_ newPriority: Priority) {
        priority = newPriority
        updatedAt = Date()
    }
    
    var progressDescription: String {
        return "\(completionPercentage)% complete"
    }
    
    var statusIcon: String {
        switch status {
        case .draft: return "doc.text"
        case .inReview: return "eye"
        case .approved: return "checkmark.circle"
        case .inDevelopment: return "hammer"
        case .testing: return "flask"
        case .implemented: return "star.fill"
        case .archived: return "archivebox"
        }
    }
}

extension PRD: CustomStringConvertible {
    var description: String {
        return "PRD{ID='\(id)', Title='\(title)', Status=\(status.displayName), Completion=\(completionPercentage)%}"
    }
}

struct Analytics: Codable {
    let totalPRDs: Int
    let statusCounts: [String: Int]
    let priorityCounts: [String: Int]
    let averageCompletion: Double
    let topAuthors: [String: Int]
    let tagFrequency: [String: Int]
    let lastUpdated: Date
    
    var mostUsedTags: [(String, Int)] {
        return tagFrequency.sorted { $0.value > $1.value }
    }
    
    var topContributors: [(String, Int)] {
        return topAuthors.sorted { $0.value > $1.value }
    }
}

// MARK: - PRD Manager

class PRDManager: ObservableObject {
    @Published private(set) var prds: [PRD] = []
    private var prdIndex: [String: Int] = [:]
    
    // MARK: - Core Operations
    
    func createPRD(title: String, description: String, author: String) -> String {
        let prd = PRD(title: title, description: description, author: author)
        prdIndex[prd.id] = prds.count
        prds.append(prd)
        
        print("PRD created successfully: \(prd.id)")
        return prd.id
    }
    
    func getPRD(id: String) -> PRD? {
        guard let index = prdIndex[id], index < prds.count else { return nil }
        return prds[index]
    }
    
    func getAllPRDs() -> [PRD] {
        return prds
    }
    
    func getPRDs(byStatus status: PRDStatus) -> [PRD] {
        return prds.filter { $0.status == status }
    }
    
    func getPRDs(byPriority priority: Priority) -> [PRD] {
        return prds.filter { $0.priority == priority }
    }
    
    func searchPRDs(searchTerm: String) -> [PRD] {
        let lowercasedTerm = searchTerm.lowercased()
        return prds.filter { prd in
            prd.title.lowercased().contains(lowercasedTerm) ||
            prd.description.lowercased().contains(lowercasedTerm) ||
            prd.tags.contains { $0.contains(lowercasedTerm) }
        }
    }
    
    func updatePRDStatus(id: String, newStatus: PRDStatus) -> Bool {
        guard let index = prdIndex[id], index < prds.count else { return false }
        prds[index].updateStatus(newStatus)
        print("PRD \(id) status updated to: \(newStatus.displayName)")
        return true
    }
    
    func updatePRDCompletion(id: String, percentage: Int) -> Bool {
        guard let index = prdIndex[id], index < prds.count else { return false }
        prds[index].setCompletionPercentage(percentage)
        return true
    }
    
    // MARK: - Analytics
    
    func generateAnalytics() -> Analytics {
        let totalPRDs = prds.count
        
        var statusCounts: [String: Int] = [:]
        var priorityCounts: [String: Int] = [:]
        var authorCounts: [String: Int] = [:]
        var tagCounts: [String: Int] = [:]
        
        var totalCompletion = 0
        
        for prd in prds {
            // Count by status
            statusCounts[prd.status.displayName, default: 0] += 1
            
            // Count by priority
            priorityCounts[prd.priority.displayName, default: 0] += 1
            
            // Count by author
            authorCounts[prd.author, default: 0] += 1
            
            // Count tags
            for tag in prd.tags {
                tagCounts[tag, default: 0] += 1
            }
            
            totalCompletion += prd.completionPercentage
        }
        
        let averageCompletion = totalPRDs > 0 ? Double(totalCompletion) / Double(totalPRDs) : 0.0
        
        return Analytics(
            totalPRDs: totalPRDs,
            statusCounts: statusCounts,
            priorityCounts: priorityCounts,
            averageCompletion: averageCompletion,
            topAuthors: authorCounts,
            tagFrequency: tagCounts,
            lastUpdated: Date()
        )
    }
    
    // MARK: - Data Management
    
    func exportToJSON() throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(prds)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func importFromJSON(_ jsonString: String) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "PRDManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        
        let importedPRDs = try decoder.decode([PRD].self, from: data)
        
        // Clear existing data and rebuild index
        prds.removeAll()
        prdIndex.removeAll()
        
        for prd in importedPRDs {
            prdIndex[prd.id] = prds.count
            prds.append(prd)
        }
    }
    
    // MARK: - Dashboard
    
    func printDashboard() {
        print("\n" + String(repeating: "=", count: 60))
        print("PRD MANAGEMENT SYSTEM - DASHBOARD")
        print(String(repeating: "=", count: 60))
        
        let analytics = generateAnalytics()
        
        print("Total PRDs: \(analytics.totalPRDs)")
        print("Average Completion: \(String(format: "%.1f", analytics.averageCompletion))%")
        
        print("\nStatus Distribution:")
        for (status, count) in analytics.statusCounts.sorted(by: { $0.key < $1.key }) {
            print("  \(status): \(count)")
        }
        
        print("\nPriority Distribution:")
        for (priority, count) in analytics.priorityCounts.sorted(by: { $0.key < $1.key }) {
            print("  \(priority): \(count)")
        }
        
        print("\nTop Authors:")
        for (author, count) in analytics.topContributors.prefix(5) {
            print("  \(author): \(count) PRDs")
        }
        
        print("\nMost Used Tags:")
        for (tag, count) in analytics.mostUsedTags.prefix(5) {
            print("  #\(tag): \(count) times")
        }
        
        print("\nRecent PRDs:")
        let recentPRDs = prds.sorted { $0.updatedAt > $1.updatedAt }.prefix(5)
        for prd in recentPRDs {
            print("  \(prd)")
        }
    }
    
    // MARK: - Sample Data
    
    func loadSampleData() {
        let sampleData: [(String, String, String, [String])] = [
            ("User Authentication System", "Implement secure login and registration", "Dev Team", ["security", "authentication"]),
            ("Dark Mode Theme", "Add dark theme option for better UX", "UX Team", ["ui", "theme"]),
            ("Payment Gateway Integration", "Integrate secure payment processing", "Product Team", ["payment", "integration"]),
            ("API Rate Limiting", "Implement API rate limiting for security", "Backend Team", ["api", "security"]),
            ("Mobile App Redesign", "Complete redesign of mobile application", "Design Team", ["mobile", "design"]),
            ("Real-time Notifications", "Add real-time notification system", "Full Stack Team", ["notifications", "realtime"]),
            ("Performance Optimization", "Optimize database queries and caching", "Database Team", ["performance", "database"]),
            ("Multi-language Support", "Add internationalization support", "Localization Team", ["i18n", "localization"]),
            ("Biometric Authentication", "Add Face ID and Touch ID support", "Security Team", ["biometric", "ios"]),
            ("Offline Mode", "Enable app functionality without internet", "Mobile Team", ["offline", "sync"])
        ]
        
        for (title, description, author, tags) in sampleData {
            let id = createPRD(title: title, description: description, author: author)
            if let index = prdIndex[id] {
                for tag in tags {
                    prds[index].addTag(tag)
                }
            }
        }
        
        // Update some statuses and priorities for variety
        if prds.count >= 10 {
            updatePRDStatus(id: prds[1].id, newStatus: .inReview)
            updatePRDStatus(id: prds[2].id, newStatus: .approved)
            updatePRDStatus(id: prds[3].id, newStatus: .inDevelopment)
            updatePRDStatus(id: prds[4].id, newStatus: .testing)
            updatePRDStatus(id: prds[5].id, newStatus: .implemented)
            
            prds[2].setPriority(.high)
            prds[3].setPriority(.critical)
            prds[8].setPriority(.high)
            
            updatePRDCompletion(id: prds[3].id, percentage: 65)
            updatePRDCompletion(id: prds[4].id, percentage: 90)
            updatePRDCompletion(id: prds[5].id, percentage: 100)
        }
    }
    
    // MARK: - Utility Methods
    
    func getCompletionStats() -> (min: Int, max: Int, average: Double) {
        guard !prds.isEmpty else { return (0, 0, 0.0) }
        
        let completions = prds.map { $0.completionPercentage }
        let min = completions.min() ?? 0
        let max = completions.max() ?? 0
        let average = Double(completions.reduce(0, +)) / Double(completions.count)
        
        return (min, max, average)
    }
    
    func getPRDsNeedingAttention() -> [PRD] {
        return prds.filter { prd in
            (prd.status == .inDevelopment && prd.completionPercentage < 50) ||
            (prd.priority == .critical && prd.status == .draft) ||
            (prd.status == .testing && prd.completionPercentage < 80)
        }
    }
}

// MARK: - Demo Implementation

func runPRDManagementDemo() {
    print("PRD Management System v1.2.0 - Swift Implementation")
    print("====================================================")
    
    // Initialize the manager
    let manager = PRDManager()
    
    // Load sample data
    manager.loadSampleData()
    
    // Display dashboard
    manager.printDashboard()
    
    // Demo operations
    print("\n" + String(repeating: "=", count: 60))
    print("DEMO OPERATIONS")
    print(String(repeating: "=", count: 60))
    
    // Search demo
    let searchResults = manager.searchPRDs(searchTerm: "authentication")
    print("\nSearching for 'authentication' related PRDs:")
    for prd in searchResults {
        print("  Found: \(prd)")
    }
    
    // Filter by status demo
    let draftPRDs = manager.getPRDs(byStatus: .draft)
    print("\nDraft PRDs (\(draftPRDs.count)):")
    for prd in draftPRDs {
        print("  \(prd)")
    }
    
    // Priority filtering demo
    let criticalPRDs = manager.getPRDs(byPriority: .critical)
    print("\nCritical Priority PRDs (\(criticalPRDs.count)):")
    for prd in criticalPRDs {
        print("  \(prd)")
    }
    
    // PRDs needing attention
    let needingAttention = manager.getPRDsNeedingAttention()
    print("\nPRDs Needing Attention (\(needingAttention.count)):")
    for prd in needingAttention {
        print("  \(prd) - \(prd.priority.displayName) priority")
    }
    
    // Completion statistics
    let (min, max, average) = manager.getCompletionStats()
    print("\nCompletion Statistics:")
    print("  Minimum: \(min)%")
    print("  Maximum: \(max)%")
    print("  Average: \(String(format: "%.1f", average))%")
    
    // Export demo
    print("\nExporting PRD data to JSON...")
    do {
        let jsonData = try manager.exportToJSON()
        print("Export completed. JSON length: \(jsonData.count) characters")
    } catch {
        print("Error exporting to JSON: \(error)")
    }
    
    print("\nSwift PRD Management System demonstration completed!")
}

// Run the demo
runPRDManagementDemo()
