/*
 * PRD Management System - C Implementation
 * Version: 1.2.0 | Last Updated: July 25, 2025
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MAX_PRD_COUNT 1000
#define MAX_STRING_LENGTH 256
#define MAX_ID_LENGTH 32

typedef enum {
    PRD_DRAFT = 0,
    PRD_IN_REVIEW = 1,
    PRD_APPROVED = 2,
    PRD_IN_DEVELOPMENT = 3,
    PRD_TESTING = 4,
    PRD_IMPLEMENTED = 5,
    PRD_ARCHIVED = 6
} prd_status_t;

typedef enum {
    PRIORITY_LOW = 1,
    PRIORITY_MEDIUM = 2,
    PRIORITY_HIGH = 3,
    PRIORITY_CRITICAL = 4
} priority_t;

typedef struct {
    char id[MAX_ID_LENGTH];
    char title[MAX_STRING_LENGTH];
    char description[MAX_STRING_LENGTH * 2];
    char author[MAX_STRING_LENGTH];
    prd_status_t status;
    priority_t priority;
    time_t created_at;
    time_t updated_at;
    int completion_percentage;
    int is_active;
} prd_t;

typedef struct {
    prd_t prds[MAX_PRD_COUNT];
    int count;
} prd_manager_t;

/* Function prototypes */
void init_prd_manager(prd_manager_t* manager);
int create_prd(prd_manager_t* manager, const char* title, const char* description, const char* author);
prd_t* find_prd_by_id(prd_manager_t* manager, const char* id);
int update_prd_status(prd_manager_t* manager, const char* id, prd_status_t status);
void print_prd_statistics(prd_manager_t* manager);
void generate_prd_id(char* id_buffer);
const char* status_to_string(prd_status_t status);
const char* priority_to_string(priority_t priority);

/* Implementation */
void init_prd_manager(prd_manager_t* manager) {
    if (manager == NULL) return;
    
    manager->count = 0;
    memset(manager->prds, 0, sizeof(manager->prds));
    
    printf("PRD Manager initialized successfully\\n");
}

int create_prd(prd_manager_t* manager, const char* title, const char* description, const char* author) {
    if (manager == NULL || title == NULL || description == NULL || author == NULL) {
        printf("Error: Invalid parameters for PRD creation\\n");
        return -1;
    }
    
    if (manager->count >= MAX_PRD_COUNT) {
        printf("Error: Maximum PRD count reached\\n");
        return -1;
    }
    
    prd_t* new_prd = &manager->prds[manager->count];
    
    // Generate unique ID
    generate_prd_id(new_prd->id);
    
    // Copy strings safely
    strncpy(new_prd->title, title, MAX_STRING_LENGTH - 1);
    new_prd->title[MAX_STRING_LENGTH - 1] = '\\0';
    
    strncpy(new_prd->description, description, (MAX_STRING_LENGTH * 2) - 1);
    new_prd->description[(MAX_STRING_LENGTH * 2) - 1] = '\\0';
    
    strncpy(new_prd->author, author, MAX_STRING_LENGTH - 1);
    new_prd->author[MAX_STRING_LENGTH - 1] = '\\0';
    
    // Set default values
    new_prd->status = PRD_DRAFT;
    new_prd->priority = PRIORITY_MEDIUM;
    new_prd->created_at = time(NULL);
    new_prd->updated_at = new_prd->created_at;
    new_prd->completion_percentage = 0;
    new_prd->is_active = 1;
    
    manager->count++;
    
    printf("PRD created successfully: %s\\n", new_prd->id);
    return manager->count - 1; // Return index
}

prd_t* find_prd_by_id(prd_manager_t* manager, const char* id) {
    if (manager == NULL || id == NULL) return NULL;
    
    for (int i = 0; i < manager->count; i++) {
        if (manager->prds[i].is_active && strcmp(manager->prds[i].id, id) == 0) {
            return &manager->prds[i];
        }
    }
    
    return NULL;
}

int update_prd_status(prd_manager_t* manager, const char* id, prd_status_t status) {
    prd_t* prd = find_prd_by_id(manager, id);
    if (prd == NULL) {
        printf("Error: PRD with ID %s not found\\n", id);
        return -1;
    }
    
    prd->status = status;
    prd->updated_at = time(NULL);
    
    printf("PRD %s status updated to: %s\\n", id, status_to_string(status));
    return 0;
}

void print_prd_statistics(prd_manager_t* manager) {
    if (manager == NULL) return;
    
    int status_counts[7] = {0}; // Array for each status
    int priority_counts[5] = {0}; // Array for each priority
    int total_completion = 0;
    
    printf("\\n=== PRD Management Statistics ===\\n");
    printf("Total PRDs: %d\\n", manager->count);
    
    // Calculate statistics
    for (int i = 0; i < manager->count; i++) {
        if (manager->prds[i].is_active) {
            status_counts[manager->prds[i].status]++;
            priority_counts[manager->prds[i].priority]++;
            total_completion += manager->prds[i].completion_percentage;
        }
    }
    
    printf("\\nStatus Distribution:\\n");
    for (int i = 0; i < 7; i++) {
        if (status_counts[i] > 0) {
            printf("  %s: %d\\n", status_to_string((prd_status_t)i), status_counts[i]);
        }
    }
    
    printf("\\nPriority Distribution:\\n");
    for (int i = 1; i <= 4; i++) {
        if (priority_counts[i] > 0) {
            printf("  %s: %d\\n", priority_to_string((priority_t)i), priority_counts[i]);
        }
    }
    
    if (manager->count > 0) {
        printf("\\nAverage Completion: %.1f%%\\n", (double)total_completion / manager->count);
    }
}

void generate_prd_id(char* id_buffer) {
    time_t now = time(NULL);
    int random_part = rand() % 10000;
    snprintf(id_buffer, MAX_ID_LENGTH, "PRD-%ld-%04d", now % 100000, random_part);
}

const char* status_to_string(prd_status_t status) {
    switch (status) {
        case PRD_DRAFT: return "Draft";
        case PRD_IN_REVIEW: return "In Review";
        case PRD_APPROVED: return "Approved";
        case PRD_IN_DEVELOPMENT: return "In Development";
        case PRD_TESTING: return "Testing";
        case PRD_IMPLEMENTED: return "Implemented";
        case PRD_ARCHIVED: return "Archived";
        default: return "Unknown";
    }
}

const char* priority_to_string(priority_t priority) {
    switch (priority) {
        case PRIORITY_LOW: return "Low";
        case PRIORITY_MEDIUM: return "Medium";
        case PRIORITY_HIGH: return "High";
        case PRIORITY_CRITICAL: return "Critical";
        default: return "Unknown";
    }
}

void demo_prd_operations(prd_manager_t* manager) {
    printf("\\n=== PRD Management Demo ===\\n");
    
    // Create sample PRDs
    create_prd(manager, "User Authentication System", "Implement secure login and registration functionality", "Development Team");
    create_prd(manager, "Dark Mode Implementation", "Add dark theme support across all UI components", "UX Team");
    create_prd(manager, "Payment Gateway Integration", "Integrate Stripe payment processing system", "Backend Team");
    create_prd(manager, "Mobile App Optimization", "Improve mobile app performance and user experience", "Mobile Team");
    
    // Update some PRD statuses
    if (manager->count > 0) {
        update_prd_status(manager, manager->prds[0].id, PRD_IN_REVIEW);
    }
    if (manager->count > 1) {
        update_prd_status(manager, manager->prds[1].id, PRD_APPROVED);
    }
    if (manager->count > 2) {
        manager->prds[2].completion_percentage = 75;
        manager->prds[2].status = PRD_IN_DEVELOPMENT;
    }
    
    // Print all PRDs
    printf("\\nCurrent PRDs:\\n");
    for (int i = 0; i < manager->count; i++) {
        prd_t* prd = &manager->prds[i];
        if (prd->is_active) {
            printf("  [%s] %s - %s (%d%% complete)\\n", 
                   prd->id, prd->title, status_to_string(prd->status), prd->completion_percentage);
        }
    }
}

int main() {
    printf("PRD Management System v1.2.0 - C Implementation\\n");
    printf("================================================\\n");
    
    // Initialize random seed
    srand((unsigned int)time(NULL));
    
    // Create and initialize PRD manager
    prd_manager_t manager;
    init_prd_manager(&manager);
    
    // Run demonstration
    demo_prd_operations(&manager);
    
    // Print final statistics
    print_prd_statistics(&manager);
    
    printf("\\nC PRD Management System demonstration completed!\\n");
    return 0;
}
