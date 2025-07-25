-- PRD Management System - Haskell Implementation
-- Version: 1.2.0 | Last Updated: July 25, 2025

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module PRDManagement where

import Data.Time
import Data.List (sortBy, group, sort, isPrefixOf)
import Data.Ord (Down(..), comparing)
import Data.Char (toLower)
import Data.Maybe (fromMaybe, catMaybes)
import System.Random
import Text.Printf
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import GHC.Generics (Generic)

-- Data Types

data PRDStatus = Draft | InReview | Approved | InDevelopment | Testing | Implemented | Archived
  deriving (Eq, Ord, Show, Read, Generic, Enum, Bounded)

data Priority = Low | Medium | High | Critical
  deriving (Eq, Ord, Show, Read, Generic, Enum, Bounded)

statusValue :: PRDStatus -> Int
statusValue Draft = 0
statusValue InReview = 1
statusValue Approved = 2
statusValue InDevelopment = 3
statusValue Testing = 4
statusValue Implemented = 5
statusValue Archived = 6

priorityValue :: Priority -> Int
priorityValue Low = 1
priorityValue Medium = 2
priorityValue High = 3
priorityValue Critical = 4

statusDisplayName :: PRDStatus -> String
statusDisplayName Draft = "Draft"
statusDisplayName InReview = "In Review"
statusDisplayName Approved = "Approved"
statusDisplayName InDevelopment = "In Development"
statusDisplayName Testing = "Testing"
statusDisplayName Implemented = "Implemented"
statusDisplayName Archived = "Archived"

priorityDisplayName :: Priority -> String
priorityDisplayName Low = "Low"
priorityDisplayName Medium = "Medium"
priorityDisplayName High = "High"
priorityDisplayName Critical = "Critical"

priorityColorCode :: Priority -> String
priorityColorCode Low = "#28a745"
priorityColorCode Medium = "#ffc107"
priorityColorCode High = "#fd7e14"
priorityColorCode Critical = "#dc3545"

data PRD = PRD
  { prdId :: String
  , prdTitle :: String
  , prdDescription :: String
  , prdAuthor :: String
  , prdStatus :: PRDStatus
  , prdPriority :: Priority
  , prdCreatedAt :: UTCTime
  , prdUpdatedAt :: UTCTime
  , prdCompletionPercentage :: Int
  , prdTags :: Set.Set String
  } deriving (Show, Generic)

data Analytics = Analytics
  { analyticsTotal :: Int
  , analyticsStatusCounts :: Map.Map String Int
  , analyticsPriorityCounts :: Map.Map String Int
  , analyticsAverageCompletion :: Double
  , analyticsTopAuthors :: Map.Map String Int
  , analyticsTagFrequency :: Map.Map String Int
  , analyticsLastUpdated :: UTCTime
  } deriving (Show, Generic)

newtype PRDManager = PRDManager [PRD]

-- PRD Creation and Management

generatePRDId :: IO String
generatePRDId = do
  timestamp <- getCurrentTime
  randomNum <- randomRIO (1000, 9999 :: Int)
  let timestampStr = show $ utctDayTime timestamp
  return $ "PRD-" ++ filter (/= '.') timestampStr ++ "-" ++ show randomNum

createPRD :: String -> String -> String -> IO PRD
createPRD title description author = do
  prdId' <- generatePRDId
  currentTime <- getCurrentTime
  return PRD
    { prdId = prdId'
    , prdTitle = title
    , prdDescription = description
    , prdAuthor = author
    , prdStatus = Draft
    , prdPriority = Medium
    , prdCreatedAt = currentTime
    , prdUpdatedAt = currentTime
    , prdCompletionPercentage = 0
    , prdTags = Set.empty
    }

updatePRDStatus :: PRDStatus -> PRD -> IO PRD
updatePRDStatus newStatus prd = do
  currentTime <- getCurrentTime
  return prd { prdStatus = newStatus, prdUpdatedAt = currentTime }

setPRDCompletion :: Int -> PRD -> IO PRD
setPRDCompletion percentage prd = do
  currentTime <- getCurrentTime
  let clampedPercentage = max 0 (min 100 percentage)
  return prd { prdCompletionPercentage = clampedPercentage, prdUpdatedAt = currentTime }

addPRDTag :: String -> PRD -> IO PRD
addPRDTag tag prd = do
  currentTime <- getCurrentTime
  let cleanTag = map toLower $ filter (/= ' ') tag
  if null cleanTag
    then return prd
    else return prd 
      { prdTags = Set.insert cleanTag (prdTags prd)
      , prdUpdatedAt = currentTime
      }

setPRDPriority :: Priority -> PRD -> IO PRD
setPRDPriority priority prd = do
  currentTime <- getCurrentTime
  return prd { prdPriority = priority, prdUpdatedAt = currentTime }

-- PRD Manager Operations

addPRDToManager :: PRD -> PRDManager -> PRDManager
addPRDToManager prd (PRDManager prds) = PRDManager (prd : prds)

findPRDById :: String -> PRDManager -> Maybe PRD
findPRDById targetId (PRDManager prds) = 
  case filter (\prd -> prdId prd == targetId) prds of
    [prd] -> Just prd
    _ -> Nothing

getAllPRDs :: PRDManager -> [PRD]
getAllPRDs (PRDManager prds) = prds

getPRDsByStatus :: PRDStatus -> PRDManager -> [PRD]
getPRDsByStatus status (PRDManager prds) = filter (\prd -> prdStatus prd == status) prds

getPRDsByPriority :: Priority -> PRDManager -> [PRD]
getPRDsByPriority priority (PRDManager prds) = filter (\prd -> prdPriority prd == priority) prds

searchPRDs :: String -> PRDManager -> [PRD]
searchPRDs searchTerm (PRDManager prds) = 
  let lowerSearchTerm = map toLower searchTerm
      matchesPRD prd = 
        lowerSearchTerm `isPrefixOf` map toLower (prdTitle prd) ||
        lowerSearchTerm `isPrefixOf` map toLower (prdDescription prd) ||
        any (lowerSearchTerm `isPrefixOf`) (Set.toList $ prdTags prd)
  in filter matchesPRD prds

updatePRDInManager :: String -> (PRD -> IO PRD) -> PRDManager -> IO (Maybe PRDManager)
updatePRDInManager targetId updateFunc (PRDManager prds) = do
  case findPRDById targetId (PRDManager prds) of
    Nothing -> return Nothing
    Just prd -> do
      updatedPRD <- updateFunc prd
      let updatedPRDs = map (\p -> if prdId p == targetId then updatedPRD else p) prds
      return $ Just (PRDManager updatedPRDs)

-- Analytics

generateAnalytics :: PRDManager -> IO Analytics
generateAnalytics (PRDManager prds) = do
  currentTime <- getCurrentTime
  let totalPRDs = length prds
      statusCounts = Map.fromListWith (+) [(statusDisplayName (prdStatus prd), 1) | prd <- prds]
      priorityCounts = Map.fromListWith (+) [(priorityDisplayName (prdPriority prd), 1) | prd <- prds]
      authorCounts = Map.fromListWith (+) [(prdAuthor prd, 1) | prd <- prds]
      tagCounts = Map.fromListWith (+) [(tag, 1) | prd <- prds, tag <- Set.toList (prdTags prd)]
      totalCompletion = sum [prdCompletionPercentage prd | prd <- prds]
      averageCompletion = if totalPRDs > 0 then fromIntegral totalCompletion / fromIntegral totalPRDs else 0.0
  
  return Analytics
    { analyticsTotal = totalPRDs
    , analyticsStatusCounts = statusCounts
    , analyticsPriorityCounts = priorityCounts
    , analyticsAverageCompletion = averageCompletion
    , analyticsTopAuthors = authorCounts
    , analyticsTagFrequency = tagCounts
    , analyticsLastUpdated = currentTime
    }

-- Utility Functions

prdToString :: PRD -> String
prdToString prd = printf "PRD{ID='%s', Title='%s', Status=%s, Completion=%d%%}"
  (prdId prd) (prdTitle prd) (statusDisplayName $ prdStatus prd) (prdCompletionPercentage prd)

prdStatusIcon :: PRD -> String
prdStatusIcon prd = case prdStatus prd of
  Draft -> "📝"
  InReview -> "👁️"
  Approved -> "✅"
  InDevelopment -> "🔨"
  Testing -> "🧪"
  Implemented -> "⭐"
  Archived -> "📦"

prdProgressDescription :: PRD -> String
prdProgressDescription prd = show (prdCompletionPercentage prd) ++ "% complete"

-- Dashboard and Reporting

printDashboard :: PRDManager -> IO ()
printDashboard manager = do
  analytics <- generateAnalytics manager
  putStrLn $ replicate 60 '='
  putStrLn "PRD MANAGEMENT SYSTEM - DASHBOARD"
  putStrLn $ replicate 60 '='
  
  printf "Total PRDs: %d\n" (analyticsTotal analytics)
  printf "Average Completion: %.1f%%\n" (analyticsAverageCompletion analytics)
  
  putStrLn "\nStatus Distribution:"
  mapM_ (\(status, count) -> printf "  %s: %d\n" status count) 
        (Map.toList $ analyticsStatusCounts analytics)
  
  putStrLn "\nPriority Distribution:"
  mapM_ (\(priority, count) -> printf "  %s: %d\n" priority count) 
        (Map.toList $ analyticsPriorityCounts analytics)
  
  putStrLn "\nTop Authors:"
  let topAuthors = take 5 $ sortBy (comparing (Down . snd)) $ Map.toList $ analyticsTopAuthors analytics
  mapM_ (\(author, count) -> printf "  %s: %d PRDs\n" author count) topAuthors
  
  putStrLn "\nMost Used Tags:"
  let topTags = take 5 $ sortBy (comparing (Down . snd)) $ Map.toList $ analyticsTagFrequency analytics
  mapM_ (\(tag, count) -> printf "  #%s: %d times\n" tag count) topTags
  
  putStrLn "\nRecent PRDs:"
  let recentPRDs = take 5 $ sortBy (comparing (Down . prdUpdatedAt)) $ getAllPRDs manager
  mapM_ (putStrLn . ("  " ++) . prdToString) recentPRDs

-- Sample Data Loading

loadSampleData :: IO PRDManager
loadSampleData = do
  let sampleDataList = 
        [ ("User Authentication System", "Implement secure login and registration", "Dev Team", ["security", "authentication"])
        , ("Dark Mode Theme", "Add dark theme option for better UX", "UX Team", ["ui", "theme"])
        , ("Payment Gateway Integration", "Integrate secure payment processing", "Product Team", ["payment", "integration"])
        , ("API Rate Limiting", "Implement API rate limiting for security", "Backend Team", ["api", "security"])
        , ("Mobile App Redesign", "Complete redesign of mobile application", "Design Team", ["mobile", "design"])
        , ("Real-time Notifications", "Add real-time notification system", "Full Stack Team", ["notifications", "realtime"])
        , ("Performance Optimization", "Optimize database queries and caching", "Database Team", ["performance", "database"])
        , ("Multi-language Support", "Add internationalization support", "Localization Team", ["i18n", "localization"])
        , ("Functional Programming", "Migrate core logic to functional paradigm", "FP Team", ["functional", "haskell"])
        , ("Type Safety Enhancement", "Improve type safety across the system", "Type Team", ["types", "safety"])
        ]
  
  prds <- mapM (\(title, desc, author, tags) -> do
    prd <- createPRD title desc author
    prdWithTags <- foldM (flip addPRDTag) prd tags
    return prdWithTags) sampleDataList
  
  -- Update some statuses and priorities for variety
  let manager = foldr addPRDToManager (PRDManager []) prds
      allPRDs = getAllPRDs manager
  
  if length allPRDs >= 10
    then do
      -- Update statuses
      updatedManager1 <- updatePRDInManager (prdId $ allPRDs !! 1) (updatePRDStatus InReview) manager
      updatedManager2 <- maybe (return Nothing) (\m -> updatePRDInManager (prdId $ allPRDs !! 2) (updatePRDStatus Approved) m) updatedManager1
      updatedManager3 <- maybe (return Nothing) (\m -> updatePRDInManager (prdId $ allPRDs !! 3) (updatePRDStatus InDevelopment) m) updatedManager2
      updatedManager4 <- maybe (return Nothing) (\m -> updatePRDInManager (prdId $ allPRDs !! 4) (updatePRDStatus Testing) m) updatedManager3
      updatedManager5 <- maybe (return Nothing) (\m -> updatePRDInManager (prdId $ allPRDs !! 5) (updatePRDStatus Implemented) m) updatedManager4
      
      -- Update priorities and completion
      finalManager <- maybe (return manager) (\m -> do
        m1 <- updatePRDInManager (prdId $ allPRDs !! 2) (setPRDPriority High) m
        m2 <- maybe (return m) (\m' -> updatePRDInManager (prdId $ allPRDs !! 3) (setPRDPriority Critical) m') m1
        m3 <- maybe (return m) (\m' -> updatePRDInManager (prdId $ allPRDs !! 3) (setPRDCompletion 65) m') m2
        m4 <- maybe (return m) (\m' -> updatePRDInManager (prdId $ allPRDs !! 4) (setPRDCompletion 90) m') m3
        maybe (return m) (\m' -> updatePRDInManager (prdId $ allPRDs !! 5) (setPRDCompletion 100) m') m4
        ) updatedManager5
      
      return $ fromMaybe manager finalManager
    else return manager

-- Advanced Analysis Functions

getCompletionStats :: PRDManager -> (Int, Int, Double)
getCompletionStats manager = 
  let prds = getAllPRDs manager
      completions = map prdCompletionPercentage prds
  in if null completions
     then (0, 0, 0.0)
     else ( minimum completions
          , maximum completions
          , fromIntegral (sum completions) / fromIntegral (length completions)
          )

getPRDsNeedingAttention :: PRDManager -> [PRD]
getPRDsNeedingAttention manager = 
  let prds = getAllPRDs manager
  in filter needsAttention prds
  where
    needsAttention prd = 
      (prdStatus prd == InDevelopment && prdCompletionPercentage prd < 50) ||
      (prdPriority prd == Critical && prdStatus prd == Draft) ||
      (prdStatus prd == Testing && prdCompletionPercentage prd < 80)

getStatusProgressReport :: PRDManager -> Map.Map String Double
getStatusProgressReport manager = 
  let prds = getAllPRDs manager
      statusGroups = Map.fromListWith (++) [(prdStatus prd, [prdCompletionPercentage prd]) | prd <- prds]
      averageCompletion completions = fromIntegral (sum completions) / fromIntegral (length completions)
  in Map.mapWithKey (\status completions -> 
       if null completions 
       then 0.0 
       else averageCompletion completions) 
     (Map.map (:[]) $ Map.fromList [(status, 0) | status <- [minBound..maxBound]]) 
     `Map.union` 
     (Map.mapKeys statusDisplayName $ fmap averageCompletion statusGroups)

-- Functional Programming Utilities

calculateVelocity :: [PRD] -> Int -> Double
calculateVelocity prds daysPeriod = 
  let completedPRDs = length $ filter (\prd -> prdStatus prd == Implemented) prds
  in fromIntegral completedPRDs / fromIntegral daysPeriod

priorityScore :: PRD -> Double
priorityScore prd = 
  let priorityWeight = fromIntegral (priorityValue $ prdPriority prd) * 0.4
      statusWeight = fromIntegral (statusValue $ prdStatus prd) * 0.3
      completionWeight = fromIntegral (prdCompletionPercentage prd) * 0.003
  in priorityWeight + statusWeight + completionWeight

recommendPRDs :: Int -> PRDManager -> [PRD]
recommendPRDs maxRecommendations manager = 
  take maxRecommendations $ 
  sortBy (comparing (Down . priorityScore)) $ 
  getAllPRDs manager

-- Demo Implementation

main :: IO ()
main = do
  putStrLn "PRD Management System v1.2.0 - Haskell Implementation"
  putStrLn "====================================================="
  
  -- Load sample data
  manager <- loadSampleData
  
  -- Display dashboard
  printDashboard manager
  
  -- Demo operations
  putStrLn $ "\n" ++ replicate 60 '='
  putStrLn "DEMO OPERATIONS"
  putStrLn $ replicate 60 '='
  
  -- Search demo
  let searchResults = searchPRDs "authentication" manager
  putStrLn "\nSearching for 'authentication' related PRDs:"
  mapM_ (putStrLn . ("  Found: " ++) . prdToString) searchResults
  
  -- Filter by status demo
  let draftPRDs = getPRDsByStatus Draft manager
  printf "\nDraft PRDs (%d):\n" (length draftPRDs)
  mapM_ (putStrLn . ("  " ++) . prdToString) draftPRDs
  
  -- Priority filtering demo
  let criticalPRDs = getPRDsByPriority Critical manager
  printf "\nCritical Priority PRDs (%d):\n" (length criticalPRDs)
  mapM_ (\prd -> putStrLn $ "  " ++ prdStatusIcon prd ++ " " ++ prdToString prd) criticalPRDs
  
  -- PRDs needing attention
  let needingAttention = getPRDsNeedingAttention manager
  printf "\nPRDs Needing Attention (%d):\n" (length needingAttention)
  mapM_ (\prd -> putStrLn $ "  " ++ prdStatusIcon prd ++ " " ++ prdToString prd ++ " - " ++ priorityDisplayName (prdPriority prd) ++ " priority") needingAttention
  
  -- Completion statistics
  let (minComp, maxComp, avgComp) = getCompletionStats manager
  putStrLn "\nCompletion Statistics:"
  printf "  Minimum: %d%%\n" minComp
  printf "  Maximum: %d%%\n" maxComp
  printf "  Average: %.1f%%\n" avgComp
  
  -- Status progress report
  putStrLn "\nStatus Progress Report:"
  let statusReport = getStatusProgressReport manager
  mapM_ (\(status, avgCompletion) -> printf "  %s: %.1f%% average completion\n" status avgCompletion) 
        (Map.toList statusReport)
  
  -- Functional analysis
  putStrLn "\nFunctional Analysis:"
  let allPRDs = getAllPRDs manager
      velocity = calculateVelocity allPRDs 30
  printf "  30-day velocity: %.2f PRDs/day\n" velocity
  
  let recommendations = recommendPRDs 3 manager
  putStrLn "  Top 3 recommended PRDs:"
  mapM_ (\prd -> do
    let score = priorityScore prd
    printf "    %s (Score: %.2f)\n" (prdTitle prd) score
    ) recommendations
  
  putStrLn "\nHaskell PRD Management System demonstration completed!"
