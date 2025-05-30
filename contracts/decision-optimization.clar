;; Decision Optimization Contract
;; Enhances legal decision quality through consciousness analysis

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u400))
(define-constant err-not-found (err u401))
(define-constant err-invalid-decision (err u402))

;; Decision structure
(define-map legal-decisions
  { decision-id: uint }
  {
    case-id: uint,
    decision-text: (string-ascii 1000),
    consciousness-factors: (list 10 uint),
    optimization-score: uint,
    fairness-index: uint,
    stakeholder-impact: uint,
    decided-by: principal,
    decided-at: uint,
    status: (string-ascii 20)
  }
)

(define-data-var next-decision-id uint u1)

;; Create a legal decision
(define-public (create-decision
  (case-id uint)
  (decision-text (string-ascii 1000))
  (consciousness-factors (list 10 uint))
  (stakeholder-impact uint)
)
  (let ((decision-id (var-get next-decision-id)))
    (map-set legal-decisions
      { decision-id: decision-id }
      {
        case-id: case-id,
        decision-text: decision-text,
        consciousness-factors: consciousness-factors,
        optimization-score: u0,
        fairness-index: u0,
        stakeholder-impact: stakeholder-impact,
        decided-by: tx-sender,
        decided-at: block-height,
        status: "draft"
      }
    )
    (var-set next-decision-id (+ decision-id u1))
    (ok decision-id)
  )
)

;; Optimize decision quality
(define-public (optimize-decision (decision-id uint) (optimization-score uint) (fairness-index uint))
  (let ((decision (unwrap! (map-get? legal-decisions { decision-id: decision-id }) err-not-found)))
    (map-set legal-decisions
      { decision-id: decision-id }
      (merge decision {
        optimization-score: optimization-score,
        fairness-index: fairness-index,
        status: "optimized"
      })
    )
    (ok true)
  )
)

;; Finalize decision
(define-public (finalize-decision (decision-id uint))
  (let ((decision (unwrap! (map-get? legal-decisions { decision-id: decision-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get decided-by decision)) err-owner-only)
    (map-set legal-decisions
      { decision-id: decision-id }
      (merge decision {
        status: "final"
      })
    )
    (ok true)
  )
)

;; Get decision information
(define-read-only (get-decision (decision-id uint))
  (map-get? legal-decisions { decision-id: decision-id })
)

;; Calculate overall decision quality
(define-read-only (calculate-decision-quality (decision-id uint))
  (match (map-get? legal-decisions { decision-id: decision-id })
    decision
    (let ((opt-score (get optimization-score decision))
          (fairness (get fairness-index decision))
          (impact (get stakeholder-impact decision)))
      (some (/ (+ opt-score fairness impact) u3))
    )
    none
  )
)
