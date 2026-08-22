# Impact

For each mapped symbol: what breaks when it changes, how badly, and in what order to update things.

| Symbol | Depends on (d=1) | Dependents (d=1) | Risk | Update order |
| --- | --- | --- | --- | --- |
| <!-- `checkout()` | `cart.total()` [verified], `stock.reserve()` [inferred] | `router` [verified] | HIGH | interface -> implementation -> callers -> tests --> |

Risk levels:

- LOW: internal helper, single caller, covered by tests
- MED: multiple callers within one module, partial test cover
- HIGH: cross-module callers, or on a critical path (payment, auth, data migration, startup)
- CRITICAL: public API or route with unknown external consumers
- UNKNOWN: not mapped yet; treat as HIGH until completed

Update order is interface -> implementation -> callers -> tests unless the symbol's card says otherwise.
