# Contribution Guidelines

Thank you for your interest in contributing to DogTV+! We welcome improvements, bug fixes, and enhancements.

## Getting Started
1. Fork the repository.
2. Clone your fork:
   ```bash
   git clone https://github.com/YourOrg/DogTV-Plus.git
   cd DogTV-Plus
   ```
3. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Code Standards
- Follow Swift API Design Guidelines.
- Use clear, descriptive naming conventions.
- Write documentation comments (`///`) for public APIs.
- Ensure code compiles without warnings.

## Pull Request Process
1. Ensure all tests pass:
   ```bash
   xcodebuild test -scheme DogTV+ -destination 'platform=tvOS Simulator,name=Apple TV'
   ```
2. Rebase onto `main` and resolve conflicts.
3. Submit a pull request with a descriptive title and summary.
4. Link related issue(s) and add appropriate labels.

## Issue Reporting
- Use the issue tracker for bug reports and feature requests.
- Provide steps to reproduce, expected vs. actual behavior, and logs if applicable.

## Contact
For questions, contact the maintainers at devops@dogtvplus.com. 