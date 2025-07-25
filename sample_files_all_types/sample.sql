-- PRD Management System Database Schema
-- Version: 1.2.0 | Last Updated: July 25, 2025
-- Database: PostgreSQL 14+

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create schema for PRD management
CREATE SCHEMA IF NOT EXISTS prd_management;
SET search_path TO prd_management, public;

-- Users table for authentication and authorization
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    team VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PRD categories lookup table
CREATE TABLE prd_categories (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(7) DEFAULT '#4CAF50',
    template_id VARCHAR(100),
    approval_required BOOLEAN DEFAULT true,
    estimations_required BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PRD status workflow table
CREATE TABLE prd_statuses (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(7) DEFAULT '#6c757d',
    sort_order INTEGER DEFAULT 0,
    is_final BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Main PRDs table
CREATE TABLE prds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prd_number VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    category_id VARCHAR(50) REFERENCES prd_categories(id),
    status_id VARCHAR(50) REFERENCES prd_statuses(id) DEFAULT 'draft',
    priority INTEGER DEFAULT 3 CHECK (priority BETWEEN 1 AND 4),
    author_id UUID REFERENCES users(id),
    assigned_team VARCHAR(100),
    estimated_effort INTEGER DEFAULT 0,
    actual_effort INTEGER DEFAULT 0,
    completion_percentage INTEGER DEFAULT 0 CHECK (completion_percentage BETWEEN 0 AND 100),
    target_date DATE,
    start_date DATE,
    completion_date DATE,
    version VARCHAR(20) DEFAULT '1.0.0',
    acceptance_criteria TEXT,
    technical_requirements TEXT,
    business_requirements TEXT,
    success_metrics TEXT,
    tags TEXT[],
    external_id VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PRD comments for collaboration
CREATE TABLE prd_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prd_id UUID REFERENCES prds(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    parent_comment_id UUID REFERENCES prd_comments(id),
    content TEXT NOT NULL,
    is_resolved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PRD attachments
CREATE TABLE prd_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prd_id UUID REFERENCES prds(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(100),
    uploaded_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PRD approval workflow
CREATE TABLE prd_approvals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prd_id UUID REFERENCES prds(id) ON DELETE CASCADE,
    approver_id UUID REFERENCES users(id),
    approval_status VARCHAR(20) DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected')),
    comments TEXT,
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PRD status history for audit trail
CREATE TABLE prd_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prd_id UUID REFERENCES prds(id) ON DELETE CASCADE,
    from_status_id VARCHAR(50),
    to_status_id VARCHAR(50) REFERENCES prd_statuses(id),
    changed_by UUID REFERENCES users(id),
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Notification preferences
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    email_notifications BOOLEAN DEFAULT true,
    slack_notifications BOOLEAN DEFAULT true,
    status_change_alerts BOOLEAN DEFAULT true,
    comment_notifications BOOLEAN DEFAULT true,
    approval_requests BOOLEAN DEFAULT true,
    daily_digest BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert default categories
INSERT INTO prd_categories (id, name, description, color) VALUES
('feature', 'Feature', 'New functionality or capabilities', '#4CAF50'),
('enhancement', 'Enhancement', 'Improvements to existing features', '#2196F3'),
('bug_fix', 'Bug Fix', 'Fixes for identified issues', '#F44336'),
('new_product', 'New Product', 'Entirely new product development', '#9C27B0'),
('maintenance', 'Maintenance', 'System maintenance and updates', '#FF9800');

-- Insert default statuses
INSERT INTO prd_statuses (id, name, description, color, sort_order) VALUES
('draft', 'Draft', 'Initial draft state', '#FFC107', 1),
('in_review', 'In Review', 'Under review by stakeholders', '#17A2B8', 2),
('approved', 'Approved', 'Approved for implementation', '#28A745', 3),
('in_development', 'In Development', 'Currently being implemented', '#6F42C1', 4),
('testing', 'Testing', 'Under quality assurance testing', '#FD7E14', 5),
('implemented', 'Implemented', 'Successfully implemented', '#20C997', 6),
('archived', 'Archived', 'Archived and no longer active', '#6C757D', 7);

-- Create indexes for performance
CREATE INDEX idx_prds_status ON prds(status_id);
CREATE INDEX idx_prds_category ON prds(category_id);
CREATE INDEX idx_prds_author ON prds(author_id);
CREATE INDEX idx_prds_created_at ON prds(created_at);
CREATE INDEX idx_prds_title_search ON prds USING gin(title gin_trgm_ops);
CREATE INDEX idx_prds_description_search ON prds USING gin(description gin_trgm_ops);
CREATE INDEX idx_prd_comments_prd_id ON prd_comments(prd_id);
CREATE INDEX idx_prd_status_history_prd_id ON prd_status_history(prd_id);

-- Create trigger for updating updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_prds_updated_at BEFORE UPDATE ON prds
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prd_comments_updated_at BEFORE UPDATE ON prd_comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to generate PRD numbers
CREATE OR REPLACE FUNCTION generate_prd_number()
RETURNS TEXT AS $$
DECLARE
    year_part TEXT;
    sequence_num INTEGER;
    prd_number TEXT;
BEGIN
    year_part := EXTRACT(YEAR FROM CURRENT_DATE)::TEXT;
    
    SELECT COALESCE(MAX(CAST(SUBSTRING(prd_number FROM 'PRD-' || year_part || '-(\d+)') AS INTEGER)), 0) + 1
    INTO sequence_num
    FROM prds
    WHERE prd_number LIKE 'PRD-' || year_part || '-%';
    
    prd_number := 'PRD-' || year_part || '-' || LPAD(sequence_num::TEXT, 4, '0');
    
    RETURN prd_number;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate PRD numbers
CREATE OR REPLACE FUNCTION auto_generate_prd_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.prd_number IS NULL OR NEW.prd_number = '' THEN
        NEW.prd_number := generate_prd_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_generate_prd_number
    BEFORE INSERT ON prds
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_prd_number();

-- Views for reporting
CREATE VIEW prd_summary AS
SELECT 
    p.id,
    p.prd_number,
    p.title,
    pc.name AS category,
    ps.name AS status,
    ps.color AS status_color,
    p.priority,
    u.full_name AS author,
    p.estimated_effort,
    p.completion_percentage,
    p.created_at,
    p.updated_at
FROM prds p
LEFT JOIN prd_categories pc ON p.category_id = pc.id
LEFT JOIN prd_statuses ps ON p.status_id = ps.id
LEFT JOIN users u ON p.author_id = u.id;

-- Analytics view for dashboard
CREATE VIEW prd_analytics AS
SELECT 
    COUNT(*) AS total_prds,
    COUNT(*) FILTER (WHERE status_id = 'draft') AS draft_count,
    COUNT(*) FILTER (WHERE status_id = 'in_review') AS in_review_count,
    COUNT(*) FILTER (WHERE status_id = 'approved') AS approved_count,
    COUNT(*) FILTER (WHERE status_id = 'implemented') AS implemented_count,
    ROUND(AVG(completion_percentage), 2) AS avg_completion,
    ROUND(AVG(estimated_effort), 2) AS avg_estimated_effort
FROM prds
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days';

-- Grant permissions
GRANT USAGE ON SCHEMA prd_management TO prd_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA prd_management TO prd_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA prd_management TO prd_app;
GRANT SELECT ON prd_summary, prd_analytics TO prd_readonly;