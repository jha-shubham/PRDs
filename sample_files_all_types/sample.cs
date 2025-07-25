/**
 * PRD Management System - C# Implementation
 * Version: 1.2.0 | Last Updated: July 25, 2025
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;

namespace PRDManagement
{
    public enum PRDStatus
    {
        Draft = 0,
        InReview = 1,
        Approved = 2,
        InDevelopment = 3,
        Testing = 4,
        Implemented = 5,
        Archived = 6
    }

    public enum Priority
    {
        Low = 1,
        Medium = 2,
        High = 3,
        Critical = 4
    }

    public class PRD
    {
        public string Id { get; private set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Author { get; set; }
        public PRDStatus Status { get; set; }
        public Priority Priority { get; set; }
        public DateTime CreatedAt { get; private set; }
        public DateTime UpdatedAt { get; set; }
        public int CompletionPercentage { get; set; }
        public List<string> Tags { get; set; }

        public PRD(string title, string description, string author)
        {
            Id = GenerateId();
            Title = title;
            Description = description;
            Author = author;
            Status = PRDStatus.Draft;
            Priority = Priority.Medium;
            CreatedAt = DateTime.UtcNow;
            UpdatedAt = DateTime.UtcNow;
            CompletionPercentage = 0;
            Tags = new List<string>();
        }

        private string GenerateId()
        {
            var timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            var random = new Random().Next(1000, 9999);
            return $"PRD-{timestamp}-{random}";
        }

        public void UpdateStatus(PRDStatus newStatus)
        {
            Status = newStatus;
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetCompletionPercentage(int percentage)
        {
            CompletionPercentage = Math.Max(0, Math.Min(100, percentage));
            UpdatedAt = DateTime.UtcNow;
        }

        public override string ToString()
        {
            return $"PRD{{Id='{Id}', Title='{Title}', Status={Status}, Completion={CompletionPercentage}%}}";
        }
    }

    public class PRDManager
    {
        private readonly List<PRD> _prds;
        private readonly Dictionary<string, PRD> _prdIndex;

        public PRDManager()
        {
            _prds = new List<PRD>();
            _prdIndex = new Dictionary<string, PRD>();
        }

        public string CreatePRD(string title, string description, string author)
        {
            var prd = new PRD(title, description, author);
            _prds.Add(prd);
            _prdIndex[prd.Id] = prd;

            Console.WriteLine($"PRD created successfully: {prd.Id}");
            return prd.Id;
        }

        public PRD GetPRD(string id)
        {
            return _prdIndex.TryGetValue(id, out var prd) ? prd : null;
        }

        public List<PRD> GetAllPRDs()
        {
            return _prds.ToList();
        }

        public List<PRD> GetPRDsByStatus(PRDStatus status)
        {
            return _prds.Where(prd => prd.Status == status).ToList();
        }

        public List<PRD> GetPRDsByPriority(Priority priority)
        {
            return _prds.Where(prd => prd.Priority == priority).ToList();
        }

        public List<PRD> SearchPRDs(string searchTerm)
        {
            var term = searchTerm.ToLowerInvariant();
            return _prds.Where(prd => 
                prd.Title.ToLowerInvariant().Contains(term) || 
                prd.Description.ToLowerInvariant().Contains(term) ||
                prd.Tags.Any(tag => tag.ToLowerInvariant().Contains(term))
            ).ToList();
        }

        public bool UpdatePRDStatus(string id, PRDStatus newStatus)
        {
            var prd = GetPRD(id);
            if (prd != null)
            {
                prd.UpdateStatus(newStatus);
                Console.WriteLine($"PRD {id} status updated to: {newStatus}");
                return true;
            }
            return false;
        }

        public Dictionary<string, object> GetStatistics()
        {
            var stats = new Dictionary<string, object>
            {
                ["TotalPRDs"] = _prds.Count,
                ["ByStatus"] = _prds.GroupBy(prd => prd.Status)
                                  .ToDictionary(g => g.Key.ToString(), g => g.Count()),
                ["ByPriority"] = _prds.GroupBy(prd => prd.Priority)
                                    .ToDictionary(g => g.Key.ToString(), g => g.Count()),
                ["AverageCompletion"] = _prds.Count > 0 ? _prds.Average(prd => prd.CompletionPercentage) : 0
            };

            return stats;
        }

        public string ExportToJson()
        {
            var options = new JsonSerializerOptions
            {
                WriteIndented = true,
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            };

            return JsonSerializer.Serialize(_prds, options);
        }

        public void PrintDashboard()
        {
            Console.WriteLine("\n" + new string('=', 60));
            Console.WriteLine("PRD MANAGEMENT SYSTEM - DASHBOARD");
            Console.WriteLine(new string('=', 60));

            var stats = GetStatistics();
            Console.WriteLine($"Total PRDs: {stats["TotalPRDs"]}");
            Console.WriteLine($"Average Completion: {stats["AverageCompletion"]:F1}%");

            Console.WriteLine("\nStatus Distribution:");
            var statusCounts = (Dictionary<string, int>)stats["ByStatus"];
            foreach (var kvp in statusCounts)
            {
                Console.WriteLine($"  {kvp.Key}: {kvp.Value}");
            }

            Console.WriteLine("\nPriority Distribution:");
            var priorityCounts = (Dictionary<string, int>)stats["ByPriority"];
            foreach (var kvp in priorityCounts)
            {
                Console.WriteLine($"  {kvp.Key}: {kvp.Value}");
            }

            Console.WriteLine("\nRecent PRDs:");
            var recentPRDs = _prds.OrderByDescending(prd => prd.UpdatedAt).Take(5);
            foreach (var prd in recentPRDs)
            {
                Console.WriteLine($"  {prd}");
            }
        }

        public void LoadSampleData()
        {
            var sampleData = new[]
            {
                ("User Authentication System", "Implement secure login and registration", "Dev Team"),
                ("Dark Mode Theme", "Add dark theme option for better UX", "UX Team"),
                ("Payment Gateway Integration", "Integrate secure payment processing", "Product Team"),
                ("API Rate Limiting", "Implement API rate limiting for security", "Backend Team"),
                ("Mobile App Redesign", "Complete redesign of mobile application", "Design Team"),
                ("Real-time Notifications", "Add real-time notification system", "Full Stack Team"),
                ("Performance Optimization", "Optimize database queries and caching", "Database Team"),
                ("Multi-language Support", "Add internationalization support", "Localization Team")
            };

            foreach (var (title, description, author) in sampleData)
            {
                var id = CreatePRD(title, description, author);
                var prd = GetPRD(id);
                
                // Add some sample tags
                prd.Tags.AddRange(title.ToLowerInvariant().Split(' ').Take(2));
            }

            // Update some statuses for variety
            var allPRDs = GetAllPRDs();
            if (allPRDs.Count >= 8)
            {
                UpdatePRDStatus(allPRDs[1].Id, PRDStatus.InReview);
                UpdatePRDStatus(allPRDs[2].Id, PRDStatus.Approved);
                UpdatePRDStatus(allPRDs[3].Id, PRDStatus.InDevelopment);
                UpdatePRDStatus(allPRDs[4].Id, PRDStatus.Testing);
                UpdatePRDStatus(allPRDs[5].Id, PRDStatus.Implemented);
                
                allPRDs[3].SetCompletionPercentage(65);
                allPRDs[4].SetCompletionPercentage(90);
                allPRDs[5].SetCompletionPercentage(100);
            }
        }
    }

    public class Program
    {
        public static void Main(string[] args)
        {
            Console.WriteLine("PRD Management System v1.2.0 - C# Implementation");
            Console.WriteLine("==================================================");

            var manager = new PRDManager();
            
            // Load sample data
            manager.LoadSampleData();

            // Display dashboard
            manager.PrintDashboard();

            // Demo some operations
            Console.WriteLine("\n" + new string('=', 60));
            Console.WriteLine("DEMO OPERATIONS");
            Console.WriteLine(new string('=', 60));

            // Search demo
            var searchResults = manager.SearchPRDs("authentication");
            Console.WriteLine($"\nSearching for 'authentication' related PRDs:");
            searchResults.ForEach(prd => Console.WriteLine($"  Found: {prd}"));

            // Filter by status demo
            var draftPRDs = manager.GetPRDsByStatus(PRDStatus.Draft);
            Console.WriteLine($"\nDraft PRDs ({draftPRDs.Count}):");
            draftPRDs.ForEach(prd => Console.WriteLine($"  {prd}"));

            // Export demo
            Console.WriteLine("\nExporting PRD data to JSON...");
            var jsonData = manager.ExportToJson();
            Console.WriteLine($"Export completed. JSON length: {jsonData.Length} characters");

            Console.WriteLine("\nC# PRD Management System demonstration completed!");
        }
    }
}
