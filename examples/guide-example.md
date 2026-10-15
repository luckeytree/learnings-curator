# Example guide: writing for customers

> An illustration of the shape, not a default. Nothing in `examples/` is loaded into your
> sessions. Your real guides live in `guides/` and come from your own syncs.

**Open this before** writing any words a customer will read: screens, emails, error messages,
help text.

- **Say what happened and what to do next.** "Your card was declined. Try another card or contact
  your bank." Not "An error occurred."
- **Write at the reader's level, not yours.** No internal names for features, teams, or systems.
- **Never promise something the product doesn't do.** If there's no undo, don't imply one.
- **Read it out loud once.** If you wouldn't say it to a person, rewrite it.

*Enforced by:* prose only.

---

Why this is a guide: all four only matter in one situation, and that
situation is easy to recognize. The global file carries one line pointing here:
`guides/customer-writing.md`: before any words a customer will read.

The *Enforced by:* line names what catches a miss: a hook, a check, an agent, or "prose only"
when nothing does but whoever reads the guide. It shows at a glance which rules nothing checks,
and those are the first to turn into a mechanism when an audit says they're failing.
`bin/check.sh` counts guide sections that are missing the line.
