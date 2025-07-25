# PRD Management System - Ruby Implementation
# Version: 1.2.0 | Last Updated: July 25, 2025

require 'json'
require 'time'

module PRDManagement
  class PRDStatus
    DRAFT = 0
    IN_REVIEW = 1
    APPROVED = 2
    IN_DEVELOPMENT = 3
    TESTING = 4
    IMPLEMENTED = 5
    ARCHIVED = 6

    NAMES = {
      DRAFT => 'Draft',
      IN_REVIEW => 'In Review',
      APPROVED => 'Approved',
      IN_DEVELOPMENT => 'In Development',
      TESTING => 'Testing',
      IMPLEMENTED => 'Implemented',
      ARCHIVED => 'Archived'
    }.freeze

    def self.display_name(status)
      NAMES[status] || 'Unknown'
    end

    def self.all
      NAMES.keys
    end
  end

  class Priority
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    CRITICAL = 4

    NAMES = {
      LOW => 'Low',
      MEDIUM => 'Medium',
      HIGH => 'High',
      CRITICAL => 'Critical'
    }.freeze

    COLORS = {
      LOW => '#28a745',
      MEDIUM => '#ffc107',
      HIGH => '#fd7e14',
      CRITICAL => '#dc3545'
    }.freeze

    def self.display_name(priority)
      NAMES[priority] || 'Unknown'
    end

    def self.color_code(priority)
      COLORS[priority] || '#6c757d'
    end

    def self.all
      NAMES.keys
    end
  end

  class PRD
    attr_reader :id, :created_at
    attr_accessor :title, :description, :author, :status, :priority, :updated_at, :completion_percentage, :tags

    def initialize(title, description, author)
      @id = generate_id
      @title = title
      @description = description
      @author = author
      @status = PRDStatus::DRAFT
      @priority = Priority::MEDIUM
      @created_at = Time.now
      @updated_at = Time.now
      @completion_percentage = 0
      @tags = []
    end

    def update_status(new_status)
      @status = new_status
      @updated_at = Time.now
    end

    def set_completion_percentage(percentage)
      @completion_percentage = [[percentage, 0].max, 100].min
      @updated_at = Time.now
    end

    def add_tag(tag)
      clean_tag = tag.strip.downcase
      unless clean_tag.empty? || @tags.include?(clean_tag)
        @tags << clean_tag
        @updated_at = Time.now
      end
    end

    def set_priority(new_priority)
      @priority = new_priority
      @updated_at = Time.now
    end

    def progress_description
      "#{@completion_percentage}% complete"
    end

    def status_icon
      case @status
      when PRDStatus::DRAFT then '📝'
      when PRDStatus::IN_REVIEW then '👁️'
      when PRDStatus::APPROVED then '✅'
      when PRDStatus::IN_DEVELOPMENT then '🔨'
      when PRDStatus::TESTING then '🧪'
      when PRDStatus::IMPLEMENTED then '⭐'
      when PRDStatus::ARCHIVED then '📦'
      else '❓'
      end
    end

    def to_h
      {
        id: @id,
        title: @title,
        description: @description,
        author: @author,
        status: @status,
        priority: @priority,
        created_at: @created_at.iso8601,
        updated_at: @updated_at.iso8601,
        completion_percentage: @completion_percentage,
        tags: @tags
      }
    end

    def to_json(*args)
      to_h.to_json(*args)
    end

    def to_s
      "PRD{ID='#{@id}', Title='#{@title}', Status=#{PRDStatus.display_name(@status)}, Completion=#{@completion_percentage}%}"
    end

    private

    def generate_id
      timestamp = Time.now.to_i
      random = rand(1000..9999)
      "PRD-#{timestamp}-#{random}"
    end
  end

  class Analytics
    attr_reader :total_prds, :status_counts, :priority_counts, :average_completion,
                :top_authors, :tag_frequency, :last_updated

    def initialize(total_prds, status_counts, priority_counts, average_completion,
                   top_authors, tag_frequency)
      @total_prds = total_prds
      @status_counts = status_counts
      @priority_counts = priority_counts
      @average_completion = average_completion
      @top_authors = top_authors
      @tag_frequency = tag_frequency
      @last_updated = Time.now
    end

    def most_used_tags
      @tag_frequency.sort_by { |_, count| -count }
    end

    def top_contributors
      @top_authors.sort_by { |_, count| -count }
    end

    def to_h
      {
        total_prds: @total_prds,
        status_counts: @status_counts,
        priority_counts: @priority_counts,
        average_completion: @average_completion,
        top_authors: @top_authors,
        tag_frequency: @tag_frequency,
        last_updated: @last_updated.iso8601
      }
    end

    def to_json(*args)
      to_h.to_json(*args)
    end
  end

  class PRDManager
    def initialize
      @prds = []
      @prd_index = {}
    end

    def create_prd(title, description, author)
      prd = PRD.new(title, description, author)
      @prd_index[prd.id] = @prds.length
      @prds << prd

      puts "PRD created successfully: #{prd.id}"
      prd.id
    end

    def get_prd(id)
      index = @prd_index[id]
      index ? @prds[index] : nil
    end

    def get_all_prds
      @prds.dup
    end

    def get_prds_by_status(status)
      @prds.select { |prd| prd.status == status }
    end

    def get_prds_by_priority(priority)
      @prds.select { |prd| prd.priority == priority }
    end

    def search_prds(search_term)
      search_term = search_term.downcase
      @prds.select do |prd|
        prd.title.downcase.include?(search_term) ||
          prd.description.downcase.include?(search_term) ||
          prd.tags.any? { |tag| tag.include?(search_term) }
      end
    end

    def update_prd_status(id, new_status)
      prd = get_prd(id)
      if prd
        prd.update_status(new_status)
        puts "PRD #{id} status updated to: #{PRDStatus.display_name(new_status)}"
        true
      else
        false
      end
    end

    def update_prd_completion(id, percentage)
      prd = get_prd(id)
      if prd
        prd.set_completion_percentage(percentage)
        true
      else
        false
      end
    end

    def generate_analytics
      total_prds = @prds.length
      status_counts = Hash.new(0)
      priority_counts = Hash.new(0)
      author_counts = Hash.new(0)
      tag_counts = Hash.new(0)
      total_completion = 0

      @prds.each do |prd|
        # Count by status
        status_counts[PRDStatus.display_name(prd.status)] += 1

        # Count by priority
        priority_counts[Priority.display_name(prd.priority)] += 1

        # Count by author
        author_counts[prd.author] += 1

        # Count tags
        prd.tags.each { |tag| tag_counts[tag] += 1 }

        total_completion += prd.completion_percentage
      end

      average_completion = total_prds > 0 ? total_completion.to_f / total_prds : 0.0

      Analytics.new(
        total_prds,
        status_counts,
        priority_counts,
        average_completion,
        author_counts,
        tag_counts
      )
    end

    def export_to_json
      JSON.pretty_generate(@prds.map(&:to_h))
    end

    def import_from_json(json_string)
      data = JSON.parse(json_string, symbolize_names: true)
      @prds.clear
      @prd_index.clear

      data.each do |prd_data|
        prd = PRD.new(prd_data[:title], prd_data[:description], prd_data[:author])
        # Set other properties if needed from prd_data
        @prd_index[prd.id] = @prds.length
        @prds << prd
      end

      true
    rescue JSON::ParserError => e
      puts "Error importing JSON: #{e.message}"
      false
    end

    def print_dashboard
      puts "\n#{'=' * 60}"
      puts "PRD MANAGEMENT SYSTEM - DASHBOARD"
      puts "#{'=' * 60}"

      analytics = generate_analytics

      puts "Total PRDs: #{analytics.total_prds}"
      puts "Average Completion: #{format('%.1f', analytics.average_completion)}%"

      puts "\nStatus Distribution:"
      analytics.status_counts.sort.each do |status, count|
        puts "  #{status}: #{count}"
      end

      puts "\nPriority Distribution:"
      analytics.priority_counts.sort.each do |priority, count|
        puts "  #{priority}: #{count}"
      end

      puts "\nTop Authors:"
      analytics.top_contributors.first(5).each do |author, count|
        puts "  #{author}: #{count} PRDs"
      end

      puts "\nMost Used Tags:"
      analytics.most_used_tags.first(5).each do |tag, count|
        puts "  ##{tag}: #{count} times"
      end

      puts "\nRecent PRDs:"
      recent_prds = @prds.sort_by(&:updated_at).reverse.first(5)
      recent_prds.each do |prd|
        puts "  #{prd}"
      end
    end

    def load_sample_data
      sample_data = [
        ['User Authentication System', 'Implement secure login and registration', 'Dev Team', %w[security authentication]],
        ['Dark Mode Theme', 'Add dark theme option for better UX', 'UX Team', %w[ui theme]],
        ['Payment Gateway Integration', 'Integrate secure payment processing', 'Product Team', %w[payment integration]],
        ['API Rate Limiting', 'Implement API rate limiting for security', 'Backend Team', %w[api security]],
        ['Mobile App Redesign', 'Complete redesign of mobile application', 'Design Team', %w[mobile design]],
        ['Real-time Notifications', 'Add real-time notification system', 'Full Stack Team', %w[notifications realtime]],
        ['Performance Optimization', 'Optimize database queries and caching', 'Database Team', %w[performance database]],
        ['Multi-language Support', 'Add internationalization support', 'Localization Team', %w[i18n localization]],
        ['Social Media Integration', 'Add social sharing and login features', 'Social Team', %w[social integration]],
        ['Analytics Dashboard', 'Create comprehensive analytics dashboard', 'Analytics Team', %w[analytics dashboard]]
      ]

      sample_data.each do |title, description, author, tags|
        id = create_prd(title, description, author)
        prd = get_prd(id)
        tags.each { |tag| prd.add_tag(tag) } if prd
      end

      # Update some statuses and priorities for variety
      if @prds.length >= 10
        update_prd_status(@prds[1].id, PRDStatus::IN_REVIEW)
        update_prd_status(@prds[2].id, PRDStatus::APPROVED)
        update_prd_status(@prds[3].id, PRDStatus::IN_DEVELOPMENT)
        update_prd_status(@prds[4].id, PRDStatus::TESTING)
        update_prd_status(@prds[5].id, PRDStatus::IMPLEMENTED)

        @prds[2].set_priority(Priority::HIGH)
        @prds[3].set_priority(Priority::CRITICAL)
        @prds[8].set_priority(Priority::HIGH)

        update_prd_completion(@prds[3].id, 65)
        update_prd_completion(@prds[4].id, 90)
        update_prd_completion(@prds[5].id, 100)
      end
    end

    def get_completion_stats
      return { min: 0, max: 0, average: 0.0 } if @prds.empty?

      completions = @prds.map(&:completion_percentage)
      {
        min: completions.min,
        max: completions.max,
        average: completions.sum.to_f / completions.length
      }
    end

    def get_prds_needing_attention
      @prds.select do |prd|
        (prd.status == PRDStatus::IN_DEVELOPMENT && prd.completion_percentage < 50) ||
          (prd.priority == Priority::CRITICAL && prd.status == PRDStatus::DRAFT) ||
          (prd.status == PRDStatus::TESTING && prd.completion_percentage < 80)
      end
    end

    def get_status_progress_report
      PRDStatus.all.each_with_object({}) do |status, report|
        prds_with_status = get_prds_by_status(status)
        avg_completion = if prds_with_status.empty?
                          0.0
                        else
                          prds_with_status.map(&:completion_percentage).sum.to_f / prds_with_status.length
                        end
        report[PRDStatus.display_name(status)] = avg_completion
      end
    end
  end
end

# Demo Implementation
def main
  puts "PRD Management System v1.2.0 - Ruby Implementation"
  puts "==================================================="

  # Initialize the manager
  manager = PRDManagement::PRDManager.new

  # Load sample data
  manager.load_sample_data

  # Display dashboard
  manager.print_dashboard

  # Demo operations
  puts "\n#{'=' * 60}"
  puts "DEMO OPERATIONS"
  puts "#{'=' * 60}"

  # Search demo
  search_results = manager.search_prds("authentication")
  puts "\nSearching for 'authentication' related PRDs:"
  search_results.each do |prd|
    puts "  Found: #{prd}"
  end

  # Filter by status demo
  draft_prds = manager.get_prds_by_status(PRDManagement::PRDStatus::DRAFT)
  puts "\nDraft PRDs (#{draft_prds.length}):"
  draft_prds.each do |prd|
    puts "  #{prd}"
  end

  # Priority filtering demo
  critical_prds = manager.get_prds_by_priority(PRDManagement::Priority::CRITICAL)
  puts "\nCritical Priority PRDs (#{critical_prds.length}):"
  critical_prds.each do |prd|
    puts "  #{prd.status_icon} #{prd}"
  end

  # PRDs needing attention
  needing_attention = manager.get_prds_needing_attention
  puts "\nPRDs Needing Attention (#{needing_attention.length}):"
  needing_attention.each do |prd|
    priority_name = PRDManagement::Priority.display_name(prd.priority)
    puts "  #{prd.status_icon} #{prd} - #{priority_name} priority"
  end

  # Completion statistics
  stats = manager.get_completion_stats
  puts "\nCompletion Statistics:"
  puts "  Minimum: #{stats[:min]}%"
  puts "  Maximum: #{stats[:max]}%"
  puts "  Average: #{format('%.1f', stats[:average])}%"

  # Status progress report
  puts "\nStatus Progress Report:"
  progress_report = manager.get_status_progress_report
  progress_report.each do |status, avg_completion|
    puts "  #{status}: #{format('%.1f', avg_completion)}% average completion"
  end

  # Export demo
  puts "\nExporting PRD data to JSON..."
  begin
    json_data = manager.export_to_json
    puts "Export completed. JSON length: #{json_data.length} characters"

    # Test import
    test_manager = PRDManagement::PRDManager.new
    if test_manager.import_from_json(json_data)
      puts "JSON import test: Success!"
    end
  rescue => e
    puts "Error exporting to JSON: #{e.message}"
  end

  puts "\nRuby PRD Management System demonstration completed!"
end

# Run the demo
main if __FILE__ == $0
