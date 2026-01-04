---
name: interview
description: Deep interview skill for thoroughly understanding a topic before planning. Use when the user invokes /interview or asks to be interviewed about an idea, feature, app, website, or any topic before implementation planning. Conducts challenging, non-obvious questioning using AskUserQuestion to uncover requirements, constraints, edge cases, and assumptions before producing a written plan.
---

# Interview

Conduct a thorough, challenging interview to fully understand a topic before planning. Use AskUserQuestion repeatedly until all key dimensions are covered, then produce a written plan.

## Interview Process

1. **Start broad, go deep** - Begin with the core concept, then probe specific dimensions
2. **Challenge assumptions** - Ask uncomfortable questions that expose weak thinking
3. **Adapt batch size** - Use 1-2 questions for complex topics needing depth, 3-4 for faster coverage
4. **Continue until coverage** - Interview is complete when all relevant dimensions are explored

## Dimensions to Cover

Select relevant dimensions based on the topic:

**Product/Feature**
- Core problem being solved (and why existing solutions fail)
- Target users and their actual behavior (not idealized)
- Success criteria and failure modes
- Scope boundaries (what's explicitly OUT)

**Technical**
- Platform constraints and dependencies
- Data model and state management
- Integration points and APIs
- Performance requirements and scale

**UX/Design**
- User mental models and expectations
- Error states and edge cases
- Accessibility requirements
- Mobile/responsive considerations

**Business/Constraints**
- Timeline and resource constraints
- Must-have vs nice-to-have
- Risks and mitigation strategies
- Maintenance and evolution

## Question Style

Ask non-obvious questions that:
- Expose unstated assumptions ("What happens when X fails?")
- Force prioritization ("If you could only ship one feature, which?")
- Reveal edge cases ("How does this work for users who...")
- Challenge scope ("Why include X but not Y?")
- Probe deeper ("You said X - what specifically do you mean?")

Avoid obvious questions like "What colors do you want?" or "Should it have a login?"

## Completion

The interview is complete when:
- Core problem and solution are clearly understood
- Key technical decisions are identified
- Scope boundaries are defined
- Major risks and edge cases are surfaced

## Output

After interviewing, produce a written plan that includes:
- Problem statement
- Proposed solution with key decisions
- Scope (in and out)
- Technical approach
- Open questions or risks
