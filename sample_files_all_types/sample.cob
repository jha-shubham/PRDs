IDENTIFICATION DIVISION.
PROGRAM-ID. PRD-MANAGEMENT-SYSTEM.
AUTHOR. DEVELOPMENT-TEAM.
DATE-WRITTEN. JULY-25-2025.
DATE-COMPILED. JULY-25-2025.

* PRD Management System - COBOL Implementation
* Version: 1.2.0 | Last Updated: July 25, 2025
* Classic enterprise-grade PRD management in COBOL

ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
SOURCE-COMPUTER. IBM-PC.
OBJECT-COMPUTER. IBM-PC.

INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT PRD-FILE ASSIGN TO "PRDDATA.DAT"
           ORGANIZATION IS INDEXED
           ACCESS MODE IS DYNAMIC
           RECORD KEY IS PRD-ID
           FILE STATUS IS FILE-STATUS.
    
    SELECT REPORT-FILE ASSIGN TO "PRDREPORT.TXT"
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS REPORT-STATUS.

DATA DIVISION.
FILE SECTION.
FD  PRD-FILE.
01  PRD-RECORD.
    05 PRD-ID                   PIC X(20).
    05 PRD-TITLE               PIC X(50).
    05 PRD-DESCRIPTION         PIC X(200).
    05 PRD-AUTHOR              PIC X(30).
    05 PRD-STATUS              PIC 9(1).
       88 STATUS-DRAFT         VALUE 0.
       88 STATUS-IN-REVIEW     VALUE 1.
       88 STATUS-APPROVED      VALUE 2.
       88 STATUS-IN-DEVELOPMENT VALUE 3.
       88 STATUS-TESTING       VALUE 4.
       88 STATUS-IMPLEMENTED   VALUE 5.
       88 STATUS-ARCHIVED      VALUE 6.
    05 PRD-PRIORITY            PIC 9(1).
       88 PRIORITY-LOW         VALUE 1.
       88 PRIORITY-MEDIUM      VALUE 2.
       88 PRIORITY-HIGH        VALUE 3.
       88 PRIORITY-CRITICAL    VALUE 4.
    05 PRD-COMPLETION-PCT      PIC 9(3).
    05 PRD-CREATED-DATE        PIC X(10).
    05 PRD-UPDATED-DATE        PIC X(10).
    05 PRD-TAGS                PIC X(100).

FD  REPORT-FILE.
01  REPORT-LINE                PIC X(120).

WORKING-STORAGE SECTION.
01  FILE-STATUS                PIC X(2).
01  REPORT-STATUS              PIC X(2).

01  PROGRAM-CONSTANTS.
    05 PROGRAM-VERSION         PIC X(15) VALUE "v1.2.0".
    05 MAX-PRDS                PIC 9(4) VALUE 1000.

01  STATUS-NAMES.
    05 STATUS-NAME-TABLE.
       10 FILLER               PIC X(15) VALUE "Draft".
       10 FILLER               PIC X(15) VALUE "In Review".
       10 FILLER               PIC X(15) VALUE "Approved".
       10 FILLER               PIC X(15) VALUE "In Development".
       10 FILLER               PIC X(15) VALUE "Testing".
       10 FILLER               PIC X(15) VALUE "Implemented".
       10 FILLER               PIC X(15) VALUE "Archived".
    05 STATUS-NAME REDEFINES STATUS-NAME-TABLE 
       OCCURS 7 TIMES          PIC X(15).

01  PRIORITY-NAMES.
    05 PRIORITY-NAME-TABLE.
       10 FILLER               PIC X(10) VALUE "Low".
       10 FILLER               PIC X(10) VALUE "Medium".
       10 FILLER               PIC X(10) VALUE "High".
       10 FILLER               PIC X(10) VALUE "Critical".
    05 PRIORITY-NAME REDEFINES PRIORITY-NAME-TABLE 
       OCCURS 4 TIMES          PIC X(10).

01  COUNTERS-AND-TOTALS.
    05 TOTAL-PRDS              PIC 9(4) VALUE ZERO.
    05 STATUS-COUNTERS         OCCURS 7 TIMES PIC 9(4) VALUE ZERO.
    05 PRIORITY-COUNTERS       OCCURS 4 TIMES PIC 9(4) VALUE ZERO.
    05 TOTAL-COMPLETION        PIC 9(6) VALUE ZERO.
    05 AVERAGE-COMPLETION      PIC 9(3)V9(2) VALUE ZERO.

01  WORK-FIELDS.
    05 WS-INDEX                PIC 9(4).
    05 WS-COUNTER              PIC 9(4).
    05 WS-TEMP-CALC            PIC 9(8)V9(2).
    05 WS-CURRENT-DATE.
       10 WS-CURRENT-YEAR      PIC 9(4).
       10 WS-CURRENT-MONTH     PIC 9(2).
       10 WS-CURRENT-DAY       PIC 9(2).
    05 WS-FORMATTED-DATE       PIC X(10).
    05 WS-SEARCH-TERM          PIC X(50).
    05 WS-FOUND-FLAG           PIC X(1) VALUE 'N'.

01  SAMPLE-DATA-AREA.
    05 SAMPLE-COUNTER          PIC 9(2) VALUE 1.
    05 SAMPLE-DATA-TABLE.
       10 SAMPLE-ENTRY OCCURS 10 TIMES.
          15 SAMPLE-TITLE      PIC X(50).
          15 SAMPLE-DESC       PIC X(200).
          15 SAMPLE-AUTHOR     PIC X(30).
          15 SAMPLE-STATUS     PIC 9(1).
          15 SAMPLE-PRIORITY   PIC 9(1).
          15 SAMPLE-COMPLETION PIC 9(3).

01  REPORT-HEADERS.
    05 MAIN-HEADER.
       10 FILLER               PIC X(50) VALUE SPACES.
       10 FILLER               PIC X(30) VALUE "PRD MANAGEMENT SYSTEM".
       10 FILLER               PIC X(40) VALUE SPACES.
    05 VERSION-HEADER.
       10 FILLER               PIC X(55) VALUE SPACES.
       10 FILLER               PIC X(10) VALUE "Version: ".
       10 FILLER               PIC X(15) VALUE "v1.2.0".
       10 FILLER               PIC X(40) VALUE SPACES.
    05 DIVIDER-LINE            PIC X(120) VALUE ALL "=".

01  MENU-OPTIONS.
    05 FILLER                  PIC X(50) VALUE "1. Display All PRDs".
    05 FILLER                  PIC X(50) VALUE "2. Search PRDs".
    05 FILLER                  PIC X(50) VALUE "3. Generate Analytics Report".
    05 FILLER                  PIC X(50) VALUE "4. Load Sample Data".
    05 FILLER                  PIC X(50) VALUE "5. Exit".

PROCEDURE DIVISION.
MAIN-LOGIC.
    PERFORM INITIALIZATION
    PERFORM DISPLAY-WELCOME
    PERFORM LOAD-SAMPLE-DATA-ROUTINE
    PERFORM GENERATE-ANALYTICS
    PERFORM DISPLAY-DASHBOARD
    PERFORM CLEANUP
    STOP RUN.

INITIALIZATION.
    ACCEPT WS-CURRENT-DATE FROM DATE YYYYMMDD
    MOVE FUNCTION CURRENT-DATE(1:8) TO WS-FORMATTED-DATE
    STRING WS-CURRENT-YEAR "-" WS-CURRENT-MONTH "-" WS-CURRENT-DAY
           DELIMITED BY SIZE INTO WS-FORMATTED-DATE
    
    * Initialize sample data
    PERFORM INIT-SAMPLE-DATA
    
    * Initialize file
    OPEN OUTPUT PRD-FILE
    IF FILE-STATUS NOT = "00"
       DISPLAY "Error opening PRD file: " FILE-STATUS
       STOP RUN
    END-IF
    CLOSE PRD-FILE.

DISPLAY-WELCOME.
    DISPLAY " "
    DISPLAY DIVIDER-LINE
    DISPLAY MAIN-HEADER
    DISPLAY VERSION-HEADER
    DISPLAY "COBOL Implementation | Last Updated: July 25, 2025"
    DISPLAY DIVIDER-LINE
    DISPLAY " ".

INIT-SAMPLE-DATA.
    * Initialize sample PRD data
    MOVE "User Authentication System" TO SAMPLE-TITLE(1)
    MOVE "Implement secure login and registration system with multi-factor authentication" TO SAMPLE-DESC(1)
    MOVE "Security Team" TO SAMPLE-AUTHOR(1)
    MOVE 0 TO SAMPLE-STATUS(1)
    MOVE 4 TO SAMPLE-PRIORITY(1)
    MOVE 25 TO SAMPLE-COMPLETION(1)
    
    MOVE "Dark Mode Theme Implementation" TO SAMPLE-TITLE(2)
    MOVE "Add comprehensive dark theme support across all application interfaces" TO SAMPLE-DESC(2)
    MOVE "UX Design Team" TO SAMPLE-AUTHOR(2)
    MOVE 1 TO SAMPLE-STATUS(2)
    MOVE 2 TO SAMPLE-PRIORITY(2)
    MOVE 60 TO SAMPLE-COMPLETION(2)
    
    MOVE "Payment Gateway Integration" TO SAMPLE-TITLE(3)
    MOVE "Integrate secure payment processing with multiple payment providers" TO SAMPLE-DESC(3)
    MOVE "Payment Team" TO SAMPLE-AUTHOR(3)
    MOVE 2 TO SAMPLE-STATUS(3)
    MOVE 3 TO SAMPLE-PRIORITY(3)
    MOVE 80 TO SAMPLE-COMPLETION(3)
    
    MOVE "API Rate Limiting Framework" TO SAMPLE-TITLE(4)
    MOVE "Implement comprehensive API rate limiting for security and performance" TO SAMPLE-DESC(4)
    MOVE "Backend Team" TO SAMPLE-AUTHOR(4)
    MOVE 3 TO SAMPLE-STATUS(4)
    MOVE 3 TO SAMPLE-PRIORITY(4)
    MOVE 65 TO SAMPLE-COMPLETION(4)
    
    MOVE "Mobile Application Redesign" TO SAMPLE-TITLE(5)
    MOVE "Complete user interface redesign for iOS and Android applications" TO SAMPLE-DESC(5)
    MOVE "Mobile Team" TO SAMPLE-AUTHOR(5)
    MOVE 4 TO SAMPLE-STATUS(5)
    MOVE 2 TO SAMPLE-PRIORITY(5)
    MOVE 90 TO SAMPLE-COMPLETION(5)
    
    MOVE "Real-time Notification System" TO SAMPLE-TITLE(6)
    MOVE "Build scalable real-time notification delivery system" TO SAMPLE-DESC(6)
    MOVE "Platform Team" TO SAMPLE-AUTHOR(6)
    MOVE 5 TO SAMPLE-STATUS(6)
    MOVE 2 TO SAMPLE-PRIORITY(6)
    MOVE 100 TO SAMPLE-COMPLETION(6)
    
    MOVE "Database Performance Optimization" TO SAMPLE-TITLE(7)
    MOVE "Optimize database queries and implement advanced caching strategies" TO SAMPLE-DESC(7)
    MOVE "Database Team" TO SAMPLE-AUTHOR(7)
    MOVE 3 TO SAMPLE-STATUS(7)
    MOVE 3 TO SAMPLE-PRIORITY(7)
    MOVE 45 TO SAMPLE-COMPLETION(7)
    
    MOVE "Internationalization Support" TO SAMPLE-TITLE(8)
    MOVE "Add comprehensive multi-language support and localization" TO SAMPLE-DESC(8)
    MOVE "I18N Team" TO SAMPLE-AUTHOR(8)
    MOVE 1 TO SAMPLE-STATUS(8)
    MOVE 2 TO SAMPLE-PRIORITY(8)
    MOVE 30 TO SAMPLE-COMPLETION(8)
    
    MOVE "COBOL Legacy System Integration" TO SAMPLE-TITLE(9)
    MOVE "Integrate modern systems with legacy COBOL mainframe applications" TO SAMPLE-DESC(9)
    MOVE "Legacy Team" TO SAMPLE-AUTHOR(9)
    MOVE 2 TO SAMPLE-STATUS(9)
    MOVE 4 TO SAMPLE-PRIORITY(9)
    MOVE 55 TO SAMPLE-COMPLETION(9)
    
    MOVE "Enterprise Reporting Dashboard" TO SAMPLE-TITLE(10)
    MOVE "Build comprehensive enterprise-grade reporting and analytics dashboard" TO SAMPLE-DESC(10)
    MOVE "Analytics Team" TO SAMPLE-AUTHOR(10)
    MOVE 0 TO SAMPLE-STATUS(10)
    MOVE 3 TO SAMPLE-PRIORITY(10)
    MOVE 15 TO SAMPLE-COMPLETION(10).

LOAD-SAMPLE-DATA-ROUTINE.
    OPEN I-O PRD-FILE
    IF FILE-STATUS = "35"
       OPEN OUTPUT PRD-FILE
       CLOSE PRD-FILE
       OPEN I-O PRD-FILE
    END-IF
    
    IF FILE-STATUS NOT = "00"
       DISPLAY "Error opening PRD file for I-O: " FILE-STATUS
       PERFORM CLEANUP
       STOP RUN
    END-IF
    
    PERFORM VARYING SAMPLE-COUNTER FROM 1 BY 1 
            UNTIL SAMPLE-COUNTER > 10
       
       * Generate PRD ID
       STRING "PRD-2025-" SAMPLE-COUNTER 
              DELIMITED BY SIZE INTO PRD-ID
       
       MOVE SAMPLE-TITLE(SAMPLE-COUNTER) TO PRD-TITLE
       MOVE SAMPLE-DESC(SAMPLE-COUNTER) TO PRD-DESCRIPTION
       MOVE SAMPLE-AUTHOR(SAMPLE-COUNTER) TO PRD-AUTHOR
       MOVE SAMPLE-STATUS(SAMPLE-COUNTER) TO PRD-STATUS
       MOVE SAMPLE-PRIORITY(SAMPLE-COUNTER) TO PRD-PRIORITY
       MOVE SAMPLE-COMPLETION(SAMPLE-COUNTER) TO PRD-COMPLETION-PCT
       MOVE WS-FORMATTED-DATE TO PRD-CREATED-DATE
       MOVE WS-FORMATTED-DATE TO PRD-UPDATED-DATE
       
       * Set tags based on content
       EVALUATE SAMPLE-COUNTER
          WHEN 1 MOVE "security,authentication,login" TO PRD-TAGS
          WHEN 2 MOVE "ui,theme,design" TO PRD-TAGS
          WHEN 3 MOVE "payment,integration,security" TO PRD-TAGS
          WHEN 4 MOVE "api,performance,security" TO PRD-TAGS
          WHEN 5 MOVE "mobile,design,ui" TO PRD-TAGS
          WHEN 6 MOVE "notifications,realtime,platform" TO PRD-TAGS
          WHEN 7 MOVE "database,performance,optimization" TO PRD-TAGS
          WHEN 8 MOVE "i18n,localization,global" TO PRD-TAGS
          WHEN 9 MOVE "cobol,legacy,integration" TO PRD-TAGS
          WHEN 10 MOVE "reporting,analytics,dashboard" TO PRD-TAGS
       END-EVALUATE
       
       WRITE PRD-RECORD
       IF FILE-STATUS NOT = "00"
          DISPLAY "Error writing PRD record: " FILE-STATUS
       ELSE
          ADD 1 TO TOTAL-PRDS
       END-IF
    END-PERFORM
    
    CLOSE PRD-FILE
    DISPLAY "Loaded " TOTAL-PRDS " sample PRDs successfully.".

GENERATE-ANALYTICS.
    * Initialize counters
    MOVE ZERO TO TOTAL-PRDS
    PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 7
       MOVE ZERO TO STATUS-COUNTERS(WS-INDEX)
    END-PERFORM
    
    PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 4
       MOVE ZERO TO PRIORITY-COUNTERS(WS-INDEX)
    END-PERFORM
    
    MOVE ZERO TO TOTAL-COMPLETION
    
    OPEN INPUT PRD-FILE
    IF FILE-STATUS NOT = "00"
       DISPLAY "Error opening PRD file for analytics: " FILE-STATUS
       GO TO ANALYTICS-EXIT
    END-IF
    
    * Read all records and calculate statistics
    PERFORM UNTIL FILE-STATUS = "10"
       READ PRD-FILE NEXT RECORD
       IF FILE-STATUS = "00"
          ADD 1 TO TOTAL-PRDS
          ADD 1 TO STATUS-COUNTERS(PRD-STATUS + 1)
          ADD 1 TO PRIORITY-COUNTERS(PRD-PRIORITY)
          ADD PRD-COMPLETION-PCT TO TOTAL-COMPLETION
       END-IF
    END-PERFORM
    
    * Calculate average completion
    IF TOTAL-PRDS > 0
       COMPUTE WS-TEMP-CALC = TOTAL-COMPLETION / TOTAL-PRDS
       MOVE WS-TEMP-CALC TO AVERAGE-COMPLETION
    END-IF
    
    CLOSE PRD-FILE
    
ANALYTICS-EXIT.
    EXIT.

DISPLAY-DASHBOARD.
    DISPLAY " "
    DISPLAY DIVIDER-LINE
    DISPLAY "PRD MANAGEMENT DASHBOARD"
    DISPLAY DIVIDER-LINE
    
    DISPLAY "Total PRDs: " TOTAL-PRDS
    DISPLAY "Average Completion: " AVERAGE-COMPLETION "%"
    
    DISPLAY " "
    DISPLAY "STATUS DISTRIBUTION:"
    PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 7
       IF STATUS-COUNTERS(WS-INDEX) > 0
          DISPLAY "  " STATUS-NAME(WS-INDEX) ": " 
                  STATUS-COUNTERS(WS-INDEX)
       END-IF
    END-PERFORM
    
    DISPLAY " "
    DISPLAY "PRIORITY DISTRIBUTION:"
    PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 4
       IF PRIORITY-COUNTERS(WS-INDEX) > 0
          DISPLAY "  " PRIORITY-NAME(WS-INDEX) ": " 
                  PRIORITY-COUNTERS(WS-INDEX)
       END-IF
    END-PERFORM
    
    PERFORM DISPLAY-CRITICAL-PRDS
    PERFORM DISPLAY-HIGH-COMPLETION-PRDS
    PERFORM GENERATE-SUMMARY-REPORT.

DISPLAY-CRITICAL-PRDS.
    DISPLAY " "
    DISPLAY "CRITICAL PRIORITY PRDS:"
    
    OPEN INPUT PRD-FILE
    IF FILE-STATUS NOT = "00"
       DISPLAY "Error opening file for critical PRD display"
       GO TO CRITICAL-EXIT
    END-IF
    
    PERFORM UNTIL FILE-STATUS = "10"
       READ PRD-FILE NEXT RECORD
       IF FILE-STATUS = "00"
          IF PRD-PRIORITY = 4
             DISPLAY "  [CRITICAL] " PRD-TITLE " - " 
                     STATUS-NAME(PRD-STATUS + 1) " (" 
                     PRD-COMPLETION-PCT "%)"
          END-IF
       END-IF
    END-PERFORM
    
    CLOSE PRD-FILE
    
CRITICAL-EXIT.
    EXIT.

DISPLAY-HIGH-COMPLETION-PRDS.
    DISPLAY " "
    DISPLAY "HIGH COMPLETION PRDS (80%+):"
    
    OPEN INPUT PRD-FILE
    IF FILE-STATUS NOT = "00"
       DISPLAY "Error opening file for high completion display"
       GO TO HIGH-COMPLETION-EXIT
    END-IF
    
    PERFORM UNTIL FILE-STATUS = "10"
       READ PRD-FILE NEXT RECORD
       IF FILE-STATUS = "00"
          IF PRD-COMPLETION-PCT >= 80
             DISPLAY "  [" PRD-COMPLETION-PCT "%] " PRD-TITLE 
                     " - " PRIORITY-NAME(PRD-PRIORITY)
          END-IF
       END-IF
    END-PERFORM
    
    CLOSE PRD-FILE
    
HIGH-COMPLETION-EXIT.
    EXIT.

GENERATE-SUMMARY-REPORT.
    DISPLAY " "
    DISPLAY "Generating comprehensive PRD report..."
    
    OPEN OUTPUT REPORT-FILE
    IF REPORT-STATUS NOT = "00"
       DISPLAY "Error creating report file: " REPORT-STATUS
       GO TO REPORT-EXIT
    END-IF
    
    * Write report header
    MOVE MAIN-HEADER TO REPORT-LINE
    WRITE REPORT-LINE
    MOVE VERSION-HEADER TO REPORT-LINE
    WRITE REPORT-LINE
    MOVE DIVIDER-LINE TO REPORT-LINE
    WRITE REPORT-LINE
    
    * Write summary statistics
    STRING "Total PRDs: " TOTAL-PRDS 
           DELIMITED BY SIZE INTO REPORT-LINE
    WRITE REPORT-LINE
    
    STRING "Average Completion: " AVERAGE-COMPLETION "%" 
           DELIMITED BY SIZE INTO REPORT-LINE
    WRITE REPORT-LINE
    
    MOVE SPACES TO REPORT-LINE
    WRITE REPORT-LINE
    
    * Write detailed PRD information
    MOVE "DETAILED PRD INFORMATION:" TO REPORT-LINE
    WRITE REPORT-LINE
    MOVE DIVIDER-LINE TO REPORT-LINE
    WRITE REPORT-LINE
    
    OPEN INPUT PRD-FILE
    IF FILE-STATUS = "00"
       PERFORM UNTIL FILE-STATUS = "10"
          READ PRD-FILE NEXT RECORD
          IF FILE-STATUS = "00"
             STRING "ID: " PRD-ID " | Title: " PRD-TITLE
                    DELIMITED BY SIZE INTO REPORT-LINE
             WRITE REPORT-LINE
             
             STRING "Author: " PRD-AUTHOR " | Status: " 
                    STATUS-NAME(PRD-STATUS + 1)
                    DELIMITED BY SIZE INTO REPORT-LINE
             WRITE REPORT-LINE
             
             STRING "Priority: " PRIORITY-NAME(PRD-PRIORITY) 
                    " | Completion: " PRD-COMPLETION-PCT "%"
                    DELIMITED BY SIZE INTO REPORT-LINE
             WRITE REPORT-LINE
             
             STRING "Description: " PRD-DESCRIPTION
                    DELIMITED BY SIZE INTO REPORT-LINE
             WRITE REPORT-LINE
             
             STRING "Tags: " PRD-TAGS
                    DELIMITED BY SIZE INTO REPORT-LINE
             WRITE REPORT-LINE
             
             MOVE SPACES TO REPORT-LINE
             WRITE REPORT-LINE
          END-IF
       END-PERFORM
       CLOSE PRD-FILE
    END-IF
    
    CLOSE REPORT-FILE
    DISPLAY "Report generated successfully: PRDREPORT.TXT"
    
REPORT-EXIT.
    EXIT.

CLEANUP.
    DISPLAY " "
    DISPLAY "COBOL PRD Management System Features:"
    DISPLAY "  * Enterprise-grade data management"
    DISPLAY "  * Indexed file organization"
    DISPLAY "  * Comprehensive reporting"
    DISPLAY "  * Status and priority tracking"
    DISPLAY "  * Completion analytics"
    DISPLAY "  * Legacy system integration ready"
    DISPLAY " "
    DISPLAY "COBOL demonstration completed successfully!"
    DISPLAY "All PRD data saved to PRDDATA.DAT"
    DISPLAY "Detailed report saved to PRDREPORT.TXT".

END PROGRAM PRD-MANAGEMENT-SYSTEM.
