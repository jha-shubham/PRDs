<?php
/**
 * PRD Management System - PHP Implementation
 * Version: 1.2.0 | Last Updated: July 25, 2025
 */

namespace PRDManagement;

enum PRDStatus: int
{
    case DRAFT = 0;
    case IN_REVIEW = 1;
    case APPROVED = 2;
    case IN_DEVELOPMENT = 3;
    case TESTING = 4;
    case IMPLEMENTED = 5;
    case ARCHIVED = 6;

    public function getDisplayName(): string
    {
        return match($this) {
            self::DRAFT => 'Draft',
            self::IN_REVIEW => 'In Review',
            self::APPROVED => 'Approved',
            self::IN_DEVELOPMENT => 'In Development',
            self::TESTING => 'Testing',
            self::IMPLEMENTED => 'Implemented',
            self::ARCHIVED => 'Archived',
        };
    }
}

enum Priority: int
{
    case LOW = 1;
    case MEDIUM = 2;
    case HIGH = 3;
    case CRITICAL = 4;

    public function getDisplayName(): string
    {
        return match($this) {
            self::LOW => 'Low',
            self::MEDIUM => 'Medium',
            self::HIGH => 'High',
            self::CRITICAL => 'Critical',
        };
    }

    public function getColorCode(): string
    {
        return match($this) {
            self::LOW => '#28a745',
            self::MEDIUM => '#ffc107',
            self::HIGH => '#fd7e14',
            self::CRITICAL => '#dc3545',
        };
    }
}

class PRD implements \JsonSerializable
{
    private string $id;
    private string $title;
    private string $description;
    private string $author;
    private PRDStatus $status;
    private Priority $priority;
    private \DateTime $createdAt;
    private \DateTime $updatedAt;
    private int $completionPercentage;
    private array $tags;

    public function __construct(string $title, string $description, string $author)
    {
        $this->id = $this->generateId();
        $this->title = $title;
        $this->description = $description;
        $this->author = $author;
        $this->status = PRDStatus::DRAFT;
        $this->priority = Priority::MEDIUM;
        $this->createdAt = new \DateTime();
        $this->updatedAt = new \DateTime();
        $this->completionPercentage = 0;
        $this->tags = [];
    }

    private function generateId(): string
    {
        $timestamp = time();
        $random = rand(1000, 9999);
        return "PRD-{$timestamp}-{$random}";
    }

    public function updateStatus(PRDStatus $newStatus): void
    {
        $this->status = $newStatus;
        $this->updatedAt = new \DateTime();
    }

    public function setCompletionPercentage(int $percentage): void
    {
        $this->completionPercentage = max(0, min(100, $percentage));
        $this->updatedAt = new \DateTime();
    }

    public function addTag(string $tag): void
    {
        $cleanTag = strtolower(trim($tag));
        if (!empty($cleanTag) && !in_array($cleanTag, $this->tags)) {
            $this->tags[] = $cleanTag;
            $this->updatedAt = new \DateTime();
        }
    }

    public function setPriority(Priority $priority): void
    {
        $this->priority = $priority;
        $this->updatedAt = new \DateTime();
    }

    // Getters
    public function getId(): string { return $this->id; }
    public function getTitle(): string { return $this->title; }
    public function getDescription(): string { return $this->description; }
    public function getAuthor(): string { return $this->author; }
    public function getStatus(): PRDStatus { return $this->status; }
    public function getPriority(): Priority { return $this->priority; }
    public function getCreatedAt(): \DateTime { return $this->createdAt; }
    public function getUpdatedAt(): \DateTime { return $this->updatedAt; }
    public function getCompletionPercentage(): int { return $this->completionPercentage; }
    public function getTags(): array { return $this->tags; }

    public function getProgressDescription(): string
    {
        return "{$this->completionPercentage}% complete";
    }

    public function getStatusIcon(): string
    {
        return match($this->status) {
            PRDStatus::DRAFT => '📝',
            PRDStatus::IN_REVIEW => '👁️',
            PRDStatus::APPROVED => '✅',
            PRDStatus::IN_DEVELOPMENT => '🔨',
            PRDStatus::TESTING => '🧪',
            PRDStatus::IMPLEMENTED => '⭐',
            PRDStatus::ARCHIVED => '📦',
        };
    }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'author' => $this->author,
            'status' => $this->status->value,
            'priority' => $this->priority->value,
            'created_at' => $this->createdAt->format('c'),
            'updated_at' => $this->updatedAt->format('c'),
            'completion_percentage' => $this->completionPercentage,
            'tags' => $this->tags,
        ];
    }

    public function __toString(): string
    {
        return "PRD{ID='{$this->id}', Title='{$this->title}', Status={$this->status->getDisplayName()}, Completion={$this->completionPercentage}%}";
    }
}

class Analytics implements \JsonSerializable
{
    public function __construct(
        public readonly int $totalPRDs,
        public readonly array $statusCounts,
        public readonly array $priorityCounts,
        public readonly float $averageCompletion,
        public readonly array $topAuthors,
        public readonly array $tagFrequency,
        public readonly \DateTime $lastUpdated
    ) {}

    public function getMostUsedTags(): array
    {
        arsort($this->tagFrequency);
        return $this->tagFrequency;
    }

    public function getTopContributors(): array
    {
        arsort($this->topAuthors);
        return $this->topAuthors;
    }

    public function jsonSerialize(): array
    {
        return [
            'total_prds' => $this->totalPRDs,
            'status_counts' => $this->statusCounts,
            'priority_counts' => $this->priorityCounts,
            'average_completion' => $this->averageCompletion,
            'top_authors' => $this->topAuthors,
            'tag_frequency' => $this->tagFrequency,
            'last_updated' => $this->lastUpdated->format('c'),
        ];
    }
}

class PRDManager
{
    private array $prds = [];
    private array $prdIndex = [];

    public function createPRD(string $title, string $description, string $author): string
    {
        $prd = new PRD($title, $description, $author);
        $this->prdIndex[$prd->getId()] = count($this->prds);
        $this->prds[] = $prd;

        echo "PRD created successfully: {$prd->getId()}\n";
        return $prd->getId();
    }

    public function getPRD(string $id): ?PRD
    {
        $index = $this->prdIndex[$id] ?? null;
        return $index !== null ? ($this->prds[$index] ?? null) : null;
    }

    public function getAllPRDs(): array
    {
        return $this->prds;
    }

    public function getPRDsByStatus(PRDStatus $status): array
    {
        return array_filter($this->prds, fn($prd) => $prd->getStatus() === $status);
    }

    public function getPRDsByPriority(Priority $priority): array
    {
        return array_filter($this->prds, fn($prd) => $prd->getPriority() === $priority);
    }

    public function searchPRDs(string $searchTerm): array
    {
        $searchTerm = strtolower($searchTerm);
        return array_filter($this->prds, function($prd) use ($searchTerm) {
            return str_contains(strtolower($prd->getTitle()), $searchTerm) ||
                   str_contains(strtolower($prd->getDescription()), $searchTerm) ||
                   array_reduce($prd->getTags(), fn($carry, $tag) => $carry || str_contains($tag, $searchTerm), false);
        });
    }

    public function updatePRDStatus(string $id, PRDStatus $newStatus): bool
    {
        $prd = $this->getPRD($id);
        if ($prd) {
            $prd->updateStatus($newStatus);
            echo "PRD {$id} status updated to: {$newStatus->getDisplayName()}\n";
            return true;
        }
        return false;
    }

    public function updatePRDCompletion(string $id, int $percentage): bool
    {
        $prd = $this->getPRD($id);
        if ($prd) {
            $prd->setCompletionPercentage($percentage);
            return true;
        }
        return false;
    }

    public function generateAnalytics(): Analytics
    {
        $totalPRDs = count($this->prds);
        $statusCounts = [];
        $priorityCounts = [];
        $authorCounts = [];
        $tagCounts = [];
        $totalCompletion = 0;

        foreach ($this->prds as $prd) {
            // Count by status
            $statusName = $prd->getStatus()->getDisplayName();
            $statusCounts[$statusName] = ($statusCounts[$statusName] ?? 0) + 1;

            // Count by priority
            $priorityName = $prd->getPriority()->getDisplayName();
            $priorityCounts[$priorityName] = ($priorityCounts[$priorityName] ?? 0) + 1;

            // Count by author
            $author = $prd->getAuthor();
            $authorCounts[$author] = ($authorCounts[$author] ?? 0) + 1;

            // Count tags
            foreach ($prd->getTags() as $tag) {
                $tagCounts[$tag] = ($tagCounts[$tag] ?? 0) + 1;
            }

            $totalCompletion += $prd->getCompletionPercentage();
        }

        $averageCompletion = $totalPRDs > 0 ? $totalCompletion / $totalPRDs : 0.0;

        return new Analytics(
            $totalPRDs,
            $statusCounts,
            $priorityCounts,
            $averageCompletion,
            $authorCounts,
            $tagCounts,
            new \DateTime()
        );
    }

    public function exportToJSON(): string
    {
        return json_encode($this->prds, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

    public function importFromJSON(string $jsonString): bool
    {
        try {
            $data = json_decode($jsonString, true, 512, JSON_THROW_ON_ERROR);
            
            $this->prds = [];
            $this->prdIndex = [];

            foreach ($data as $prdData) {
                $prd = new PRD($prdData['title'], $prdData['description'], $prdData['author']);
                // Set other properties if needed
                $this->prdIndex[$prd->getId()] = count($this->prds);
                $this->prds[] = $prd;
            }

            return true;
        } catch (\JsonException $e) {
            echo "Error importing JSON: {$e->getMessage()}\n";
            return false;
        }
    }

    public function printDashboard(): void
    {
        echo "\n" . str_repeat("=", 60) . "\n";
        echo "PRD MANAGEMENT SYSTEM - DASHBOARD\n";
        echo str_repeat("=", 60) . "\n";

        $analytics = $this->generateAnalytics();

        echo "Total PRDs: {$analytics->totalPRDs}\n";
        echo "Average Completion: " . number_format($analytics->averageCompletion, 1) . "%\n";

        echo "\nStatus Distribution:\n";
        ksort($analytics->statusCounts);
        foreach ($analytics->statusCounts as $status => $count) {
            echo "  {$status}: {$count}\n";
        }

        echo "\nPriority Distribution:\n";
        ksort($analytics->priorityCounts);
        foreach ($analytics->priorityCounts as $priority => $count) {
            echo "  {$priority}: {$count}\n";
        }

        echo "\nTop Authors:\n";
        $topAuthors = $analytics->getTopContributors();
        $count = 0;
        foreach ($topAuthors as $author => $prdCount) {
            if ($count++ >= 5) break;
            echo "  {$author}: {$prdCount} PRDs\n";
        }

        echo "\nMost Used Tags:\n";
        $topTags = $analytics->getMostUsedTags();
        $count = 0;
        foreach ($topTags as $tag => $frequency) {
            if ($count++ >= 5) break;
            echo "  #{$tag}: {$frequency} times\n";
        }

        echo "\nRecent PRDs:\n";
        $recentPRDs = $this->prds;
        usort($recentPRDs, fn($a, $b) => $b->getUpdatedAt() <=> $a->getUpdatedAt());
        for ($i = 0; $i < min(5, count($recentPRDs)); $i++) {
            echo "  {$recentPRDs[$i]}\n";
        }
    }

    public function loadSampleData(): void
    {
        $sampleData = [
            ['User Authentication System', 'Implement secure login and registration', 'Dev Team', ['security', 'authentication']],
            ['Dark Mode Theme', 'Add dark theme option for better UX', 'UX Team', ['ui', 'theme']],
            ['Payment Gateway Integration', 'Integrate secure payment processing', 'Product Team', ['payment', 'integration']],
            ['API Rate Limiting', 'Implement API rate limiting for security', 'Backend Team', ['api', 'security']],
            ['Mobile App Redesign', 'Complete redesign of mobile application', 'Design Team', ['mobile', 'design']],
            ['Real-time Notifications', 'Add real-time notification system', 'Full Stack Team', ['notifications', 'realtime']],
            ['Performance Optimization', 'Optimize database queries and caching', 'Database Team', ['performance', 'database']],
            ['Multi-language Support', 'Add internationalization support', 'Localization Team', ['i18n', 'localization']],
            ['E-commerce Integration', 'Add shopping cart and payment processing', 'Commerce Team', ['ecommerce', 'payments']],
            ['AI-powered Search', 'Implement intelligent search functionality', 'AI Team', ['ai', 'search']],
        ];

        foreach ($sampleData as [$title, $description, $author, $tags]) {
            $id = $this->createPRD($title, $description, $author);
            $prd = $this->getPRD($id);
            if ($prd) {
                foreach ($tags as $tag) {
                    $prd->addTag($tag);
                }
            }
        }

        // Update some statuses and priorities for variety
        if (count($this->prds) >= 10) {
            $this->updatePRDStatus($this->prds[1]->getId(), PRDStatus::IN_REVIEW);
            $this->updatePRDStatus($this->prds[2]->getId(), PRDStatus::APPROVED);
            $this->updatePRDStatus($this->prds[3]->getId(), PRDStatus::IN_DEVELOPMENT);
            $this->updatePRDStatus($this->prds[4]->getId(), PRDStatus::TESTING);
            $this->updatePRDStatus($this->prds[5]->getId(), PRDStatus::IMPLEMENTED);

            $this->prds[2]->setPriority(Priority::HIGH);
            $this->prds[3]->setPriority(Priority::CRITICAL);
            $this->prds[8]->setPriority(Priority::HIGH);

            $this->updatePRDCompletion($this->prds[3]->getId(), 65);
            $this->updatePRDCompletion($this->prds[4]->getId(), 90);
            $this->updatePRDCompletion($this->prds[5]->getId(), 100);
        }
    }

    public function getCompletionStats(): array
    {
        if (empty($this->prds)) {
            return ['min' => 0, 'max' => 0, 'average' => 0.0];
        }

        $completions = array_map(fn($prd) => $prd->getCompletionPercentage(), $this->prds);
        $min = min($completions);
        $max = max($completions);
        $average = array_sum($completions) / count($completions);

        return ['min' => $min, 'max' => $max, 'average' => $average];
    }

    public function getPRDsNeedingAttention(): array
    {
        return array_filter($this->prds, function($prd) {
            return ($prd->getStatus() === PRDStatus::IN_DEVELOPMENT && $prd->getCompletionPercentage() < 50) ||
                   ($prd->getPriority() === Priority::CRITICAL && $prd->getStatus() === PRDStatus::DRAFT) ||
                   ($prd->getStatus() === PRDStatus::TESTING && $prd->getCompletionPercentage() < 80);
        });
    }
}

// Demo Implementation
function main(): void
{
    echo "PRD Management System v1.2.0 - PHP Implementation\n";
    echo "==================================================\n";

    // Initialize the manager
    $manager = new PRDManager();

    // Load sample data
    $manager->loadSampleData();

    // Display dashboard
    $manager->printDashboard();

    // Demo operations
    echo "\n" . str_repeat("=", 60) . "\n";
    echo "DEMO OPERATIONS\n";
    echo str_repeat("=", 60) . "\n";

    // Search demo
    $searchResults = $manager->searchPRDs("authentication");
    echo "\nSearching for 'authentication' related PRDs:\n";
    foreach ($searchResults as $prd) {
        echo "  Found: {$prd}\n";
    }

    // Filter by status demo
    $draftPRDs = $manager->getPRDsByStatus(PRDStatus::DRAFT);
    echo "\nDraft PRDs (" . count($draftPRDs) . "):\n";
    foreach ($draftPRDs as $prd) {
        echo "  {$prd}\n";
    }

    // Priority filtering demo
    $criticalPRDs = $manager->getPRDsByPriority(Priority::CRITICAL);
    echo "\nCritical Priority PRDs (" . count($criticalPRDs) . "):\n";
    foreach ($criticalPRDs as $prd) {
        echo "  {$prd->getStatusIcon()} {$prd}\n";
    }

    // PRDs needing attention
    $needingAttention = $manager->getPRDsNeedingAttention();
    echo "\nPRDs Needing Attention (" . count($needingAttention) . "):\n";
    foreach ($needingAttention as $prd) {
        echo "  {$prd->getStatusIcon()} {$prd} - {$prd->getPriority()->getDisplayName()} priority\n";
    }

    // Completion statistics
    $stats = $manager->getCompletionStats();
    echo "\nCompletion Statistics:\n";
    echo "  Minimum: {$stats['min']}%\n";
    echo "  Maximum: {$stats['max']}%\n";
    echo "  Average: " . number_format($stats['average'], 1) . "%\n";

    // Export demo
    echo "\nExporting PRD data to JSON...\n";
    $jsonData = $manager->exportToJSON();
    echo "Export completed. JSON length: " . strlen($jsonData) . " characters\n";

    echo "\nPHP PRD Management System demonstration completed!\n";
}

// Run the demo
main();
?>
