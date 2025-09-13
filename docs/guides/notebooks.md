# Notebook Research Guide

## Overview

The Holocron Notebook System enables systematic knowledge extraction and research across large holocrons. When you need to research a specific topic across many files, notebooks provide a structured approach to mining information, tracking progress, and creating comprehensive documentation.

## When to Use Notebooks

- **Large holocrons** (50+ files) where manual file-by-file research is impractical
- **Complex research topics** that span multiple directories and file types
- **Multi-session research** where you need to track progress across chat sessions
- **Comprehensive documentation** requiring systematic information gathering
- **Knowledge extraction** from historical progress logs, decision logs, and documentation

## Quick Start

### 1. Create a Research Brief
Write a comprehensive research brief to `_memory/tmp/buffer` describing:
- What you're researching
- What to look for in files
- Key areas of focus
- Expected outcomes

### 2. Create a Notebook
```bash
holo notebook new --from-buffer --name your_research_topic
```

The notebook will contain your research brief at the top, followed by a list of all sources to research.

### 3. Review Sources
The system will show you all files with metadata:
```
- [ ] 0001: README.md (2.3KB, 2025-09-12, md)
- [ ] 0002: _memory/progress_logs/2025-09-05_setup.md (15.2KB, 2025-09-11, md)
```

### 4. Research Systematically
- **CRITICAL**: Process EVERY source file in the list - the job isn't done until all sources are consumed
- **FIRST**: Read the research brief at the top of the notebook to understand your research objectives
- Use `holo notebook status <name>` to see progress
- Read files in batches of ~10 entries at a time (see batching strategies below)
- **For relevant sources**: Add entries with `holo notebook add-entry <name> <file-id> <content>`
- **For irrelevant sources**: Mark complete with `holo notebook mark-source <name> <file-id>`
- **Check with user after each batch** to see if you should continue or stop
- Track progress across multiple sessions

## Batching Strategies for Large Holocrons

### Batch Size and User Check-ins
- **Process ~10 sources per batch** to avoid context window issues
- **Check with user after each batch** before continuing to next batch
- **User can stop or continue** based on context window and needs
- **Complete ALL sources** unless user explicitly says otherwise

### Token Budget Batching
- **Target**: 6-8k tokens per batch
- **Small files first**: Process many small files (1-5KB) for quick breadth
- **Large files later**: Tackle chunky files (20KB+) in dedicated batches
- **Estimate**: ~1KB = 250-300 tokens (rough guideline)

### Source Processing Guidelines
- **Process ALL sources systematically** - don't skip files based on filename or path
- **Source filenames don't indicate relevance** - each file needs to be examined
- **Reference the research brief** at the top of the notebook to determine relevance
- **If source has no relevant content, mark as processed anyway** - don't make up content
- **Use `holo notebook mark-source` for irrelevant sources** - don't create entries for them

### Prioritization Heuristics (for batching order only)
- **Keyword relevance**: Files with research topic keywords in path/name
- **Recency**: Newer files (recent mtime) often more relevant
- **Path priority**: `_memory/progress_logs/` > `_memory/decision_log.md` > `README.md`
- **File type**: `md` > `rb` > `json` > `txt` for documentation research

### Two-Pass Research Strategy
- **Pass 1 - Skim**: Process top 20-30% most promising files
  - Quick 1-3 bullet summaries per file
  - Identify high-value sources for deep dive
- **Pass 2 - Deep Dive**: Focus on high-value files
  - Comprehensive entries for most relevant sources
  - Summary entries for remaining sources

## Batch Processing Guidelines

### Concatenation Format
When reading multiple files in a batch, use clear delimiters:
```
--- FILE: README.md (2.3KB, 2025-09-12, md) ---
[file content here]

--- FILE: _memory/progress_logs/2025-09-05_setup.md (15.2KB, 2025-09-11, md) ---
[file content here]
```

### Entry Rules
- **One entry per file**: Always create separate H4 entries for each file
- **Proper citations**: Include full source path and metadata
- **No cross-file merging**: Never combine content from multiple files in one entry
- **Line ranges**: For large files, include line ranges when citing specific sections

### Chunking Large Files
For files >50KB, consider chunking by:
- **Headings/sections**: Natural break points
- **Fixed line windows**: 500-1000 lines per chunk
- **Include line ranges**: `[README.md:45-120]` in citations

## Best Practices

### When to Create Entries vs. Mark Complete
**Create an entry ONLY if the source contains content relevant to your research objectives** (found in the research brief at the top of the notebook).

**Use `holo notebook mark-source <name> <file-id>` for sources that are:**
- Empty or nearly empty files
- Basic setup/configuration files (README.md, package.json, etc.)
- Generated files (package-lock.json, yarn.lock, Gemfile.lock)
- Files unrelated to your research topic
- Binary files or images (unless specifically relevant)
- Files that don't contribute to your research objectives

**Use `holo notebook add-entry <name> <file-id> <content>` for sources that contain:**
- Information directly related to your research topic
- Historical context or background
- Technical details relevant to your objectives
- Decision rationale or lessons learned
- Progress updates or status information

### Entry Content Guidelines
- **Keep entries concise**: Think 3x5 index cards, not novels
- **Focus on relevance**: Only include content that relates to your research objectives
- **Use simple formatting**: Basic text and bulleted lists work best
- **No headers needed**: The gem provides the entry header automatically
- **No source references needed**: The gem provides source links automatically
- **One paragraph, maybe two**: Keep it digestible
- **Reference line numbers**: For large sources, cite specific sections
- **Don't make up content**: If nothing relevant, just mark complete and move on

### Progress Tracking
- Check status regularly with `holo notebook status <name>`
- Use `holo notebook list` to see all notebooks and progress if needed

### Noise Control
- **Skip generated files**: `package-lock.json`, `yarn.lock`, `Gemfile.lock`
- **Downweight vendor dirs**: `node_modules/`, `vendor/`, `tmp/`
- **Skip binaries**: Images, compiled files, data dumps

## Commands Reference

### `holo notebook new --from-buffer --name <name>`
Creates a new research notebook with comprehensive source listing.

### `holo notebook status <name>`
Shows notebook progress, sources list, and completion status.

### `holo notebook add-entry <name> <file-id> <content>`
Adds a research entry for a specific file, marking it as completed.

### `holo notebook mark-source <name> <file-id>`
Toggles source completion status without adding an entry. Useful for marking sources as complete when they have no relevant content.

### `holo notebook list`
Lists all notebooks with progress indicators.

## Sample Entry

Here's an example of a well-structured research entry (assuming the research objective is "documenting the RisingWave migration journey"):

```
Major breakthrough in fixing the RisingWave migration pipeline. Root cause was dbmate's transaction management being incompatible with RisingWave's streaming database architecture.

**Key Technical Solutions**:
- Implemented custom migration script bypassing dbmate's transaction wrapper
- Fixed password exposure in CI logs with masked logging
- Resolved RisingWave SQL syntax issues (no VARCHAR length specifiers, different DEFAULT handling)
- Added proper error detection to prevent false positive migration marking

**Impact**: CI/CD pipeline now successfully runs migrations with proper credential security and RisingWave compatibility.
```

**What makes this entry good**:
- **No headings**: This isn't a document, it's a quick note.
- **Concise but informative**: Captures the essence without overwhelming detail
- **Clear structure**: Uses bullet points to organize information logically
- **Key insights highlighted**: Bullet points make important information scannable
- **Technical details**: Includes specific solutions and their impact
- **Relevant to research objective**: Directly relates to documenting the migration journey
- **Actionable information**: Explains what was accomplished and why it matters

*IMPORTANT:* it is completely acceptable to make a very, very long entry IF it's needed. If a source is full of good information, include all of it! Be as brief as you can, but the goal is that the finished notebook could be used in isolation to fully understand all relevant subject matter. Don't leave things out.

### When NOT to Create Entries

**If a source has no relevant content for your research objective, don't create an entry at all.** Instead, use:

```bash
holo notebook mark-source <name> <file-id>
```

**Examples of sources that typically don't need entries**:
- Basic README files with only setup instructions
- Empty or nearly empty files
- Generated files (package-lock.json, etc.)
- Files that don't relate to your research topic
- Binary files or images (unless specifically relevant)

**Remember**: The goal is to process ALL sources systematically, but only create entries for sources that actually contribute to your research. If there's nothing relevant, just mark it complete and move on.

## Example Workflow

1. **Write research brief** to `_memory/tmp/buffer`
2. **Create notebook**: `holo notebook new --from-buffer --name risingwave_challenges`
3. **Review sources**: `holo notebook status risingwave_challenges`
4. **Process first batch**: Read ~10 files, add entries for each, check with user
5. **Continue batches**: Process remaining files in ~10-file batches
6. **Check with user**: After each batch, ask if you should continue or stop
7. **Complete ALL sources**: Don't stop until every source is processed unless told to
8. **Track progress**: Use `holo notebook status` to see completion
9. **Resume later**: You'll probably spread this task over multiple chat sessions if there are a lot of sources

## Tips for Success

- **Process EVERY source**: Don't skip files - complete the entire list
- **Batch size matters**: ~10 sources per batch to avoid context window issues
- **Check with user**: Ask if you should continue after each batch
- **Keep entries concise**: Focus on highlights, use hyperlinks for details
- **Don't make up content**: If source has nothing relevant, mark as "No relevant content found"
- **Start with metadata**: Use file sizes and dates to plan your approach
- **Batch intelligently**: Group files by size and relevance
- **Take breaks**: Large research projects benefit from multiple sessions
- **Document insights**: Note patterns and connections as you find them
- **Stay organized**: Use clear entry headers and proper citations
- **Check progress**: Regular status checks help maintain momentum

## Critical Workflow Requirements

### What NOT to Do
- ❌ **Don't cherry-pick sources** - you must process ALL sources in the list
- ❌ **Don't assume relevance from filenames** - examine every file
- ❌ **Don't write long entries** - keep them concise with highlights only
- ❌ **Don't make up content** - if nothing relevant, just mark complete and move on
- ❌ **Don't process all sources at once** - batch in ~10-file chunks
- ❌ **Don't create entries for irrelevant sources** - use mark-source instead

### What TO Do
- ✅ **Read the research brief first** - understand your research objectives before starting
- ✅ **Process every single source** in the provided list
- ✅ **Batch ~10 sources at a time** to avoid context window issues
- ✅ **Check with user after each batch** before continuing
- ✅ **Keep entries concise** - focus on key insights and highlights
- ✅ **Only create entries for relevant sources** - use mark-source for irrelevant ones
- ✅ **Reference the research objectives** - ensure content relates to your research goals

The notebook system transforms overwhelming research tasks into manageable, trackable processes that can span multiple sessions while maintaining clear progress and comprehensive documentation.
