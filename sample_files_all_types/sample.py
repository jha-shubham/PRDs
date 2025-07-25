print('Hello World')

"""
PRD Management System - Python Implementation
==============================================

This module provides utilities for managing Product Requirements Documents (PRDs)
including creation, validation, and analysis functionality.
"""

import json
import datetime
import uuid
from typing import List, Dict, Optional
from dataclasses import dataclass, asdict
from enum import Enum

class PRDStatus(Enum):
    """Enumeration for PRD status values"""
    DRAFT = "Draft"
    IN_REVIEW = "In Review"
    APPROVED = "Approved"
    IMPLEMENTED = "Implemented"
    ARCHIVED = "Archived"

class PRDCategory(Enum):
    """Enumeration for PRD categories"""
    FEATURE = "Feature"
    BUG_FIX = "Bug Fix"
    ENHANCEMENT = "Enhancement"
    NEW_PRODUCT = "New Product"
    MAINTENANCE = "Maintenance"

@dataclass
class PRD:
    """Data class representing a Product Requirements Document"""
    title: str
    description: str
    author: str
    category: PRDCategory
    status: PRDStatus = PRDStatus.DRAFT
    id: str = None
    created_date: str = None
    last_modified: str = None
    version: str = "1.0.0"
    priority: int = 3  # 1=High, 2=Medium, 3=Low
    estimated_effort: int = 0  # Story points or hours
    
    def __post_init__(self):
        """Initialize computed fields after object creation"""
        if self.id is None:
            self.id = f"PRD-{uuid.uuid4().hex[:8]}"
        if self.created_date is None:
            self.created_date = datetime.datetime.now().isoformat()
        if self.last_modified is None:
            self.last_modified = self.created_date

class PRDManager:
    """Manager class for handling PRD operations"""
    
    def __init__(self):
        """Initialize the PRD manager"""
        self.prds: List[PRD] = []
        self.load_sample_data()
    
    def add_prd(self, title: str, description: str, author: str, 
                category: PRDCategory, priority: int = 3, 
                estimated_effort: int = 0) -> str:
        """
        Add a new PRD to the system
        
        Args:
            title: PRD title
            description: Detailed description
            author: Author name
            category: PRD category
            priority: Priority level (1-3)
            estimated_effort: Effort estimation
            
        Returns:
            PRD ID
        """
        prd = PRD(
            title=title,
            description=description,
            author=author,
            category=category,
            priority=priority,
            estimated_effort=estimated_effort
        )
        self.prds.append(prd)
        print(f"PRD '{title}' added successfully with ID: {prd.id}")
        return prd.id
    
    def update_status(self, prd_id: str, new_status: PRDStatus) -> bool:
        """Update the status of a PRD"""
        prd = self.get_prd_by_id(prd_id)
        if prd:
            prd.status = new_status
            prd.last_modified = datetime.datetime.now().isoformat()
            print(f"PRD {prd_id} status updated to: {new_status.value}")
            return True
        print(f"PRD with ID {prd_id} not found")
        return False
    
    def get_prd_by_id(self, prd_id: str) -> Optional[PRD]:
        """Retrieve a PRD by its ID"""
        return next((prd for prd in self.prds if prd.id == prd_id), None)
    
    def get_prds_by_status(self, status: PRDStatus) -> List[PRD]:
        """Get all PRDs with a specific status"""
        return [prd for prd in self.prds if prd.status == status]
    
    def get_prds_by_category(self, category: PRDCategory) -> List[PRD]:
        """Get all PRDs in a specific category"""
        return [prd for prd in self.prds if prd.category == category]
    
    def search_prds(self, search_term: str) -> List[PRD]:
        """Search PRDs by title or description"""
        term = search_term.lower()
        return [prd for prd in self.prds 
                if term in prd.title.lower() or term in prd.description.lower()]
    
    def get_statistics(self) -> Dict:
        """Get summary statistics for all PRDs"""
        stats = {
            'total_prds': len(self.prds),
            'by_status': {},
            'by_category': {},
            'by_priority': {1: 0, 2: 0, 3: 0},
            'average_effort': 0
        }
        
        for status in PRDStatus:
            stats['by_status'][status.value] = len(self.get_prds_by_status(status))
        
        for category in PRDCategory:
            stats['by_category'][category.value] = len(self.get_prds_by_category(category))
        
        for prd in self.prds:
            stats['by_priority'][prd.priority] += 1
        
        if self.prds:
            stats['average_effort'] = sum(prd.estimated_effort for prd in self.prds) / len(self.prds)
        
        return stats
    
    def export_to_json(self, filename: str = None) -> str:
        """Export PRDs to JSON format"""
        data = [asdict(prd) for prd in self.prds]
        json_data = json.dumps(data, indent=2, default=str)
        
        if filename:
            with open(filename, 'w') as f:
                f.write(json_data)
            print(f"PRDs exported to {filename}")
        
        return json_data
    
    def load_sample_data(self):
        """Load sample PRD data for demonstration"""
        sample_prds = [
            ("User Authentication", "Implement secure login system", "Dev Team", PRDCategory.FEATURE, 1, 8),
            ("Dark Mode Theme", "Add dark theme option", "UX Team", PRDCategory.ENHANCEMENT, 2, 5),
            ("Payment Gateway", "Integrate payment processing", "Product Team", PRDCategory.FEATURE, 1, 13),
            ("Bug Fix: Login Error", "Fix login validation bug", "QA Team", PRDCategory.BUG_FIX, 1, 3),
            ("Mobile App Redesign", "Complete mobile UI overhaul", "Design Team", PRDCategory.NEW_PRODUCT, 2, 21)
        ]
        
        for title, desc, author, category, priority, effort in sample_prds:
            self.add_prd(title, desc, author, category, priority, effort)

# Example usage and testing
if __name__ == "__main__":
    # Initialize the PRD management system
    manager = PRDManager()
    
    # Display current statistics
    print("\nPRD Statistics:")
    stats = manager.get_statistics()
    for key, value in stats.items():
        print(f"  {key}: {value}")
    
    # Search for specific PRDs
    print("\nSearching for 'login' related PRDs:")
    login_prds = manager.search_prds("login")
    for prd in login_prds:
        print(f"  - {prd.title} ({prd.status.value})")
    
    # Update a PRD status
    if manager.prds:
        first_prd = manager.prds[0]
        manager.update_status(first_prd.id, PRDStatus.IN_REVIEW)
        
    print("\nPRD Management System initialized successfully!")