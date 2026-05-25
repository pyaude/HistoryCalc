---
description: git-commit
---

---
name: git-auto-commit-and-push
description: Analyzes staged changes, generates a Chinese commit message according to Conventional Commits, and executes git commit and git push. Use this when the user asks to commit changes.
---
# Instructions
1. **Analyze:** Review the staged git changes to understand the modifications.
2. **Format:** Determine the `type` (e.g., feat, fix, docs) and `scope`. Write a concise `description` strictly in **Chinese** (中文). 
   - Example format: `feat(ui): 优化了深色模式的对比度`
3. **Execute Commit:** Use the terminal/shell tool to run the commit command with your generated message:
   `git commit -m "<your_generated_chinese_message>"`
4. **Execute Push:** After a successful commit, use the terminal/shell tool to push the changes to the current branch:
   `git push`
5. **Report:** Briefly inform the user in Chinese that the commit and push operations have been completed successfully, and show the commit message used.