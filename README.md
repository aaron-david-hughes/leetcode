# 🧑‍💻 Enterprise-Grade LeetCode Solutions

![CI](https://github.com/aarondavidhughes/leetcode/actions/workflows/ci.yml/badge.svg)

Clean, well-documented, thoroughly tested LeetCode solutions — built to production standards.

---

## 📋 Problem Tracker

| # | Problem | Status | Solution |
|---|---------|--------|----------|
| 13 | [Roman to Integer](https://leetcode.com/problems/roman-to-integer/) | ✅ Done | [`roman-to-integer/`](roman-to-integer/) |
| 12 | [Integer to Roman](https://leetcode.com/problems/integer-to-roman/) | ✅ Done | [`integer-to-roman/`](integer-to-roman/) |
| 6  | [Zigzag Conversion](https://leetcode.com/problems/zigzag-conversion/) | 🚧 In Progress | [`zigzag/`](zigzag/) |

---

## 🏗️ Structure

Each problem lives in its own **Maven child module** under the root multi-module project:

```
leetcode/
├── pom.xml                    (parent POM — dependency management)
├── roman-to-integer/          (LeetCode #13)
│   ├── pom.xml
│   └── src/
│       ├── main/java/.../Solution.java
│       └── test/java/.../SolutionTest.java
├── integer-to-roman/          (LeetCode #12)
│   ├── pom.xml
│   └── src/
│       ├── main/java/.../Solution.java
│       └── test/java/.../SolutionTest.java
└── zigzag/                    (LeetCode #6)
    ├── pom.xml
    └── src/
        ├── main/java/.../Solution.java
        └── test/java/.../SolutionTest.java
```

**Every solution follows the same standards:**

- **Clean code** — meaningful names, small methods, no magic numbers
- **Javadoc** — every public method documents what it does and its constraints
- **Parameterized tests** — JUnit 5 `@ParameterizedTest` with `@MethodSource` for readable, data-driven coverage
- **Enum-based lookups** where appropriate (e.g., Roman numeral symbols as an enum implementing `Supplier<Integer>`)

---

## 🚀 Running Tests

**All solutions:**
```bash
mvn test
```

**Single module:**
```bash
mvn test -pl roman-to-integer
```

**With verbose output:**
```bash
mvn test -pl integer-to-roman -Dsurefire.useFile=false
```

Requires **Java 21+** and **Maven 3.9+**.

---

## 🔄 CI/CD

Every push and pull request triggers the CI pipeline via **GitHub Actions**:

1. Checkout source
2. Set up Java 21 (Temurin distribution)
3. Cache Maven dependencies
4. Run `mvn test` across all modules

GitHub Pages publishes an up-to-date site from this README on every merge to `main`.

---

## ➕ Adding a New Problem

1. Create a new directory named after the problem (kebab-case)
2. Copy the `pom.xml` pattern from an existing module (child of parent `com.github.aarondavidhughes:leetcode`)
3. Implement `src/main/java/com/github/aarondavidhughes/Solution.java`
4. Add parameterized tests in `src/test/java/com/github/aarondavidhughes/SolutionTest.java`
5. Run `mvn test -pl <new-module>` to verify
6. Update the [Problem Tracker](#-problem-table) table above
7. Add the module to the root `pom.xml` `<modules>` section
