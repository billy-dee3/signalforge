;; ============================================================
;; Contract: signalforge.clar
;; Purpose : Decentralized on-chain feature flag controller
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------
(define-constant ERR-NOT-AUTHORIZED (err u7001))
(define-constant ERR-FEATURE-NOT-FOUND (err u7002))

;; -------------------------
;; CONSTANTS
;; -------------------------
(define-constant contract-owner tx-sender)

;; -------------------------
;; FEATURE STORAGE
;; -------------------------

;; Each feature has:
;; - enabled: bool
(define-map feature-flags
  { feature: (string-ascii 32) }
  { enabled: bool }
)

;; -------------------------
;; AUTHORIZATION
;; -------------------------

(define-read-only (is-authorized)
  (is-eq tx-sender contract-owner)
)

;; -------------------------
;; FEATURE MANAGEMENT
;; -------------------------

(define-public (set-feature
  (feature (string-ascii 32))
  (enabled bool)
)
  (begin
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)

    (map-set feature-flags
      { feature: feature }
      { enabled: enabled }
    )

    (ok enabled)
  )
)

(define-public (remove-feature
  (feature (string-ascii 32))
)
  (begin
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)
    (map-delete feature-flags { feature: feature })
    (ok true)
  )
)

;; -------------------------
;; READ INTERFACE (CRITICAL)
;; -------------------------

(define-read-only (feature-enabled?
  (feature (string-ascii 32))
)
  (match (map-get? feature-flags { feature: feature })
    flag (get enabled flag)
    false
  )
)

(define-read-only (feature-info
  (feature (string-ascii 32))
)
  (match (map-get? feature-flags { feature: feature })
    flag (ok flag)
    ERR-FEATURE-NOT-FOUND
  )
)
