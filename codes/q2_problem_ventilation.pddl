;; ============================================================
;; Q2 - PROBLEM A : "the room must be made safe before entry"
;; roomA holds residual gas (level 6 > the safe-rescue limit of 5)
;; but no active source. The gas robot must sweep the room and
;; switch on the extractor; the ventilation PROCESS then lowers the
;; level over TIME. The planner is forced to let time pass (wait)
;; until (gas-level roomA) < 5 before it can rescue - a clean
;; demonstration that "doing nothing" is now a deliberate choice
;; with an effect. No source, so the lethal event never fires.
;;
;; Heterogeneous robots: thermalbot / visualbot / gasbot (one sensor each).
;; ============================================================

(define (problem sar-dyn-A)
  (:domain sar-sensing-dynamic-gas)

  (:objects
    thermalbot visualbot gasbot   - robot
    entrance hallway roomA        - location
    v1                            - victim
  )

  (:init
    (at thermalbot entrance)
    (at visualbot  entrance)
    (at gasbot     entrance)

    (adjacent entrance hallway) (adjacent hallway entrance)
    (adjacent hallway roomA)    (adjacent roomA hallway)

    (victim-in v1 roomA)
    (alive v1)

    (has-thermal thermalbot)
    (has-visual  visualbot)
    (has-gas     gasbot)

    ;; --- gas state: every location's fluent MUST be initialised ---
    (= (gas-level entrance) 0)
    (= (gas-level hallway)  0)
    (= (gas-level roomA)    6)     ; residual gas, above safe limit

    ;; no active sources anywhere (clean flags let the spread event exist but it won't fire)
    (no-gas-source entrance)
    (no-gas-source hallway)
    (no-gas-source roomA)
  )

  (:goal (and (rescued v1)))

  (:metric minimize (total-time))
)
