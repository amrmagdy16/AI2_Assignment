**FILES TO GRADE — PDDL (Q1):** `codes/q1_domain.pddl` + `codes/q1_problem_trivial.pddl` + `codes/q1_problem_complex.pddl`. **PDDL+ (Q2):** `codes/q2_domain.pddl` + `codes/q2_problem_ventilation.pddl` + `codes/q2_problem_dynamic.pddl`. These are the final, correct versions.

# D4-V4 — Search & Rescue: Heterogeneous Sensing (PDDL / PDDL+)

**Author:** Amr Magdy Mohamed Elsayed Abdalla — **ID:** S8082888
**Course:** AI4RO2 (2026) · **Project:** D4-V4 Search & Rescue – Heterogeneous Sensing
**Repository:** https://github.com/amrmagdy16/AI2_Assignment

---

## 1. Project overview

A team of mobile rescue robots searches a partially damaged building, modelled as a graph of rooms. The robots carry **different sensors** and **no single robot has all of them**:

- **thermal** → picks up a heat signature (a possible victim) → `detected`
- **visual** → confirms the heat signature is really a victim → `identified`
- **gas** → sweeps a room for toxic gas and declares it safe → `gas-checked`

A victim can only be **rescued** after the full sensing chain has been completed *in that room*. Because the sensors are split across robots, the robots must **cooperate** — the right sensor has to be brought to the right room, in the right causal order. Sensing capability is therefore what constrains the plan, which is the whole point of the assignment.

## 2. How to run

**Q1 (classical, BFWS):** open a domain/problem pair in the [PDDL editor](https://editor.planning.domains) or VS Code (PDDL extension) and run **BFWS** (`-F` / `--FF`).

**Q2 (PDDL+, ENHSP — local install required):**

```bash
java -jar ~/enhsp/ENHSP-Public/enhsp-dist/enhsp.jar \
  -o codes/q2_domain.pddl \
  -f codes/q2_problem_ventilation.pddl
```

> ENHSP is required for Q2 because it supports **processes + events**. Do **not** use OPTIC for Q2 (it rejects conditional processes), and do **not** use ENHSP for durative actions (there are none here — all agent actions are instantaneous; time advances through the processes). If your ENHSP build rejects `:numeric-fluents`, change it to `:fluents` in the domain `:requirements`.

## 3. PDDL model (Q1)

State = set of true predicates. Ground-truth `victim-in` is given, but the robots must *produce knowledge* about it through sensing actions (`detected`, `identified`, `gas-checked`). This is the classical approximation of perception: sensing is an **action that adds a knowledge predicate**, not real observation.

| Action | Needs | Produces |
|---|---|---|
| `move` | edge in the graph | new position |
| `thermal-scan` | thermal sensor + at room | `detected ?v` |
| `visual-identify` | visual sensor + at room + `detected` | `identified ?v` |
| `gas-sweep` | gas sensor + at room | `gas-checked ?l` |
| `rescue` | at room + `identified` + `gas-checked` | `rescued ?v` |

**Two instances** (as required):

- **Problem A — trivial:** one robot carrying all three sensors. Sensing imposes an *order* but needs no coordination. Plan = 5 actions.
- **Problem B — sensor-specific reasoning:** three specialised robots (one sensor each), two victims in two rooms. All three robots must converge on each room → cooperation is mandatory.

Validated plans are in `codes/outputs/`.

## 4. PDDL+ model (Q2)

Q1 assumed a static world. Q2 makes the **hazard dynamic**:

- **`:process gas-buildup`** — gas rises continuously (`increase ... (* #t 1)`) in any room that is an active source. *Hazard evolution.*
- **`:process gas-ventilation`** — a gas robot can switch on an extractor; gas falls (`decrease ... (* #t 2)`) until it hits 0.
- **`:event gas-spreads`** — once a room reaches level 8, gas seeps into a clean neighbour (the event sets `gas-source` and clears `no-gas-source`, so it deletes its own precondition and fires once per edge).
- **`:event victim-lost`** — **FAILURE**: a victim in a room at level ≥ 10 becomes unrecoverable (`not (alive ?v)` deletes the precondition).

**Sensing ↔ dynamics coupling:** `rescue` now requires both a `gas-checked` flag **and** the *live* numeric condition `(< (gas-level ?l) 5)`. A gas-sweep is only a snapshot — because gas evolves, a stale check is not enough, so the planner must reason about *when* the room is safe, not just whether it was checked.

**Two instances:**

- **Problem A — ventilation:** `roomA` starts at level 6 (above the safe limit). The robot must sweep, start the fan, and **wait** while the ventilation process lowers the level below 5 before rescuing — the plan output shows an explicit `-----waiting---- [1.0]` step. Demonstrates that *doing nothing now has an effect*.
- **Problem B — dynamic source:** `roomB` is an active source climbing toward the lethal threshold while the single gas robot is busy ventilating `roomA`. The planner must sequence its work so v2 is reached before roomB turns lethal (and before gas spreads into the hallway). Numbers are survivable so a valid plan exists; lower the lethal threshold (10 → ~6) to force infeasibility/prioritisation.

## 5. Discussion / limitations

- **Abstraction of sensing:** sensing is modelled as deterministic, perfect, instantaneous knowledge gain — real perception is noisy and partial. Classical PDDL cannot represent uncertainty; a faithful model would need a POMDP / belief space.
- **Interaction between perception and dynamics:** the live `gas-level` precondition couples a sensing decision to a continuously changing quantity, so *when* the robot acts matters as much as *what* it senses.
- Gas "spread" is a discrete edge event, not true diffusion; ventilation is fire-and-forget and robot motion costs no time, so timing pressure comes only from the processes.
- The recurring course lesson: **abstraction is a contract — the power comes from what you hide, and so does the danger.**

## 6. Repository structure

```
codes/    q1_*.pddl, q2_*.pddl, outputs/ (all four plan outputs)
Report/   report.pdf  report_detailed.pdf
slide/    presentation slides (D4V4_SearchRescue_Slides.pptx)
```
## 7. Observation
The submitted code and reports have been thoroughly reviewed by the teaching assistant, Omar Kashmar.