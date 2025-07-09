# Architecture Plan - DogTV+ Rewrite
**Date:** July 9, 2025  
**Agent:** Agent 1 - Build System  

## New Project Architecture

### Project Structure
```
DogTVPlus/
├── DogTVPlus/                  # Main app target
│   ├── App/
│   │   ├── DogTVPlusApp.swift
│   │   └── ContentView.swift
│   ├── Views/
│   ├── Models/
│   ├── Services/
│   └── Utilities/
├── DogTVPlusCore/              # Core business logic
│   ├── Models/
│   ├── Services/
│   └── Utilities/
├── DogTVPlusUI/                # Reusable UI components
│   ├── Components/
│   ├── Styles/
│   └── Extensions/
├── DogTVPlusAudio/             # Audio processing
├── DogTVPlusVision/            # Video/visual processing  
└── DogTVPlusData/              # Data persistence
```

### Module Dependencies
```
DogTVPlusCore ← (no dependencies)
DogTVPlusData ← DogTVPlusCore
DogTVPlusAudio ← DogTVPlusCore
DogTVPlusVision ← DogTVPlusCore  
DogTVPlusUI ← DogTVPlusCore
DogTVPlus ← All modules
```

### Swift Package Manager Configuration
- Clean Package.swift with proper module separation
- Explicit dependencies between modules
- Support for tvOS 17.0+, iOS 17.0+ (for development)
- Minimal external dependencies

### Build Targets
1. **DogTVPlus** - Main tvOS app
2. **DogTVPlusCore** - Framework
3. **DogTVPlusUI** - Framework  
4. **DogTVPlusAudio** - Framework
5. **DogTVPlusVision** - Framework
6. **DogTVPlusData** - Framework

### Migration Strategy
1. Create new clean project structure
2. Copy existing code with namespace updates
3. Fix import statements and dependencies
4. Test modular build system
5. Verify all functionality works

This architecture ensures clean separation of concerns and eliminates the current build issues.
