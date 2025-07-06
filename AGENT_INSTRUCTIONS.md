# Agent Instructions for DogTV+ Pre-Deployment Development

## 🎯 Mission Overview
You are tasked with systematically implementing the DogTV+ Apple TV app according to the comprehensive TODO list. This is a scientifically-backed application for canine well-being that must meet industry standards before deployment.

## 📋 Core Workflow Protocol

### 1. Task Selection & Prioritization
**ALWAYS follow this order:**
1. Start with **Critical** tasks (marked 🔴)
2. Move to **Important** tasks (marked 🟡) 
3. Complete **Nice to Have** tasks (marked 🟢) last

**Task Selection Rules:**
- Work through tasks sequentially within each priority level
- Never skip a task unless explicitly instructed
- If a task has dependencies, complete those first
- Update TODO.md after each task completion

### 2. Implementation Standards

#### Code Quality Requirements:
- **Swift Best Practices**: Follow Apple's Swift API Design Guidelines
- **Documentation**: Add comprehensive comments for all public methods
- **Error Handling**: Implement proper error handling and logging
- **Performance**: Optimize for Apple TV hardware limitations
- **Testing**: Write unit tests for all new functionality

#### Scientific Integration:
- **Research-Based**: All features must align with the scientific background in README.md
- **Citations**: Include references to relevant research papers
- **Validation**: Test implementations against scientific findings
- **Adaptability**: Ensure features can evolve with new research

#### Apple TV Specific Requirements:
- **HIG Compliance**: Follow Apple's Human Interface Guidelines for tvOS
- **Remote Navigation**: Optimize for Apple TV remote interaction
- **Performance**: Maintain 60fps on Apple TV hardware
- **Accessibility**: Include VoiceOver and accessibility features

### 3. Progress Tracking Protocol

#### Before Starting Each Task:
1. **Read the task description** in TODO.md completely
2. **Check dependencies** - ensure prerequisites are met
3. **Review related scientific research** from README.md
4. **Plan implementation approach** before coding

#### During Implementation:
1. **Create/update files** as needed
2. **Add comprehensive comments** explaining the science behind implementations
3. **Test functionality** immediately after implementation
4. **Update TODO.md** with progress (check off completed sub-tasks)

#### After Completing Each Task:
1. **Commit changes** with descriptive commit messages
2. **Push to GitHub** to maintain version control
3. **Update progress tracking** in TODO.md
4. **Verify integration** with existing components

### 4. File Management Standards

#### File Organization:
```
DogTV+/
├── Core/                    # Core application logic
├── Rendering/              # Visual rendering systems
├── Audio/                  # Audio processing engines
├── Behavior/               # Behavior analysis systems
├── Performance/            # Performance optimization
├── Testing/                # Test suites
├── Documentation/          # Technical documentation
└── Resources/              # Assets and resources
```

#### Naming Conventions:
- **Files**: PascalCase (e.g., `CanineBehaviorAnalyzer.swift`)
- **Classes**: PascalCase (e.g., `VisualRenderer`)
- **Methods**: camelCase (e.g., `optimizeForBreed`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_FRAME_RATE`)

### 5. Quality Assurance Checklist

#### Before Marking Any Task Complete:
- [ ] **Functionality**: Feature works as specified
- [ ] **Performance**: Meets Apple TV performance requirements
- [ ] **Testing**: Unit tests written and passing
- [ ] **Documentation**: Code is well-documented
- [ ] **Integration**: Works with existing components
- [ ] **Scientific Validation**: Aligns with research findings
- [ ] **Error Handling**: Proper error handling implemented
- [ ] **Accessibility**: Accessibility features included

### 6. Communication Protocol

#### Progress Updates:
- **Daily**: Update TODO.md progress tracking
- **Weekly**: Provide summary of completed tasks
- **Blockers**: Immediately report any blocking issues
- **Decisions**: Document any architectural decisions made

#### Commit Message Format:
```
[Category] Brief description of changes

- Detailed bullet points of changes
- Scientific rationale if applicable
- Performance implications if any
- Testing notes if relevant
```

### 7. Testing Requirements

#### Unit Testing:
- **Coverage**: Minimum 80% code coverage
- **Test Types**: Unit, integration, and performance tests
- **Mocking**: Use proper mocking for external dependencies
- **Assertions**: Clear, descriptive test assertions

#### Integration Testing:
- **Component Interaction**: Test all component interactions
- **End-to-End**: Test complete user workflows
- **Performance**: Benchmark critical paths
- **Edge Cases**: Test boundary conditions

### 8. Documentation Standards

#### Code Documentation:
- **Header Comments**: Describe purpose and scientific basis
- **Method Documentation**: Explain parameters, returns, and behavior
- **Inline Comments**: Clarify complex algorithms
- **Examples**: Provide usage examples for public APIs

#### Technical Documentation:
- **Architecture**: Document system architecture
- **APIs**: Document all public interfaces
- **Deployment**: Provide deployment instructions
- **Troubleshooting**: Include common issues and solutions

### 9. Scientific Integration Guidelines

#### Research Implementation:
- **Citation**: Include research paper citations in comments
- **Validation**: Test implementations against published findings
- **Adaptability**: Design for future research integration
- **Documentation**: Explain scientific rationale in code

#### Breed-Specific Features:
- **Database**: Maintain breed-specific data
- **Algorithms**: Implement breed-specific algorithms
- **Testing**: Test with multiple breed types
- **Validation**: Validate against breed research

### 10. Performance Optimization Standards

#### Apple TV Optimization:
- **Frame Rate**: Maintain 60fps target
- **Memory**: Optimize memory usage
- **Thermal**: Implement thermal management
- **Battery**: Minimize power consumption

#### Monitoring:
- **Metrics**: Track key performance metrics
- **Alerts**: Implement performance alerts
- **Logging**: Comprehensive performance logging
- **Analysis**: Regular performance analysis

## 🚨 Critical Reminders

### Always Remember:
1. **Science First**: Every feature must be scientifically grounded
2. **Quality Over Speed**: Don't rush - maintain high standards
3. **Document Everything**: Comprehensive documentation is essential
4. **Test Thoroughly**: Testing is not optional
5. **Update Progress**: Keep TODO.md current
6. **Commit Regularly**: Maintain clean version control
7. **Follow Standards**: Adhere to all coding and documentation standards

### Red Flags (Stop and Report):
- Performance degradation
- Scientific inaccuracies
- Security vulnerabilities
- Accessibility issues
- Integration failures
- Test failures

## 📊 Success Metrics

### Completion Criteria:
- All 50 tasks completed
- 80%+ test coverage
- Performance targets met
- Documentation complete
- Scientific validation passed
- App Store ready

### Quality Gates:
- Code review passed
- Performance benchmarks met
- Security audit passed
- Accessibility audit passed
- Scientific review passed

---

**Remember**: You are building a scientifically-backed application that will impact canine well-being. Every decision should prioritize scientific accuracy, performance, and user experience. Take pride in creating something that truly helps dogs and their owners. 