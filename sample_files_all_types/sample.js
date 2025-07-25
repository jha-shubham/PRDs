console.log('Hello World');

// PRD Documentation Management System
// JavaScript utilities for handling PRD-related operations

/**
 * Class for managing Product Requirements Documents
 */
class PRDManager {
    constructor() {
        this.documents = [];
        this.categories = ['Feature', 'Bug Fix', 'Enhancement', 'New Product'];
        this.statusOptions = ['Draft', 'In Review', 'Approved', 'Implemented'];
    }

    /**
     * Add a new PRD to the system
     * @param {Object} prd - The PRD object
     * @param {string} prd.title - Title of the PRD
     * @param {string} prd.category - Category of the PRD
     * @param {string} prd.description - Description of the PRD
     * @param {string} prd.author - Author of the PRD
     */
    addPRD(prd) {
        const newPRD = {
            id: this.generateId(),
            title: prd.title,
            category: prd.category,
            description: prd.description,
            author: prd.author,
            createdDate: new Date().toISOString(),
            status: 'Draft',
            version: '1.0.0'
        };
        this.documents.push(newPRD);
        console.log(`PRD "${newPRD.title}" added successfully with ID: ${newPRD.id}`);
        return newPRD.id;
    }

    /**
     * Update PRD status
     * @param {string} id - PRD ID
     * @param {string} status - New status
     */
    updateStatus(id, status) {
        const prd = this.documents.find(doc => doc.id === id);
        if (prd && this.statusOptions.includes(status)) {
            prd.status = status;
            prd.lastModified = new Date().toISOString();
            console.log(`PRD ${id} status updated to: ${status}`);
        } else {
            console.error('Invalid PRD ID or status');
        }
    }

    /**
     * Generate unique ID for PRDs
     */
    generateId() {
        return 'PRD-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9);
    }

    /**
     * Get all PRDs by category
     * @param {string} category - Category to filter by
     */
    getPRDsByCategory(category) {
        return this.documents.filter(doc => doc.category === category);
    }

    /**
     * Search PRDs by title or description
     * @param {string} searchTerm - Term to search for
     */
    searchPRDs(searchTerm) {
        const term = searchTerm.toLowerCase();
        return this.documents.filter(doc => 
            doc.title.toLowerCase().includes(term) || 
            doc.description.toLowerCase().includes(term)
        );
    }

    /**
     * Export PRD data as JSON
     */
    exportData() {
        return JSON.stringify(this.documents, null, 2);
    }

    /**
     * Get summary statistics
     */
    getStatistics() {
        const stats = {
            totalPRDs: this.documents.length,
            byStatus: {},
            byCategory: {}
        };

        this.statusOptions.forEach(status => {
            stats.byStatus[status] = this.documents.filter(doc => doc.status === status).length;
        });

        this.categories.forEach(category => {
            stats.byCategory[category] = this.documents.filter(doc => doc.category === category).length;
        });

        return stats;
    }
}

// Initialize the PRD management system
const prdManager = new PRDManager();

// Example usage
prdManager.addPRD({
    title: "User Authentication System",
    category: "Feature",
    description: "Implement secure user login and registration functionality",
    author: "Product Team"
});

prdManager.addPRD({
    title: "Mobile App Dark Mode",
    category: "Enhancement", 
    description: "Add dark mode theme option for mobile application",
    author: "UX Team"
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = PRDManager;
}