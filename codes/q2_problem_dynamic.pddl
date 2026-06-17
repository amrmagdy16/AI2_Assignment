;; ============================================================
;; Q2 - PROBLEM B : "the hazard evolves while you work"
;; Two victims. roomB contains an ACTIVE gas source, so its level
;; climbs at +1/time-unit from 0. Meanwhile roomA holds residual
;; gas (6) that must be ventilated down, which forces time to pass.
;; While the single gas robot is busy making roomA safe, roomB
;; keeps getting worse:
;;   - at level 8  the gas-spreads EVENT seeps gas into the hallway
;;   - at level 10 the victim-lost EVENT would kill v2 (FAILURE)
;; The planner must therefore SEQUENCE its sensing/rescue work so
;; that v2 is reached before roomB turns lethal - sensing decisions
;; and hazard dynamics are now coupled.
;;
;; (Numbers are deliberately survivable so a valid plan exists. To
;;  see infeasibility / forced prioritisation, lower the lethal
;;  threshold in the domain from 10 to ~6, or raise the buildup rate.)
;; ============================================================

(define (problem sar-dyn-B)
  (:domain sar-sensing-dynamic-gas)

  (:objects
    thermalbot visualbot gasbot        - robot
    entrance hallway roomA roomB       - location
    v1 v2                              - victim
  )

  (:init
    (at thermalbot entrance)
    (at visualbot  entrance)
    (at gasbot     entrance)

    ;;  entrance - hallway - roomA
    ;;                    \- roomB (gas source)
    (adjacent entrance hallway) (adjacent hallway entrance)
    (adjacent hallway roomA)    (adjacent roomA hallway)
    (adjacent hallway roomB)    (adjacent roomB hallway)

    (victim-in v1 roomA) (alive v1)
    (victim-in v2 roomB) (alive v2)

    (has-thermal thermalbot)
    (has-visual  visualbot)
    (has-gas     gasbot)

    ;; --- gas state ---
    (= (gas-level entrance) 0)
    (= (gas-level hallway)  0)
    (= (gas-level roomA)    6)     ; residual, needs ventilation
    (= (gas-level roomB)    0)     ; starts clean but...

    (gas-source roomB)             ; ...roomB is an active source -> rises over time

    (no-gas-source entrance)
    (no-gas-source hallway)
    (no-gas-source roomA)
    ;; NOTE: roomB is a source, so it gets NO no-gas-source flag
  )

  (:goal (and (rescued v1) (rescued v2)))

  (:metric minimize (total-time))
)
