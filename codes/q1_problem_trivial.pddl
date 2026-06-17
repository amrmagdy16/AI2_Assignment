;; ============================================================
;; Q1 - PROBLEM A : "sensing is trivial"
;; One robot that happens to carry ALL THREE sensors, one victim.
;; Sensing still imposes an ORDER (thermal -> visual -> gas-check
;; -> rescue) but it requires NO coordination, because a single
;; agent can do everything. Use this to show the baseline chain.
;; Expected plan length: 5 actions.
;; ============================================================

(define (problem sar-trivial)
  (:domain sar-heterogeneous-sensing)

  (:objects
    r1                  - robot
    entrance roomA      - location
    v1                  - victim
  )

  (:init
    (at r1 entrance)
    (adjacent entrance roomA) (adjacent roomA entrance)
    (victim-in v1 roomA)
    ;; r1 is fully equipped
    (has-thermal r1) (has-visual r1) (has-gas r1)
  )

  (:goal (and (rescued v1)))
)
