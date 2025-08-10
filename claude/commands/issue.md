# 🔁 GitHub/GitLab Issue Resolution Workflow

**Ultra think about this issue before proceeding**: $ARGUMENTS

## 🎯 High-Level Workflow Philosophy
- Create GitHub/GitLab issues for every feature/task
- Use Claude Code via custom slash commands for complete SDLC:
  - **Plan**: Break issues into atomic tasks using scratchpads in ./scratchpads directory
  - **Create**: Generate code from the plan
  - **Test**: Run test suites and Puppeteer-based browser tests
  - **Deploy**: Commit code, open PRs, and merge upon success
- Act as **project manager first, coder second**
- Human accountability with AI assistance

---

## 📋 Phase 1: Issue Analysis & Strategic Planning

### 1.1 Initial Context Gathering
- **Enable Plan Mode First** (Shift+Tab) - reason without making changes
- **GitHub**: `gh issue view $ISSUE_NUMBER` to retrieve issue details
- **GitLab**: `glab issue view $ISSUE_NUMBER` for GitLab repositories
- **Auto-detect platform**: Check remote origin automatically
- **Screenshot Context**: Drag relevant screenshots (UI bugs, error messages, designs) for visual context
- **Web Context**: Paste documentation URLs for Claude to browse and reference

### 1.2 Deep Analysis with Progressive Thinking Levels
Apply escalating thought depth as needed:
1. **"Think about this"** - initial analysis
2. **"Think hard about this"** - deeper consideration
3. **"Think harder about this"** - comprehensive analysis
4. **"Ultra think about this"** - maximum processing depth before proceeding

**Analysis checklist:**
- Understand issue type (bug, feature, enhancement, etc.)
- Extract error messages, reproduction steps, expected vs actual behavior
- Check labels, milestones, assignees for context
- Identify potential scope creep or hidden complexity

### 1.3 Research & Prior Art Investigation
- **Search scratchpads**: Look for previous analysis on similar issues in ./scratchpads
- **Review related PRs**: Search for patterns and previous attempts
  ```bash
  # GitHub
  gh pr list --search "in:title $KEYWORDS"
  gh pr list --state closed --search "in:title $KEYWORDS"

  # GitLab
  glab mr list --search "$KEYWORDS"
  glab mr list --state closed --search "$KEYWORDS"
  ```
- **Codebase exploration**: Identify relevant files and components
- **Additional context**: Upload related project folders for broader understanding

### 1.4 Requirements Refinement
- **Avoid premature issue creation**: Ensure issues are specific, granular, and atomic
- Ask clarifying questions if scope is unclear
- Break large issues into smaller, manageable sub-tasks
- Consider backward compatibility and breaking changes
- Document potential risks and edge cases

### 1.5 Strategic Planning Documentation
- **Create scratchpad**: `issue-$ISSUE_NUMBER-$BRIEF_DESCRIPTION.md`
- **Include in scratchpad**:
  - Direct link to the issue
  - Problem summary and root cause analysis
  - Proposed solution approach with alternatives considered
  - Atomic task breakdown with priorities
  - Risk assessment and mitigation strategies
  - Testing strategy
  - Deployment considerations

---

## 🧰 Phase 2: Environment Setup & Implementation

### 2.1 Project Context Management
- **Maintain claude.md**: Use `/init` to generate, update with project-specific rules
- **Commit frequently**: Git commits act as checkpoints (Claude Code lacks restore)
- **Work tree consideration**: Single Claude instance preferred for early-stage projects
  - Multiple branches can be clunky with permission prompts
  - Merge conflicts require manual resolution
  - Cleanup overhead often not worth parallel benefits

### 2.2 Branch Management & Development
- **Create descriptive branch**: `git checkout -b fix/issue-$ISSUE_NUMBER-brief-description`
- **Ensure latest base**: Start from updated main/master branch
- **Incremental commits**: Each commit represents complete, logical change
- **Commit message quality**: Clear, descriptive (no AI references)
- **Follow conventional commits** where applicable

### 2.3 Code Implementation Strategy
- **Start with Plan Mode**: Review proposed approach before execution
- **Atomic changes**: Implement in small, testable increments
- **Code quality standards**:
  - Follow existing project conventions
  - Add meaningful comments for complex logic
  - Implement proper error handling
  - Consider performance implications
- **Self-review prompts**: Ask Claude to validate its own work for edge cases

---

## ✅ Phase 3: Comprehensive Testing Strategy

### 3.1 Test-Driven Confidence
- **Build robust test suite early** - confidence comes from coverage, not code inspection
- **Prevent regressions**: Tests catch issues from seemingly minor changes
- **Test types to implement**:
  - Unit tests for new functionality
  - Integration tests for component interactions
  - Edge case and error condition testing

### 3.2 UI Testing (when applicable)
- **Puppeteer MCP server**: For browser-based UI testing
- **Test critical user flows**
- **Verify responsive design and accessibility**
- **Cross-browser compatibility** if required

### 3.3 Full Test Suite Execution
- **Run complete test suite**: `npm test` or project equivalent
- **CI/CD integration**: GitHub Actions runs tests and linter on each commit
- **Fix failing tests immediately**: Don't proceed with broken tests
- **Performance regression checks**

### 3.4 Manual Validation
- **Test specific issue scenario**
- **Verify reproduction steps are resolved**
- **Test edge cases manually**
- **Environment-specific testing** if applicable

---

## 🚀 Phase 4: Review, Deploy & Integration

### 4.1 Pre-Submission Quality Gates
- [ ] All tests passing
- [ ] Code follows project conventions
- [ ] Documentation updated (if needed)
- [ ] Changelog updated (if applicable)
- [ ] No debug code or console statements
- [ ] Branch up to date with main
- [ ] Self-review completed

### 4.2 Pull/Merge Request Creation
- **GitHub**: `gh pr create --title "Fix #$ISSUE_NUMBER: Brief description" --body "Description of changes"`
- **GitLab**: `glab mr create --title "Fix #$ISSUE_NUMBER: Brief description" --description "Description of changes"`

**PR/MR Description Template**:
```markdown
## Summary
Brief description of changes made

## Related Issue
Fixes #$ISSUE_NUMBER

## Changes Made
- List of specific changes
- Include breaking changes if any

## Testing Performed
- Unit tests added/updated
- Manual testing scenarios
- Screenshots/videos for UI changes

## Review Checklist
- [ ] Code follows project standards
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] No breaking changes (or properly documented)
```

### 4.3 Review Process Management
- **Human review priority**: Most effort goes into planning and reviewing
- **Claude-assisted reviews**: Can delegate some review tasks to Claude
- **Specialized review prompts**: e.g., "review in the style of Sandy Metz"
- **Address feedback promptly**: Maintain momentum
- **CI/CD pipeline**: Ensure all automated checks pass

### 4.4 Deployment Strategy
- **Merge = Deploy**: For projects with automatic deployment (e.g., Render.com)
- **Feature flags**: Consider for risky changes
- **Rollback preparation**: Document rollback procedures for critical changes
- **Database migrations**: Handle with extra care and testing

---

## 🔧 Advanced Techniques & Considerations

### Context Management
- **Use /clear after each issue**: Reset Claude's context for fresh start
- **Folder uploads**: Provide broader codebase context when needed
- **URL references**: Let Claude browse documentation for current information
- **Screenshot context**: Visual debugging and design references

### Claude Code Optimization
- **Sub-agents for large tasks**: Spawn parallel agents for complex migrations
- **Progressive thinking prompts**: Scale thinking depth based on complexity
- **Plan Mode utilization**: Always start with reasoning before execution
- **Self-validation requests**: Ask Claude to double-check its work

### Cost & Resource Management
- **GitHub Actions Claude integration**: Metered usage can generate unexpected charges
- **Recommended for**: Small fixes, not large code changes
- **Monitor API usage**: Especially for Claude Max users
- **Local development priority**: Use Claude Code locally when possible

---

## 🚨 Error Handling & Contingencies

### Common Issues & Solutions
- **Issue access problems**: Verify permissions and issue number
- **Merge conflicts**: Rebase branch and resolve systematically
- **Test failures**: Investigate root cause before proceeding
- **Scope creep**: Break into smaller, focused issues
- **Performance degradation**: Profile and optimize before merging

### Quality Assurance Checkpoints
- **Never proceed with failing tests**
- **All phases must complete successfully before advancing**
- **Human review required** for all PR/MR submissions
- **Git commits as checkpoints**: Frequent commits enable easy rollback
- **Always review Claude's code critically**: Treat as another developer's PR

### Emergency Procedures
- **Rollback plan**: Keep detailed commit history
- **Hotfix process**: Streamlined path for critical issues
- **Communication**: Update issue with progress and any blockers
- **Escalation**: Know when to involve other team members

---

## 🎯 Success Metrics & Continuous Improvement

### Workflow Effectiveness
- Time from issue creation to resolution
- Test coverage percentage
- Number of regressions introduced
- PR/MR approval time
- Deployment success rate

### Learning & Iteration
- Document what works well in claude.md
- Refine slash commands based on experience
- Update workflow based on project needs
- Share successful patterns with team

**Remember**: Claude acts as a powerful assistant, but **human accountability and oversight remain essential**. Best results come from clear planning, tight context management, and thoughtful review.
