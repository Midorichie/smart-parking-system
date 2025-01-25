;; Parking Management Contract Tests

(use-trait parking-management-trait .parking-management.parking-management-trait)

(define-public (test-initialize-spot)
  (let 
    ((spot-id u1))
    (asserts! 
      (is-ok (contract-call? .parking-management initialize-spot spot-id))
      (err "Failed to initialize parking spot")
    )
    (ok true)
  )
)

(define-public (test-reserve-spot)
  (let 
    ((spot-id u1))
    ;; Initialize spot first
    (try! (contract-call? .parking-management initialize-spot spot-id))
    
    ;; Attempt reservation
    (asserts! 
      (is-ok (contract-call? .parking-management reserve-spot spot-id))
      (err "Failed to reserve parking spot")
    )
    (ok true)
  )
)

(define-public (test-unauthorized-initialization)
  (let 
    ((spot-id u1))
    (asserts! 
      (is-err (contract-call? .parking-management initialize-spot spot-id))
      (err "Unauthorized initialization should fail")
    )
    (ok true)
  )
)
