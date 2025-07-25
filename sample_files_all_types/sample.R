# PRD Management System - R Implementation
# Version: 1.2.0 | Last Updated: July 25, 2025

# Load required libraries
if (!require(jsonlite)) install.packages("jsonlite", dependencies = TRUE)
if (!require(dplyr)) install.packages("dplyr", dependencies = TRUE)
if (!require(ggplot2)) install.packages("ggplot2", dependencies = TRUE)
if (!require(lubridate)) install.packages("lubridate", dependencies = TRUE)

library(jsonlite)
library(dplyr)
library(ggplot2)
library(lubridate)

# Define status and priority enumerations
PRD_STATUS <- list(
  DRAFT = 0,
  IN_REVIEW = 1,
  APPROVED = 2,
  IN_DEVELOPMENT = 3,
  TESTING = 4,
  IMPLEMENTED = 5,
  ARCHIVED = 6
)

PRIORITY <- list(
  LOW = 1,
  MEDIUM = 2,
  HIGH = 3,
  CRITICAL = 4
)

# Status display names
status_names <- c("Draft", "In Review", "Approved", "In Development", 
                  "Testing", "Implemented", "Archived")
names(status_names) <- 0:6

# Priority display names
priority_names <- c("Low", "Medium", "High", "Critical")
names(priority_names) <- 1:4

# Priority color codes
priority_colors <- c("#28a745", "#ffc107", "#fd7e14", "#dc3545")
names(priority_colors) <- 1:4

# PRD class definition using S4
setClass("PRD",
  slots = list(
    id = "character",
    title = "character",
    description = "character",
    author = "character",
    status = "numeric",
    priority = "numeric",
    created_at = "POSIXct",
    updated_at = "POSIXct",
    completion_percentage = "numeric",
    tags = "character"
  )
)

# PRD constructor
createPRD <- function(title, description, author) {
  timestamp <- as.numeric(Sys.time())
  random_num <- sample(1000:9999, 1)
  id <- paste0("PRD-", timestamp, "-", random_num)
  
  new("PRD",
    id = id,
    title = title,
    description = description,
    author = author,
    status = PRD_STATUS$DRAFT,
    priority = PRIORITY$MEDIUM,
    created_at = Sys.time(),
    updated_at = Sys.time(),
    completion_percentage = 0,
    tags = character(0)
  )
}

# PRD Manager class
setClass("PRDManager",
  slots = list(
    prds = "list",
    prd_index = "list"
  )
)

# PRD Manager constructor
createPRDManager <- function() {
  new("PRDManager",
    prds = list(),
    prd_index = list()
  )
}

# Method to add PRD to manager
setGeneric("addPRD", function(manager, prd) standardGeneric("addPRD"))
setMethod("addPRD", "PRDManager", function(manager, prd) {
  index <- length(manager@prds) + 1
  manager@prds[[index]] <- prd
  manager@prd_index[[prd@id]] <- index
  
  cat("PRD created successfully:", prd@id, "\n")
  return(manager)
})

# Method to get PRD by ID
setGeneric("getPRD", function(manager, id) standardGeneric("getPRD"))
setMethod("getPRD", "PRDManager", function(manager, id) {
  if (id %in% names(manager@prd_index)) {
    index <- manager@prd_index[[id]]
    return(manager@prds[[index]])
  }
  return(NULL)
})

# Method to get all PRDs
setGeneric("getAllPRDs", function(manager) standardGeneric("getAllPRDs"))
setMethod("getAllPRDs", "PRDManager", function(manager) {
  return(manager@prds)
})

# Method to get PRDs by status
setGeneric("getPRDsByStatus", function(manager, status) standardGeneric("getPRDsByStatus"))
setMethod("getPRDsByStatus", "PRDManager", function(manager, status) {
  return(Filter(function(prd) prd@status == status, manager@prds))
})

# Method to get PRDs by priority
setGeneric("getPRDsByPriority", function(manager, priority) standardGeneric("getPRDsByPriority"))
setMethod("getPRDsByPriority", "PRDManager", function(manager, priority) {
  return(Filter(function(prd) prd@priority == priority, manager@prds))
})

# Method to search PRDs
setGeneric("searchPRDs", function(manager, search_term) standardGeneric("searchPRDs"))
setMethod("searchPRDs", "PRDManager", function(manager, search_term) {
  search_term <- tolower(search_term)
  
  results <- Filter(function(prd) {
    title_match <- grepl(search_term, tolower(prd@title), fixed = TRUE)
    desc_match <- grepl(search_term, tolower(prd@description), fixed = TRUE)
    tag_match <- any(grepl(search_term, tolower(prd@tags), fixed = TRUE))
    
    return(title_match || desc_match || tag_match)
  }, manager@prds)
  
  return(results)
})

# Method to update PRD status
setGeneric("updatePRDStatus", function(manager, id, new_status) standardGeneric("updatePRDStatus"))
setMethod("updatePRDStatus", "PRDManager", function(manager, id, new_status) {
  if (id %in% names(manager@prd_index)) {
    index <- manager@prd_index[[id]]
    manager@prds[[index]]@status <- new_status
    manager@prds[[index]]@updated_at <- Sys.time()
    
    cat("PRD", id, "status updated to:", status_names[as.character(new_status)], "\n")
    return(TRUE)
  }
  return(FALSE)
})

# Method to update completion percentage
setGeneric("updatePRDCompletion", function(manager, id, percentage) standardGeneric("updatePRDCompletion"))
setMethod("updatePRDCompletion", "PRDManager", function(manager, id, percentage) {
  if (id %in% names(manager@prd_index)) {
    index <- manager@prd_index[[id]]
    manager@prds[[index]]@completion_percentage <- max(0, min(100, percentage))
    manager@prds[[index]]@updated_at <- Sys.time()
    return(TRUE)
  }
  return(FALSE)
})

# Method to add tag to PRD
setGeneric("addTag", function(manager, id, tag) standardGeneric("addTag"))
setMethod("addTag", "PRDManager", function(manager, id, tag) {
  if (id %in% names(manager@prd_index)) {
    index <- manager@prd_index[[id]]
    clean_tag <- tolower(trimws(tag))
    if (clean_tag != "" && !clean_tag %in% manager@prds[[index]]@tags) {
      manager@prds[[index]]@tags <- c(manager@prds[[index]]@tags, clean_tag)
      manager@prds[[index]]@updated_at <- Sys.time()
    }
    return(TRUE)
  }
  return(FALSE)
})

# Method to generate analytics
setGeneric("generateAnalytics", function(manager) standardGeneric("generateAnalytics"))
setMethod("generateAnalytics", "PRDManager", function(manager) {
  if (length(manager@prds) == 0) {
    return(list(
      total_prds = 0,
      status_counts = numeric(0),
      priority_counts = numeric(0),
      average_completion = 0,
      top_authors = character(0),
      tag_frequency = character(0),
      last_updated = Sys.time()
    ))
  }
  
  # Extract data from PRDs
  statuses <- sapply(manager@prds, function(prd) prd@status)
  priorities <- sapply(manager@prds, function(prd) prd@priority)
  authors <- sapply(manager@prds, function(prd) prd@author)
  completions <- sapply(manager@prds, function(prd) prd@completion_percentage)
  
  # Get all tags
  all_tags <- unlist(lapply(manager@prds, function(prd) prd@tags))
  
  # Count occurrences
  status_counts <- table(factor(statuses, levels = 0:6, labels = status_names))
  priority_counts <- table(factor(priorities, levels = 1:4, labels = priority_names))
  author_counts <- table(authors)
  tag_counts <- if(length(all_tags) > 0) table(all_tags) else numeric(0)
  
  # Calculate average completion
  avg_completion <- mean(completions)
  
  return(list(
    total_prds = length(manager@prds),
    status_counts = status_counts,
    priority_counts = priority_counts,
    average_completion = avg_completion,
    top_authors = author_counts,
    tag_frequency = tag_counts,
    last_updated = Sys.time()
  ))
})

# Method to print dashboard
setGeneric("printDashboard", function(manager) standardGeneric("printDashboard"))
setMethod("printDashboard", "PRDManager", function(manager) {
  cat("\n", paste(rep("=", 60), collapse = ""), "\n")
  cat("PRD MANAGEMENT SYSTEM - DASHBOARD\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  analytics <- generateAnalytics(manager)
  
  cat("Total PRDs:", analytics$total_prds, "\n")
  cat("Average Completion:", sprintf("%.1f%%", analytics$average_completion), "\n")
  
  cat("\nStatus Distribution:\n")
  if (length(analytics$status_counts) > 0) {
    for (i in 1:length(analytics$status_counts)) {
      if (analytics$status_counts[i] > 0) {
        cat("  ", names(analytics$status_counts)[i], ": ", analytics$status_counts[i], "\n")
      }
    }
  }
  
  cat("\nPriority Distribution:\n")
  if (length(analytics$priority_counts) > 0) {
    for (i in 1:length(analytics$priority_counts)) {
      if (analytics$priority_counts[i] > 0) {
        cat("  ", names(analytics$priority_counts)[i], ": ", analytics$priority_counts[i], "\n")
      }
    }
  }
  
  cat("\nTop Authors:\n")
  if (length(analytics$top_authors) > 0) {
    top_authors <- sort(analytics$top_authors, decreasing = TRUE)
    for (i in 1:min(5, length(top_authors))) {
      cat("  ", names(top_authors)[i], ": ", top_authors[i], " PRDs\n")
    }
  }
  
  cat("\nMost Used Tags:\n")
  if (length(analytics$tag_frequency) > 0) {
    top_tags <- sort(analytics$tag_frequency, decreasing = TRUE)
    for (i in 1:min(5, length(top_tags))) {
      cat("  #", names(top_tags)[i], ": ", top_tags[i], " times\n")
    }
  }
  
  cat("\nRecent PRDs:\n")
  if (length(manager@prds) > 0) {
    # Sort by updated_at and take last 5
    updated_times <- sapply(manager@prds, function(prd) as.numeric(prd@updated_at))
    sorted_indices <- order(updated_times, decreasing = TRUE)
    recent_indices <- head(sorted_indices, 5)
    
    for (i in recent_indices) {
      prd <- manager@prds[[i]]
      cat("  PRD{ID='", prd@id, "', Title='", prd@title, "', Status=", 
          status_names[as.character(prd@status)], ", Completion=", 
          prd@completion_percentage, "%}\n", sep = "")
    }
  }
})

# Method to load sample data
setGeneric("loadSampleData", function(manager) standardGeneric("loadSampleData"))
setMethod("loadSampleData", "PRDManager", function(manager) {
  sample_data <- data.frame(
    title = c(
      "User Authentication System",
      "Dark Mode Theme", 
      "Payment Gateway Integration",
      "API Rate Limiting",
      "Mobile App Redesign",
      "Real-time Notifications",
      "Performance Optimization",
      "Multi-language Support",
      "Statistical Analysis Dashboard",
      "Data Visualization Engine"
    ),
    description = c(
      "Implement secure login and registration",
      "Add dark theme option for better UX",
      "Integrate secure payment processing", 
      "Implement API rate limiting for security",
      "Complete redesign of mobile application",
      "Add real-time notification system",
      "Optimize database queries and caching",
      "Add internationalization support",
      "Create comprehensive analytics dashboard using R",
      "Build interactive data visualization with ggplot2"
    ),
    author = c(
      "Dev Team",
      "UX Team",
      "Product Team",
      "Backend Team", 
      "Design Team",
      "Full Stack Team",
      "Database Team",
      "Localization Team",
      "Data Science Team",
      "Analytics Team"
    ),
    tags_list = I(list(
      c("security", "authentication"),
      c("ui", "theme"),
      c("payment", "integration"),
      c("api", "security"),
      c("mobile", "design"),
      c("notifications", "realtime"),
      c("performance", "database"),
      c("i18n", "localization"),
      c("analytics", "r"),
      c("visualization", "ggplot2")
    )),
    stringsAsFactors = FALSE
  )
  
  # Create PRDs
  for (i in 1:nrow(sample_data)) {
    prd <- createPRD(sample_data$title[i], sample_data$description[i], sample_data$author[i])
    manager <- addPRD(manager, prd)
    
    # Add tags
    for (tag in sample_data$tags_list[[i]]) {
      addTag(manager, prd@id, tag)
    }
  }
  
  # Update some statuses and priorities for variety
  if (length(manager@prds) >= 10) {
    prd_ids <- sapply(manager@prds, function(prd) prd@id)
    
    updatePRDStatus(manager, prd_ids[2], PRD_STATUS$IN_REVIEW)
    updatePRDStatus(manager, prd_ids[3], PRD_STATUS$APPROVED)
    updatePRDStatus(manager, prd_ids[4], PRD_STATUS$IN_DEVELOPMENT)
    updatePRDStatus(manager, prd_ids[5], PRD_STATUS$TESTING)
    updatePRDStatus(manager, prd_ids[6], PRD_STATUS$IMPLEMENTED)
    
    # Update priorities
    manager@prds[[3]]@priority <- PRIORITY$HIGH
    manager@prds[[4]]@priority <- PRIORITY$CRITICAL
    manager@prds[[9]]@priority <- PRIORITY$HIGH
    
    # Update completion percentages
    updatePRDCompletion(manager, prd_ids[4], 65)
    updatePRDCompletion(manager, prd_ids[5], 90)
    updatePRDCompletion(manager, prd_ids[6], 100)
  }
  
  return(manager)
})

# Method to export to JSON
setGeneric("exportToJSON", function(manager) standardGeneric("exportToJSON"))
setMethod("exportToJSON", "PRDManager", function(manager) {
  prd_list <- lapply(manager@prds, function(prd) {
    list(
      id = prd@id,
      title = prd@title,
      description = prd@description,
      author = prd@author,
      status = prd@status,
      priority = prd@priority,
      created_at = format(prd@created_at, "%Y-%m-%dT%H:%M:%S"),
      updated_at = format(prd@updated_at, "%Y-%m-%dT%H:%M:%S"),
      completion_percentage = prd@completion_percentage,
      tags = prd@tags
    )
  })
  
  return(toJSON(prd_list, pretty = TRUE, auto_unbox = TRUE))
})

# Utility functions for analysis
getCompletionStats <- function(manager) {
  if (length(manager@prds) == 0) {
    return(list(min = 0, max = 0, average = 0))
  }
  
  completions <- sapply(manager@prds, function(prd) prd@completion_percentage)
  
  return(list(
    min = min(completions),
    max = max(completions),
    average = mean(completions)
  ))
}

getPRDsNeedingAttention <- function(manager) {
  return(Filter(function(prd) {
    (prd@status == PRD_STATUS$IN_DEVELOPMENT && prd@completion_percentage < 50) ||
    (prd@priority == PRIORITY$CRITICAL && prd@status == PRD_STATUS$DRAFT) ||
    (prd@status == PRD_STATUS$TESTING && prd@completion_percentage < 80)
  }, manager@prds))
}

# Visualization functions
plotStatusDistribution <- function(manager) {
  analytics <- generateAnalytics(manager)
  
  if (length(analytics$status_counts) == 0) {
    cat("No data to plot\n")
    return(NULL)
  }
  
  status_df <- data.frame(
    Status = names(analytics$status_counts),
    Count = as.numeric(analytics$status_counts)
  )
  
  ggplot(status_df, aes(x = Status, y = Count, fill = Status)) +
    geom_bar(stat = "identity") +
    labs(title = "PRD Status Distribution", 
         x = "Status", y = "Count") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

plotCompletionByPriority <- function(manager) {
  if (length(manager@prds) == 0) {
    cat("No data to plot\n")
    return(NULL)
  }
  
  completion_df <- data.frame(
    Priority = factor(sapply(manager@prds, function(prd) priority_names[as.character(prd@priority)]),
                     levels = priority_names),
    Completion = sapply(manager@prds, function(prd) prd@completion_percentage),
    Status = factor(sapply(manager@prds, function(prd) status_names[as.character(prd@status)]))
  )
  
  ggplot(completion_df, aes(x = Priority, y = Completion, color = Priority)) +
    geom_boxplot() +
    geom_jitter(width = 0.2, alpha = 0.7) +
    scale_color_manual(values = priority_colors) +
    labs(title = "Completion Percentage by Priority",
         x = "Priority", y = "Completion %") +
    theme_minimal()
}

# Demo implementation
main <- function() {
  cat("PRD Management System v1.2.0 - R Implementation\n")
  cat("===============================================\n")
  
  # Initialize manager
  manager <- createPRDManager()
  
  # Load sample data
  manager <- loadSampleData(manager)
  
  # Print dashboard
  printDashboard(manager)
  
  # Demo operations
  cat("\n", paste(rep("=", 60), collapse = ""), "\n")
  cat("DEMO OPERATIONS\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  # Search demo
  search_results <- searchPRDs(manager, "authentication")
  cat("\nSearching for 'authentication' related PRDs:\n")
  if (length(search_results) > 0) {
    for (prd in search_results) {
      cat("  Found: PRD{ID='", prd@id, "', Title='", prd@title, "'}\n", sep = "")
    }
  }
  
  # Filter by status demo
  draft_prds <- getPRDsByStatus(manager, PRD_STATUS$DRAFT)
  cat("\nDraft PRDs (", length(draft_prds), "):\n", sep = "")
  if (length(draft_prds) > 0) {
    for (prd in draft_prds) {
      cat("  PRD{ID='", prd@id, "', Title='", prd@title, "'}\n", sep = "")
    }
  }
  
  # Priority filtering demo  
  critical_prds <- getPRDsByPriority(manager, PRIORITY$CRITICAL)
  cat("\nCritical Priority PRDs (", length(critical_prds), "):\n", sep = "")
  if (length(critical_prds) > 0) {
    for (prd in critical_prds) {
      cat("  🔥 PRD{ID='", prd@id, "', Title='", prd@title, "'}\n", sep = "")
    }
  }
  
  # PRDs needing attention
  needing_attention <- getPRDsNeedingAttention(manager)
  cat("\nPRDs Needing Attention (", length(needing_attention), "):\n", sep = "")
  if (length(needing_attention) > 0) {
    for (prd in needing_attention) {
      cat("  ⚠️  PRD{ID='", prd@id, "', Title='", prd@title, "', Priority=", 
          priority_names[as.character(prd@priority)], "}\n", sep = "")
    }
  }
  
  # Completion statistics
  stats <- getCompletionStats(manager)
  cat("\nCompletion Statistics:\n")
  cat("  Minimum:", stats$min, "%\n")
  cat("  Maximum:", stats$max, "%\n") 
  cat("  Average:", sprintf("%.1f%%", stats$average), "\n")
  
  # Export demo
  cat("\nExporting PRD data to JSON...\n")
  tryCatch({
    json_data <- exportToJSON(manager)
    cat("Export completed. JSON length:", nchar(json_data), "characters\n")
  }, error = function(e) {
    cat("Error exporting to JSON:", e$message, "\n")
  })
  
  # Generate plots
  cat("\nGenerating visualizations...\n")
  tryCatch({
    p1 <- plotStatusDistribution(manager)
    if (!is.null(p1)) {
      print(p1)
      cat("Status distribution plot generated\n")
    }
    
    p2 <- plotCompletionByPriority(manager)
    if (!is.null(p2)) {
      print(p2)
      cat("Completion by priority plot generated\n")
    }
  }, error = function(e) {
    cat("Error generating plots:", e$message, "\n")
  })
  
  cat("\nR PRD Management System demonstration completed!\n")
}

# Run the demo
if (interactive()) {
  main()
} else {
  # For non-interactive mode
  main()
}
