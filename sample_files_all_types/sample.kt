package main.prd

/**
 * PRD Management System - Kotlin Implementation
 * Version: 1.2.0 | Last Updated: July 25, 2025
 */

import kotlinx.serialization.*
import kotlinx.serialization.json.*
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.*
import kotlin.collections.*

@Serializable
enum class PRDStatus(val value: Int, val displayName: String) {
    DRAFT(0, "Draft"),
    IN_REVIEW(1, "In Review"),
    APPROVED(2, "Approved"),
    IN_DEVELOPMENT(3, "In Development"),
    TESTING(4, "Testing"),
    IMPLEMENTED(5, "Implemented"),
    ARCHIVED(6, "Archived");

    companion object {
        fun fromValue(value: Int): PRDStatus = values().find { it.value == value } ?: DRAFT
    }
}

@Serializable
enum class Priority(val value: Int, val displayName: String, val colorCode: String) {
    LOW(1, "Low", "#28a745"),
    MEDIUM(2, "Medium", "#ffc107"),
    HIGH(3, "High", "#fd7e14"),
    CRITICAL(4, "Critical", "#dc3545");

    companion object {
        fun fromValue(value: Int): Priority = values().find { it.value == value } ?: MEDIUM
    }
}

@Serializable
data class PRD(
    val id: String = generateId(),
    var title: String,
    var description: String,
    var author: String,
    var status: PRDStatus = PRDStatus.DRAFT,
    var priority: Priority = Priority.MEDIUM,
    @Serializable(with = LocalDateTimeSerializer::class)
    val createdAt: LocalDateTime = LocalDateTime.now(),
    @Serializable(with = LocalDateTimeSerializer::class)
    var updatedAt: LocalDateTime = LocalDateTime.now(),
    var completionPercentage: Int = 0,
    var tags: MutableList<String> = mutableListOf()
) {
    companion object {
        private fun generateId(): String {
            val timestamp = System.currentTimeMillis()
            val random = (1000..9999).random()
            return "PRD-$timestamp-$random"
        }
    }

    fun updateStatus(newStatus: PRDStatus) {
        status = newStatus
        updatedAt = LocalDateTime.now()
    }

    fun setCompletionPercentage(percentage: Int) {
        completionPercentage = percentage.coerceIn(0, 100)
        updatedAt = LocalDateTime.now()
    }

    fun addTag(tag: String) {
        val cleanTag = tag.trim().lowercase()
        if (cleanTag.isNotBlank() && !tags.contains(cleanTag)) {
            tags.add(cleanTag)
            updatedAt = LocalDateTime.now()
        }
    }

    fun setPriority(newPriority: Priority) {
        priority = newPriority
        updatedAt = LocalDateTime.now()
    }

    val progressDescription: String
        get() = "$completionPercentage% complete"

    val statusIcon: String
        get() = when (status) {
            PRDStatus.DRAFT -> "📝"
            PRDStatus.IN_REVIEW -> "👁️"
            PRDStatus.APPROVED -> "✅"
            PRDStatus.IN_DEVELOPMENT -> "🔨"
            PRDStatus.TESTING -> "🧪"
            PRDStatus.IMPLEMENTED -> "⭐"
            PRDStatus.ARCHIVED -> "📦"
        }

    override fun toString(): String {
        return "PRD{ID='$id', Title='$title', Status=${status.displayName}, Completion=$completionPercentage%}"
    }
}

@Serializable
data class Analytics(
    val totalPRDs: Int,
    val statusCounts: Map<String, Int>,
    val priorityCounts: Map<String, Int>,
    val averageCompletion: Double,
    val topAuthors: Map<String, Int>,
    val tagFrequency: Map<String, Int>,
    @Serializable(with = LocalDateTimeSerializer::class)
    val lastUpdated: LocalDateTime
) {
    val mostUsedTags: List<Pair<String, Int>>
        get() = tagFrequency.toList().sortedByDescending { it.second }

    val topContributors: List<Pair<String, Int>>
        get() = topAuthors.toList().sortedByDescending { it.second }
}

object LocalDateTimeSerializer : KSerializer<LocalDateTime> {
    override val descriptor = PrimitiveSerialDescriptor("LocalDateTime", PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: LocalDateTime) {
        encoder.encodeString(value.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME))
    }

    override fun deserialize(decoder: Decoder): LocalDateTime {
        return LocalDateTime.parse(decoder.decodeString(), DateTimeFormatter.ISO_LOCAL_DATE_TIME)
    }
}

class PRDManager {
    private val prds = mutableListOf<PRD>()
    private val prdIndex = mutableMapOf<String, Int>()

    // Core Operations
    fun createPRD(title: String, description: String, author: String): String {
        val prd = PRD(title = title, description = description, author = author)
        prdIndex[prd.id] = prds.size
        prds.add(prd)
        
        println("PRD created successfully: ${prd.id}")
        return prd.id
    }

    fun getPRD(id: String): PRD? {
        val index = prdIndex[id] ?: return null
        return prds.getOrNull(index)
    }

    fun getAllPRDs(): List<PRD> = prds.toList()

    fun getPRDsByStatus(status: PRDStatus): List<PRD> = prds.filter { it.status == status }

    fun getPRDsByPriority(priority: Priority): List<PRD> = prds.filter { it.priority == priority }

    fun searchPRDs(searchTerm: String): List<PRD> {
        val lowercaseTerm = searchTerm.lowercase()
        return prds.filter { prd ->
            prd.title.lowercase().contains(lowercaseTerm) ||
            prd.description.lowercase().contains(lowercaseTerm) ||
            prd.tags.any { it.contains(lowercaseTerm) }
        }
    }

    fun updatePRDStatus(id: String, newStatus: PRDStatus): Boolean {
        val prd = getPRD(id) ?: return false
        prd.updateStatus(newStatus)
        println("PRD $id status updated to: ${newStatus.displayName}")
        return true
    }

    fun updatePRDCompletion(id: String, percentage: Int): Boolean {
        val prd = getPRD(id) ?: return false
        prd.setCompletionPercentage(percentage)
        return true
    }

    // Analytics
    fun generateAnalytics(): Analytics {
        val totalPRDs = prds.size
        val statusCounts = prds.groupingBy { it.status.displayName }.eachCount()
        val priorityCounts = prds.groupingBy { it.priority.displayName }.eachCount()
        val authorCounts = prds.groupingBy { it.author }.eachCount()
        
        val tagCounts = mutableMapOf<String, Int>()
        prds.forEach { prd ->
            prd.tags.forEach { tag ->
                tagCounts[tag] = tagCounts.getOrDefault(tag, 0) + 1
            }
        }

        val averageCompletion = if (totalPRDs > 0) {
            prds.sumOf { it.completionPercentage }.toDouble() / totalPRDs
        } else 0.0

        return Analytics(
            totalPRDs = totalPRDs,
            statusCounts = statusCounts,
            priorityCounts = priorityCounts,
            averageCompletion = averageCompletion,
            topAuthors = authorCounts,
            tagFrequency = tagCounts,
            lastUpdated = LocalDateTime.now()
        )
    }

    // Data Management
    fun exportToJSON(): String {
        val json = Json { 
            prettyPrint = true
            encodeDefaults = true
        }
        return json.encodeToString(prds)
    }

    fun importFromJSON(jsonString: String): Boolean {
        return try {
            val json = Json { ignoreUnknownKeys = true }
            val importedPRDs = json.decodeFromString<List<PRD>>(jsonString)
            
            prds.clear()
            prdIndex.clear()
            
            importedPRDs.forEach { prd ->
                prdIndex[prd.id] = prds.size
                prds.add(prd)
            }
            true
        } catch (e: Exception) {
            println("Error importing JSON: ${e.message}")
            false
        }
    }

    // Dashboard
    fun printDashboard() {
        println("\n${"=".repeat(60)}")
        println("PRD MANAGEMENT SYSTEM - DASHBOARD")
        println("${"=".repeat(60)}")

        val analytics = generateAnalytics()

        println("Total PRDs: ${analytics.totalPRDs}")
        println("Average Completion: ${"%.1f".format(analytics.averageCompletion)}%")

        println("\nStatus Distribution:")
        analytics.statusCounts.toSortedMap().forEach { (status, count) ->
            println("  $status: $count")
        }

        println("\nPriority Distribution:")
        analytics.priorityCounts.toSortedMap().forEach { (priority, count) ->
            println("  $priority: $count")
        }

        println("\nTop Authors:")
        analytics.topContributors.take(5).forEach { (author, count) ->
            println("  $author: $count PRDs")
        }

        println("\nMost Used Tags:")
        analytics.mostUsedTags.take(5).forEach { (tag, count) ->
            println("  #$tag: $count times")
        }

        println("\nRecent PRDs:")
        prds.sortedByDescending { it.updatedAt }.take(5).forEach { prd ->
            println("  $prd")
        }
    }

    // Sample Data
    fun loadSampleData() {
        val sampleData = listOf(
            Triple("User Authentication System", "Implement secure login and registration", "Dev Team") to listOf("security", "authentication"),
            Triple("Dark Mode Theme", "Add dark theme option for better UX", "UX Team") to listOf("ui", "theme"),
            Triple("Payment Gateway Integration", "Integrate secure payment processing", "Product Team") to listOf("payment", "integration"),
            Triple("API Rate Limiting", "Implement API rate limiting for security", "Backend Team") to listOf("api", "security"),
            Triple("Mobile App Redesign", "Complete redesign of mobile application", "Design Team") to listOf("mobile", "design"),
            Triple("Real-time Notifications", "Add real-time notification system", "Full Stack Team") to listOf("notifications", "realtime"),
            Triple("Performance Optimization", "Optimize database queries and caching", "Database Team") to listOf("performance", "database"),
            Triple("Multi-language Support", "Add internationalization support", "Localization Team") to listOf("i18n", "localization"),
            Triple("Biometric Authentication", "Add fingerprint and face recognition", "Security Team") to listOf("biometric", "android"),
            Triple("Offline Mode", "Enable app functionality without internet", "Mobile Team") to listOf("offline", "sync")
        )

        sampleData.forEach { (triple, tags) ->
            val (title, description, author) = triple
            val id = createPRD(title, description, author)
            val prd = getPRD(id)
            tags.forEach { prd?.addTag(it) }
        }

        // Update some statuses and priorities for variety
        if (prds.size >= 10) {
            updatePRDStatus(prds[1].id, PRDStatus.IN_REVIEW)
            updatePRDStatus(prds[2].id, PRDStatus.APPROVED)
            updatePRDStatus(prds[3].id, PRDStatus.IN_DEVELOPMENT)
            updatePRDStatus(prds[4].id, PRDStatus.TESTING)
            updatePRDStatus(prds[5].id, PRDStatus.IMPLEMENTED)

            prds[2].setPriority(Priority.HIGH)
            prds[3].setPriority(Priority.CRITICAL)
            prds[8].setPriority(Priority.HIGH)

            updatePRDCompletion(prds[3].id, 65)
            updatePRDCompletion(prds[4].id, 90)
            updatePRDCompletion(prds[5].id, 100)
        }
    }

    // Utility Methods
    fun getCompletionStats(): Triple<Int, Int, Double> {
        if (prds.isEmpty()) return Triple(0, 0, 0.0)

        val completions = prds.map { it.completionPercentage }
        val min = completions.minOrNull() ?: 0
        val max = completions.maxOrNull() ?: 0
        val average = completions.average()

        return Triple(min, max, average)
    }

    fun getPRDsNeedingAttention(): List<PRD> {
        return prds.filter { prd ->
            (prd.status == PRDStatus.IN_DEVELOPMENT && prd.completionPercentage < 50) ||
            (prd.priority == Priority.CRITICAL && prd.status == PRDStatus.DRAFT) ||
            (prd.status == PRDStatus.TESTING && prd.completionPercentage < 80)
        }
    }

    fun getStatusProgressReport(): Map<PRDStatus, Double> {
        return PRDStatus.values().associateWith { status ->
            val prdsWithStatus = getPRDsByStatus(status)
            if (prdsWithStatus.isEmpty()) 0.0
            else prdsWithStatus.map { it.completionPercentage }.average()
        }
    }
}

// Demo Implementation
fun main() {
    println("PRD Management System v1.2.0 - Kotlin Implementation")
    println("====================================================")

    // Initialize the manager
    val manager = PRDManager()

    // Load sample data
    manager.loadSampleData()

    // Display dashboard
    manager.printDashboard()

    // Demo operations
    println("\n${"=".repeat(60)}")
    println("DEMO OPERATIONS")
    println("${"=".repeat(60)}")

    // Search demo
    val searchResults = manager.searchPRDs("authentication")
    println("\nSearching for 'authentication' related PRDs:")
    searchResults.forEach { prd ->
        println("  Found: $prd")
    }

    // Filter by status demo
    val draftPRDs = manager.getPRDsByStatus(PRDStatus.DRAFT)
    println("\nDraft PRDs (${draftPRDs.size}):")
    draftPRDs.forEach { prd ->
        println("  $prd")
    }

    // Priority filtering demo
    val criticalPRDs = manager.getPRDsByPriority(Priority.CRITICAL)
    println("\nCritical Priority PRDs (${criticalPRDs.size}):")
    criticalPRDs.forEach { prd ->
        println("  ${prd.statusIcon} $prd")
    }

    // PRDs needing attention
    val needingAttention = manager.getPRDsNeedingAttention()
    println("\nPRDs Needing Attention (${needingAttention.size}):")
    needingAttention.forEach { prd ->
        println("  ${prd.statusIcon} $prd - ${prd.priority.displayName} priority")
    }

    // Completion statistics
    val (min, max, average) = manager.getCompletionStats()
    println("\nCompletion Statistics:")
    println("  Minimum: $min%")
    println("  Maximum: $max%")
    println("  Average: ${"%.1f".format(average)}%")

    // Status progress report
    println("\nStatus Progress Report:")
    val statusReport = manager.getStatusProgressReport()
    statusReport.forEach { (status, avgCompletion) ->
        println("  ${status.displayName}: ${"%.1f".format(avgCompletion)}% average completion")
    }

    // Export demo
    println("\nExporting PRD data to JSON...")
    try {
        val jsonData = manager.exportToJSON()
        println("Export completed. JSON length: ${jsonData.length} characters")
        
        // Test import
        val testManager = PRDManager()
        if (testManager.importFromJSON(jsonData)) {
            println("JSON import test: Success!")
        }
    } catch (e: Exception) {
        println("Error exporting to JSON: ${e.message}")
    }

    println("\nKotlin PRD Management System demonstration completed!")
}
