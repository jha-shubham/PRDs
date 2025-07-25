use std::collections::HashMap;
use std::fmt;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// PRD Management System - Rust Implementation
/// Version: 1.2.0 | Last Updated: July 25, 2025

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum PRDStatus {
    Draft = 0,
    InReview = 1,
    Approved = 2,
    InDevelopment = 3,
    Testing = 4,
    Implemented = 5,
    Archived = 6,
}

impl fmt::Display for PRDStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let status_str = match self {
            PRDStatus::Draft => "Draft",
            PRDStatus::InReview => "In Review",
            PRDStatus::Approved => "Approved",
            PRDStatus::InDevelopment => "In Development",
            PRDStatus::Testing => "Testing",
            PRDStatus::Implemented => "Implemented",
            PRDStatus::Archived => "Archived",
        };
        write!(f, "{}", status_str)
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Priority {
    Low = 1,
    Medium = 2,
    High = 3,
    Critical = 4,
}

impl fmt::Display for Priority {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let priority_str = match self {
            Priority::Low => "Low",
            Priority::Medium => "Medium",
            Priority::High => "High",
            Priority::Critical => "Critical",
        };
        write!(f, "{}", priority_str)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PRD {
    pub id: String,
    pub title: String,
    pub description: String,
    pub author: String,
    pub status: PRDStatus,
    pub priority: Priority,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub completion_percentage: u8,
    pub tags: Vec<String>,
}

impl PRD {
    pub fn new(title: String, description: String, author: String) -> Self {
        let now = Utc::now();
        Self {
            id: format!("PRD-{}", Uuid::new_v4()),
            title,
            description,
            author,
            status: PRDStatus::Draft,
            priority: Priority::Medium,
            created_at: now,
            updated_at: now,
            completion_percentage: 0,
            tags: Vec::new(),
        }
    }

    pub fn update_status(&mut self, new_status: PRDStatus) {
        self.status = new_status;
        self.updated_at = Utc::now();
    }

    pub fn set_completion_percentage(&mut self, percentage: u8) {
        self.completion_percentage = percentage.min(100);
        self.updated_at = Utc::now();
    }

    pub fn add_tag(&mut self, tag: String) {
        let tag = tag.trim().to_lowercase();
        if !tag.is_empty() && !self.tags.contains(&tag) {
            self.tags.push(tag);
            self.updated_at = Utc::now();
        }
    }

    pub fn set_priority(&mut self, priority: Priority) {
        self.priority = priority;
        self.updated_at = Utc::now();
    }
}

impl fmt::Display for PRD {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "PRD{{ID='{}', Title='{}', Status={}, Completion={}%}}",
            self.id, self.title, self.status, self.completion_percentage
        )
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Analytics {
    pub total_prds: usize,
    pub status_counts: HashMap<String, usize>,
    pub priority_counts: HashMap<String, usize>,
    pub average_completion: f64,
    pub top_authors: HashMap<String, usize>,
    pub tag_frequency: HashMap<String, usize>,
    pub last_updated: DateTime<Utc>,
}

impl Analytics {
    pub fn new() -> Self {
        Self {
            total_prds: 0,
            status_counts: HashMap::new(),
            priority_counts: HashMap::new(),
            average_completion: 0.0,
            top_authors: HashMap::new(),
            tag_frequency: HashMap::new(),
            last_updated: Utc::now(),
        }
    }
}

pub struct PRDManager {
    prds: Vec<PRD>,
    prd_index: HashMap<String, usize>,
    analytics: Analytics,
}

impl PRDManager {
    pub fn new() -> Self {
        Self {
            prds: Vec::new(),
            prd_index: HashMap::new(),
            analytics: Analytics::new(),
        }
    }

    pub fn create_prd(&mut self, title: String, description: String, author: String) -> String {
        let prd = PRD::new(title, description, author);
        let id = prd.id.clone();
        
        self.prd_index.insert(id.clone(), self.prds.len());
        self.prds.push(prd);
        self.update_analytics();

        println!("PRD created successfully: {}", id);
        id
    }

    pub fn get_prd(&self, id: &str) -> Option<&PRD> {
        self.prd_index.get(id).and_then(|&index| self.prds.get(index))
    }

    pub fn get_prd_mut(&mut self, id: &str) -> Option<&mut PRD> {
        if let Some(&index) = self.prd_index.get(id) {
            self.prds.get_mut(index)
        } else {
            None
        }
    }

    pub fn get_all_prds(&self) -> &[PRD] {
        &self.prds
    }

    pub fn get_prds_by_status(&self, status: PRDStatus) -> Vec<&PRD> {
        self.prds.iter().filter(|prd| prd.status == status).collect()
    }

    pub fn get_prds_by_priority(&self, priority: Priority) -> Vec<&PRD> {
        self.prds.iter().filter(|prd| prd.priority == priority).collect()
    }

    pub fn search_prds(&self, search_term: &str) -> Vec<&PRD> {
        let search_term = search_term.to_lowercase();
        self.prds
            .iter()
            .filter(|prd| {
                prd.title.to_lowercase().contains(&search_term)
                    || prd.description.to_lowercase().contains(&search_term)
                    || prd.tags.iter().any(|tag| tag.contains(&search_term))
            })
            .collect()
    }

    pub fn update_prd_status(&mut self, id: &str, new_status: PRDStatus) -> bool {
        if let Some(prd) = self.get_prd_mut(id) {
            prd.update_status(new_status);
            self.update_analytics();
            println!("PRD {} status updated to: {}", id, new_status);
            true
        } else {
            false
        }
    }

    fn update_analytics(&mut self) {
        self.analytics.total_prds = self.prds.len();
        self.analytics.status_counts.clear();
        self.analytics.priority_counts.clear();
        self.analytics.top_authors.clear();
        self.analytics.tag_frequency.clear();

        let mut total_completion = 0u32;

        for prd in &self.prds {
            // Count by status
            *self.analytics.status_counts
                .entry(prd.status.to_string())
                .or_insert(0) += 1;

            // Count by priority
            *self.analytics.priority_counts
                .entry(prd.priority.to_string())
                .or_insert(0) += 1;

            // Count by author
            *self.analytics.top_authors
                .entry(prd.author.clone())
                .or_insert(0) += 1;

            // Count tags
            for tag in &prd.tags {
                *self.analytics.tag_frequency
                    .entry(tag.clone())
                    .or_insert(0) += 1;
            }

            total_completion += prd.completion_percentage as u32;
        }

        self.analytics.average_completion = if self.prds.is_empty() {
            0.0
        } else {
            total_completion as f64 / self.prds.len() as f64
        };

        self.analytics.last_updated = Utc::now();
    }

    pub fn get_analytics(&mut self) -> &Analytics {
        self.update_analytics();
        &self.analytics
    }

    pub fn export_to_json(&self) -> Result<String, serde_json::Error> {
        serde_json::to_string_pretty(&self.prds)
    }

    pub fn print_dashboard(&mut self) {
        println!("\n{}", "=".repeat(60));
        println!("PRD MANAGEMENT SYSTEM - DASHBOARD");
        println!("{}", "=".repeat(60));

        let analytics = self.get_analytics();

        println!("Total PRDs: {}", analytics.total_prds);
        println!("Average Completion: {:.1}%", analytics.average_completion);

        println!("\nStatus Distribution:");
        for (status, count) in &analytics.status_counts {
            println!("  {}: {}", status, count);
        }

        println!("\nPriority Distribution:");
        for (priority, count) in &analytics.priority_counts {
            println!("  {}: {}", priority, count);
        }

        println!("\nTop Authors:");
        let mut authors: Vec<_> = analytics.top_authors.iter().collect();
        authors.sort_by(|a, b| b.1.cmp(a.1));
        for (author, count) in authors.iter().take(5) {
            println!("  {}: {} PRDs", author, count);
        }

        println!("\nMost Used Tags:");
        let mut tags: Vec<_> = analytics.tag_frequency.iter().collect();
        tags.sort_by(|a, b| b.1.cmp(a.1));
        for (tag, count) in tags.iter().take(5) {
            println!("  #{}: {} times", tag, count);
        }

        println!("\nRecent PRDs:");
        let mut recent_prds = self.prds.clone();
        recent_prds.sort_by(|a, b| b.updated_at.cmp(&a.updated_at));
        for prd in recent_prds.iter().take(5) {
            println!("  {}", prd);
        }
    }

    pub fn load_sample_data(&mut self) {
        let sample_data = vec![
            ("User Authentication System", "Implement secure login and registration", "Dev Team", vec!["security", "authentication"]),
            ("Dark Mode Theme", "Add dark theme option for better UX", "UX Team", vec!["ui", "theme"]),
            ("Payment Gateway Integration", "Integrate secure payment processing", "Product Team", vec!["payment", "integration"]),
            ("API Rate Limiting", "Implement API rate limiting for security", "Backend Team", vec!["api", "security"]),
            ("Mobile App Redesign", "Complete redesign of mobile application", "Design Team", vec!["mobile", "design"]),
            ("Real-time Notifications", "Add real-time notification system", "Full Stack Team", vec!["notifications", "realtime"]),
            ("Performance Optimization", "Optimize database queries and caching", "Database Team", vec!["performance", "database"]),
            ("Multi-language Support", "Add internationalization support", "Localization Team", vec!["i18n", "localization"]),
        ];

        for (title, description, author, tags) in sample_data {
            let id = self.create_prd(title.to_string(), description.to_string(), author.to_string());
            if let Some(prd) = self.get_prd_mut(&id) {
                for tag in tags {
                    prd.add_tag(tag.to_string());
                }
            }
        }

        // Update some statuses and priorities for variety
        let prd_ids: Vec<String> = self.prds.iter().map(|prd| prd.id.clone()).collect();
        
        if prd_ids.len() >= 8 {
            self.update_prd_status(&prd_ids[1], PRDStatus::InReview);
            self.update_prd_status(&prd_ids[2], PRDStatus::Approved);
            self.update_prd_status(&prd_ids[3], PRDStatus::InDevelopment);
            self.update_prd_status(&prd_ids[4], PRDStatus::Testing);
            self.update_prd_status(&prd_ids[5], PRDStatus::Implemented);

            if let Some(prd) = self.get_prd_mut(&prd_ids[2]) {
                prd.set_priority(Priority::High);
            }
            if let Some(prd) = self.get_prd_mut(&prd_ids[3]) {
                prd.set_completion_percentage(65);
                prd.set_priority(Priority::Critical);
            }
            if let Some(prd) = self.get_prd_mut(&prd_ids[4]) {
                prd.set_completion_percentage(90);
            }
            if let Some(prd) = self.get_prd_mut(&prd_ids[5]) {
                prd.set_completion_percentage(100);
            }
        }
    }

    pub fn get_completion_stats(&self) -> (u8, u8, f64) {
        if self.prds.is_empty() {
            return (0, 0, 0.0);
        }

        let completions: Vec<u8> = self.prds.iter().map(|prd| prd.completion_percentage).collect();
        let min_completion = *completions.iter().min().unwrap_or(&0);
        let max_completion = *completions.iter().max().unwrap_or(&0);
        let avg_completion = completions.iter().sum::<u8>() as f64 / completions.len() as f64;

        (min_completion, max_completion, avg_completion)
    }
}

impl Default for PRDManager {
    fn default() -> Self {
        Self::new()
    }
}

fn main() {
    println!("PRD Management System v1.2.0 - Rust Implementation");
    println!("====================================================");

    // Initialize the manager
    let mut manager = PRDManager::new();

    // Load sample data
    manager.load_sample_data();

    // Display dashboard
    manager.print_dashboard();

    // Demo operations
    println!("\n{}", "=".repeat(60));
    println!("DEMO OPERATIONS");
    println!("{}", "=".repeat(60));

    // Search demo
    let search_results = manager.search_prds("authentication");
    println!("\nSearching for 'authentication' related PRDs:");
    for prd in search_results {
        println!("  Found: {}", prd);
    }

    // Filter by status demo
    let draft_prds = manager.get_prds_by_status(PRDStatus::Draft);
    println!("\nDraft PRDs ({}):", draft_prds.len());
    for prd in draft_prds {
        println!("  {}", prd);
    }

    // Completion statistics
    let (min, max, avg) = manager.get_completion_stats();
    println!("\nCompletion Statistics:");
    println!("  Minimum: {}%", min);
    println!("  Maximum: {}%", max);
    println!("  Average: {:.1}%", avg);

    // Export demo
    println!("\nExporting PRD data to JSON...");
    match manager.export_to_json() {
        Ok(json_data) => {
            println!("Export completed. JSON length: {} characters", json_data.len());
        }
        Err(e) => {
            eprintln!("Error exporting to JSON: {}", e);
        }
    }

    println!("\nRust PRD Management System demonstration completed!");
}
