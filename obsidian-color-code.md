# Color code for highlights, kanban and tickets

Optional convention for working with the ticket files in Obsidian. One color means the same thing everywhere: in text highlights (Obsidian 1.14.4+ suggests the colors when you type `==`), in the kanban views of `tasks.base` and in the ticket status. The color says what kind of attention a spot needs, not what it is about.

| Color | Meaning | Highlight in text | Ticket status | Priority |
| --- | --- | --- | --- | --- |
| 🔴 Red | Urgent, blocker, risk. Needs to be resolved before anything else. | `==🔴text==` | – | high |
| 🟠 Orange | Waiting for someone. Question asked, answer pending, follow up. | `==🟠text==` | blocked, waiting | – |
| 🟡 Yellow | Check. Unverified number, unsupported claim, assumption. | `==🟡text==` | – | medium |
| 🟢 Green | Decided, confirmed, done. Counts as settled. | `==🟢text==` | done | – |
| 🔵 Blue | Reference, source, context. Information only, nothing to do. | `==🔵text==` | – | – |
| 🟣 Violet | Idea, later, parking lot. Deliberately not now. | `==🟣text==` | – | – |
| ⚪ None | Normal. Open and workable, no special attention. | `==text==` | open, active | low |
| ⚫ Grey | Dropped. Stays as a record. | ~~strikethrough~~ | dropped | – |

## Rules

- The emoji goes right after the opening `==`, without a space: `==🔴Blocker: license missing==`.
- Green always means "done or certain". It is never used for low priority, so a green dot never reads as "unimportant".
- Yellow marks numbers and statements that have to be verified before a text leaves your hands.
- Remove highlights from texts you pass on to others. They are a review tool, not part of the document.

## Ticket fields

| Field | Purpose |
| --- | --- |
| `title` | Task title on the dashboard card (also the key for checkbox sync, keep it unique) |
| `id` | Short ticket id shown on the card, e.g. DEMO-1 |
| `status` | One bare value: open, active, blocked, waiting, done, dropped. Kanban columns are built from it |
| `status_note` | Who, what, when behind the status, e.g. "waiting for the design review". Shown on the dashboard card |
| `priority` | high, medium, low |
| `project` | Anchor id of the project row in the overview table |
| `due` | Optional: a date (YYYY-MM-DD, shown as "in 3 days") or a short text such as "this week"; shown in the pill on the card |
| `created` | Date the ticket was created (YYYY-MM-DD) |
| `summary` | One line for the dashboard card |
| `next` | The next concrete step, shown as "Next step" on the card |

## Views in tasks.base

| View | Columns | Dragging a card changes |
| --- | --- | --- |
| Kanban Status | open, active, blocked, waiting, done, dropped | `status` |
| Kanban Priority | high, medium, low (active tickets only) | `priority` |
| Due | table of active tickets with a due date or text | – |
| All | table of all tickets | – |

New tickets: the template `templates/ticket.md` (Obsidian core plugin Templates, set the template folder to `templates`).
