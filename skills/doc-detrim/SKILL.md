---
name: doc-detrim
description: Audit agent-written documentation (CLAUDE.md, SKILL.md, README, agent memory) for bloat and propose trims. Use when the user says "trim this doc", "audit doc bloat", "this is over-explained", or hands over an agent-written doc that reads as bloated or defensive.
argument-hint: "[doc files to trim]"
disable-model-invocation: true
---

$ARGUMENTS
Audit this doc for over-description. The reader is a capable agent that can reason from naming and read referenced code. Flag and propose to trim: rationale repeated >1×; rules / tag-sets / lists restated across sections; justifying parentheticals after self-evident statements; defensive prose against dead or hypothetical workflows; behavior the code self-documents; symbol explanations the naming makes obvious. Bias toward trimming — keep only what changes behavior or removes real ambiguity.
