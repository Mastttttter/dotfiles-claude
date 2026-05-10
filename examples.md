# Behavior Examples

<bad-example>
| function | cumtime | calls |
|---|---|---|
| read_csv | 4.2s `[verified: cprofile.txt L1]` | 1 `[verified: cprofile.txt L1]` |
| groupby | 2.1s `[verified: cprofile.txt L2]` | 12 `[verified: cprofile.txt L2]` |
| to_parquet | 0.8s `[verified: cprofile.txt L3]` | 1 `[verified: cprofile.txt L3]` |

`read_csv` dominates.
</bad-example>

<good-example>
| function | cumtime | calls |
|---|---|---|
| read_csv | 4.2s | 1 |
| groupby | 2.1s | 12 |
| to_parquet | 0.8s | 1 |

**What this means**

Hot spots from the profile run `[verified: cprofile.txt L1-L3]`. `read_csv` dominates `[opinion]`.
</good-example>

<bad-example>
| metric | reported  | after fix (projected) |
|--------|-----------|-----------------------|
| p99    | 240ms     | ~80ms                 |
| errors | 1.4%      | slightly different    |

The cache_keepalive change should close the connection-leak path and dramatically improve latency.
</bad-example>

<good-example>
| metric | reported | after fix (projected) |
|---|---|---|
| p99 | 240ms `[verified: load_test.json L8]` | ~80ms `[opinion]` |
| errors | 1.4% `[verified: load_test.json L12]` | unchanged direction `[opinion]` |

**Read**

The `cache_keepalive` change might close the connection-leak path `[opinion]`.

**Next**

Re-run the load test to confirm the projected p99 drop `[opinion]`. Go?
</good-example>

<bad-example>
<User>Please implement and run the 95 feature pipeline.</User>
Acknowledged. Writing the production pipeline now.
<Write>production_pipeline.py</Write>
Production pipeline written. Initial run will produce 95 feature columns. ETA ~30 min. Running the full pipeline now to get production data.
<Bash>uv run production_pipeline.py</Bash>
</bad-example>

<good-example>
<User>Please implement and run the 95 feature pipeline.</User>
Acknowledged. Writing the production pipeline now.
<Write>production_pipeline.py</Write>
Let me run a smoke test on a 1-day slice: 5200 rows × 95 feature columns. First query the latest available date in your data source:
<Bash>some-sql-tool --query "SELECT max(date) FROM some_table"</Bash>
The latest available date is 2026-04-01 `[verified: some-sql-tool output: "max(date) = 2026-04-01"]`. Running smoke test on that day.
<Bash>uv run production_pipeline.py --date 2026-04-01</Bash>
Smoke clean `[verified: production_pipeline.py --date 2026-04-01: exit 0, 5200 rows × 95 cols]`.

Initial run will produce 95 feature columns `[verified: production_pipeline.py L42: FEATURE_COLUMNS]`. ETA ~30 min `[opinion]`. Running the full pipeline now to get production data. This can be computation-intensive, so I will load the `/preflight-check` skill for guidance before running directly.
<Skill name="preflight-check" arg="uv run production_pipeline.py"></Skill>
</good-example>

<bad-example>
<Edit>src/rate_limiter.py</Edit>
<Bash>uv run pytest tests/test_rate_limiter.py</Bash>
Bumped retry budget from 3 to 5.
</bad-example>

<good-example>
<Edit>src/rate_limiter.py</Edit>
<Bash>uv run pytest tests/test_rate_limiter.py</Bash>
Bumped retry budget from 3 to 5 `[verified: test_rate_limiter.py 8/8 passing]`.

**Verification:** `uv run pytest tests/test_rate_limiter.py` → 8/8 passing.
</good-example>

<bad-example>
<Read>src/rate_limiter.py</Read>
Current retry budget is 5.

**Verification:** not run (read-only, no changes made).
</bad-example>

<bad-example>
<Read>src/rate_limiter.py</Read>
Current retry budget is 5 `[verified: rate_limiter.py L12: N_RETRY = 5]`.
</bad-example>

<good-example>
<Read>src/rate_limiter.py</Read>
Current retry budget is 5 `[verified: rate_limiter.py L12: N_RETRY = 5]`, applied across three callsites `[verified: rate_limiter.py L12, L48, L91]`, with one bypass case `[verified: rate_limiter.py L120]`.

**Sources:**
- rate_limiter.py L12: N_RETRY = 5 — locatable
- rate_limiter.py L48 — locatable
- rate_limiter.py L91 — locatable
- rate_limiter.py L120 — locatable
</good-example>

<bad-example>
(assistant mistakenly emitted no Read call, skipped the substrate check)
Retry budget is 5 `[verified: rate_limiter.py L12: N_RETRY = 5]`.
<User>You fabricated the `[verified: <source>]`?</User>
I apologize for the hallucinated cite. Let me read the actual file now.
<Read>src/rate_limiter.py</Read>
Retry budget is actually 3 `[verified: src/rate_limiter.py L8: N_RETRY = 3]` — prior claim was wrong.
</bad-example>

<good-example>
(assistant emitted no Read call yet)
Retry budget is 5 `[opinion]` — recalled from earlier context, not yet substrate-checked.

Before sending: my recall is unverified. Reading the file to upgrade or correct.
<Bash>rg -n "N_RETRY" src/rate_limiter.py</Bash>
Retry budget is actually 3 `[verified: src/rate_limiter.py L8: N_RETRY = 3]` — prior recall was wrong.
</good-example>
