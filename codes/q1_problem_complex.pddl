;; ============================================================
;; Q1 - PROBLEM B : "sensor-specific reasoning is required"
;; Three SPECIALISED robots - no robot owns more than one sensor:
;;   thermalbot : thermal only
;;   visualbot  : visual  only
;;   gasbot     : gas     only
;; Two victims in two different rooms. To rescue EITHER victim,
;; all three specialised robots must converge on that room (in the
;; right causal order). The planner is forced to reason about
;; WHICH robot must go WHERE - the heterogeneous-sensing core of
;; the assignment. Cooperation is mandatory; no single robot can
;; complete the chain alone.
;; ============================================================

(define (problem sar-heterogeneous)
  (:domain sar-heterogeneous-sensing)

  (:objects
    thermalbot visualbot gasbot       - robot
    entrance hallway roomA roomB      - location
    v1 v2                             - victim
  )

  (:init
    ;; all robots start at the entrance
    (at thermalbot entrance)
    (at visualbot  entrance)
    (at gasbot     entrance)

    ;; map:  entrance - hallway - roomA
    ;;                         \- roomB
    (adjacent entrance hallway) (adjacent hallway entrance)
    (adjacent hallway roomA)    (adjacent roomA hallway)
    (adjacent hallway roomB)    (adjacent roomB hallway)

    ;; victims
    (victim-in v1 roomA)
    (victim-in v2 roomB)

    ;; HETEROGENEOUS sensors - one each, no overlap
    (has-thermal thermalbot)
    (has-visual  visualbot)
    (has-gas     gasbot)
  )

  (:goal (and (rescued v1) (rescued v2)))
)
