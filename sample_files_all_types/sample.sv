module prd_management;

// PRD Management System - SystemVerilog Implementation
// Version: 1.2.0 | Last Updated: July 25, 2025

typedef enum {
    DRAFT = 0,
    IN_REVIEW = 1,
    APPROVED = 2,
    IN_DEVELOPMENT = 3,
    TESTING = 4,
    IMPLEMENTED = 5,
    ARCHIVED = 6
} prd_status_e;

typedef enum {
    LOW = 1,
    MEDIUM = 2,
    HIGH = 3,
    CRITICAL = 4
} priority_e;

typedef struct {
    string id;
    string title;
    string description;
    string author;
    prd_status_e status;
    priority_e priority;
    longint created_at;
    longint updated_at;
    int completion_percentage;
    string tags[$];
} prd_t;

typedef struct {
    int total_prds;
    int status_counts[prd_status_e];
    int priority_counts[priority_e];
    real average_completion;
    int author_counts[string];
    int tag_counts[string];
    longint last_updated;
} analytics_t;

class prd_manager;
    
    prd_t prds[$];
    int prd_index[string];
    int next_id_counter;
    
    function new();
        next_id_counter = 1000;
    endfunction
    
    function string generate_id();
        string id;
        id = $sformatf("PRD-%0d-%0d", $time, next_id_counter++);
        return id;
    endfunction
    
    function string create_prd(string title, string description, string author);
        prd_t new_prd;
        new_prd.id = generate_id();
        new_prd.title = title;
        new_prd.description = description;
        new_prd.author = author;
        new_prd.status = DRAFT;
        new_prd.priority = MEDIUM;
        new_prd.created_at = $time;
        new_prd.updated_at = $time;
        new_prd.completion_percentage = 0;
        new_prd.tags = {};
        
        prd_index[new_prd.id] = prds.size();
        prds.push_back(new_prd);
        
        $display("PRD created successfully: %s", new_prd.id);
        return new_prd.id;
    endfunction
    
    function prd_t get_prd(string id);
        if (prd_index.exists(id)) begin
            int index = prd_index[id];
            if (index < prds.size()) begin
                return prds[index];
            end
        end
        // Return empty PRD if not found
        prd_t empty_prd;
        return empty_prd;
    endfunction
    
    function prd_t get_all_prds[$];
        return prds;
    endfunction
    
    function prd_t get_prds_by_status[$](prd_status_e status);
        prd_t filtered_prds[$];
        foreach (prds[i]) begin
            if (prds[i].status == status) begin
                filtered_prds.push_back(prds[i]);
            end
        end
        return filtered_prds;
    endfunction
    
    function prd_t get_prds_by_priority[$](priority_e priority);
        prd_t filtered_prds[$];
        foreach (prds[i]) begin
            if (prds[i].priority == priority) begin
                filtered_prds.push_back(prds[i]);
            end
        end
        return filtered_prds;
    endfunction
    
    function prd_t search_prds[$](string search_term);
        prd_t results[$];
        string lower_search_term = search_term.tolower();
        
        foreach (prds[i]) begin
            string lower_title = prds[i].title.tolower();
            string lower_desc = prds[i].description.tolower();
            bit found = 0;
            
            // Search in title and description
            if (lower_title.substr(0, lower_search_term.len()-1) == lower_search_term ||
                lower_desc.substr(0, lower_search_term.len()-1) == lower_search_term) begin
                found = 1;
            end
            
            // Search in tags
            if (!found) begin
                foreach (prds[i].tags[j]) begin
                    if (prds[i].tags[j].substr(0, lower_search_term.len()-1) == lower_search_term) begin
                        found = 1;
                        break;
                    end
                end
            end
            
            if (found) begin
                results.push_back(prds[i]);
            end
        end
        
        return results;
    endfunction
    
    function bit update_prd_status(string id, prd_status_e new_status);
        if (prd_index.exists(id)) begin
            int index = prd_index[id];
            if (index < prds.size()) begin
                prds[index].status = new_status;
                prds[index].updated_at = $time;
                $display("PRD %s status updated to: %s", id, get_status_name(new_status));
                return 1;
            end
        end
        return 0;
    endfunction
    
    function bit update_prd_completion(string id, int percentage);
        if (prd_index.exists(id)) begin
            int index = prd_index[id];
            if (index < prds.size()) begin
                prds[index].completion_percentage = (percentage < 0) ? 0 : (percentage > 100) ? 100 : percentage;
                prds[index].updated_at = $time;
                return 1;
            end
        end
        return 0;
    endfunction
    
    function void add_tag(string id, string tag);
        if (prd_index.exists(id)) begin
            int index = prd_index[id];
            if (index < prds.size()) begin
                string clean_tag = tag.tolower();
                // Check if tag already exists
                bit tag_exists = 0;
                foreach (prds[index].tags[i]) begin
                    if (prds[index].tags[i] == clean_tag) begin
                        tag_exists = 1;
                        break;
                    end
                end
                if (!tag_exists && clean_tag.len() > 0) begin
                    prds[index].tags.push_back(clean_tag);
                    prds[index].updated_at = $time;
                end
            end
        end
    endfunction
    
    function analytics_t generate_analytics();
        analytics_t analytics;
        int total_completion = 0;
        
        analytics.total_prds = prds.size();
        analytics.last_updated = $time;
        
        // Initialize counts
        foreach (analytics.status_counts[i]) analytics.status_counts[i] = 0;
        foreach (analytics.priority_counts[i]) analytics.priority_counts[i] = 0;
        analytics.author_counts.delete();
        analytics.tag_counts.delete();
        
        foreach (prds[i]) begin
            // Count by status
            analytics.status_counts[prds[i].status]++;
            
            // Count by priority
            analytics.priority_counts[prds[i].priority]++;
            
            // Count by author
            if (analytics.author_counts.exists(prds[i].author)) begin
                analytics.author_counts[prds[i].author]++;
            end else begin
                analytics.author_counts[prds[i].author] = 1;
            end
            
            // Count tags
            foreach (prds[i].tags[j]) begin
                if (analytics.tag_counts.exists(prds[i].tags[j])) begin
                    analytics.tag_counts[prds[i].tags[j]]++;
                end else begin
                    analytics.tag_counts[prds[i].tags[j]] = 1;
                end
            end
            
            total_completion += prds[i].completion_percentage;
        end
        
        analytics.average_completion = (prds.size() > 0) ? real'(total_completion) / real'(prds.size()) : 0.0;
        
        return analytics;
    endfunction
    
    function string get_status_name(prd_status_e status);
        case (status)
            DRAFT: return "Draft";
            IN_REVIEW: return "In Review";
            APPROVED: return "Approved";
            IN_DEVELOPMENT: return "In Development";
            TESTING: return "Testing";
            IMPLEMENTED: return "Implemented";
            ARCHIVED: return "Archived";
            default: return "Unknown";
        endcase
    endfunction
    
    function string get_priority_name(priority_e priority);
        case (priority)
            LOW: return "Low";
            MEDIUM: return "Medium";
            HIGH: return "High";
            CRITICAL: return "Critical";
            default: return "Unknown";
        endcase
    endfunction
    
    function string get_status_icon(prd_status_e status);
        case (status)
            DRAFT: return "📝";
            IN_REVIEW: return "👁️";
            APPROVED: return "✅";
            IN_DEVELOPMENT: return "🔨";
            TESTING: return "🧪";
            IMPLEMENTED: return "⭐";
            ARCHIVED: return "📦";
            default: return "❓";
        endcase
    endfunction
    
    function void print_dashboard();
        analytics_t analytics = generate_analytics();
        
        $display("============================================================");
        $display("PRD MANAGEMENT SYSTEM - DASHBOARD");
        $display("============================================================");
        
        $display("Total PRDs: %0d", analytics.total_prds);
        $display("Average Completion: %0.1f%%", analytics.average_completion);
        
        $display("\nStatus Distribution:");
        foreach (analytics.status_counts[i]) begin
            if (analytics.status_counts[i] > 0) begin
                $display("  %s: %0d", get_status_name(i), analytics.status_counts[i]);
            end
        end
        
        $display("\nPriority Distribution:");
        foreach (analytics.priority_counts[i]) begin
            if (analytics.priority_counts[i] > 0) begin
                $display("  %s: %0d", get_priority_name(i), analytics.priority_counts[i]);
            end
        end
        
        $display("\nTop Authors:");
        string authors[$];
        analytics.author_counts.first(authors);
        for (int i = 0; i < 5 && i < authors.size(); i++) begin
            $display("  %s: %0d PRDs", authors[i], analytics.author_counts[authors[i]]);
        end
        
        $display("\nMost Used Tags:");
        string tags[$];
        analytics.tag_counts.first(tags);
        for (int i = 0; i < 5 && i < tags.size(); i++) begin
            $display("  #%s: %0d times", tags[i], analytics.tag_counts[tags[i]]);
        end
        
        $display("\nRecent PRDs:");
        // Show last 5 PRDs (simplified - in real implementation would sort by updated_at)
        int start_idx = (prds.size() > 5) ? prds.size() - 5 : 0;
        for (int i = start_idx; i < prds.size(); i++) begin
            $display("  PRD{ID='%s', Title='%s', Status=%s, Completion=%0d%%}", 
                     prds[i].id, prds[i].title, get_status_name(prds[i].status), prds[i].completion_percentage);
        end
    endfunction
    
    function void load_sample_data();
        string sample_titles[] = '{
            "User Authentication System",
            "Dark Mode Theme",
            "Payment Gateway Integration",
            "API Rate Limiting",
            "Mobile App Redesign",
            "Real-time Notifications",
            "Performance Optimization",
            "Multi-language Support",
            "Hardware Verification",
            "FPGA Implementation"
        };
        
        string sample_descriptions[] = '{
            "Implement secure login and registration",
            "Add dark theme option for better UX",
            "Integrate secure payment processing",
            "Implement API rate limiting for security",
            "Complete redesign of mobile application",
            "Add real-time notification system",
            "Optimize database queries and caching",
            "Add internationalization support",
            "Verify hardware design using SystemVerilog",
            "Implement design on FPGA platform"
        };
        
        string sample_authors[] = '{
            "Dev Team",
            "UX Team",
            "Product Team",
            "Backend Team",
            "Design Team",
            "Full Stack Team",
            "Database Team",
            "Localization Team",
            "Verification Team",
            "Hardware Team"
        };
        
        string sample_tags[][] = '{
            '{"security", "authentication"},
            '{"ui", "theme"},
            '{"payment", "integration"},
            '{"api", "security"},
            '{"mobile", "design"},
            '{"notifications", "realtime"},
            '{"performance", "database"},
            '{"i18n", "localization"},
            '{"verification", "systemverilog"},
            '{"fpga", "hardware"}
        };
        
        // Create sample PRDs
        for (int i = 0; i < sample_titles.size(); i++) begin
            string id = create_prd(sample_titles[i], sample_descriptions[i], sample_authors[i]);
            
            // Add tags
            foreach (sample_tags[i][j]) begin
                add_tag(id, sample_tags[i][j]);
            end
        end
        
        // Update some statuses and priorities for variety
        if (prds.size() >= 10) begin
            update_prd_status(prds[1].id, IN_REVIEW);
            update_prd_status(prds[2].id, APPROVED);
            update_prd_status(prds[3].id, IN_DEVELOPMENT);
            update_prd_status(prds[4].id, TESTING);
            update_prd_status(prds[5].id, IMPLEMENTED);
            
            // Update priorities
            prds[2].priority = HIGH;
            prds[3].priority = CRITICAL;
            prds[8].priority = HIGH;
            
            // Update completion percentages
            update_prd_completion(prds[3].id, 65);
            update_prd_completion(prds[4].id, 90);
            update_prd_completion(prds[5].id, 100);
        end
    endfunction
    
    function prd_t get_prds_needing_attention[$]();
        prd_t needing_attention[$];
        
        foreach (prds[i]) begin
            bit needs_attention = 0;
            
            if ((prds[i].status == IN_DEVELOPMENT && prds[i].completion_percentage < 50) ||
                (prds[i].priority == CRITICAL && prds[i].status == DRAFT) ||
                (prds[i].status == TESTING && prds[i].completion_percentage < 80)) begin
                needs_attention = 1;
            end
            
            if (needs_attention) begin
                needing_attention.push_back(prds[i]);
            end
        end
        
        return needing_attention;
    endfunction
    
    function void get_completion_stats(output int min_comp, output int max_comp, output real avg_comp);
        if (prds.size() == 0) begin
            min_comp = 0;
            max_comp = 0;
            avg_comp = 0.0;
            return;
        end
        
        min_comp = 100;
        max_comp = 0;
        int total_comp = 0;
        
        foreach (prds[i]) begin
            if (prds[i].completion_percentage < min_comp) min_comp = prds[i].completion_percentage;
            if (prds[i].completion_percentage > max_comp) max_comp = prds[i].completion_percentage;
            total_comp += prds[i].completion_percentage;
        end
        
        avg_comp = real'(total_comp) / real'(prds.size());
    endfunction
    
endclass

// Testbench/Demo Module
module prd_management_demo;
    
    prd_manager manager;
    
    initial begin
        $display("PRD Management System v1.2.0 - SystemVerilog Implementation");
        $display("=============================================================");
        
        // Initialize manager
        manager = new();
        
        // Load sample data
        manager.load_sample_data();
        
        // Display dashboard
        manager.print_dashboard();
        
        // Demo operations
        $display("\n============================================================");
        $display("DEMO OPERATIONS");
        $display("============================================================");
        
        // Search demo
        begin
            prd_t search_results[$];
            search_results = manager.search_prds("authentication");
            $display("\nSearching for 'authentication' related PRDs:");
            foreach (search_results[i]) begin
                $display("  Found: PRD{ID='%s', Title='%s', Status=%s, Completion=%0d%%}", 
                         search_results[i].id, search_results[i].title, 
                         manager.get_status_name(search_results[i].status), 
                         search_results[i].completion_percentage);
            end
        end
        
        // Filter by status demo
        begin
            prd_t draft_prds[$];
            draft_prds = manager.get_prds_by_status(DRAFT);
            $display("\nDraft PRDs (%0d):", draft_prds.size());
            foreach (draft_prds[i]) begin
                $display("  PRD{ID='%s', Title='%s', Status=%s, Completion=%0d%%}", 
                         draft_prds[i].id, draft_prds[i].title, 
                         manager.get_status_name(draft_prds[i].status), 
                         draft_prds[i].completion_percentage);
            end
        end
        
        // Priority filtering demo
        begin
            prd_t critical_prds[$];
            critical_prds = manager.get_prds_by_priority(CRITICAL);
            $display("\nCritical Priority PRDs (%0d):", critical_prds.size());
            foreach (critical_prds[i]) begin
                $display("  %s PRD{ID='%s', Title='%s', Status=%s, Completion=%0d%%}", 
                         manager.get_status_icon(critical_prds[i].status),
                         critical_prds[i].id, critical_prds[i].title, 
                         manager.get_status_name(critical_prds[i].status), 
                         critical_prds[i].completion_percentage);
            end
        end
        
        // PRDs needing attention
        begin
            prd_t needing_attention[$];
            needing_attention = manager.get_prds_needing_attention();
            $display("\nPRDs Needing Attention (%0d):", needing_attention.size());
            foreach (needing_attention[i]) begin
                $display("  %s PRD{ID='%s', Title='%s'} - %s priority", 
                         manager.get_status_icon(needing_attention[i].status),
                         needing_attention[i].id, needing_attention[i].title,
                         manager.get_priority_name(needing_attention[i].priority));
            end
        end
        
        // Completion statistics
        begin
            int min_comp, max_comp;
            real avg_comp;
            manager.get_completion_stats(min_comp, max_comp, avg_comp);
            $display("\nCompletion Statistics:");
            $display("  Minimum: %0d%%", min_comp);
            $display("  Maximum: %0d%%", max_comp);
            $display("  Average: %0.1f%%", avg_comp);
        end
        
        $display("\nSystemVerilog PRD Management System demonstration completed!");
        $finish;
    end
    
endmodule

endmodule
