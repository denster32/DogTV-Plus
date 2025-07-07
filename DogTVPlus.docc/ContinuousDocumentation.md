# Continuous Documentation Integration

To ensure documentation stays up-to-date, integrate Swift-DocC into the CI pipeline:

1. **DocBuild Step**  
   Add a CI job to run:
   ```bash
   xcodebuild \
     docbuild \
     -scheme DogTV+ \
     -destination 'generic/platform=macOS'
   ```
   on each merge to `main`.

2. **Publish Documentation**  
   - Upload the generated `.doccarchive` to a documentation hosting service (e.g., GitHub Pages, AWS S3).  
   - Use `docc publish` commands or custom scripts.

3. **Linting and Validation**  
   - Include `docc validate` to catch missing documentation comments.  
   - Enforce code coverage thresholds for public API docs.

4. **Automation**  
   - Use GitHub Actions to trigger on pull requests and merges.  
   - Fail the build if documentation errors occur.

By following these steps, all public interfaces remain well-documented within the CI/CD workflow. 