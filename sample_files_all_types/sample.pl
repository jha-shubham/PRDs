#!/usr/bin/perl
# PRD Management System - Perl Implementation
# Version: 1.2.0 | Last Updated: July 25, 2025

use strict;
use warnings;
use Data::Dumper;
use JSON;
use Time::HiRes qw(time);
use POSIX qw(strftime);
use List::Util qw(first max min sum);

print "PRD Management System v1.2.0 - Perl Implementation\n";
print "=" x 60 . "\n";

# PRD Class
package PRD {
    use constant {
        DRAFT => 0,
        IN_REVIEW => 1,
        APPROVED => 2,
        IN_DEVELOPMENT => 3,
        TESTING => 4,
        IMPLEMENTED => 5,
        ARCHIVED => 6
    };
    
    use constant {
        LOW => 1,
        MEDIUM => 2,
        HIGH => 3,
        CRITICAL => 4
    };
    
    my @STATUS_NAMES = qw(Draft InReview Approved InDevelopment Testing Implemented Archived);
    my @PRIORITY_NAMES = qw(Low Medium High Critical);
    my @STATUS_ICONS = qw(📝 👁️ ✅ 🔨 🧪 ⭐ 📦);
    my @PRIORITY_COLORS = ('#28a745', '#ffc107', '#fd7e14', '#dc3545');
    
    sub new {
        my ($class, $title, $description, $author) = @_;
        my $self = {
            id => _generate_id(),
            title => $title,
            description => $description,
            author => $author,
            status => DRAFT,
            priority => MEDIUM,
            created_at => time(),
            updated_at => time(),
            completion_percentage => 0,
            tags => []
        };
        bless $self, $class;
        return $self;
    }
    
    sub _generate_id {
        my $timestamp = int(time() * 1000);
        my $random = int(rand(9999)) + 1000;
        return "PRD-$timestamp-$random";
    }
    
    sub update_status {
        my ($self, $new_status) = @_;
        $self->{status} = $new_status;
        $self->{updated_at} = time();
    }
    
    sub set_completion_percentage {
        my ($self, $percentage) = @_;
        $self->{completion_percentage} = ($percentage < 0) ? 0 : (($percentage > 100) ? 100 : $percentage);
        $self->{updated_at} = time();
    }
    
    sub add_tag {
        my ($self, $tag) = @_;
        my $clean_tag = lc($tag);
        $clean_tag =~ s/^\s+|\s+$//g; # trim whitespace
        
        if ($clean_tag && !grep { $_ eq $clean_tag } @{$self->{tags}}) {
            push @{$self->{tags}}, $clean_tag;
            $self->{updated_at} = time();
        }
    }
    
    sub set_priority {
        my ($self, $priority) = @_;
        $self->{priority} = $priority;
        $self->{updated_at} = time();
    }
    
    sub get_status_name {
        my ($self) = @_;
        return $STATUS_NAMES[$self->{status}];
    }
    
    sub get_priority_name {
        my ($self) = @_;
        return $PRIORITY_NAMES[$self->{priority} - 1];
    }
    
    sub get_status_icon {
        my ($self) = @_;
        return $STATUS_ICONS[$self->{status}];
    }
    
    sub get_priority_color {
        my ($self) = @_;
        return $PRIORITY_COLORS[$self->{priority} - 1];
    }
    
    sub get_progress_description {
        my ($self) = @_;
        return $self->{completion_percentage} . "% complete";
    }
    
    sub format_timestamp {
        my ($self, $timestamp) = @_;
        return strftime("%Y-%m-%d %H:%M:%S", localtime($timestamp));
    }
    
    sub get_created_date {
        my ($self) = @_;
        return $self->format_timestamp($self->{created_at});
    }
    
    sub get_updated_date {
        my ($self) = @_;
        return $self->format_timestamp($self->{updated_at});
    }
    
    sub to_string {
        my ($self) = @_;
        return sprintf("PRD{ID='%s', Title='%s', Status=%s, Completion=%d%%}",
                      $self->{id}, $self->{title}, $self->get_status_name(), $self->{completion_percentage});
    }
    
    sub to_hash {
        my ($self) = @_;
        return {
            id => $self->{id},
            title => $self->{title},
            description => $self->{description},
            author => $self->{author},
            status => $self->{status},
            priority => $self->{priority},
            created_at => $self->get_created_date(),
            updated_at => $self->get_updated_date(),
            completion_percentage => $self->{completion_percentage},
            tags => [@{$self->{tags}}]
        };
    }
    
    sub matches_search {
        my ($self, $search_term) = @_;
        my $term = lc($search_term);
        
        return (index(lc($self->{title}), $term) != -1) ||
               (index(lc($self->{description}), $term) != -1) ||
               (grep { index($_, $term) != -1 } @{$self->{tags}});
    }
    
    sub needs_attention {
        my ($self) = @_;
        return ($self->{status} == IN_DEVELOPMENT && $self->{completion_percentage} < 50) ||
               ($self->{priority} == CRITICAL && $self->{status} == DRAFT) ||
               ($self->{status} == TESTING && $self->{completion_percentage} < 80);
    }
    
    sub get_age_days {
        my ($self) = @_;
        return int((time() - $self->{created_at}) / 86400);
    }
    
    sub is_stale {
        my ($self) = @_;
        my $days_since_update = int((time() - $self->{updated_at}) / 86400);
        return $days_since_update > 30 && $self->{status} != IMPLEMENTED && $self->{status} != ARCHIVED;
    }
    
    sub get_detailed_info {
        my ($self) = @_;
        my $info = sprintf("PRD Details:\n");
        $info .= sprintf("  ID: %s\n", $self->{id});
        $info .= sprintf("  Title: %s\n", $self->{title});
        $info .= sprintf("  Description: %s\n", $self->{description});
        $info .= sprintf("  Author: %s\n", $self->{author});
        $info .= sprintf("  Status: %s %s\n", $self->get_status_icon(), $self->get_status_name());
        $info .= sprintf("  Priority: %s\n", $self->get_priority_name());
        $info .= sprintf("  Completion: %s\n", $self->get_progress_description());
        $info .= sprintf("  Created: %s (%d days ago)\n", $self->get_created_date(), $self->get_age_days());
        $info .= sprintf("  Updated: %s\n", $self->get_updated_date());
        
        if (@{$self->{tags}}) {
            $info .= sprintf("  Tags: %s\n", join(', ', map { "#$_" } @{$self->{tags}}));
        }
        
        return $info;
    }
}

# PRD Manager Class
package PRDManager {
    sub new {
        my ($class) = @_;
        my $self = {
            prds => [],
            prd_index => {}
        };
        bless $self, $class;
        return $self;
    }
    
    sub create_prd {
        my ($self, $title, $description, $author) = @_;
        my $prd = PRD->new($title, $description, $author);
        
        push @{$self->{prds}}, $prd;
        $self->{prd_index}->{$prd->{id}} = $prd;
        
        print "PRD created successfully: " . $prd->{id} . "\n";
        return $prd->{id};
    }
    
    sub get_prd {
        my ($self, $id) = @_;
        return $self->{prd_index}->{$id};
    }
    
    sub get_all_prds {
        my ($self) = @_;
        return @{$self->{prds}};
    }
    
    sub get_prds_by_status {
        my ($self, $status) = @_;
        return grep { $_->{status} == $status } @{$self->{prds}};
    }
    
    sub get_prds_by_priority {
        my ($self, $priority) = @_;
        return grep { $_->{priority} == $priority } @{$self->{prds}};
    }
    
    sub get_prds_by_author {
        my ($self, $author) = @_;
        return grep { $_->{author} eq $author } @{$self->{prds}};
    }
    
    sub search_prds {
        my ($self, $search_term) = @_;
        return grep { $_->matches_search($search_term) } @{$self->{prds}};
    }
    
    sub update_prd_status {
        my ($self, $id, $new_status) = @_;
        my $prd = $self->get_prd($id);
        if ($prd) {
            $prd->update_status($new_status);
            printf "PRD %s status updated to: %s\n", $id, $prd->get_status_name();
            return 1;
        }
        return 0;
    }
    
    sub update_prd_completion {
        my ($self, $id, $percentage) = @_;
        my $prd = $self->get_prd($id);
        if ($prd) {
            $prd->set_completion_percentage($percentage);
            return 1;
        }
        return 0;
    }
    
    sub add_prd_tag {
        my ($self, $id, $tag) = @_;
        my $prd = $self->get_prd($id);
        if ($prd) {
            $prd->add_tag($tag);
            return 1;
        }
        return 0;
    }
    
    sub get_prds_needing_attention {
        my ($self) = @_;
        return grep { $_->needs_attention() } @{$self->{prds}};
    }
    
    sub get_stale_prds {
        my ($self) = @_;
        return grep { $_->is_stale() } @{$self->{prds}};
    }
    
    sub generate_analytics {
        my ($self) = @_;
        my $total_prds = scalar @{$self->{prds}};
        
        return {
            total_prds => 0,
            status_counts => [0, 0, 0, 0, 0, 0, 0],
            priority_counts => [0, 0, 0, 0],
            average_completion => 0,
            author_counts => {},
            tag_frequency => {},
            last_updated => time()
        } if $total_prds == 0;
        
        my @status_counts = (0) x 7;
        my @priority_counts = (0) x 4;
        my %author_counts;
        my %tag_frequency;
        my $total_completion = 0;
        
        for my $prd (@{$self->{prds}}) {
            $status_counts[$prd->{status}]++;
            $priority_counts[$prd->{priority} - 1]++;
            $author_counts{$prd->{author}}++;
            $total_completion += $prd->{completion_percentage};
            
            for my $tag (@{$prd->{tags}}) {
                $tag_frequency{$tag}++;
            }
        }
        
        my $average_completion = $total_completion / $total_prds;
        
        return {
            total_prds => $total_prds,
            status_counts => \@status_counts,
            priority_counts => \@priority_counts,
            average_completion => $average_completion,
            author_counts => \%author_counts,
            tag_frequency => \%tag_frequency,
            last_updated => time()
        };
    }
    
    sub print_dashboard {
        my ($self) = @_;
        
        print "\n" . "=" x 60 . "\n";
        print "PRD MANAGEMENT SYSTEM - DASHBOARD\n";
        print "=" x 60 . "\n";
        
        my $analytics = $self->generate_analytics();
        
        printf "Total PRDs: %d\n", $analytics->{total_prds};
        printf "Average Completion: %.1f%%\n", $analytics->{average_completion};
        
        print "\nStatus Distribution:\n";
        my @status_names = qw(Draft InReview Approved InDevelopment Testing Implemented Archived);
        for my $i (0..$#{$analytics->{status_counts}}) {
            if ($analytics->{status_counts}->[$i] > 0) {
                printf "  %s: %d\n", $status_names[$i], $analytics->{status_counts}->[$i];
            }
        }
        
        print "\nPriority Distribution:\n";
        my @priority_names = qw(Low Medium High Critical);
        for my $i (0..$#{$analytics->{priority_counts}}) {
            if ($analytics->{priority_counts}->[$i] > 0) {
                printf "  %s: %d\n", $priority_names[$i], $analytics->{priority_counts}->[$i];
            }
        }
        
        print "\nTop Authors:\n";
        my @sorted_authors = sort { $analytics->{author_counts}->{$b} <=> $analytics->{author_counts}->{$a} } 
                            keys %{$analytics->{author_counts}};
        for my $i (0..min(4, $#sorted_authors)) {
            my $author = $sorted_authors[$i];
            printf "  %s: %d PRDs\n", $author, $analytics->{author_counts}->{$author};
        }
        
        print "\nMost Used Tags:\n";
        my @sorted_tags = sort { $analytics->{tag_frequency}->{$b} <=> $analytics->{tag_frequency}->{$a} } 
                         keys %{$analytics->{tag_frequency}};
        for my $i (0..min(4, $#sorted_tags)) {
            my $tag = $sorted_tags[$i];
            printf "  #%s: %d times\n", $tag, $analytics->{tag_frequency}->{$tag};
        }
        
        print "\nRecent PRDs:\n";
        my @sorted_prds = sort { $b->{updated_at} <=> $a->{updated_at} } @{$self->{prds}};
        for my $i (0..min(4, $#sorted_prds)) {
            print "  " . $sorted_prds[$i]->to_string() . "\n";
        }
        
        # PRDs needing attention
        my @attention_prds = $self->get_prds_needing_attention();
        if (@attention_prds) {
            print "\nPRDs Needing Attention:\n";
            for my $prd (@attention_prds) {
                printf "  %s %s - %s priority\n", 
                       $prd->get_status_icon(), $prd->to_string(), $prd->get_priority_name();
            }
        }
        
        # Stale PRDs
        my @stale_prds = $self->get_stale_prds();
        if (@stale_prds) {
            print "\nStale PRDs (no updates in 30+ days):\n";
            for my $prd (@stale_prds) {
                printf "  ⚠️  %s (last updated: %s)\n", $prd->to_string(), $prd->get_updated_date();
            }
        }
    }
    
    sub load_sample_data {
        my ($self) = @_;
        
        my @sample_data = (
            ["User Authentication System", "Implement secure login and registration", "Dev Team", ["security", "authentication"]],
            ["Dark Mode Theme", "Add dark theme option for better UX", "UX Team", ["ui", "theme"]],
            ["Payment Gateway Integration", "Integrate secure payment processing", "Product Team", ["payment", "integration"]],
            ["API Rate Limiting", "Implement API rate limiting for security", "Backend Team", ["api", "security"]],
            ["Mobile App Redesign", "Complete redesign of mobile application", "Design Team", ["mobile", "design"]],
            ["Real-time Notifications", "Add real-time notification system", "Full Stack Team", ["notifications", "realtime"]],
            ["Performance Optimization", "Optimize database queries and caching", "Database Team", ["performance", "database"]],
            ["Multi-language Support", "Add internationalization support", "Localization Team", ["i18n", "localization"]],
            ["Perl Script Automation", "Automate deployment with Perl scripts", "DevOps Team", ["perl", "automation"]],
            ["Log Analysis Pipeline", "Build log processing with Perl regex", "Analytics Team", ["perl", "logs"]]
        );
        
        my @prd_ids;
        for my $data (@sample_data) {
            my ($title, $description, $author, $tags) = @$data;
            my $id = $self->create_prd($title, $description, $author);
            push @prd_ids, $id;
            
            # Add tags
            for my $tag (@$tags) {
                $self->add_prd_tag($id, $tag);
            }
        }
        
        # Update some statuses and priorities for variety
        if (@prd_ids >= 10) {
            $self->update_prd_status($prd_ids[1], PRD::IN_REVIEW);
            $self->update_prd_status($prd_ids[2], PRD::APPROVED);
            $self->update_prd_status($prd_ids[3], PRD::IN_DEVELOPMENT);
            $self->update_prd_status($prd_ids[4], PRD::TESTING);
            $self->update_prd_status($prd_ids[5], PRD::IMPLEMENTED);
            
            # Update priorities
            $self->get_prd($prd_ids[2])->set_priority(PRD::HIGH);
            $self->get_prd($prd_ids[3])->set_priority(PRD::CRITICAL);
            $self->get_prd($prd_ids[8])->set_priority(PRD::HIGH);
            
            # Update completion percentages
            $self->update_prd_completion($prd_ids[3], 65);
            $self->update_prd_completion($prd_ids[4], 90);
            $self->update_prd_completion($prd_ids[5], 100);
        }
        
        return $self;
    }
    
    sub get_completion_stats {
        my ($self) = @_;
        return { min => 0, max => 0, average => 0 } if !@{$self->{prds}};
        
        my @completions = map { $_->{completion_percentage} } @{$self->{prds}};
        return {
            min => min(@completions),
            max => max(@completions),
            average => sum(@completions) / @completions
        };
    }
    
    sub export_to_json {
        my ($self) = @_;
        my @data = map { $_->to_hash() } @{$self->{prds}};
        my $json = JSON->new->pretty->encode(\@data);
        return $json;
    }
    
    sub export_to_csv {
        my ($self) = @_;
        my $csv = "ID,Title,Description,Author,Status,Priority,Completion,Created,Updated,Tags\n";
        
        for my $prd (@{$self->{prds}}) {
            my $tags = join(';', @{$prd->{tags}});
            $csv .= sprintf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",%d,\"%s\",\"%s\",\"%s\"\n",
                           $prd->{id}, $prd->{title}, $prd->{description}, $prd->{author},
                           $prd->get_status_name(), $prd->get_priority_name(),
                           $prd->{completion_percentage}, $prd->get_created_date(),
                           $prd->get_updated_date(), $tags);
        }
        
        return $csv;
    }
    
    sub search_and_filter {
        my ($self, $options) = @_;
        my @results = @{$self->{prds}};
        
        # Apply search term filter
        if ($options->{search_term}) {
            @results = grep { $_->matches_search($options->{search_term}) } @results;
        }
        
        # Apply status filter
        if (defined $options->{status}) {
            @results = grep { $_->{status} == $options->{status} } @results;
        }
        
        # Apply priority filter
        if (defined $options->{priority}) {
            @results = grep { $_->{priority} == $options->{priority} } @results;
        }
        
        # Apply author filter
        if ($options->{author}) {
            @results = grep { $_->{author} eq $options->{author} } @results;
        }
        
        # Apply completion range filter
        if (defined $options->{min_completion}) {
            @results = grep { $_->{completion_percentage} >= $options->{min_completion} } @results;
        }
        
        if (defined $options->{max_completion}) {
            @results = grep { $_->{completion_percentage} <= $options->{max_completion} } @results;
        }
        
        # Apply sorting
        if ($options->{sort_by}) {
            if ($options->{sort_by} eq 'title') {
                @results = sort { $a->{title} cmp $b->{title} } @results;
            } elsif ($options->{sort_by} eq 'created') {
                @results = sort { $a->{created_at} <=> $b->{created_at} } @results;
            } elsif ($options->{sort_by} eq 'updated') {
                @results = sort { $b->{updated_at} <=> $a->{updated_at} } @results;
            } elsif ($options->{sort_by} eq 'completion') {
                @results = sort { $b->{completion_percentage} <=> $a->{completion_percentage} } @results;
            }
        }
        
        return @results;
    }
}

# Main execution
sub main {
    # Create PRD Manager
    my $manager = PRDManager->new();
    
    # Load sample data
    $manager->load_sample_data();
    
    # Print dashboard
    $manager->print_dashboard();
    
    # Demo operations
    print "\n" . "=" x 60 . "\n";
    print "DEMO OPERATIONS\n";
    print "=" x 60 . "\n";
    
    # Search demo
    my @search_results = $manager->search_prds('authentication');
    print "\nSearching for 'authentication' related PRDs:\n";
    for my $prd (@search_results) {
        print "  Found: " . $prd->to_string() . "\n";
    }
    
    # Filter by status demo
    my @draft_prds = $manager->get_prds_by_status(PRD::DRAFT);
    printf "\nDraft PRDs (%d):\n", scalar @draft_prds;
    for my $prd (@draft_prds) {
        print "  " . $prd->to_string() . "\n";
    }
    
    # Priority filtering demo
    my @critical_prds = $manager->get_prds_by_priority(PRD::CRITICAL);
    printf "\nCritical Priority PRDs (%d):\n", scalar @critical_prds;
    for my $prd (@critical_prds) {
        printf "  %s %s\n", $prd->get_status_icon(), $prd->to_string();
    }
    
    # Completion statistics
    my $stats = $manager->get_completion_stats();
    print "\nCompletion Statistics:\n";
    printf "  Minimum: %d%%\n", $stats->{min};
    printf "  Maximum: %d%%\n", $stats->{max};
    printf "  Average: %.1f%%\n", $stats->{average};
    
    # Advanced search demo
    print "\nAdvanced Search - High priority, incomplete PRDs:\n";
    my @advanced_results = $manager->search_and_filter({
        priority => PRD::HIGH,
        max_completion => 90,
        sort_by => 'completion'
    });
    
    for my $prd (@advanced_results) {
        printf "  %s %s - %s (%s)\n", 
               $prd->get_status_icon(), 
               $prd->to_string(), 
               $prd->get_priority_name(),
               $prd->get_progress_description();
    }
    
    # Export demo
    print "\nExporting PRD data...\n";
    eval {
        my $json_data = $manager->export_to_json();
        printf "JSON export completed. Length: %d characters\n", length($json_data);
        
        my $csv_data = $manager->export_to_csv();
        printf "CSV export completed. Length: %d characters\n", length($csv_data);
    };
    if ($@) {
        print "Error during export: $@\n";
    }
    
    # Detailed PRD info demo
    my @all_prds = $manager->get_all_prds();
    if (@all_prds) {
        print "\nDetailed PRD Information (first PRD):\n";
        print $all_prds[0]->get_detailed_info();
    }
    
    print "\nPerl PRD Management System demonstration completed!\n";
    print "Perl Features Demonstrated:\n";
    print "  ✓ Object-oriented programming with packages\n";
    print "  ✓ Hash and array references\n";
    print "  ✓ Pattern matching and text processing\n";
    print "  ✓ JSON serialization\n";
    print "  ✓ Advanced data structures and algorithms\n";
    print "  ✓ Error handling with eval\n";
    print "  ✓ Time and date manipulation\n";
    print "  ✓ List processing and functional programming\n";
}

# Run the main function
main() unless caller;
