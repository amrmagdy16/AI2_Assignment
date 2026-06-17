;; ============================================================
;; D4-V4  Search & Rescue - Heterogeneous Sensing
;; Q1  Basic classical PDDL model  (run with BFWS)
;; ------------------------------------------------------------
;; A team of rescue robots searches a building (graph of rooms).
;; Each robot carries a DIFFERENT subset of sensors:
;;   - thermal : finds a heat signature  -> (detected ?v)
;;   - visual  : confirms it is a victim -> (identified ?v)
;;   - gas     : sweeps a room for hazard -> (gas-checked ?l)
;; No single robot has every sensor, so the robots must
;; cooperate: the right sensor has to be brought to the right
;; room before a victim can be rescued. This is the whole point
;; of the assignment - sensing capability constrains the plan.
;; ============================================================

(define (domain sar-heterogeneous-sensing)

  (:requirements :strips :typing)

  (:types
    robot location victim - object
  )

  (:predicates
    ;; --- world / topology ---
    (at ?r - robot ?l - location)            ; robot position
    (adjacent ?l1 - location ?l2 - location) ; map edge (declare BOTH directions)
    (victim-in ?v - victim ?l - location)    ; ground-truth victim position

    ;; --- sensor capabilities (heterogeneous!) ---
    (has-thermal ?r - robot)
    (has-visual  ?r - robot)
    (has-gas     ?r - robot)

    ;; --- knowledge produced by sensing (the "belief") ---
    (detected   ?v - victim)     ; a heat signature was picked up
    (identified ?v - victim)     ; visually confirmed to be a victim
    (gas-checked ?l - location)  ; room swept and declared safe to enter

    ;; --- goal predicate ---
    (rescued ?v - victim)
  )

  ;; ----- navigation -----
  (:action move
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and (at ?r ?from) (adjacent ?from ?to))
    :effect (and (not (at ?r ?from)) (at ?r ?to))
  )

  ;; ----- thermal sensing: produces a "detection" -----
  (:action thermal-scan
    :parameters (?r - robot ?v - victim ?l - location)
    :precondition (and (at ?r ?l) (has-thermal ?r) (victim-in ?v ?l))
    :effect (and (detected ?v))
  )

  ;; ----- visual sensing: upgrades a detection to an identification -----
  (:action visual-identify
    :parameters (?r - robot ?v - victim ?l - location)
    :precondition (and (at ?r ?l) (has-visual ?r) (victim-in ?v ?l) (detected ?v))
    :effect (and (identified ?v))
  )

  ;; ----- gas sensing: clears the room for entry -----
  (:action gas-sweep
    :parameters (?r - robot ?l - location)
    :precondition (and (at ?r ?l) (has-gas ?r))
    :effect (and (gas-checked ?l))
  )

  ;; ----- rescue: any robot can extract, but only AFTER the full
  ;;       heterogeneous sensing chain has been completed -----
  (:action rescue
    :parameters (?r - robot ?v - victim ?l - location)
    :precondition (and (at ?r ?l)
                       (victim-in ?v ?l)
                       (identified ?v)
                       (gas-checked ?l))
    :effect (and (rescued ?v))
  )
)
