(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-SPOT-UNAVAILABLE (err u2))
(define-constant ERR-INVALID-PARAMS (err u3))
(define-constant ERR-RESERVATION-EXPIRED (err u4))

;; Parking spot metadata
(define-map parking-spots 
  { spot-id: uint }
  { 
    is-available: bool,
    reserved-by: (optional principal),
    reservation-time: (optional uint),
    reservation-duration: (optional uint)
  }
)

;; Parking fee configuration
(define-map parking-fees 
  { duration: uint }
  { fee: uint }
)

;; Initialize parking fees
(define-public (set-parking-fees)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (map-set parking-fees { duration: u30 } { fee: u5 })
    (map-set parking-fees { duration: u60 } { fee: u8 })
    (map-set parking-fees { duration: u120 } { fee: u12 })
    (ok true)
  )
)

;; Initialize a parking spot with advanced validation
(define-public (initialize-spot 
  (spot-id uint) 
  (max-reservation-duration uint)
)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (> max-reservation-duration u0) ERR-INVALID-PARAMS)
    (map-set parking-spots 
      { spot-id: spot-id }
      { 
        is-available: true, 
        reserved-by: none, 
        reservation-time: none,
        reservation-duration: (some max-reservation-duration)
      }
    )
    (ok true)
  )
)

;; Advanced spot reservation with fee calculation
(define-public (reserve-spot 
  (spot-id uint) 
  (reservation-duration uint)
)
  (let 
    ((spot (unwrap! 
      (map-get? parking-spots { spot-id: spot-id }) 
      ERR-SPOT-UNAVAILABLE))
     (current-time block-height)
     (max-duration (unwrap! (get reservation-duration spot) ERR-INVALID-PARAMS))
     (parking-fee (unwrap! 
       (map-get? parking-fees { duration: reservation-duration }) 
       ERR-INVALID-PARAMS))
    )
    (asserts! (get is-available spot) ERR-SPOT-UNAVAILABLE)
    (asserts! (<= reservation-duration max-duration) ERR-INVALID-PARAMS)
    
    (map-set parking-spots 
      { spot-id: spot-id }
      { 
        is-available: false, 
        reserved-by: (some tx-sender), 
        reservation-time: (some current-time),
        reservation-duration: (some reservation-duration)
      }
    )
    (ok parking-fee)
  )
)

;; Release parking spot after reservation
(define-public (release-spot (spot-id uint))
  (let 
    ((spot (unwrap! 
      (map-get? parking-spots { spot-id: spot-id }) 
      ERR-SPOT-UNAVAILABLE))
     (current-time block-height)
    )
    (asserts! 
      (is-eq (unwrap! (get reserved-by spot) ERR-SPOT-UNAVAILABLE) tx-sender) 
      ERR-UNAUTHORIZED
    )
    (map-set parking-spots 
      { spot-id: spot-id }
      { 
        is-available: true, 
        reserved-by: none, 
        reservation-time: none,
        reservation-duration: (get reservation-duration spot)
      }
    )
    (ok true)
  )
)
