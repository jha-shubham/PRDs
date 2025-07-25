package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"sort"
	"strings"
	"time"
)

// PRDStatus represents the current status of a PRD
type PRDStatus int

const (
	Draft PRDStatus = iota
	InReview
	Approved
	InDevelopment
	Testing
	Implemented
	Archived
)

var statusNames = map[PRDStatus]string{
	Draft:         "Draft",
	InReview:      "InReview",
	Approved:      "Approved",
	InDevelopment: "InDevelopment",
	Testing:       "Testing",
	Implemented:   "Implemented",
	Archived:      "Archived",
}

// Priority represents the priority level of a PRD
type Priority int

const (
	Low Priority = iota + 1
	Medium
	High
	Critical
)

var priorityNames = map[Priority]string{
	Low:      "Low",
	Medium:   "Medium",
	High:     "High",
	Critical: "Critical",
}

// PRD represents a Product Requirements Document
type PRD struct {
	ID                   string    `json:"id"`
	Title                string    `json:"title"`
	Description          string    `json:"description"`
	Author               string    `json:"author"`
	Status               PRDStatus `json:"status"`
	Priority             Priority  `json:"priority"`
	CreatedAt            time.Time `json:"created_at"`
	UpdatedAt            time.Time `json:"updated_at"`
	CompletionPercentage int       `json:"completion_percentage"`
	Tags                 []string  `json:"tags"`
}

// NewPRD creates a new PRD instance
func NewPRD(title, description, author string) *PRD {
	return &PRD{
		ID:                   generateID(),
		Title:                title,
		Description:          description,
		Author:               author,
		Status:               Draft,
		Priority:             Medium,
		CreatedAt:            time.Now().UTC(),
		UpdatedAt:            time.Now().UTC(),
		CompletionPercentage: 0,
		Tags:                 make([]string, 0),
	}
}

// generateID creates a unique identifier for PRDs
func generateID() string {
	timestamp := time.Now().UnixMilli()
	randomNum := rand.Intn(9000) + 1000
	return fmt.Sprintf("PRD-%d-%d", timestamp, randomNum)
}

// UpdateStatus changes the status of the PRD
func (p *PRD) UpdateStatus(newStatus PRDStatus) {
	p.Status = newStatus
	p.UpdatedAt = time.Now().UTC()
}

// SetCompletionPercentage sets the completion percentage (0-100)
func (p *PRD) SetCompletionPercentage(percentage int) {
	if percentage < 0 {
		percentage = 0
	}
	if percentage > 100 {
		percentage = 100
	}
	p.CompletionPercentage = percentage
	p.UpdatedAt = time.Now().UTC()
}

// AddTag adds a tag to the PRD
func (p *PRD) AddTag(tag string) {
	tag = strings.TrimSpace(strings.ToLower(tag))
	if tag != "" {
		// Check if tag already exists
		for _, existingTag := range p.Tags {
			if existingTag == tag {
				return
			}
		}
		p.Tags = append(p.Tags, tag)
	}
}

// String returns a string representation of the PRD
func (p *PRD) String() string {
	return fmt.Sprintf("PRD{ID='%s', Title='%s', Status=%s, Completion=%d%%}",
		p.ID, p.Title, statusNames[p.Status], p.CompletionPercentage)
}

// PRDManager manages a collection of PRDs
type PRDManager struct {
	prds      []*PRD
	prdIndex  map[string]*PRD
	analytics *Analytics
}

// Analytics holds statistical information about PRDs
type Analytics struct {
	TotalPRDs         int                    `json:"total_prds"`
	StatusCounts      map[string]int         `json:"status_counts"`
	PriorityCounts    map[string]int         `json:"priority_counts"`
	AverageCompletion float64                `json:"average_completion"`
	TopAuthors        map[string]int         `json:"top_authors"`
	TagFrequency      map[string]int         `json:"tag_frequency"`
	LastUpdated       time.Time              `json:"last_updated"`
}

// NewPRDManager creates a new instance of PRDManager
func NewPRDManager() *PRDManager {
	return &PRDManager{
		prds:     make([]*PRD, 0),
		prdIndex: make(map[string]*PRD),
		analytics: &Analytics{
			StatusCounts:   make(map[string]int),
			PriorityCounts: make(map[string]int),
			TopAuthors:     make(map[string]int),
			TagFrequency:   make(map[string]int),
		},
	}
}

// CreatePRD creates a new PRD and adds it to the manager
func (pm *PRDManager) CreatePRD(title, description, author string) string {
	prd := NewPRD(title, description, author)
	pm.prds = append(pm.prds, prd)
	pm.prdIndex[prd.ID] = prd
	pm.updateAnalytics()

	fmt.Printf("PRD created successfully: %s\n", prd.ID)
	return prd.ID
}

// GetPRD retrieves a PRD by its ID
func (pm *PRDManager) GetPRD(id string) *PRD {
	if prd, exists := pm.prdIndex[id]; exists {
		return prd
	}
	return nil
}

// GetAllPRDs returns all PRDs
func (pm *PRDManager) GetAllPRDs() []*PRD {
	result := make([]*PRD, len(pm.prds))
	copy(result, pm.prds)
	return result
}

// GetPRDsByStatus returns PRDs filtered by status
func (pm *PRDManager) GetPRDsByStatus(status PRDStatus) []*PRD {
	var result []*PRD
	for _, prd := range pm.prds {
		if prd.Status == status {
			result = append(result, prd)
		}
	}
	return result
}

// GetPRDsByPriority returns PRDs filtered by priority
func (pm *PRDManager) GetPRDsByPriority(priority Priority) []*PRD {
	var result []*PRD
	for _, prd := range pm.prds {
		if prd.Priority == priority {
			result = append(result, prd)
		}
	}
	return result
}

// SearchPRDs searches for PRDs by title, description, or tags
func (pm *PRDManager) SearchPRDs(searchTerm string) []*PRD {
	searchTerm = strings.ToLower(searchTerm)
	var result []*PRD

	for _, prd := range pm.prds {
		// Search in title and description
		if strings.Contains(strings.ToLower(prd.Title), searchTerm) ||
			strings.Contains(strings.ToLower(prd.Description), searchTerm) {
			result = append(result, prd)
			continue
		}

		// Search in tags
		for _, tag := range prd.Tags {
			if strings.Contains(tag, searchTerm) {
				result = append(result, prd)
				break
			}
		}
	}

	return result
}

// UpdatePRDStatus updates the status of a PRD
func (pm *PRDManager) UpdatePRDStatus(id string, newStatus PRDStatus) bool {
	if prd := pm.GetPRD(id); prd != nil {
		prd.UpdateStatus(newStatus)
		pm.updateAnalytics()
		fmt.Printf("PRD %s status updated to: %s\n", id, statusNames[newStatus])
		return true
	}
	return false
}

// updateAnalytics recalculates all analytics
func (pm *PRDManager) updateAnalytics() {
	pm.analytics.TotalPRDs = len(pm.prds)
	pm.analytics.StatusCounts = make(map[string]int)
	pm.analytics.PriorityCounts = make(map[string]int)
	pm.analytics.TopAuthors = make(map[string]int)
	pm.analytics.TagFrequency = make(map[string]int)

	totalCompletion := 0

	for _, prd := range pm.prds {
		// Count by status
		pm.analytics.StatusCounts[statusNames[prd.Status]]++

		// Count by priority
		pm.analytics.PriorityCounts[priorityNames[prd.Priority]]++

		// Count by author
		pm.analytics.TopAuthors[prd.Author]++

		// Count tags
		for _, tag := range prd.Tags {
			pm.analytics.TagFrequency[tag]++
		}

		totalCompletion += prd.CompletionPercentage
	}

	if len(pm.prds) > 0 {
		pm.analytics.AverageCompletion = float64(totalCompletion) / float64(len(pm.prds))
	}

	pm.analytics.LastUpdated = time.Now().UTC()
}

// GetAnalytics returns the current analytics
func (pm *PRDManager) GetAnalytics() *Analytics {
	pm.updateAnalytics()
	return pm.analytics
}

// ExportToJSON exports all PRDs to JSON format
func (pm *PRDManager) ExportToJSON() (string, error) {
	data, err := json.MarshalIndent(pm.prds, "", "  ")
	if err != nil {
		return "", err
	}
	return string(data), nil
}

// PrintDashboard displays a comprehensive dashboard
func (pm *PRDManager) PrintDashboard() {
	fmt.Println("\n" + strings.Repeat("=", 60))
	fmt.Println("PRD MANAGEMENT SYSTEM - DASHBOARD")
	fmt.Println(strings.Repeat("=", 60))

	analytics := pm.GetAnalytics()

	fmt.Printf("Total PRDs: %d\n", analytics.TotalPRDs)
	fmt.Printf("Average Completion: %.1f%%\n", analytics.AverageCompletion)

	fmt.Println("\nStatus Distribution:")
	for status, count := range analytics.StatusCounts {
		fmt.Printf("  %s: %d\n", status, count)
	}

	fmt.Println("\nPriority Distribution:")
	for priority, count := range analytics.PriorityCounts {
		fmt.Printf("  %s: %d\n", priority, count)
	}

	fmt.Println("\nTop Authors:")
	type authorCount struct {
		author string
		count  int
	}
	var authors []authorCount
	for author, count := range analytics.TopAuthors {
		authors = append(authors, authorCount{author, count})
	}
	sort.Slice(authors, func(i, j int) bool {
		return authors[i].count > authors[j].count
	})
	for i, ac := range authors {
		if i >= 5 {
			break
		}
		fmt.Printf("  %s: %d PRDs\n", ac.author, ac.count)
	}

	fmt.Println("\nRecent PRDs:")
	recentPRDs := pm.GetAllPRDs()
	sort.Slice(recentPRDs, func(i, j int) bool {
		return recentPRDs[i].UpdatedAt.After(recentPRDs[j].UpdatedAt)
	})
	for i, prd := range recentPRDs {
		if i >= 5 {
			break
		}
		fmt.Printf("  %s\n", prd)
	}
}

// LoadSampleData loads sample PRD data for demonstration
func (pm *PRDManager) LoadSampleData() {
	sampleData := []struct {
		title       string
		description string
		author      string
		tags        []string
	}{
		{"User Authentication System", "Implement secure login and registration", "Dev Team", []string{"security", "authentication"}},
		{"Dark Mode Theme", "Add dark theme option for better UX", "UX Team", []string{"ui", "theme"}},
		{"Payment Gateway Integration", "Integrate secure payment processing", "Product Team", []string{"payment", "integration"}},
		{"API Rate Limiting", "Implement API rate limiting for security", "Backend Team", []string{"api", "security"}},
		{"Mobile App Redesign", "Complete redesign of mobile application", "Design Team", []string{"mobile", "design"}},
		{"Real-time Notifications", "Add real-time notification system", "Full Stack Team", []string{"notifications", "realtime"}},
		{"Performance Optimization", "Optimize database queries and caching", "Database Team", []string{"performance", "database"}},
		{"Multi-language Support", "Add internationalization support", "Localization Team", []string{"i18n", "localization"}},
	}

	for _, data := range sampleData {
		id := pm.CreatePRD(data.title, data.description, data.author)
		if prd := pm.GetPRD(id); prd != nil {
			for _, tag := range data.tags {
				prd.AddTag(tag)
			}
		}
	}

	// Update some statuses for variety
	allPRDs := pm.GetAllPRDs()
	if len(allPRDs) >= 8 {
		pm.UpdatePRDStatus(allPRDs[1].ID, InReview)
		pm.UpdatePRDStatus(allPRDs[2].ID, Approved)
		pm.UpdatePRDStatus(allPRDs[3].ID, InDevelopment)
		pm.UpdatePRDStatus(allPRDs[4].ID, Testing)
		pm.UpdatePRDStatus(allPRDs[5].ID, Implemented)

		allPRDs[3].SetCompletionPercentage(65)
		allPRDs[4].SetCompletionPercentage(90)
		allPRDs[5].SetCompletionPercentage(100)
	}
}

func main() {
	fmt.Println("PRD Management System v1.2.0 - Go Implementation")
	fmt.Println("==================================================")

	// Initialize the manager
	manager := NewPRDManager()

	// Load sample data
	manager.LoadSampleData()

	// Display dashboard
	manager.PrintDashboard()

	// Demo operations
	fmt.Println("\n" + strings.Repeat("=", 60))
	fmt.Println("DEMO OPERATIONS")
	fmt.Println(strings.Repeat("=", 60))

	// Search demo
	searchResults := manager.SearchPRDs("authentication")
	fmt.Printf("\nSearching for 'authentication' related PRDs:\n")
	for _, prd := range searchResults {
		fmt.Printf("  Found: %s\n", prd)
	}

	// Filter by status demo
	draftPRDs := manager.GetPRDsByStatus(Draft)
	fmt.Printf("\nDraft PRDs (%d):\n", len(draftPRDs))
	for _, prd := range draftPRDs {
		fmt.Printf("  %s\n", prd)
	}

	// Analytics demo
	analytics := manager.GetAnalytics()
	analyticsJSON, err := json.MarshalIndent(analytics, "", "  ")
	if err != nil {
		log.Printf("Error marshaling analytics: %v", err)
	} else {
		fmt.Println("\nAnalytics Summary:")
		fmt.Printf("Last updated: %s\n", analytics.LastUpdated.Format("2006-01-02 15:04:05"))
		fmt.Printf("Analytics data size: %d bytes\n", len(analyticsJSON))
	}

	// Export demo
	fmt.Println("\nExporting PRD data to JSON...")
	jsonData, err := manager.ExportToJSON()
	if err != nil {
		log.Printf("Error exporting to JSON: %v", err)
	} else {
		fmt.Printf("Export completed. JSON length: %d characters\n", len(jsonData))
	}

	fmt.Println("\nGo PRD Management System demonstration completed!")
}
