% PRD Management System - MATLAB Implementation
% Version: 1.2.0 | Last Updated: July 25, 2025

function prd_management_demo()
    fprintf('PRD Management System v1.2.0 - MATLAB Implementation\n');
    fprintf('====================================================\n');
    
    % Initialize PRD Manager
    manager = PRDManager();
    
    % Load sample data
    manager = manager.loadSampleData();
    
    % Print dashboard
    manager.printDashboard();
    
    % Demo operations
    fprintf('\n%s\n', repmat('=', 1, 60));
    fprintf('DEMO OPERATIONS\n');
    fprintf('%s\n', repmat('=', 1, 60));
    
    % Search demo
    searchResults = manager.searchPRDs('authentication');
    fprintf('\nSearching for ''authentication'' related PRDs:\n');
    for i = 1:length(searchResults)
        prd = searchResults{i};
        fprintf('  Found: %s\n', prd.toString());
    end
    
    % Filter by status demo
    draftPRDs = manager.getPRDsByStatus(0); % DRAFT = 0
    fprintf('\nDraft PRDs (%d):\n', length(draftPRDs));
    for i = 1:length(draftPRDs)
        fprintf('  %s\n', draftPRDs{i}.toString());
    end
    
    % Priority filtering demo
    criticalPRDs = manager.getPRDsByPriority(4); % CRITICAL = 4
    fprintf('\nCritical Priority PRDs (%d):\n', length(criticalPRDs));
    for i = 1:length(criticalPRDs)
        fprintf('  %s %s\n', criticalPRDs{i}.getStatusIcon(), criticalPRDs{i}.toString());
    end
    
    % PRDs needing attention
    needingAttention = manager.getPRDsNeedingAttention();
    fprintf('\nPRDs Needing Attention (%d):\n', length(needingAttention));
    for i = 1:length(needingAttention)
        prd = needingAttention{i};
        fprintf('  %s %s - %s priority\n', prd.getStatusIcon(), prd.toString(), prd.getPriorityName());
    end
    
    % Completion statistics
    stats = manager.getCompletionStats();
    fprintf('\nCompletion Statistics:\n');
    fprintf('  Minimum: %d%%\n', stats.min);
    fprintf('  Maximum: %d%%\n', stats.max);
    fprintf('  Average: %.1f%%\n', stats.average);
    
    % Generate visualizations
    fprintf('\nGenerating visualizations...\n');
    manager.generateVisualizations();
    
    % Export demo
    fprintf('\nExporting PRD data to JSON...\n');
    try
        jsonData = manager.exportToJSON();
        fprintf('Export completed. JSON length: %d characters\n', length(jsonData));
    catch ME
        fprintf('Error exporting to JSON: %s\n', ME.message);
    end
    
    fprintf('\nMATLAB PRD Management System demonstration completed!\n');
end

% PRD Class Definition
classdef PRD < handle
    properties
        id
        title
        description
        author
        status      % 0-6: Draft, InReview, Approved, InDevelopment, Testing, Implemented, Archived
        priority    % 1-4: Low, Medium, High, Critical
        createdAt
        updatedAt
        completionPercentage
        tags
    end
    
    properties (Constant)
        STATUS_NAMES = {'Draft', 'In Review', 'Approved', 'In Development', ...
                       'Testing', 'Implemented', 'Archived'};
        PRIORITY_NAMES = {'Low', 'Medium', 'High', 'Critical'};
        PRIORITY_COLORS = {'#28a745', '#ffc107', '#fd7e14', '#dc3545'};
    end
    
    methods
        function obj = PRD(title, description, author)
            obj.id = obj.generateId();
            obj.title = title;
            obj.description = description;
            obj.author = author;
            obj.status = 0; % Draft
            obj.priority = 2; % Medium
            obj.createdAt = datetime('now');
            obj.updatedAt = datetime('now');
            obj.completionPercentage = 0;
            obj.tags = {};
        end
        
        function id = generateId(obj)
            timestamp = posixtime(datetime('now'));
            randomNum = randi([1000, 9999]);
            id = sprintf('PRD-%.0f-%d', timestamp, randomNum);
        end
        
        function updateStatus(obj, newStatus)
            obj.status = newStatus;
            obj.updatedAt = datetime('now');
        end
        
        function setCompletionPercentage(obj, percentage)
            obj.completionPercentage = max(0, min(100, percentage));
            obj.updatedAt = datetime('now');
        end
        
        function addTag(obj, tag)
            cleanTag = lower(strtrim(tag));
            if ~isempty(cleanTag) && ~any(strcmp(obj.tags, cleanTag))
                obj.tags{end+1} = cleanTag;
                obj.updatedAt = datetime('now');
            end
        end
        
        function setPriority(obj, priority)
            obj.priority = priority;
            obj.updatedAt = datetime('now');
        end
        
        function name = getStatusName(obj)
            name = obj.STATUS_NAMES{obj.status + 1};
        end
        
        function name = getPriorityName(obj)
            name = obj.PRIORITY_NAMES{obj.priority};
        end
        
        function icon = getStatusIcon(obj)
            icons = {'📝', '👁️', '✅', '🔨', '🧪', '⭐', '📦'};
            icon = icons{obj.status + 1};
        end
        
        function desc = getProgressDescription(obj)
            desc = sprintf('%d%% complete', obj.completionPercentage);
        end
        
        function str = toString(obj)
            str = sprintf('PRD{ID=''%s'', Title=''%s'', Status=%s, Completion=%d%%}', ...
                         obj.id, obj.title, obj.getStatusName(), obj.completionPercentage);
        end
        
        function data = toStruct(obj)
            data.id = obj.id;
            data.title = obj.title;
            data.description = obj.description;
            data.author = obj.author;
            data.status = obj.status;
            data.priority = obj.priority;
            data.createdAt = char(obj.createdAt);
            data.updatedAt = char(obj.updatedAt);
            data.completionPercentage = obj.completionPercentage;
            data.tags = obj.tags;
        end
    end
end

% PRD Manager Class Definition
classdef PRDManager < handle
    properties
        prds
        prdIndex
    end
    
    methods
        function obj = PRDManager()
            obj.prds = {};
            obj.prdIndex = containers.Map();
        end
        
        function id = createPRD(obj, title, description, author)
            prd = PRD(title, description, author);
            obj.prdIndex(prd.id) = length(obj.prds) + 1;
            obj.prds{end+1} = prd;
            
            fprintf('PRD created successfully: %s\n', prd.id);
            id = prd.id;
        end
        
        function prd = getPRD(obj, id)
            if isKey(obj.prdIndex, id)
                index = obj.prdIndex(id);
                prd = obj.prds{index};
            else
                prd = [];
            end
        end
        
        function prds = getAllPRDs(obj)
            prds = obj.prds;
        end
        
        function prds = getPRDsByStatus(obj, status)
            prds = {};
            for i = 1:length(obj.prds)
                if obj.prds{i}.status == status
                    prds{end+1} = obj.prds{i};
                end
            end
        end
        
        function prds = getPRDsByPriority(obj, priority)
            prds = {};
            for i = 1:length(obj.prds)
                if obj.prds{i}.priority == priority
                    prds{end+1} = obj.prds{i};
                end
            end
        end
        
        function results = searchPRDs(obj, searchTerm)
            results = {};
            searchTerm = lower(searchTerm);
            
            for i = 1:length(obj.prds)
                prd = obj.prds{i};
                titleMatch = contains(lower(prd.title), searchTerm);
                descMatch = contains(lower(prd.description), searchTerm);
                tagMatch = any(cellfun(@(tag) contains(tag, searchTerm), prd.tags));
                
                if titleMatch || descMatch || tagMatch
                    results{end+1} = prd;
                end
            end
        end
        
        function success = updatePRDStatus(obj, id, newStatus)
            prd = obj.getPRD(id);
            if ~isempty(prd)
                prd.updateStatus(newStatus);
                fprintf('PRD %s status updated to: %s\n', id, prd.getStatusName());
                success = true;
            else
                success = false;
            end
        end
        
        function success = updatePRDCompletion(obj, id, percentage)
            prd = obj.getPRD(id);
            if ~isempty(prd)
                prd.setCompletionPercentage(percentage);
                success = true;
            else
                success = false;
            end
        end
        
        function analytics = generateAnalytics(obj)
            totalPRDs = length(obj.prds);
            
            if totalPRDs == 0
                analytics = struct('totalPRDs', 0, 'statusCounts', zeros(1,7), ...
                                 'priorityCounts', zeros(1,4), 'averageCompletion', 0, ...
                                 'topAuthors', containers.Map(), 'tagFrequency', containers.Map(), ...
                                 'lastUpdated', datetime('now'));
                return;
            end
            
            % Initialize counters
            statusCounts = zeros(1, 7);
            priorityCounts = zeros(1, 4);
            authorCounts = containers.Map();
            tagCounts = containers.Map();
            totalCompletion = 0;
            
            % Count occurrences
            for i = 1:length(obj.prds)
                prd = obj.prds{i};
                
                % Status counts
                statusCounts(prd.status + 1) = statusCounts(prd.status + 1) + 1;
                
                % Priority counts
                priorityCounts(prd.priority) = priorityCounts(prd.priority) + 1;
                
                % Author counts
                if isKey(authorCounts, prd.author)
                    authorCounts(prd.author) = authorCounts(prd.author) + 1;
                else
                    authorCounts(prd.author) = 1;
                end
                
                % Tag counts
                for j = 1:length(prd.tags)
                    tag = prd.tags{j};
                    if isKey(tagCounts, tag)
                        tagCounts(tag) = tagCounts(tag) + 1;
                    else
                        tagCounts(tag) = 1;
                    end
                end
                
                totalCompletion = totalCompletion + prd.completionPercentage;
            end
            
            averageCompletion = totalCompletion / totalPRDs;
            
            analytics = struct('totalPRDs', totalPRDs, 'statusCounts', statusCounts, ...
                             'priorityCounts', priorityCounts, 'averageCompletion', averageCompletion, ...
                             'topAuthors', authorCounts, 'tagFrequency', tagCounts, ...
                             'lastUpdated', datetime('now'));
        end
        
        function printDashboard(obj)
            fprintf('\n%s\n', repmat('=', 1, 60));
            fprintf('PRD MANAGEMENT SYSTEM - DASHBOARD\n');
            fprintf('%s\n', repmat('=', 1, 60));
            
            analytics = obj.generateAnalytics();
            
            fprintf('Total PRDs: %d\n', analytics.totalPRDs);
            fprintf('Average Completion: %.1f%%\n', analytics.averageCompletion);
            
            fprintf('\nStatus Distribution:\n');
            statusNames = PRD.STATUS_NAMES;
            for i = 1:length(analytics.statusCounts)
                if analytics.statusCounts(i) > 0
                    fprintf('  %s: %d\n', statusNames{i}, analytics.statusCounts(i));
                end
            end
            
            fprintf('\nPriority Distribution:\n');
            priorityNames = PRD.PRIORITY_NAMES;
            for i = 1:length(analytics.priorityCounts)
                if analytics.priorityCounts(i) > 0
                    fprintf('  %s: %d\n', priorityNames{i}, analytics.priorityCounts(i));
                end
            end
            
            fprintf('\nTop Authors:\n');
            if analytics.topAuthors.Count > 0
                authors = keys(analytics.topAuthors);
                counts = cell2mat(values(analytics.topAuthors));
                [~, sortIdx] = sort(counts, 'descend');
                for i = 1:min(5, length(authors))
                    idx = sortIdx(i);
                    fprintf('  %s: %d PRDs\n', authors{idx}, counts(idx));
                end
            end
            
            fprintf('\nMost Used Tags:\n');
            if analytics.tagFrequency.Count > 0
                tags = keys(analytics.tagFrequency);
                counts = cell2mat(values(analytics.tagFrequency));
                [~, sortIdx] = sort(counts, 'descend');
                for i = 1:min(5, length(tags))
                    idx = sortIdx(i);
                    fprintf('  #%s: %d times\n', tags{idx}, counts(idx));
                end
            end
            
            fprintf('\nRecent PRDs:\n');
            if ~isempty(obj.prds)
                % Sort by updated time and take last 5
                updateTimes = cellfun(@(prd) posixtime(prd.updatedAt), obj.prds);
                [~, sortIdx] = sort(updateTimes, 'descend');
                recentIdx = sortIdx(1:min(5, length(sortIdx)));
                
                for i = 1:length(recentIdx)
                    fprintf('  %s\n', obj.prds{recentIdx(i)}.toString());
                end
            end
        end
        
        function obj = loadSampleData(obj)
            sampleData = {
                {'User Authentication System', 'Implement secure login and registration', 'Dev Team', {'security', 'authentication'}};
                {'Dark Mode Theme', 'Add dark theme option for better UX', 'UX Team', {'ui', 'theme'}};
                {'Payment Gateway Integration', 'Integrate secure payment processing', 'Product Team', {'payment', 'integration'}};
                {'API Rate Limiting', 'Implement API rate limiting for security', 'Backend Team', {'api', 'security'}};
                {'Mobile App Redesign', 'Complete redesign of mobile application', 'Design Team', {'mobile', 'design'}};
                {'Real-time Notifications', 'Add real-time notification system', 'Full Stack Team', {'notifications', 'realtime'}};
                {'Performance Optimization', 'Optimize database queries and caching', 'Database Team', {'performance', 'database'}};
                {'Multi-language Support', 'Add internationalization support', 'Localization Team', {'i18n', 'localization'}};
                {'MATLAB Integration', 'Integrate MATLAB analytics engine', 'Analytics Team', {'matlab', 'analytics'}};
                {'Signal Processing Pipeline', 'Implement real-time signal processing', 'DSP Team', {'dsp', 'matlab'}}
            };
            
            % Create PRDs
            for i = 1:length(sampleData)
                data = sampleData{i};
                id = obj.createPRD(data{1}, data{2}, data{3});
                
                % Add tags
                prd = obj.getPRD(id);
                for j = 1:length(data{4})
                    prd.addTag(data{4}{j});
                end
            end
            
            % Update some statuses and priorities for variety
            if length(obj.prds) >= 10
                prdIds = cellfun(@(prd) prd.id, obj.prds, 'UniformOutput', false);
                
                obj.updatePRDStatus(prdIds{2}, 1); % IN_REVIEW
                obj.updatePRDStatus(prdIds{3}, 2); % APPROVED
                obj.updatePRDStatus(prdIds{4}, 3); % IN_DEVELOPMENT
                obj.updatePRDStatus(prdIds{5}, 4); % TESTING
                obj.updatePRDStatus(prdIds{6}, 5); % IMPLEMENTED
                
                % Update priorities
                obj.prds{3}.setPriority(3); % HIGH
                obj.prds{4}.setPriority(4); % CRITICAL
                obj.prds{9}.setPriority(3); % HIGH
                
                % Update completion percentages
                obj.updatePRDCompletion(prdIds{4}, 65);
                obj.updatePRDCompletion(prdIds{5}, 90);
                obj.updatePRDCompletion(prdIds{6}, 100);
            end
        end
        
        function stats = getCompletionStats(obj)
            if isempty(obj.prds)
                stats = struct('min', 0, 'max', 0, 'average', 0);
                return;
            end
            
            completions = cellfun(@(prd) prd.completionPercentage, obj.prds);
            stats = struct('min', min(completions), 'max', max(completions), ...
                          'average', mean(completions));
        end
        
        function prds = getPRDsNeedingAttention(obj)
            prds = {};
            for i = 1:length(obj.prds)
                prd = obj.prds{i};
                needsAttention = (prd.status == 3 && prd.completionPercentage < 50) || ...
                               (prd.priority == 4 && prd.status == 0) || ...
                               (prd.status == 4 && prd.completionPercentage < 80);
                
                if needsAttention
                    prds{end+1} = prd;
                end
            end
        end
        
        function jsonData = exportToJSON(obj)
            dataStructs = cellfun(@(prd) prd.toStruct(), obj.prds, 'UniformOutput', false);
            jsonData = jsonencode(dataStructs, 'PrettyPrint', true);
        end
        
        function generateVisualizations(obj)
            if isempty(obj.prds)
                fprintf('No data to visualize\n');
                return;
            end
            
            analytics = obj.generateAnalytics();
            
            % Status Distribution Chart
            figure('Name', 'PRD Status Distribution');
            statusData = analytics.statusCounts(analytics.statusCounts > 0);
            statusLabels = PRD.STATUS_NAMES(analytics.statusCounts > 0);
            pie(statusData, statusLabels);
            title('PRD Status Distribution');
            
            % Completion by Priority
            figure('Name', 'Completion by Priority');
            priorities = cellfun(@(prd) prd.priority, obj.prds);
            completions = cellfun(@(prd) prd.completionPercentage, obj.prds);
            
            % Create box plot
            uniquePriorities = unique(priorities);
            groupData = {};
            groupLabels = {};
            
            for i = 1:length(uniquePriorities)
                priority = uniquePriorities(i);
                priorityCompletions = completions(priorities == priority);
                groupData{end+1} = priorityCompletions;
                groupLabels{end+1} = PRD.PRIORITY_NAMES{priority};
            end
            
            boxplot([groupData{:}], 'Labels', groupLabels);
            title('Completion Percentage by Priority');
            ylabel('Completion %');
            xlabel('Priority');
            
            % Timeline of PRD Creation
            figure('Name', 'PRD Creation Timeline');
            creationTimes = cellfun(@(prd) posixtime(prd.createdAt), obj.prds);
            statuses = cellfun(@(prd) prd.status, obj.prds);
            
            scatter(creationTimes, statuses, 100, 'filled');
            ylabel('Status');
            xlabel('Creation Time');
            title('PRD Creation Timeline');
            yticks(0:6);
            yticklabels(PRD.STATUS_NAMES);
            
            % Completion Heat Map by Author and Priority
            figure('Name', 'Completion Heat Map');
            authors = unique(cellfun(@(prd) prd.author, obj.prds, 'UniformOutput', false));
            priorityNames = PRD.PRIORITY_NAMES;
            
            heatmapData = zeros(length(authors), 4);
            
            for i = 1:length(authors)
                for j = 1:4
                    authorPRDs = cellfun(@(prd) strcmp(prd.author, authors{i}) && prd.priority == j, obj.prds);
                    if any(authorPRDs)
                        authorCompletions = cellfun(@(prd) prd.completionPercentage, obj.prds(authorPRDs));
                        heatmapData(i, j) = mean(authorCompletions);
                    end
                end
            end
            
            imagesc(heatmapData);
            colorbar;
            xlabel('Priority');
            ylabel('Author');
            title('Average Completion % by Author and Priority');
            xticks(1:4);
            xticklabels(priorityNames);
            yticks(1:length(authors));
            yticklabels(authors);
            
            fprintf('Visualizations generated successfully\n');
        end
    end
end
