# 📋 KANBAN BOARD - ECOS DO ABISMO

## **BOARD OVERVIEW**
**Visual task management para desenvolvimento ágil**

---

## **📌 BACKLOG**
*Features e tasks planejados*

### **🔴 HIGH PRIORITY (Sprint 1)**
- [ ] **US1.1.1** - Combat system básico
- [ ] **US1.2.1** - Resource management (Vontade)
- [ ] **US1.2.2** - Corruption system
- [ ] **US1.3.1** - Basic UI layout

### **🟡 MEDIUM PRIORITY (Sprint 2)**
- [ ] **US2.1.1** - Visual feedback & juice
- [ ] **US2.2.1** - Game balancing
- [ ] **US2.3.1** - UI polish

### **🟢 LOW PRIORITY (Sprint 3)**
- [ ] **US3.1.1** - Quality assurance
- [ ] **US3.2.1** - Onboarding experience
- [ ] **US3.3.1** - Final polish

---

## **🔄 TODO**
*Tasks prontos para começar*

### **READY TO START**
- [ ] **TASK-001** - Setup project structure (2h)
- [ ] **TASK-002** - Create Player.gd resource (1h)
- [ ] **TASK-003** - Create Enemy.gd resource (1h)
- [ ] **TASK-004** - Create Card.gd resource (2h)

### **BLOCKED**
- [ ] **TASK-012** - Add audio feedback ⛔ *Waiting for audio assets*

---

## **⚡ IN PROGRESS**
*Currently being worked on (WIP Limit: 3)*

### **👤 DEVELOPER**
- [🔄] **TASK-005** - Build basic UI layout (4h)
  - **Started**: Today 09:00
  - **Estimated Complete**: Today 13:00
  - **Progress**: 25% - Layout structure done

---

## **🔍 REVIEW**
*Completed tasks awaiting review*

### **CODE REVIEW**
- [ ] **TASK-XXX** - (Example - empty for now)

### **TESTING**
- [ ] **TASK-XXX** - (Example - empty for now)

---

## **✅ DONE**
*Completed tasks (last 7 days)*

### **THIS WEEK**
- [✅] **TASK-000** - Delete old codebase (30min)
  - **Completed**: Today 08:30
  - **Reviewer**: N/A

---

## **📊 BOARD METRICS**

### **CURRENT SPRINT PROGRESS**
```
Sprint 1 Progress: [████░░░░░░] 40%
- Completed: 0 story points
- In Progress: 8 story points
- Remaining: 27 story points
```

### **TEAM CAPACITY**
```
Week 1: [████████░░] 80% allocated
- Developer: 35h planned / 40h available
- Buffer: 5h for unexpected issues
```

### **FLOW METRICS**
- **Cycle Time**: N/A (first sprint)
- **Lead Time**: N/A (first sprint)
- **WIP**: 1/3 (healthy)
- **Throughput**: TBD

---

## **🚨 BLOCKERS & IMPEDIMENTS**

### **CURRENT BLOCKERS**
*None at the moment*

### **RESOLVED BLOCKERS**
- [✅] **BLOCKER-001** - Old codebase cleanup
  - **Issue**: Conflicting architecture
  - **Resolution**: Complete deletion + fresh start
  - **Resolved**: Today 08:30

---

## **📋 TASK TEMPLATES**

### **DEVELOPMENT TASK**
```markdown
**TASK-XXX: [Title]**
- **Type**: Development
- **Story**: US-X.X.X
- **Estimate**: Xh
- **Assignee**: Developer
- **Priority**: High/Medium/Low
- **Acceptance Criteria**:
  - [ ] Criteria 1
  - [ ] Criteria 2
- **Definition of Done**:
  - [ ] Code written
  - [ ] Manual testing
  - [ ] Code review (if needed)
```

### **BUG TASK**
```markdown
**BUG-XXX: [Title]**
- **Severity**: Critical/High/Medium/Low
- **Steps to Reproduce**:
  1. Step 1
  2. Step 2
- **Expected**: What should happen
- **Actual**: What actually happens
- **Environment**: Godot 4.4, Windows 11
```

---

## **🔄 WORKFLOW RULES**

### **COLUMN TRANSITIONS**
```
BACKLOG → TODO
├── Acceptance criteria defined
├── Story points estimated
└── Dependencies resolved

TODO → IN PROGRESS
├── Assignee assigned
├── WIP limit not exceeded
└── All blockers removed

IN PROGRESS → REVIEW
├── Implementation complete
├── Self-testing done
└── Ready for external review

REVIEW → DONE
├── Code review passed (if applicable)
├── Manual testing passed
├── Acceptance criteria met
└── Stakeholder approval
```

### **WIP LIMITS**
- **TODO**: No limit (planning buffer)
- **IN PROGRESS**: 3 tasks max
- **REVIEW**: 5 tasks max
- **DONE**: Keep last 10 tasks visible

### **PRIORITY RULES**
1. **Blockers** always first
2. **Sprint commitment** before new features
3. **Dependencies** before dependents
4. **High-value** before low-value

---

## **📈 DAILY OPERATIONS**

### **MORNING CHECKLIST** (5 min)
- [ ] Check for new blockers
- [ ] Update task progress
- [ ] Move completed tasks to REVIEW
- [ ] Pull next task if WIP allows

### **EVENING CHECKLIST** (5 min)
- [ ] Update time tracking
- [ ] Note any impediments
- [ ] Prepare next day tasks
- [ ] Update progress metrics

### **WEEKLY REVIEW** (15 min)
- [ ] Review board metrics
- [ ] Identify process improvements
- [ ] Update estimates based on actuals
- [ ] Plan next week capacity

---

## **🎯 FOCUS AREAS**

### **THIS WEEK**
**Primary Focus**: Core combat loop
**Secondary Focus**: Basic UI
**Avoid**: Feature creep, premature optimization

### **SUCCESS CRITERIA**
- [ ] Player can play 3 cards
- [ ] Enemy takes damage and dies
- [ ] New enemy spawns
- [ ] Resources work correctly
- [ ] No critical bugs

---

## **📞 ESCALATION PATH**

### **BLOCKERS**
1. **Try to resolve** within 2h
2. **Document** in BLOCKED column
3. **Escalate** if affects sprint goal
4. **Daily standup** for team visibility

### **SCOPE CHANGES**
1. **Product Owner** approval required
2. **Impact assessment** on sprint goal
3. **Re-prioritization** if necessary
4. **Stakeholder** communication

---

## **🛠️ TOOLS & INTEGRATIONS**

### **MANUAL TRACKING**
- **This Document**: Primary board
- **Git Commits**: Link to task IDs
- **Time Tracking**: Manual log in tasks

### **POTENTIAL INTEGRATIONS**
- **GitHub Issues**: Sync with task IDs
- **Godot Editor**: Custom task tracking plugin
- **Time Tracking**: Toggl or RescueTime
- **Analytics**: Custom dashboard

---

## **📝 NOTES & LEARNINGS**

### **PROCESS IMPROVEMENTS**
*Track what works and what doesn't*

### **TECHNICAL DEBT**
*Track shortcuts taken for future cleanup*

### **KNOWLEDGE BASE**
*Document solutions to common problems*