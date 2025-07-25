C     PRD Management System - FORTRAN Implementation
C     Version: 1.2.0 | Last Updated: July 25, 2025
C     High-performance scientific computing for PRD analytics

      PROGRAM PRDMGMT
      IMPLICIT NONE
      
C     Parameter declarations
      INTEGER, PARAMETER :: MAXPRDS = 1000
      INTEGER, PARAMETER :: MAXSTRING = 200
      INTEGER, PARAMETER :: MAXAUTHOR = 50
      INTEGER, PARAMETER :: MAXTITLE = 100
      INTEGER, PARAMETER :: MAXTAGS = 500
      
C     Status constants
      INTEGER, PARAMETER :: DRAFT = 0
      INTEGER, PARAMETER :: INREVIEW = 1
      INTEGER, PARAMETER :: APPROVED = 2
      INTEGER, PARAMETER :: INDEVELOPMENT = 3
      INTEGER, PARAMETER :: TESTING = 4
      INTEGER, PARAMETER :: IMPLEMENTED = 5
      INTEGER, PARAMETER :: ARCHIVED = 6
      
C     Priority constants
      INTEGER, PARAMETER :: LOW = 1
      INTEGER, PARAMETER :: MEDIUM = 2
      INTEGER, PARAMETER :: HIGH = 3
      INTEGER, PARAMETER :: CRITICAL = 4
      
C     PRD data structure arrays
      CHARACTER(LEN=20) :: PRDIDS(MAXPRDS)
      CHARACTER(LEN=MAXTITLE) :: TITLES(MAXPRDS)
      CHARACTER(LEN=MAXSTRING) :: DESCRIPTIONS(MAXPRDS)
      CHARACTER(LEN=MAXAUTHOR) :: AUTHORS(MAXPRDS)
      INTEGER :: STATUSES(MAXPRDS)
      INTEGER :: PRIORITIES(MAXPRDS)
      INTEGER :: COMPLETIONS(MAXPRDS)
      INTEGER :: CREATEDDATES(MAXPRDS)
      INTEGER :: UPDATEDDATES(MAXPRDS)
      CHARACTER(LEN=MAXTAGS) :: TAGSLISTS(MAXPRDS)
      
C     Working variables
      INTEGER :: NPRDS, I, J, K
      INTEGER :: STATUSCOUNTS(0:6)
      INTEGER :: PRIORITYCOUNTS(1:4)
      REAL :: AVGCOMPLETION, TOTALCOMPLETION
      INTEGER :: SEARCHCOUNT, CHOICE
      CHARACTER(LEN=50) :: SEARCHTERM
      CHARACTER(LEN=20) :: TEMPID
      LOGICAL :: FOUND
      
C     Status and priority name arrays
      CHARACTER(LEN=15) :: STATUSNAMES(0:6)
      CHARACTER(LEN=10) :: PRIORITYNAMES(1:4)
      
C     Analytics variables
      REAL :: COMPLETIONSTATS(3)  ! MIN, MAX, AVG
      INTEGER :: CRITICALCOUNT, HIGHLOWCOUNT
      REAL :: PRODUCTIVITYINDEX
      
C     Matrix for advanced analytics
      REAL :: STATUSMATRIX(0:6, 1:4)
      REAL :: TRENDANALYSIS(10)
      INTEGER :: WEEKLYCOMPLETION(52)
      
      WRITE(*,*) 'PRD Management System v1.2.0 - FORTRAN Implementation'
      WRITE(*,*) REPEAT('=', 60)
      
C     Initialize status and priority names
      DATA STATUSNAMES /'Draft', 'In Review', 'Approved', 
     &                  'In Development', 'Testing', 'Implemented',
     &                  'Archived'/
      DATA PRIORITYNAMES /'Low', 'Medium', 'High', 'Critical'/
      
C     Initialize system
      CALL INITSYSTEM(NPRDS)
      
C     Load sample data
      CALL LOADSAMPLEDATA(NPRDS, PRDIDS, TITLES, DESCRIPTIONS, 
     &                    AUTHORS, STATUSES, PRIORITIES, 
     &                    COMPLETIONS, CREATEDDATES, UPDATEDDATES,
     &                    TAGSLISTS)
      
C     Generate analytics
      CALL GENERATEANALYTICS(NPRDS, STATUSES, PRIORITIES, 
     &                       COMPLETIONS, STATUSCOUNTS, 
     &                       PRIORITYCOUNTS, AVGCOMPLETION,
     &                       COMPLETIONSTATS)
      
C     Display dashboard
      CALL DISPLAYDASHBOARD(NPRDS, STATUSCOUNTS, PRIORITYCOUNTS,
     &                      AVGCOMPLETION, STATUSNAMES, 
     &                      PRIORITYNAMES, COMPLETIONSTATS)
      
C     Perform advanced analytics
      CALL ADVANCEDANALYTICS(NPRDS, STATUSES, PRIORITIES,
     &                       COMPLETIONS, STATUSMATRIX,
     &                       PRODUCTIVITYINDEX)
      
C     Demo operations
      WRITE(*,*) ''
      WRITE(*,*) REPEAT('=', 60)
      WRITE(*,*) 'DEMO OPERATIONS'
      WRITE(*,*) REPEAT('=', 60)
      
C     Search demonstration
      SEARCHTERM = 'authentication'
      CALL SEARCHPRDS(NPRDS, TITLES, DESCRIPTIONS, TAGSLISTS,
     &                SEARCHTERM, SEARCHCOUNT)
      
C     Priority filtering demonstration
      CALL FILTERBYPRIORITY(NPRDS, PRIORITIES, CRITICAL, 
     &                      CRITICALCOUNT)
      WRITE(*,100) 'Critical Priority PRDs found: ', CRITICALCOUNT
      
C     Status filtering demonstration
      CALL FILTERBYSTATUS(NPRDS, STATUSES, DRAFT, HIGHLOWCOUNT)
      WRITE(*,100) 'Draft PRDs found: ', HIGHLOWCOUNT
      
C     Completion analysis
      CALL COMPLETIONANALYSIS(NPRDS, COMPLETIONS, STATUSES,
     &                        PRIORITIES)
      
C     Generate mathematical models
      CALL MATHEMATICALMODELING(NPRDS, STATUSES, PRIORITIES,
     &                          COMPLETIONS, TRENDANALYSIS)
      
C     Performance metrics
      CALL PERFORMANCEMETRICS(NPRDS, COMPLETIONS, STATUSES,
     &                        PRODUCTIVITYINDEX)
      
C     Export results
      CALL EXPORTRESULTS(NPRDS, PRDIDS, TITLES, DESCRIPTIONS,
     &                   AUTHORS, STATUSES, PRIORITIES,
     &                   COMPLETIONS, STATUSNAMES, PRIORITYNAMES)
      
      WRITE(*,*) ''
      WRITE(*,*) 'FORTRAN PRD Management System demonstration completed!'
      WRITE(*,*) 'FORTRAN Features Demonstrated:'
      WRITE(*,*) '  * High-performance numeric computing'
      WRITE(*,*) '  * Advanced mathematical modeling'
      WRITE(*,*) '  * Matrix operations and linear algebra'
      WRITE(*,*) '  * Statistical analysis and trend prediction'
      WRITE(*,*) '  * Scientific data processing'
      WRITE(*,*) '  * Efficient array operations'
      
      STOP
      
C     Format statements
100   FORMAT(A, I0)
200   FORMAT(A, F6.2)
300   FORMAT(A, I0, A, F6.2, A)
      
      END PROGRAM PRDMGMT

C     Subroutine to initialize the system
      SUBROUTINE INITSYSTEM(NPRDS)
      IMPLICIT NONE
      INTEGER, INTENT(OUT) :: NPRDS
      
      NPRDS = 0
      WRITE(*,*) 'PRD Management System initialized.'
      RETURN
      END SUBROUTINE INITSYSTEM

C     Subroutine to load sample data
      SUBROUTINE LOADSAMPLEDATA(NPRDS, PRDIDS, TITLES, DESCRIPTIONS,
     &                          AUTHORS, STATUSES, PRIORITIES,
     &                          COMPLETIONS, CREATEDDATES, 
     &                          UPDATEDDATES, TAGSLISTS)
      IMPLICIT NONE
      INTEGER, PARAMETER :: MAXPRDS = 1000
      INTEGER, PARAMETER :: MAXSTRING = 200
      INTEGER, PARAMETER :: MAXAUTHOR = 50
      INTEGER, PARAMETER :: MAXTITLE = 100
      INTEGER, PARAMETER :: MAXTAGS = 500
      
      INTEGER, INTENT(INOUT) :: NPRDS
      CHARACTER(LEN=20), INTENT(OUT) :: PRDIDS(MAXPRDS)
      CHARACTER(LEN=MAXTITLE), INTENT(OUT) :: TITLES(MAXPRDS)
      CHARACTER(LEN=MAXSTRING), INTENT(OUT) :: DESCRIPTIONS(MAXPRDS)
      CHARACTER(LEN=MAXAUTHOR), INTENT(OUT) :: AUTHORS(MAXPRDS)
      INTEGER, INTENT(OUT) :: STATUSES(MAXPRDS)
      INTEGER, INTENT(OUT) :: PRIORITIES(MAXPRDS)
      INTEGER, INTENT(OUT) :: COMPLETIONS(MAXPRDS)
      INTEGER, INTENT(OUT) :: CREATEDDATES(MAXPRDS)
      INTEGER, INTENT(OUT) :: UPDATEDDATES(MAXPRDS)
      CHARACTER(LEN=MAXTAGS), INTENT(OUT) :: TAGSLISTS(MAXPRDS)
      
      INTEGER :: I, CURRENTDATE
      
C     Get current date (simplified)
      CURRENTDATE = 20250725
      
      NPRDS = 12
      
C     Sample PRD 1
      PRDIDS(1) = 'PRD-2025-001'
      TITLES(1) = 'Quantum Authentication System'
      DESCRIPTIONS(1) = 'Implement quantum-resistant authentication'//
     &                  ' with advanced cryptographic protocols'
      AUTHORS(1) = 'Quantum Security Team'
      STATUSES(1) = 0  ! DRAFT
      PRIORITIES(1) = 4  ! CRITICAL
      COMPLETIONS(1) = 15
      CREATEDDATES(1) = CURRENTDATE
      UPDATEDDATES(1) = CURRENTDATE
      TAGSLISTS(1) = 'quantum,security,authentication,crypto'
      
C     Sample PRD 2
      PRDIDS(2) = 'PRD-2025-002'
      TITLES(2) = 'Scientific Computing Dashboard'
      DESCRIPTIONS(2) = 'Build high-performance scientific computing'//
     &                  ' dashboard with real-time analytics'
      AUTHORS(2) = 'HPC Team'
      STATUSES(2) = 1  ! IN_REVIEW
      PRIORITIES(2) = 3  ! HIGH
      COMPLETIONS(2) = 45
      CREATEDDATES(2) = CURRENTDATE
      UPDATEDDATES(2) = CURRENTDATE
      TAGSLISTS(2) = 'hpc,scientific,dashboard,analytics'
      
C     Sample PRD 3
      PRDIDS(3) = 'PRD-2025-003'
      TITLES(3) = 'Matrix Operations Optimization'
      DESCRIPTIONS(3) = 'Optimize matrix operations for large-scale'//
     &                  ' linear algebra computations'
      AUTHORS(3) = 'Math Computing Team'
      STATUSES(3) = 2  ! APPROVED
      PRIORITIES(3) = 3  ! HIGH
      COMPLETIONS(3) = 70
      CREATEDDATES(3) = CURRENTDATE
      UPDATEDDATES(3) = CURRENTDATE
      TAGSLISTS(3) = 'matrix,optimization,linear-algebra,math'
      
C     Sample PRD 4
      PRDIDS(4) = 'PRD-2025-004'
      TITLES(4) = 'Parallel Processing Framework'
      DESCRIPTIONS(4) = 'Develop parallel processing framework for'//
     &                  ' distributed scientific computations'
      AUTHORS(4) = 'Parallel Computing'
      STATUSES(4) = 3  ! IN_DEVELOPMENT
      PRIORITIES(4) = 4  ! CRITICAL
      COMPLETIONS(4) = 60
      CREATEDDATES(4) = CURRENTDATE
      UPDATEDDATES(4) = CURRENTDATE
      TAGSLISTS(4) = 'parallel,distributed,framework,computing'
      
C     Sample PRD 5
      PRDIDS(5) = 'PRD-2025-005'
      TITLES(5) = 'Numerical Methods Library'
      DESCRIPTIONS(5) = 'Create comprehensive numerical methods'//
     &                  ' library for scientific applications'
      AUTHORS(5) = 'Numerical Team'
      STATUSES(5) = 4  ! TESTING
      PRIORITIES(5) = 2  ! MEDIUM
      COMPLETIONS(5) = 85
      CREATEDDATES(5) = CURRENTDATE
      UPDATEDDATES(5) = CURRENTDATE
      TAGSLISTS(5) = 'numerical,methods,library,scientific'
      
C     Sample PRD 6
      PRDIDS(6) = 'PRD-2025-006'
      TITLES(6) = 'Weather Simulation Engine'
      DESCRIPTIONS(6) = 'Build advanced weather simulation engine'//
     &                  ' using computational fluid dynamics'
      AUTHORS(6) = 'Climate Modeling'
      STATUSES(6) = 5  ! IMPLEMENTED
      PRIORITIES(6) = 3  ! HIGH
      COMPLETIONS(6) = 100
      CREATEDDATES(6) = CURRENTDATE
      UPDATEDDATES(6) = CURRENTDATE
      TAGSLISTS(6) = 'weather,simulation,cfd,climate'
      
C     Sample PRD 7
      PRDIDS(7) = 'PRD-2025-007'
      TITLES(7) = 'Statistical Analysis Platform'
      DESCRIPTIONS(7) = 'Develop comprehensive statistical analysis'//
     &                  ' platform for research applications'
      AUTHORS(7) = 'Statistics Team'
      STATUSES(7) = 2  ! APPROVED
      PRIORITIES(7) = 2  ! MEDIUM
      COMPLETIONS(7) = 50
      CREATEDDATES(7) = CURRENTDATE
      UPDATEDDATES(7) = CURRENTDATE
      TAGSLISTS(7) = 'statistics,analysis,research,platform'
      
C     Sample PRD 8
      PRDIDS(8) = 'PRD-2025-008'
      TITLES(8) = 'Finite Element Solver'
      DESCRIPTIONS(8) = 'Implement high-performance finite element'//
     &                  ' solver for engineering simulations'
      AUTHORS(8) = 'Engineering Team'
      STATUSES(8) = 3  ! IN_DEVELOPMENT
      PRIORITIES(8) = 4  ! CRITICAL
      COMPLETIONS(8) = 40
      CREATEDDATES(8) = CURRENTDATE
      UPDATEDDATES(8) = CURRENTDATE
      TAGSLISTS(8) = 'fem,finite-element,solver,engineering'
      
C     Sample PRD 9
      PRDIDS(9) = 'PRD-2025-009'
      TITLES(9) = 'Signal Processing Algorithms'
      DESCRIPTIONS(9) = 'Develop advanced signal processing'//
     &                  ' algorithms for real-time applications'
      AUTHORS(9) = 'DSP Team'
      STATUSES(9) = 1  ! IN_REVIEW
      PRIORITIES(9) = 3  ! HIGH
      COMPLETIONS(9) = 25
      CREATEDDATES(9) = CURRENTDATE
      UPDATEDDATES(9) = CURRENTDATE
      TAGSLISTS(9) = 'dsp,signal,processing,algorithms'
      
C     Sample PRD 10
      PRDIDS(10) = 'PRD-2025-010'
      TITLES(10) = 'Optimization Algorithms Suite'
      DESCRIPTIONS(10) = 'Create comprehensive optimization'//
     &                   ' algorithms suite for various domains'
      AUTHORS(10) = 'Optimization Team'
      STATUSES(10) = 0  ! DRAFT
      PRIORITIES(10) = 2  ! MEDIUM
      COMPLETIONS(10) = 10
      CREATEDDATES(10) = CURRENTDATE
      UPDATEDDATES(10) = CURRENTDATE
      TAGSLISTS(10) = 'optimization,algorithms,suite,domains'
      
C     Sample PRD 11
      PRDIDS(11) = 'PRD-2025-011'
      TITLES(11) = 'FORTRAN Legacy Modernization'
      DESCRIPTIONS(11) = 'Modernize legacy FORTRAN scientific'//
     &                   ' code with contemporary standards'
      AUTHORS(11) = 'Legacy Team'
      STATUSES(11) = 2  ! APPROVED
      PRIORITIES(11) = 3  ! HIGH
      COMPLETIONS(11) = 65
      CREATEDDATES(11) = CURRENTDATE
      UPDATEDDATES(11) = CURRENTDATE
      TAGSLISTS(11) = 'fortran,legacy,modernization,standards'
      
C     Sample PRD 12
      PRDIDS(12) = 'PRD-2025-012'
      TITLES(12) = 'Supercomputing Integration'
      DESCRIPTIONS(12) = 'Integrate applications with'//
     &                   ' supercomputing infrastructure'
      AUTHORS(12) = 'HPC Infrastructure'
      STATUSES(12) = 4  ! TESTING
      PRIORITIES(12) = 4  ! CRITICAL
      COMPLETIONS(12) = 90
      CREATEDDATES(12) = CURRENTDATE
      UPDATEDDATES(12) = CURRENTDATE
      TAGSLISTS(12) = 'supercomputing,hpc,infrastructure,integration'
      
      WRITE(*,100) 'Loaded ', NPRDS, ' sample PRDs successfully.'
100   FORMAT(A, I0, A)
      RETURN
      END SUBROUTINE LOADSAMPLEDATA

C     Subroutine to generate analytics
      SUBROUTINE GENERATEANALYTICS(NPRDS, STATUSES, PRIORITIES,
     &                             COMPLETIONS, STATUSCOUNTS,
     &                             PRIORITYCOUNTS, AVGCOMPLETION,
     &                             COMPLETIONSTATS)
      IMPLICIT NONE
      INTEGER, PARAMETER :: MAXPRDS = 1000
      INTEGER, INTENT(IN) :: NPRDS
      INTEGER, INTENT(IN) :: STATUSES(MAXPRDS)
      INTEGER, INTENT(IN) :: PRIORITIES(MAXPRDS)
      INTEGER, INTENT(IN) :: COMPLETIONS(MAXPRDS)
      INTEGER, INTENT(OUT) :: STATUSCOUNTS(0:6)
      INTEGER, INTENT(OUT) :: PRIORITYCOUNTS(1:4)
      REAL, INTENT(OUT) :: AVGCOMPLETION
      REAL, INTENT(OUT) :: COMPLETIONSTATS(3)
      
      INTEGER :: I, TOTALCOMPLETION, MINCOMPLETION, MAXCOMPLETION
      
C     Initialize counters
      DO I = 0, 6
         STATUSCOUNTS(I) = 0
      END DO
      
      DO I = 1, 4
         PRIORITYCOUNTS(I) = 0
      END DO
      
      TOTALCOMPLETION = 0
      MINCOMPLETION = 100
      MAXCOMPLETION = 0
      
C     Count occurrences and calculate statistics
      DO I = 1, NPRDS
         STATUSCOUNTS(STATUSES(I)) = STATUSCOUNTS(STATUSES(I)) + 1
         PRIORITYCOUNTS(PRIORITIES(I)) = PRIORITYCOUNTS(PRIORITIES(I))
     &                                   + 1
         TOTALCOMPLETION = TOTALCOMPLETION + COMPLETIONS(I)
         
         IF (COMPLETIONS(I) < MINCOMPLETION) THEN
            MINCOMPLETION = COMPLETIONS(I)
         END IF
         
         IF (COMPLETIONS(I) > MAXCOMPLETION) THEN
            MAXCOMPLETION = COMPLETIONS(I)
         END IF
      END DO
      
C     Calculate average completion
      IF (NPRDS > 0) THEN
         AVGCOMPLETION = REAL(TOTALCOMPLETION) / REAL(NPRDS)
      ELSE
         AVGCOMPLETION = 0.0
      END IF
      
      COMPLETIONSTATS(1) = REAL(MINCOMPLETION)
      COMPLETIONSTATS(2) = REAL(MAXCOMPLETION)
      COMPLETIONSTATS(3) = AVGCOMPLETION
      
      RETURN
      END SUBROUTINE GENERATEANALYTICS

C     Subroutine to display dashboard
      SUBROUTINE DISPLAYDASHBOARD(NPRDS, STATUSCOUNTS, PRIORITYCOUNTS,
     &                            AVGCOMPLETION, STATUSNAMES,
     &                            PRIORITYNAMES, COMPLETIONSTATS)
      IMPLICIT NONE
      INTEGER, INTENT(IN) :: NPRDS
      INTEGER, INTENT(IN) :: STATUSCOUNTS(0:6)
      INTEGER, INTENT(IN) :: PRIORITYCOUNTS(1:4)
      REAL, INTENT(IN) :: AVGCOMPLETION
      CHARACTER(LEN=15), INTENT(IN) :: STATUSNAMES(0:6)
      CHARACTER(LEN=10), INTENT(IN) :: PRIORITYNAMES(1:4)
      REAL, INTENT(IN) :: COMPLETIONSTATS(3)
      
      INTEGER :: I
      
      WRITE(*,*) ''
      WRITE(*,*) REPEAT('=', 60)
      WRITE(*,*) 'PRD MANAGEMENT SYSTEM - DASHBOARD'
      WRITE(*,*) REPEAT('=', 60)
      
      WRITE(*,100) 'Total PRDs: ', NPRDS
      WRITE(*,200) 'Average Completion: ', AVGCOMPLETION, '%'
      
      WRITE(*,*) ''
      WRITE(*,*) 'Status Distribution:'
      DO I = 0, 6
         IF (STATUSCOUNTS(I) > 0) THEN
            WRITE(*,300) '  ', TRIM(STATUSNAMES(I)), ': ', 
     &                   STATUSCOUNTS(I)
         END IF
      END DO
      
      WRITE(*,*) ''
      WRITE(*,*) 'Priority Distribution:'
      DO I = 1, 4
         IF (PRIORITYCOUNTS(I) > 0) THEN
            WRITE(*,300) '  ', TRIM(PRIORITYNAMES(I)), ': ',
     &                   PRIORITYCOUNTS(I)
         END IF
      END DO
      
      WRITE(*,*) ''
      WRITE(*,*) 'Completion Statistics:'
      WRITE(*,200) '  Minimum: ', COMPLETIONSTATS(1), '%'
      WRITE(*,200) '  Maximum: ', COMPLETIONSTATS(2), '%'
      WRITE(*,200) '  Average: ', COMPLETIONSTATS(3), '%'
      
100   FORMAT(A, I0)
200   FORMAT(A, F6.2, A)
300   FORMAT(A, A, A, I0)
      RETURN
      END SUBROUTINE DISPLAYDASHBOARD

C     Subroutine for advanced analytics
      SUBROUTINE ADVANCEDANALYTICS(NPRDS, STATUSES, PRIORITIES,
     &                             COMPLETIONS, STATUSMATRIX,
     &                             PRODUCTIVITYINDEX)
      IMPLICIT NONE
      INTEGER, PARAMETER :: MAXPRDS = 1000
      INTEGER, INTENT(IN) :: NPRDS
      INTEGER, INTENT(IN) :: STATUSES(MAXPRDS)
      INTEGER, INTENT(IN) :: PRIORITIES(MAXPRDS)
      INTEGER, INTENT(IN) :: COMPLETIONS(MAXPRDS)
      REAL, INTENT(OUT) :: STATUSMATRIX(0:6, 1:4)
      REAL, INTENT(OUT) :: PRODUCTIVITYINDEX
      
      INTEGER :: I, J, K, COUNT
      REAL :: TOTALWEIGHT, WEIGHTEDSUM
      
C     Initialize matrix
      DO I = 0, 6
         DO J = 1, 4
            STATUSMATRIX(I, J) = 0.0
         END DO
      END DO
      
C     Build status-priority matrix
      DO I = 1, NPRDS
         J = STATUSES(I)
         K = PRIORITIES(I)
         STATUSMATRIX(J, K) = STATUSMATRIX(J, K) + 
     &                        REAL(COMPLETIONS(I))
      END DO
      
C     Calculate productivity index
      TOTALWEIGHT = 0.0
      WEIGHTEDSUM = 0.0
      
      DO I = 1, NPRDS
         TOTALWEIGHT = TOTALWEIGHT + REAL(PRIORITIES(I))
         WEIGHTEDSUM = WEIGHTEDSUM + REAL(PRIORITIES(I)) * 
     &                 REAL(COMPLETIONS(I))
      END DO
      
      IF (TOTALWEIGHT > 0.0) THEN
         PRODUCTIVITYINDEX = WEIGHTEDSUM / TOTALWEIGHT
      ELSE
         PRODUCTIVITYINDEX = 0.0
      END IF
      
      WRITE(*,*) ''
      WRITE(*,*) 'Advanced Analytics:'
      WRITE(*,100) 'Productivity Index: ', PRODUCTIVITYINDEX
      
100   FORMAT(A, F8.2)
      RETURN
      END SUBROUTINE ADVANCEDANALYTICS

C     Subroutine to search PRDs
      SUBROUTINE SEARCHPRDS(NPRDS, TITLES, DESCRIPTIONS, TAGSLISTS,
     &                      SEARCHTERM, SEARCHCOUNT)
      IMPLICIT NONE
      INTEGER, PARAMETER :: MAXPRDS = 1000
      INTEGER, PARAMETER :: MAXSTRING = 200
      INTEGER, PARAMETER :: MAXTITLE = 100
      INTEGER, PARAMETER :: MAXTAGS = 500
      
      INTEGER, INTENT(IN) :: NPRDS
      CHARACTER(LEN=MAXTITLE), INTENT(IN) :: TITLES(MAXPRDS)
      CHARACTER(LEN=MAXSTRING), INTENT(IN) :: DESCRIPTIONS(MAXPRDS)
      CHARACTER(LEN=MAXTAGS), INTENT(IN) :: TAGSLISTS(MAXPRDS)
      CHARACTER(LEN=50), INTENT(IN) :: SEARCHTERM
      INTEGER, INTENT(OUT) :: SEARCHCOUNT
      
      INTEGER :: I
      LOGICAL :: FOUND
      
      SEARCHCOUNT = 0
      WRITE(*,*) ''
      WRITE(*,*) 'Searching for: ', TRIM(SEARCHTERM)
      
      DO I = 1, NPRDS
         FOUND = .FALSE.
         
C        Simple substring search (case-insensitive simulation)
         IF (INDEX(TITLES(I), TRIM(SEARCHTERM)) > 0 .OR.
     &       INDEX(DESCRIPTIONS(I), TRIM(SEARCHTERM)) > 0 .OR.
     &       INDEX(TAGSLISTS(I), TRIM(SEARCHTERM)) > 0) THEN
            FOUND = .TRUE.
         END IF
         
         IF (FOUND) THEN
            SEARCHCOUNT = SEARCHCOUNT + 1
            WRITE(*,100) '  Found: ', TRIM(TITLES(I))
         END IF
      END DO
      
      WRITE(*,200) 'Total matches found: ', SEARCHCOUNT
      
100   FORMAT(A, A)
200   FORMAT(A, I0)
      RETURN
      END SUBROUTINE SEARCHPRDS

C     Subroutine to filter by priority
      SUBROUTINE FILTERBYPRIORITY(NPRDS, PRIORITIES, TARGETPRIORITY,
     &                            COUNT)
      IMPLICIT NONE
      INTEGER, PARAMETER :: MAXPRDS = 1000
      INTEGER, INTENT(IN) :: NPRDS
      INTEGER, INTENT(IN) :: PRIORITIES(MAXPRDS)
      INTEGER, INTENT(IN) :: TARGETPRIORITY
      INTEGER, INTENT(OUT) :: COUNT
      
      INTEGER :: I
      
      COUNT = 0
      DO I = 1, NPRDS
         IF (PRIORITIES(I) == TARGETPRIORITY) THEN
            COUNT = COUNT + 1
         END IF
      END DO
      
      RETURN
      END SUBROUTINE FILTERBYPRIORITY

C     Subroutine to filter by status
      SUBROUTINE FILTERBYSTATUS(NPRDS, STATUSES, TARGETSTATUS, COUNT)
      IMPLICIT NONE
      INTEGER, PARAMETER :: MAXPRDS = 1000
      INTEGER, INTENT(IN) :: NPRDS
      INTEGER, INTENT(IN) :: STATUSES(MAXPRDS)
      INTEGER, INTENT(IN) :: TARGETSTATUS
      INTEGER, INTENT(OUT) :: COUNT
      
      INTEGER :: I
      
      COUNT = 0
      DO I = 1, NPRDS
         IF (STATUSES(I) == TARGETSTATUS) THEN
            COUNT = COUNT + 1
         END IF
      END DO
      
      RETURN
      END SUBROUTINE FILTERBYSTATUS

C     Subroutine for completion analysis
      SUBROUTINE COMPLETIONANALYSIS(NPRDS, COMPLETIONS, STATUSES,
     &                              PRIORITIES)
      IMPLICIT NONE
      INTEGER, PARAMETER :: MAXPRDS = 1000
      INTEGER, INTENT(IN) :: NPRDS
      INTEGER, INTENT(IN) :: COMPLETIONS(MAXPRDS)
      INTEGER, INTENT(IN) :: STATUSES(MAXPRDS)
      INTEGER, INTENT(IN) :: PRIORITIES(MAXPRDS)
      
      INTEGER :: I, HIGHCOMPLETIONCOUNT
      REAL :: VARIANCE, MEAN, SUMSQ
      
      HIGHCOMPLETIONCOUNT = 0
      MEAN = 0.0
      SUMSQ = 0.0
      
C     Calculate mean
      DO I = 1, NPRDS
         MEAN = MEAN + REAL(COMPLETIONS(I))
         IF (COMPLETIONS(I) >= 80) THEN
            HIGHCOMPLETIONCOUNT = HIGHCOMPLETIONCOUNT + 1
         END IF
      END DO
      
      IF (NPRDS > 0) THEN
         MEAN = MEAN / REAL(NPRDS)
      END IF
      
C     Calculate variance
      DO I = 1, NPRDS
         SUMSQ = SUMSQ + (REAL(COMPLETIONS(I)) - MEAN)**2
      END DO
      
      IF (NPRDS > 1) THEN
         VARIANCE = SUMSQ / REAL(NPRDS - 1)
      ELSE
         VARIANCE = 0.0
      END IF
      
      WRITE(*,*) ''
      WRITE(*,*) 'Completion Analysis:'
      WRITE(*,100) '  Mean Completion: ', MEAN, '%'
      WRITE(*,100) '  Completion Variance: ', VARIANCE
      WRITE(*,200) '  High Completion (80%+): ', HIGHCOMPLETIONCOUNT
      
100   FORMAT(A, F8.2, A)
200   FORMAT(A, I0)
      RETURN
      END SUBROUTINE COMPLETIONANALYSIS

C     Subroutine for mathematical modeling
      SUBROUTINE MATHEMATICALMODELING(NPRDS, STATUSES, PRIORITIES,
     &                                COMPLETIONS, TRENDANALYSIS)
      IMPLICIT NONE
      INTEGER, PARAMETER :: MAXPRDS = 1000
      INTEGER, INTENT(IN) :: NPRDS
      INTEGER, INTENT(IN) :: STATUSES(MAXPRDS)
      INTEGER, INTENT(IN) :: PRIORITIES(MAXPRDS)
      INTEGER, INTENT(IN) :: COMPLETIONS(MAXPRDS)
      REAL, INTENT(OUT) :: TRENDANALYSIS(10)
      
      INTEGER :: I, J
      REAL :: CORRELATION, SUMXY, SUMX, SUMY, SUMX2, SUMY2
      REAL :: N
      
      N = REAL(NPRDS)
      SUMXY = 0.0
      SUMX = 0.0
      SUMY = 0.0
      SUMX2 = 0.0
      SUMY2 = 0.0
      
C     Calculate correlation between priority and completion
      DO I = 1, NPRDS
         SUMX = SUMX + REAL(PRIORITIES(I))
         SUMY = SUMY + REAL(COMPLETIONS(I))
         SUMXY = SUMXY + REAL(PRIORITIES(I)) * REAL(COMPLETIONS(I))
         SUMX2 = SUMX2 + REAL(PRIORITIES(I))**2
         SUMY2 = SUMY2 + REAL(COMPLETIONS(I))**2
      END DO
      
      IF (N > 1.0) THEN
         CORRELATION = (N * SUMXY - SUMX * SUMY) / 
     &                 SQRT((N * SUMX2 - SUMX**2) * 
     &                      (N * SUMY2 - SUMY**2))
      ELSE
         CORRELATION = 0.0
      END IF
      
      TRENDANALYSIS(1) = CORRELATION
      
      WRITE(*,*) ''
      WRITE(*,*) 'Mathematical Modeling Results:'
      WRITE(*,100) '  Priority-Completion Correlation: ', CORRELATION
      
100   FORMAT(A, F8.4)
      RETURN
      END SUBROUTINE MATHEMATICALMODELING

C     Subroutine for performance metrics
      SUBROUTINE PERFORMANCEMETRICS(NPRDS, COMPLETIONS, STATUSES,
     &                              PRODUCTIVITYINDEX)
      IMPLICIT NONE
      INTEGER, PARAMETER :: MAXPRDS = 1000
      INTEGER, INTENT(IN) :: NPRDS
      INTEGER, INTENT(IN) :: COMPLETIONS(MAXPRDS)
      INTEGER, INTENT(IN) :: STATUSES(MAXPRDS)
      REAL, INTENT(IN) :: PRODUCTIVITYINDEX
      
      INTEGER :: I, IMPLEMENTEDCOUNT
      REAL :: IMPLEMENTATIONRATE, EFFICIENCY
      
      IMPLEMENTEDCOUNT = 0
      
      DO I = 1, NPRDS
         IF (STATUSES(I) == 5) THEN  ! IMPLEMENTED
            IMPLEMENTEDCOUNT = IMPLEMENTEDCOUNT + 1
         END IF
      END DO
      
      IF (NPRDS > 0) THEN
         IMPLEMENTATIONRATE = REAL(IMPLEMENTEDCOUNT) / REAL(NPRDS) * 
     &                        100.0
      ELSE
         IMPLEMENTATIONRATE = 0.0
      END IF
      
      EFFICIENCY = PRODUCTIVITYINDEX / 100.0
      
      WRITE(*,*) ''
      WRITE(*,*) 'Performance Metrics:'
      WRITE(*,100) '  Implementation Rate: ', IMPLEMENTATIONRATE, '%'
      WRITE(*,200) '  System Efficiency: ', EFFICIENCY
      
100   FORMAT(A, F8.2, A)
200   FORMAT(A, F8.4)
      RETURN
      END SUBROUTINE PERFORMANCEMETRICS

C     Subroutine to export results
      SUBROUTINE EXPORTRESULTS(NPRDS, PRDIDS, TITLES, DESCRIPTIONS,
     &                         AUTHORS, STATUSES, PRIORITIES,
     &                         COMPLETIONS, STATUSNAMES, PRIORITYNAMES)
      IMPLICIT NONE
      INTEGER, PARAMETER :: MAXPRDS = 1000
      INTEGER, PARAMETER :: MAXSTRING = 200
      INTEGER, PARAMETER :: MAXAUTHOR = 50
      INTEGER, PARAMETER :: MAXTITLE = 100
      
      INTEGER, INTENT(IN) :: NPRDS
      CHARACTER(LEN=20), INTENT(IN) :: PRDIDS(MAXPRDS)
      CHARACTER(LEN=MAXTITLE), INTENT(IN) :: TITLES(MAXPRDS)
      CHARACTER(LEN=MAXSTRING), INTENT(IN) :: DESCRIPTIONS(MAXPRDS)
      CHARACTER(LEN=MAXAUTHOR), INTENT(IN) :: AUTHORS(MAXPRDS)
      INTEGER, INTENT(IN) :: STATUSES(MAXPRDS)
      INTEGER, INTENT(IN) :: PRIORITIES(MAXPRDS)
      INTEGER, INTENT(IN) :: COMPLETIONS(MAXPRDS)
      CHARACTER(LEN=15), INTENT(IN) :: STATUSNAMES(0:6)
      CHARACTER(LEN=10), INTENT(IN) :: PRIORITYNAMES(1:4)
      
      INTEGER :: I
      
      WRITE(*,*) ''
      WRITE(*,*) 'Exporting PRD data to FORTRAN binary format...'
      
      OPEN(UNIT=10, FILE='PRD_DATA.DAT', FORM='UNFORMATTED',
     &     STATUS='REPLACE')
      
      WRITE(10) NPRDS
      
      DO I = 1, NPRDS
         WRITE(10) PRDIDS(I), TITLES(I), DESCRIPTIONS(I),
     &             AUTHORS(I), STATUSES(I), PRIORITIES(I),
     &             COMPLETIONS(I)
      END DO
      
      CLOSE(10)
      
      WRITE(*,*) 'Export completed: PRD_DATA.DAT'
      WRITE(*,100) 'Exported ', NPRDS, ' PRD records'
      
100   FORMAT(A, I0, A)
      RETURN
      END SUBROUTINE EXPORTRESULTS
