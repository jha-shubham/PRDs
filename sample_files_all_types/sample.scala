// PRD Management System - Scala Implementation
// Version: 1.2.0 | Last Updated: July 25, 2025

import java.time.{LocalDateTime, ZoneOffset}
import java.util.concurrent.ThreadLocalRandom
import scala.collection.mutable
import scala.util.{Try, Success, Failure}
import scala.math.Ordering.Implicits._

object PRDManagement {

  sealed trait PRDStatus {
    def value: Int
    def displayName: String
  }

  object PRDStatus {
    case object Draft extends PRDStatus { val value = 0; val displayName = "Draft" }
    case object InReview extends PRDStatus { val value = 1; val displayName = "In Review" }
    case object Approved extends PRDStatus { val value = 2; val displayName = "Approved" }
    case object InDevelopment extends PRDStatus { val value = 3; val displayName = "In Development" }
    case object Testing extends PRDStatus { val value = 4; val displayName = "Testing" }
    case object Implemented extends PRDStatus { val value = 5; val displayName = "Implemented" }
    case object Archived extends PRDStatus { val value = 6; val displayName = "Archived" }

    val all: List[PRDStatus] = List(Draft, InReview, Approved, InDevelopment, Testing, Implemented, Archived)

    def fromValue(value: Int): Option[PRDStatus] = all.find(_.value == value)
  }

  sealed trait Priority {
    def value: Int
    def displayName: String
    def colorCode: String
  }

  object Priority {
    case object Low extends Priority { 
      val value = 1; val displayName = "Low"; val colorCode = "#28a745" 
    }
    case object Medium extends Priority { 
      val value = 2; val displayName = "Medium"; val colorCode = "#ffc107" 
    }
    case object High extends Priority { 
      val value = 3; val displayName = "High"; val colorCode = "#fd7e14" 
    }
    case object Critical extends Priority { 
      val value = 4; val displayName = "Critical"; val colorCode = "#dc3545" 
    }

    val all: List[Priority] = List(Low, Medium, High, Critical)

    def fromValue(value: Int): Option[Priority] = all.find(_.value == value)
  }

  case class PRD(
    id: String,
    var title: String,
    var description: String,
    var author: String,
    var status: PRDStatus = PRDStatus.Draft,
    var priority: Priority = Priority.Medium,
    createdAt: LocalDateTime = LocalDateTime.now(),
    var updatedAt: LocalDateTime = LocalDateTime.now(),
    var completionPercentage: Int = 0,
    tags: mutable.Set[String] = mutable.Set.empty[String]
  ) {

    def updateStatus(newStatus: PRDStatus): Unit = {
      status = newStatus
      updatedAt = LocalDateTime.now()
    }

    def setCompletionPercentage(percentage: Int): Unit = {
      completionPercentage = math.max(0, math.min(100, percentage))
      updatedAt = LocalDateTime.now()
    }

    def addTag(tag: String): Unit = {
      val cleanTag = tag.trim.toLowerCase
      if (cleanTag.nonEmpty) {
        tags += cleanTag
        updatedAt = LocalDateTime.now()
      }
    }

    def setPriority(newPriority: Priority): Unit = {
      priority = newPriority
      updatedAt = LocalDateTime.now()
    }

    def progressDescription: String = s"$completionPercentage% complete"

    def statusIcon: String = status match {
      case PRDStatus.Draft => "📝"
      case PRDStatus.InReview => "👁️"
      case PRDStatus.Approved => "✅"
      case PRDStatus.InDevelopment => "🔨"
      case PRDStatus.Testing => "🧪"
      case PRDStatus.Implemented => "⭐"
      case PRDStatus.Archived => "📦"
    }

    override def toString: String = 
      s"PRD{ID='$id', Title='$title', Status=${status.displayName}, Completion=$completionPercentage%}"
  }

  object PRD {
    def apply(title: String, description: String, author: String): PRD = {
      val timestamp = System.currentTimeMillis()
      val random = ThreadLocalRandom.current().nextInt(1000, 10000)
      val id = s"PRD-$timestamp-$random"
      new PRD(id, title, description, author)
    }
  }

  case class Analytics(
    totalPRDs: Int,
    statusCounts: Map[String, Int],
    priorityCounts: Map[String, Int],
    averageCompletion: Double,
    topAuthors: Map[String, Int],
    tagFrequency: Map[String, Int],
    lastUpdated: LocalDateTime = LocalDateTime.now()
  ) {

    lazy val mostUsedTags: List[(String, Int)] = 
      tagFrequency.toList.sortBy(-_._2)

    lazy val topContributors: List[(String, Int)] = 
      topAuthors.toList.sortBy(-_._2)
  }

  class PRDManager {
    private val prds = mutable.ArrayBuffer[PRD]()
    private val prdIndex = mutable.Map[String, Int]()

    def createPRD(title: String, description: String, author: String): String = {
      val prd = PRD(title, description, author)
      prdIndex(prd.id) = prds.length
      prds += prd
      
      println(s"PRD created successfully: ${prd.id}")
      prd.id
    }

    def getPRD(id: String): Option[PRD] = 
      prdIndex.get(id).flatMap(index => prds.lift(index))

    def getAllPRDs: List[PRD] = prds.toList

    def getPRDsByStatus(status: PRDStatus): List[PRD] = 
      prds.filter(_.status == status).toList

    def getPRDsByPriority(priority: Priority): List[PRD] = 
      prds.filter(_.priority == priority).toList

    def searchPRDs(searchTerm: String): List[PRD] = {
      val lowercaseTerm = searchTerm.toLowerCase
      prds.filter { prd =>
        prd.title.toLowerCase.contains(lowercaseTerm) ||
        prd.description.toLowerCase.contains(lowercaseTerm) ||
        prd.tags.exists(_.contains(lowercaseTerm))
      }.toList
    }

    def updatePRDStatus(id: String, newStatus: PRDStatus): Boolean = {
      getPRD(id) match {
        case Some(prd) =>
          prd.updateStatus(newStatus)
          println(s"PRD $id status updated to: ${newStatus.displayName}")
          true
        case None => false
      }
    }

    def updatePRDCompletion(id: String, percentage: Int): Boolean = {
      getPRD(id) match {
        case Some(prd) =>
          prd.setCompletionPercentage(percentage)
          true
        case None => false
      }
    }

    def generateAnalytics(): Analytics = {
      val totalPRDs = prds.length
      val statusCounts = prds.groupBy(_.status.displayName).view.mapValues(_.length).toMap
      val priorityCounts = prds.groupBy(_.priority.displayName).view.mapValues(_.length).toMap
      val authorCounts = prds.groupBy(_.author).view.mapValues(_.length).toMap
      
      val tagCounts = prds.flatMap(_.tags).groupBy(identity).view.mapValues(_.length).toMap
      
      val averageCompletion = if (totalPRDs > 0) {
        prds.map(_.completionPercentage).sum.toDouble / totalPRDs
      } else 0.0

      Analytics(
        totalPRDs = totalPRDs,
        statusCounts = statusCounts,
        priorityCounts = priorityCounts,
        averageCompletion = averageCompletion,
        topAuthors = authorCounts,
        tagFrequency = tagCounts
      )
    }

    def exportToJSON(): String = {
      // Simplified JSON export (in real implementation, would use a JSON library)
      val prdJsons = prds.map { prd =>
        s"""{
          |  "id": "${prd.id}",
          |  "title": "${prd.title}",
          |  "description": "${prd.description}",
          |  "author": "${prd.author}",
          |  "status": ${prd.status.value},
          |  "priority": ${prd.priority.value},
          |  "completion_percentage": ${prd.completionPercentage},
          |  "tags": [${prd.tags.map(tag => s""""$tag"""").mkString(", ")}]
          |}""".stripMargin
      }
      s"[\n${prdJsons.mkString(",\n")}\n]"
    }

    def printDashboard(): Unit = {
      println("\n" + "=" * 60)
      println("PRD MANAGEMENT SYSTEM - DASHBOARD")
      println("=" * 60)

      val analytics = generateAnalytics()

      println(s"Total PRDs: ${analytics.totalPRDs}")
      println(f"Average Completion: ${analytics.averageCompletion}%.1f%%")

      println("\nStatus Distribution:")
      analytics.statusCounts.toSeq.sortBy(_._1).foreach { case (status, count) =>
        println(s"  $status: $count")
      }

      println("\nPriority Distribution:")
      analytics.priorityCounts.toSeq.sortBy(_._1).foreach { case (priority, count) =>
        println(s"  $priority: $count")
      }

      println("\nTop Authors:")
      analytics.topContributors.take(5).foreach { case (author, count) =>
        println(s"  $author: $count PRDs")
      }

      println("\nMost Used Tags:")
      analytics.mostUsedTags.take(5).foreach { case (tag, count) =>
        println(s"  #$tag: $count times")
      }

      println("\nRecent PRDs:")
      prds.sortBy(_.updatedAt)(Ordering[LocalDateTime].reverse).take(5).foreach { prd =>
        println(s"  $prd")
      }
    }

    def loadSampleData(): Unit = {
      val sampleData = List(
        ("User Authentication System", "Implement secure login and registration", "Dev Team", List("security", "authentication")),
        ("Dark Mode Theme", "Add dark theme option for better UX", "UX Team", List("ui", "theme")),
        ("Payment Gateway Integration", "Integrate secure payment processing", "Product Team", List("payment", "integration")),
        ("API Rate Limiting", "Implement API rate limiting for security", "Backend Team", List("api", "security")),
        ("Mobile App Redesign", "Complete redesign of mobile application", "Design Team", List("mobile", "design")),
        ("Real-time Notifications", "Add real-time notification system", "Full Stack Team", List("notifications", "realtime")),
        ("Performance Optimization", "Optimize database queries and caching", "Database Team", List("performance", "database")),
        ("Multi-language Support", "Add internationalization support", "Localization Team", List("i18n", "localization")),
        ("Microservices Architecture", "Migrate to microservices architecture", "Architecture Team", List("microservices", "architecture")),
        ("Machine Learning Pipeline", "Implement ML model training pipeline", "ML Team", List("ml", "pipeline"))
      )

      sampleData.foreach { case (title, description, author, tags) =>
        val id = createPRD(title, description, author)
        getPRD(id).foreach { prd =>
          tags.foreach(prd.addTag)
        }
      }

      // Update some statuses and priorities for variety
      if (prds.length >= 10) {
        updatePRDStatus(prds(1).id, PRDStatus.InReview)
        updatePRDStatus(prds(2).id, PRDStatus.Approved)
        updatePRDStatus(prds(3).id, PRDStatus.InDevelopment)
        updatePRDStatus(prds(4).id, PRDStatus.Testing)
        updatePRDStatus(prds(5).id, PRDStatus.Implemented)

        prds(2).setPriority(Priority.High)
        prds(3).setPriority(Priority.Critical)
        prds(8).setPriority(Priority.High)

        updatePRDCompletion(prds(3).id, 65)
        updatePRDCompletion(prds(4).id, 90)
        updatePRDCompletion(prds(5).id, 100)
      }
    }

    def getCompletionStats: (Int, Int, Double) = {
      if (prds.isEmpty) (0, 0, 0.0)
      else {
        val completions = prds.map(_.completionPercentage)
        val min = completions.min
        val max = completions.max
        val average = completions.sum.toDouble / completions.length
        (min, max, average)
      }
    }

    def getPRDsNeedingAttention: List[PRD] = {
      prds.filter { prd =>
        (prd.status == PRDStatus.InDevelopment && prd.completionPercentage < 50) ||
        (prd.priority == Priority.Critical && prd.status == PRDStatus.Draft) ||
        (prd.status == PRDStatus.Testing && prd.completionPercentage < 80)
      }.toList
    }

    def getStatusProgressReport: Map[PRDStatus, Double] = {
      PRDStatus.all.map { status =>
        val prdsWithStatus = getPRDsByStatus(status)
        val avgCompletion = if (prdsWithStatus.nonEmpty) {
          prdsWithStatus.map(_.completionPercentage).sum.toDouble / prdsWithStatus.length
        } else 0.0
        status -> avgCompletion
      }.toMap
    }

    def getPRDsByDateRange(startDate: LocalDateTime, endDate: LocalDateTime): List[PRD] = {
      prds.filter { prd =>
        prd.createdAt.isAfter(startDate) && prd.createdAt.isBefore(endDate)
      }.toList
    }

    def bulkUpdateStatus(ids: List[String], newStatus: PRDStatus): Int = {
      ids.count(updatePRDStatus(_, newStatus))
    }

    def getAuthorProductivity: Map[String, Double] = {
      prds.groupBy(_.author).view.mapValues { authorPRDs =>
        if (authorPRDs.nonEmpty) {
          authorPRDs.map(_.completionPercentage).sum.toDouble / authorPRDs.length
        } else 0.0
      }.toMap
    }
  }

  // Functional utilities for PRD management
  object PRDUtils {
    def calculateVelocity(prds: List[PRD], daysPeriod: Int): Double = {
      val completedPRDs = prds.count(_.status == PRDStatus.Implemented)
      completedPRDs.toDouble / daysPeriod
    }

    def predictCompletion(prd: PRD, dailyProgress: Double): Option[LocalDateTime] = {
      val remainingProgress = 100 - prd.completionPercentage
      if (dailyProgress > 0) {
        val daysToComplete = (remainingProgress / dailyProgress).ceil.toInt
        Some(LocalDateTime.now().plusDays(daysToComplete))
      } else None
    }

    def priorityScore(prd: PRD): Double = {
      val priorityWeight = prd.priority.value * 0.4
      val statusWeight = prd.status.value * 0.3
      val completionWeight = prd.completionPercentage * 0.003 // Scale to 0-0.3
      priorityWeight + statusWeight + completionWeight
    }

    def recommend(prds: List[PRD], maxRecommendations: Int = 5): List[PRD] = {
      prds.sortBy(priorityScore)(Ordering[Double].reverse).take(maxRecommendations)
    }
  }
}

// Demo Implementation
object PRDManagementDemo extends App {
  import PRDManagement._

  println("PRD Management System v1.2.0 - Scala Implementation")
  println("====================================================")

  // Initialize the manager
  val manager = new PRDManager()

  // Load sample data
  manager.loadSampleData()

  // Display dashboard
  manager.printDashboard()

  // Demo operations
  println("\n" + "=" * 60)
  println("DEMO OPERATIONS")
  println("=" * 60)

  // Search demo
  val searchResults = manager.searchPRDs("authentication")
  println(s"\nSearching for 'authentication' related PRDs:")
  searchResults.foreach(prd => println(s"  Found: $prd"))

  // Filter by status demo
  val draftPRDs = manager.getPRDsByStatus(PRDStatus.Draft)
  println(s"\nDraft PRDs (${draftPRDs.length}):")
  draftPRDs.foreach(prd => println(s"  $prd"))

  // Priority filtering demo
  val criticalPRDs = manager.getPRDsByPriority(Priority.Critical)
  println(s"\nCritical Priority PRDs (${criticalPRDs.length}):")
  criticalPRDs.foreach(prd => println(s"  ${prd.statusIcon} $prd"))

  // PRDs needing attention
  val needingAttention = manager.getPRDsNeedingAttention
  println(s"\nPRDs Needing Attention (${needingAttention.length}):")
  needingAttention.foreach { prd =>
    println(s"  ${prd.statusIcon} $prd - ${prd.priority.displayName} priority")
  }

  // Completion statistics
  val (min, max, average) = manager.getCompletionStats
  println(s"\nCompletion Statistics:")
  println(s"  Minimum: $min%")
  println(s"  Maximum: $max%")
  println(f"  Average: $average%.1f%%")

  // Status progress report
  println(s"\nStatus Progress Report:")
  val statusReport = manager.getStatusProgressReport
  statusReport.foreach { case (status, avgCompletion) =>
    println(f"  ${status.displayName}: $avgCompletion%.1f%% average completion")
  }

  // Author productivity
  println(s"\nAuthor Productivity:")
  val productivity = manager.getAuthorProductivity
  productivity.toSeq.sortBy(-_._2).take(5).foreach { case (author, avgCompletion) =>
    println(f"  $author: $avgCompletion%.1f%% average completion")
  }

  // Functional utilities demo
  println(s"\nFunctional Analysis:")
  val allPRDs = manager.getAllPRDs
  val velocity = PRDUtils.calculateVelocity(allPRDs, 30)
  println(f"  30-day velocity: $velocity%.2f PRDs/day")

  val recommendations = PRDUtils.recommend(allPRDs, 3)
  println(s"  Top 3 recommended PRDs:")
  recommendations.foreach { prd =>
    val score = PRDUtils.priorityScore(prd)
    println(f"    ${prd.title} (Score: $score%.2f)")
  }

  // Export demo
  println(s"\nExporting PRD data to JSON...")
  Try(manager.exportToJSON()) match {
    case Success(jsonData) =>
      println(s"Export completed. JSON length: ${jsonData.length} characters")
    case Failure(exception) =>
      println(s"Error exporting to JSON: ${exception.getMessage}")
  }

  println(s"\nScala PRD Management System demonstration completed!")
}
