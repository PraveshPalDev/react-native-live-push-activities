# 🤝 Contributing to React Native Live Activities

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Code of Conduct

Please be respectful and constructive in all interactions with the community.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **iOS version**
- **React Native version**
- **Package version**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Screenshots** (if applicable)
- **Error messages** (from Xcode console)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide detailed description** of the proposed functionality
- **Explain why this enhancement would be useful**
- **Provide examples** of how it would be used

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **Make your changes**:
   - Follow the existing code style
   - Add tests if applicable
   - Update documentation
3. **Test your changes**:
   - Run the example app
   - Test on physical device
   - Verify both lock screen and Dynamic Island
4. **Commit with clear messages**:
   ```
   feat: add timer widget template
   fix: resolve deployment target mismatch warning
   docs: update API documentation
   ```
5. **Submit the PR** with:
   - Clear description of changes
   - Related issue numbers
   - Testing performed

## Development Setup

1. **Clone your fork**:

   ```bash
   git clone https://github.com/YOUR-USERNAME/react-native-live-activities
   cd react-native-live-activities
   ```

2. **Install dependencies**:

   ```bash
   yarn install
   ```

3. **Setup example app**:

   ```bash
   yarn bootstrap
   ```

4. **Run example**:
   ```bash
   yarn example ios
   ```

## Project Structure

```
react-native-live-activities/
├── src/                    # TypeScript source
│   ├── index.tsx          # Main module
│   └── templates/         # Pre-built templates
├── ios/                   # Native iOS code
│   ├── LiveActivities.m   # Objective-C bridge
│   └── LiveActivities.swift # Swift implementation
├── scripts/               # Setup & automation
├── docs/                  # Documentation
├── example/               # Example app
└── package.json
```

## Coding Guidelines

### TypeScript

- Use TypeScript for all `.ts/.tsx` files
- Export types for all public APIs
- Add JSDoc comments for public methods
- Follow existing code style

### Swift

- Use Swift 5.5+
- Follow Apple's Swift style guide
- Add comments for complex logic
- Handle errors gracefully

### Documentation

- Update README for major features
- Add examples to docs/EXAMPLES.md
- Update API.md for new methods
- Include code examples

## Testing

### Manual Testing Checklist

- [ ] Test on physical device (iOS 16.1+)
- [ ] Test lock screen appearance
- [ ] Test Dynamic Island (iPhone 14 Pro+)
- [ ] Test all templates (Ride, Delivery, Sports, Timer)
- [ ] Test error handling
- [ ] Test with both RN CLI and Expo

### What to Test

1. **Start Activity**: Appears on lock screen
2. **Update Activity**: Updates reflect immediately
3. **End Activity**: Dismisses correctly
4. **Multiple Activities**: Handle >1 activity
5. **Error Cases**: Invalid data, disabled features

## Releasing (Maintainers Only)

1. **Update version** in `package.json`
2. **Update CHANGELOG.md**
3. **Create release**:
   ```bash
   yarn release
   ```
4. **Publish to npm**:
   ```bash
   npm publish
   ```

## Questions?

- Open a [GitHub Discussion](https://github.com/yourusername/react-native-live-activities/discussions)
- Check [existing issues](https://github.com/yourusername/react-native-live-activities/issues)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for making React Native Live Activities better!** 🙏
