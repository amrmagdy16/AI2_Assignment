;; ============================================================
;; D4-V4  Search & Rescue - Heterogeneous Sensing
;; Q2  PDDL+ model  (run with ENHSP)
;; ------------------------------------------------------------
;; Q1 treated the world as static. Here the HAZARD IS DYNAMIC:
;; toxic gas builds up continuously, spreads to neighbouring
;; rooms, and can kill a victim if it crosses a lethal threshold.
;;
;;   PROCESS  gas-buildup     : gas rises over time in a gassy room
;;   PROCESS  gas-ventilation : a gas robot can pump gas back out
;;   EVENT    gas-spreads     : gas seeps into a clean neighbour
;;   EVENT    victim-lost     : a victim in a lethal room is lost  (FAILURE)
;;
;; The heterogeneous sensing chain (thermal -> visual) is kept
;; from Q1. The gas sensor now has a DYNAMIC role: a stale
;; gas-sweep is not enough - rescue also requires the LIVE gas
;; level to be below a safe value, so the planner must reason
;; about WHEN the room is safe, not just whether it was checked.
;; ============================================================

(define (domain sar-sensing-dynamic-gas)

  ;; NOTE: if your ENHSP build rejects :numeric-fluents, replace it with :fluents
  (:requirements :strips :typing :numeric-fluents :time)

  (:types
    robot location victim - object
  )

  (:predicates
    (at ?r - robot ?l - location)
    (adjacent ?l1 - location ?l2 - location)
    (victim-in ?v - victim ?l - location)

    (has-thermal ?r - robot)
    (has-visual  ?r - robot)
    (has-gas     ?r - robot)

    (detected   ?v - victim)
    (identified ?v - victim)
    (gas-checked ?l - location)
    (rescued ?v - victim)

    (alive ?v - victim)            ; victim still recoverable
    (gas-source   ?l - location)   ; room is actively producing gas
    (no-gas-source ?l - location)  ; explicit "clean" flag (lets the spread event fire once)
    (venting ?l - location)        ; extractor fan running in this room
  )

  (:functions
    (gas-level ?l - location)      ; current gas concentration in a room
  )

  ;; ---------------- discrete agent actions ----------------

  (:action move
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and (at ?r ?from) (adjacent ?from ?to))
    :effect (and (not (at ?r ?from)) (at ?r ?to))
  )

  (:action thermal-scan
    :parameters (?r - robot ?v - victim ?l - location)
    :precondition (and (at ?r ?l) (has-thermal ?r) (victim-in ?v ?l) (alive ?v))
    :effect (and (detected ?v))
  )

  (:action visual-identify
    :parameters (?r - robot ?v - victim ?l - location)
    :precondition (and (at ?r ?l) (has-visual ?r) (victim-in ?v ?l)
                       (detected ?v) (alive ?v))
    :effect (and (identified ?v))
  )

  (:action gas-sweep
    :parameters (?r - robot ?l - location)
    :precondition (and (at ?r ?l) (has-gas ?r))
    :effect (and (gas-checked ?l))
  )

  ;; gas robot switches on an extractor fan (starts the ventilation process)
  (:action start-ventilation
    :parameters (?r - robot ?l - location)
    :precondition (and (at ?r ?l) (has-gas ?r) (gas-checked ?l))
    :effect (and (venting ?l))
  )

  ;; rescue needs: identified victim + a gas-check + victim alive +
  ;; the LIVE gas level currently safe (< 5). The numeric precondition
  ;; is what ties the decision to the continuous hazard.
  (:action rescue
    :parameters (?r - robot ?v - victim ?l - location)
    :precondition (and (at ?r ?l)
                       (victim-in ?v ?l)
                       (identified ?v)
                       (gas-checked ?l)
                       (alive ?v)
                       (< (gas-level ?l) 5))
    :effect (and (rescued ?v) (not (victim-in ?v ?l)))
  )

  ;; ---------------- continuous processes ----------------

  ;; gas keeps building while a room is an active source
  (:process gas-buildup
    :parameters (?l - location)
    :precondition (and (gas-source ?l))
    :effect (and (increase (gas-level ?l) (* #t 1)))
  )

  ;; ventilation removes gas while the fan is on (stops at 0)
  (:process gas-ventilation
    :parameters (?l - location)
    :precondition (and (venting ?l) (> (gas-level ?l) 0))
    :effect (and (decrease (gas-level ?l) (* #t 2)))
  )

  ;; ---------------- discrete events (world-driven) ----------------

  ;; gas seeps into a clean neighbour once a room is gassy enough.
  ;; Setting (gas-source ?l2) + removing (no-gas-source ?l2) deletes
  ;; this event's own precondition, so it fires at most once per edge.
  (:event gas-spreads
    :parameters (?l1 - location ?l2 - location)
    :precondition (and (adjacent ?l1 ?l2)
                       (>= (gas-level ?l1) 8)
                       (no-gas-source ?l2))
    :effect (and (gas-source ?l2) (not (no-gas-source ?l2)))
  )

  ;; FAILURE: a victim in a lethal room becomes unrecoverable.
  ;; (not (alive ?v)) deletes the event's own precondition.
  (:event victim-lost
    :parameters (?v - victim ?l - location)
    :precondition (and (victim-in ?v ?l) (alive ?v) (>= (gas-level ?l) 10))
    :effect (and (not (alive ?v)))
  )
)
