# Telemetry Evaluator Skill

Stateless tool for evaluating telemetry data against success criteria rules.

## Description
This skill encapsulates the recursive logic for evaluating complex success criteria (AND, OR, Thresholds, Matches) against raw telemetry values.

## Interface
- **Tool Name:** `evaluate_telemetry`
- **Inputs:**
    - `criteria`: JSON - Success criteria object (supports nested logic).
    - `value`: any - The telemetry value to evaluate.
    - `dataType`: string - The data type of the telemetry (`STRING`, `NUMBER`, `BOOLEAN`, etc).
- **Logic Rule:** Inherits logic definitions from `.agent/rules/telemetry-logic.json`.

## Usage
Used by the Telemetry Engine during batch or individual attribute evaluation. It supports recursive callback for composite criteria.
