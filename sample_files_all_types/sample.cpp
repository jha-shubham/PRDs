/**
 * PRD Management System - C++ Implementation
 * Version: 1.2.0 | Last Updated: July 25, 2025
 */

#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <memory>
#include <chrono>
#include <algorithm>

namespace PRDManagement {

enum class PRDStatus {
    DRAFT,
    IN_REVIEW,
    APPROVED,
    IN_DEVELOPMENT,
    TESTING,
    IMPLEMENTED,
    ARCHIVED
};

enum class Priority {
    LOW = 1,
    MEDIUM = 2,
    HIGH = 3,
    CRITICAL = 4
};

class PRD {
private:
    std::string id;
    std::string title;
    std::string description;
    std::string author;
    PRDStatus status;
    Priority priority;
    std::chrono::system_clock::time_point created_at;
    std::chrono::system_clock::time_point updated_at;
    int completion_percentage;

public:
    PRD(const std::string& title, const std::string& description, const std::string& author)
        : title(title), description(description), author(author), 
          status(PRDStatus::DRAFT), priority(Priority::MEDIUM),
          completion_percentage(0) {
        
        auto now = std::chrono::system_clock::now();
        created_at = now;
        updated_at = now;
        
        // Generate unique ID
        auto time_since_epoch = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch());
        id = "PRD-" + std::to_string(time_since_epoch.count());
    }

    // Getters
    const std::string& getId() const { return id; }
    const std::string& getTitle() const { return title; }
    const std::string& getDescription() const { return description; }
    const std::string& getAuthor() const { return author; }
    PRDStatus getStatus() const { return status; }
    Priority getPriority() const { return priority; }
    int getCompletionPercentage() const { return completion_percentage; }

    // Setters
    void setStatus(PRDStatus new_status) {
        status = new_status;
        updated_at = std::chrono::system_clock::now();
    }

    void setPriority(Priority new_priority) {
        priority = new_priority;
        updated_at = std::chrono::system_clock::now();
    }

    void setCompletionPercentage(int percentage) {
        completion_percentage = std::max(0, std::min(100, percentage));
        updated_at = std::chrono::system_clock::now();
    }

    std::string toString() const {
        return "PRD{id='" + id + "', title='" + title + "', status=" + 
               std::to_string(static_cast<int>(status)) + ", completion=" + 
               std::to_string(completion_percentage) + "%}";
    }
};

class PRDManager {
private:
    std::vector<std::shared_ptr<PRD>> prds;
    std::map<std::string, std::shared_ptr<PRD>> prd_index;

public:
    std::string createPRD(const std::string& title, const std::string& description, const std::string& author) {
        auto prd = std::make_shared<PRD>(title, description, author);
        prds.push_back(prd);
        prd_index[prd->getId()] = prd;
        
        std::cout << "PRD created successfully: " << prd->getId() << std::endl;
        return prd->getId();
    }

    std::shared_ptr<PRD> getPRD(const std::string& id) {
        auto it = prd_index.find(id);
        return (it != prd_index.end()) ? it->second : nullptr;
    }

    std::vector<std::shared_ptr<PRD>> getPRDsByStatus(PRDStatus status) {
        std::vector<std::shared_ptr<PRD>> result;
        std::copy_if(prds.begin(), prds.end(), std::back_inserter(result),
                     [status](const std::shared_ptr<PRD>& prd) {
                         return prd->getStatus() == status;
                     });
        return result;
    }

    bool updatePRDStatus(const std::string& id, PRDStatus new_status) {
        auto prd = getPRD(id);
        if (prd) {
            prd->setStatus(new_status);
            std::cout << "PRD " << id << " status updated successfully" << std::endl;
            return true;
        }
        return false;
    }

    void printStatistics() {
        std::map<PRDStatus, int> status_counts;
        std::map<Priority, int> priority_counts;
        
        for (const auto& prd : prds) {
            status_counts[prd->getStatus()]++;
            priority_counts[prd->getPriority()]++;
        }

        std::cout << "\n=== PRD Management Statistics ===" << std::endl;
        std::cout << "Total PRDs: " << prds.size() << std::endl;
        
        std::cout << "\nStatus Distribution:" << std::endl;
        for (const auto& [status, count] : status_counts) {
            std::cout << "  Status " << static_cast<int>(status) << ": " << count << std::endl;
        }
        
        std::cout << "\nPriority Distribution:" << std::endl;
        for (const auto& [priority, count] : priority_counts) {
            std::cout << "  Priority " << static_cast<int>(priority) << ": " << count << std::endl;
        }
    }
};

} // namespace PRDManagement

int main() {
    std::cout << "PRD Management System v1.2.0 - C++ Implementation" << std::endl;
    
    PRDManagement::PRDManager manager;
    
    // Create sample PRDs
    manager.createPRD("User Authentication", "Implement secure login system", "Dev Team");
    manager.createPRD("Dark Mode Theme", "Add dark theme support", "UX Team");
    manager.createPRD("API Integration", "Integrate with external APIs", "Backend Team");
    
    // Update some statuses
    auto prds = manager.getPRDsByStatus(PRDManagement::PRDStatus::DRAFT);
    if (!prds.empty()) {
        manager.updatePRDStatus(prds[0]->getId(), PRDManagement::PRDStatus::IN_REVIEW);
    }
    
    // Print statistics
    manager.printStatistics();
    
    std::cout << "\nC++ PRD Management System demonstration completed!" << std::endl;
    return 0;
}
