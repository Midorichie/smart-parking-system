;; Parking Management Smart Contract

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-SPOT-UNAVAILABLE (err u2))

;; Parking spot structure
(define-map parking-spots 
  { spot-id: uint }
  { 
    is-available: bool,
    reserved-by: (optional principal),
    reservation-time: (optional uint)
  }
)

;; Initialize a parking spot
(define-public (initialize-spot (spot-id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (map-set parking-spots 
      { spot-id: spot-id }
      { 
        is-available: true, 
        reserved-by: none, 
        reservation-time: none 
      }
    )
    (ok true)
  )
)

;; Reserve a parking spot
(define-public (reserve-spot (spot-id uint))
  (let 
    ((spot (unwrap! (map-get? parking-spots { spot-id: spot-id }) ERR-SPOT-UNAVAILABLE))
     (current-time block-height)
    )
    (asserts! (get is-available spot) ERR-SPOT-UNAVAILABLE)
    (map-set parking-spots 
      { spot-id: spot-id }
      { 
        is-available: false, 
        reserved-by: (some tx-sender), 
        reservation-time: (some current-time) 
      }
    )
    (ok true)
  )
)
