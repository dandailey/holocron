# Creating Long Form Documents

When you need to create a document that's too long for a single AI response, use the longform approach.

## The Problem

AI responses have length limits, but complex documentation often needs to be longer than those limits.

## The Solution

1. Break your document into logical sections
2. Create separate files for each section in `longform_docs/`
3. Use numbered prefixes for ordering: `01_introduction.md`, `02_setup.md`, etc.
4. Use `holo longform concat longform_docs/` to combine them

## File Naming Convention

Use this pattern: `NN_section_name.md`
- `NN` = two-digit number for ordering
- `section_name` = descriptive name in snake_case

## Example Structure

```
longform_docs/
├── 01_introduction.md
├── 02_installation.md
├── 03_configuration.md
├── 04_usage.md
└── 05_troubleshooting.md
```

## Concatenating Documents

```bash
# Concatenate all files in longform_docs/
holo longform concat longform_docs/

# Concatenate to a specific output file
holo longform concat longform_docs/ --output complete_guide.md
```

## Tips

- Keep each section focused on one topic
- Use consistent formatting across sections
- Include cross-references between sections
- Test the concatenated output for flow and completeness
