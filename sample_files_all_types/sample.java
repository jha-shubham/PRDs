/**
 * PRD Management System - Java Implementation
 * Version: 1.2.0 | Last Updated: July 25, 2025
 * 
 * Main application class for the PRD Management System
 * Provides core functionality for managing Product Requirements Documents
 */

package com.company.prd.management;

import java.util.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.stream.Collectors;

/**
 * Enumeration for PRD Status values
 */
enum PRDStatus {
    DRAFT("Draft", "#FFC107"),
    IN_REVIEW("In Review", "#17A2B8"),
    APPROVED("Approved", "#28A745"),
    IN_DEVELOPMENT("In Development", "#6F42C1"),
    TESTING("Testing", "#FD7E14"),
    IMPLEMENTED("Implemented", "#20C997"),
    ARCHIVED("Archived", "#6C757D");

    private final String displayName;
    private final String color;

    PRDStatus(String displayName, String color) {
        this.displayName = displayName;
        this.color = color;
    }

    public String getDisplayName() { return displayName; }
    public String getColor() { return color; }
}

/**
 * Enumeration for PRD Categories
 */
enum PRDCategory {
    FEATURE("Feature", "New functionality or capabilities"),
    ENHANCEMENT("Enhancement", "Improvements to existing features"),
    BUG_FIX("Bug Fix", "Fixes for identified issues"),
    NEW_PRODUCT("New Product", "Entirely new product development"),
    MAINTENANCE("Maintenance", "System maintenance and updates");

    private final String displayName;
    private final String description;

    PRDCategory(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }

    public String getDisplayName() { return displayName; }
    public String getDescription() { return description; }
}

/**
 * PRD (Product Requirements Document) data class
 */
class PRD {
    private String id;
    private String title;
    private String description;
    private String author;
    private PRDCategory category;
    private PRDStatus status;
    private int priority;
    private int estimatedEffort;
    private int completionPercentage;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<String> tags;
    private String version;

    // Constructor
    public PRD(String title, String description, String author, PRDCategory category) {
        this.id = generateId();
        this.title = title;
        this.description = description;
        this.author = author;
        this.category = category;
        this.status = PRDStatus.DRAFT;
        this.priority = 3; // Default medium priority
        this.estimatedEffort = 0;
        this.completionPercentage = 0;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.tags = new ArrayList<>();
        this.version = "1.0.0";
    }

    private String generateId() {
        return "PRD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    // Getters and Setters
    public String getId() { return id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; updateTimestamp(); }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; updateTimestamp(); }
    public String getAuthor() { return author; }
    public PRDCategory getCategory() { return category; }
    public PRDStatus getStatus() { return status; }
    public void setStatus(PRDStatus status) { this.status = status; updateTimestamp(); }
    public int getPriority() { return priority; }
    public void setPriority(int priority) { this.priority = Math.max(1, Math.min(4, priority)); updateTimestamp(); }
    public int getEstimatedEffort() { return estimatedEffort; }
    public void setEstimatedEffort(int estimatedEffort) { this.estimatedEffort = estimatedEffort; updateTimestamp(); }
    public int getCompletionPercentage() { return completionPercentage; }
    public void setCompletionPercentage(int completionPercentage) { 
        this.completionPercentage = Math.max(0, Math.min(100, completionPercentage)); 
        updateTimestamp(); 
    }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public List<String> getTags() { return new ArrayList<>(tags); }
    public void addTag(String tag) { if (!tags.contains(tag)) { tags.add(tag); updateTimestamp(); } }
    public void removeTag(String tag) { tags.remove(tag); updateTimestamp(); }
    public String getVersion() { return version; }
    public void setVersion(String version) { this.version = version; updateTimestamp(); }

    private void updateTimestamp() {
        this.updatedAt = LocalDateTime.now();
    }

    @Override
    public String toString() {
        return String.format("PRD{id='%s', title='%s', status=%s, priority=%d, completion=%d%%}", 
                           id, title, status.getDisplayName(), priority, completionPercentage);
    }
}

/**
 * PRD Manager class - handles all PRD operations
 */
class PRDManager {
    private Map<String, PRD> prds;
    private DateTimeFormatter formatter;

    public PRDManager() {
        this.prds = new HashMap<>();
        this.formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        loadSampleData();
    }

    public String createPRD(String title, String description, String author, PRDCategory category) {
        PRD prd = new PRD(title, description, author, category);
        prds.put(prd.getId(), prd);
        System.out.println("PRD created successfully: " + prd.getId());
        return prd.getId();
    }

    public PRD getPRD(String id) {
        return prds.get(id);
    }

    public List<PRD> getAllPRDs() {
        return new ArrayList<>(prds.values());
    }

    public List<PRD> getPRDsByStatus(PRDStatus status) {
        return prds.values().stream()
                   .filter(prd -> prd.getStatus() == status)
                   .collect(Collectors.toList());
    }

    public List<PRD> getPRDsByCategory(PRDCategory category) {
        return prds.values().stream()
                   .filter(prd -> prd.getCategory() == category)
                   .collect(Collectors.toList());
    }

    public List<PRD> searchPRDs(String searchTerm) {
        String term = searchTerm.toLowerCase();
        return prds.values().stream()
                   .filter(prd -> prd.getTitle().toLowerCase().contains(term) || 
                                 prd.getDescription().toLowerCase().contains(term))
                   .collect(Collectors.toList());
    }

    public boolean updatePRDStatus(String id, PRDStatus newStatus) {
        PRD prd = prds.get(id);
        if (prd != null) {
            prd.setStatus(newStatus);
            System.out.println("PRD " + id + " status updated to: " + newStatus.getDisplayName());
            return true;
        }
        return false;
    }

    public Map<String, Object> getStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalPRDs", prds.size());
        
        Map<String, Long> statusCounts = prds.values().stream()
            .collect(Collectors.groupingBy(prd -> prd.getStatus().getDisplayName(), Collectors.counting()));
        stats.put("byStatus", statusCounts);
        
        Map<String, Long> categoryCounts = prds.values().stream()
            .collect(Collectors.groupingBy(prd -> prd.getCategory().getDisplayName(), Collectors.counting()));
        stats.put("byCategory", categoryCounts);
        
        double avgCompletion = prds.values().stream()
            .mapToInt(PRD::getCompletionPercentage)
            .average()
            .orElse(0.0);
        stats.put("averageCompletion", Math.round(avgCompletion * 100.0) / 100.0);
        
        return stats;
    }

    public void printDashboard() {
        System.out.println("\n" + "=".repeat(60));
        System.out.println("PRD MANAGEMENT SYSTEM - DASHBOARD");
        System.out.println("=".repeat(60));
        
        Map<String, Object> stats = getStatistics();
        System.out.println("Total PRDs: " + stats.get("totalPRDs"));
        System.out.println("Average Completion: " + stats.get("averageCompletion") + "%");
        
        System.out.println("\nStatus Distribution:");
        @SuppressWarnings("unchecked")
        Map<String, Long> statusCounts = (Map<String, Long>) stats.get("byStatus");
        statusCounts.forEach((status, count) -> 
            System.out.println("  " + status + ": " + count));
        
        System.out.println("\nCategory Distribution:");
        @SuppressWarnings("unchecked")
        Map<String, Long> categoryCounts = (Map<String, Long>) stats.get("byCategory");
        categoryCounts.forEach((category, count) -> 
            System.out.println("  " + category + ": " + count));
        
        System.out.println("\nRecent PRDs:");
        prds.values().stream()
            .sorted((a, b) -> b.getUpdatedAt().compareTo(a.getUpdatedAt()))
            .limit(5)
            .forEach(prd -> System.out.println("  " + prd));
    }

    private void loadSampleData() {
        createPRD("User Authentication System", "Implement secure login and registration", "Dev Team", PRDCategory.FEATURE);
        createPRD("Dark Mode Theme", "Add dark theme option for better UX", "UX Team", PRDCategory.ENHANCEMENT);
        createPRD("Payment Gateway Integration", "Integrate secure payment processing", "Product Team", PRDCategory.FEATURE);
        createPRD("Login Validation Bug", "Fix validation error in login form", "QA Team", PRDCategory.BUG_FIX);
        createPRD("Mobile App Redesign", "Complete redesign of mobile application", "Design Team", PRDCategory.NEW_PRODUCT);
        
        // Update some statuses for variety
        List<PRD> prdList = getAllPRDs();
        if (prdList.size() >= 5) {
            updatePRDStatus(prdList.get(1).getId(), PRDStatus.IN_REVIEW);
            updatePRDStatus(prdList.get(2).getId(), PRDStatus.APPROVED);
            updatePRDStatus(prdList.get(3).getId(), PRDStatus.IMPLEMENTED);
            prdList.get(4).setCompletionPercentage(75);
        }
    }
}

/**
 * Main application class
 */
public class PRDManagementSystem {
    public static void main(String[] args) {
        System.out.println("PRD Management System v1.2.0");
        System.out.println("Initializing system...");
        
        PRDManager manager = new PRDManager();
        
        // Display dashboard
        manager.printDashboard();
        
        // Demo some operations
        System.out.println("\n" + "=".repeat(60));
        System.out.println("DEMO OPERATIONS");
        System.out.println("=".repeat(60));
        
        // Search demo
        List<PRD> searchResults = manager.searchPRDs("login");
        System.out.println("\nSearching for 'login' related PRDs:");
        searchResults.forEach(prd -> System.out.println("  Found: " + prd));
        
        // Filter by status demo
        List<PRD> draftPRDs = manager.getPRDsByStatus(PRDStatus.DRAFT);
        System.out.println("\nDraft PRDs (" + draftPRDs.size() + "):");
        draftPRDs.forEach(prd -> System.out.println("  " + prd));
        
        System.out.println("\nPRD Management System demonstration completed!");
    }
}