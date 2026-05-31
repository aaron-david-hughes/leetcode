#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
# add-problem.sh — Scaffold a new LeetCode problem module
#
# Expected environment variables (set from workflow inputs):
#   PROBLEM_NUMBER   — e.g. "1"
#   PROBLEM_TITLE    — e.g. "Two Sum"
#   PROBLEM_DESC     — (optional) full problem description text
#   METHOD_SIGNATURE — e.g. "int[] twoSum(int[] nums, int target)"
# ──────────────────────────────────────────────────────────────

# ── Derive kebab-case module name ─────────────────────────────
MODULE_NAME=$(echo "$PROBLEM_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
echo "📦 Module name: ${MODULE_NAME}"

# ── Determine return default from method signature ────────────
DEFAULT_RETURN="null"
METHOD_NAME="solve"
PARAMS=""
if [[ -n "${METHOD_SIGNATURE:-}" ]]; then
  # Extract return type (everything before the first space-followed-by-identifier-open-paren)
  RETURN_TYPE=$(echo "$METHOD_SIGNATURE" | sed 's/^\([^(]*\) .*/\1' | xargs)
  METHOD_NAME=$(echo "$METHOD_SIGNATURE" | sed 's/^[^ ]* \([^(]*\) .*/\1')
  # Extract params between parens
  PARAMS=$(echo "$METHOD_SIGNATURE" | sed 's/^.*(\(.*\)).*/\1/')

  case "$RETURN_TYPE" in
    int)        DEFAULT_RETURN="-1" ;;
    long)       DEFAULT_RETURN="-1L" ;;
    double)     DEFAULT_RETURN="-1.0" ;;
    float)      DEFAULT_RETURN="-1.0f" ;;
    boolean)    DEFAULT_RETURN="false" ;;
    String)     DEFAULT_RETURN='""' ;;
    void)       DEFAULT_RETURN="" ;;
    char)       DEFAULT_RETURN="'\\0'" ;;
    int\[\])    DEFAULT_RETURN="new int[0]" ;;
    long\[\])   DEFAULT_RETURN="new long[0]" ;;
    double\[\]) DEFAULT_RETURN="new double[0]" ;;
    String\[\]) DEFAULT_RETURN="new String[0]" ;;
    char\[\])   DEFAULT_RETURN="new char[0]" ;;
    boolean\[\]) DEFAULT_RETURN="new boolean[0]" ;;
    List\*|ArrayList*)
                DEFAULT_RETURN="new ArrayList<>()" ;;
    *)
                # If it ends with [], treat as array
                if [[ "$RETURN_TYPE" == *"[]" ]]; then
                  DEFAULT_RETURN="new ${RETURN_TYPE} {}"
                else
                  DEFAULT_RETURN="null"
                fi
                ;;
  esac
fi

echo "🔧 Method: ${METHOD_NAME} → ${RETURN_TYPE:-<none>} → default: ${DEFAULT_RETURN}"
echo "   Params: ${PARAMS}"

# ── Build default-return statement for the stub ───────────────
if [[ -z "$DEFAULT_RETURN" ]]; then
  DEFAULT_STUB=""           # void method — no return
elif [[ "$DEFAULT_RETURN" == "null" ]]; then
  DEFAULT_STUB="return null;"
else
  DEFAULT_STUB="return ${DEFAULT_RETURN};"
fi

# ── Build parameter list with type erasure for the stub ───────
# For the stub, we keep the real types so it compiles cleanly
STUB_PARAMS="$PARAMS"

# ── Create directory structure ────────────────────────────────
MODULE_DIR="${MODULE_NAME}"
SRC_MAIN="${MODULE_DIR}/src/main/java/com/github/aarondavidhughes"
SRC_TEST="${MODULE_DIR}/src/test/java/com/github/aarondavidhughes"

mkdir -p "$SRC_MAIN" "$SRC_TEST"
echo "📁 Created directory structure"

# ── Generate module pom.xml ───────────────────────────────────
cat > "${MODULE_DIR}/pom.xml" <<POMEOF
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.github.aarondavidhughes</groupId>
        <artifactId>leetcode</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>${MODULE_NAME}</artifactId>
    <packaging>jar</packaging>

    <dependencies>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.mockito</groupId>
            <artifactId>mockito-junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

</project>
POMEOF
echo "📄 Generated pom.xml"

# ── Generate README.md ────────────────────────────────────────
LEETCODE_URL="https://leetcode.com/problems/${MODULE_NAME}/"

if [[ -n "${PROBLEM_DESC:-}" ]]; then
  cat > "${MODULE_DIR}/README.md" <<READMEEOF
# ${PROBLEM_TITLE}

[LeetCode #${PROBLEM_NUMBER}](${LEETCODE_URL})

${PROBLEM_DESC}
READMEEOF
else
  cat > "${MODULE_DIR}/README.md" <<READMEEOF
# ${PROBLEM_TITLE}

[LeetCode #${PROBLEM_NUMBER}](${LEETCODE_URL})

> Problem description not provided — visit the link above for the full statement.
READMEEOF
fi
echo "📄 Generated README.md"

# ── Generate Solution.java stub ───────────────────────────────
if [[ -n "${METHOD_SIGNATURE:-}" ]]; then
  # Normalize: collapse newlines/spaces in the signature to a single-line form
  CLEAN_SIG=$(echo "$METHOD_SIGNATURE" | tr '\n' ' ' | sed 's/  */ /g' | xargs)
  cat > "${SRC_MAIN}/Solution.java" <<JAVAEOF
package com.github.aarondavidhughes;

public class Solution {

    /**
     * TODO: implement
     *
     * @see <a href="${LEETCODE_URL}">LeetCode #${PROBLEM_NUMBER} — ${PROBLEM_TITLE}</a>
     */
    public ${CLEAN_SIG} {
        ${DEFAULT_STUB}
    }
}
JAVAEOF
else
  cat > "${SRC_MAIN}/Solution.java" <<JAVAEOF
package com.github.aarondavidhughes;

public class Solution {

    /**
     * TODO: implement
     *
     * @see <a href="${LEETCODE_URL}">LeetCode #${PROBLEM_NUMBER} — ${PROBLEM_TITLE}</a>
     */
    public Object solve() {
        return null;
    }
}
JAVAEOF
fi
echo "📄 Generated Solution.java"

# ── Generate SolutionTest.java stub ───────────────────────────
cat > "${SRC_TEST}/SolutionTest.java" <<TESTEOF
package com.github.aarondavidhughes;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class SolutionTest {

    private final Solution solution = new Solution();

    @Test
    void todo() {
        // TODO: replace with parameterized tests
        assertTrue(true);
    }
}
TESTEOF
echo "📄 Generated SolutionTest.java"

# ── Update parent pom.xml — insert module alphabetically ─────
# Use a simple sed-based insertion while maintaining alphabetical order
# We add the <module> line only if it's not already present
if grep -q "<module>${MODULE_NAME}</module>" pom.xml; then
  echo "⚠️  Module '${MODULE_NAME}' already listed in parent pom.xml — skipping"
else
  # Find the right insertion point inside <modules>…</modules>
  # We want to insert before the first module that sorts *after* ours alphabetically
  # If ours sorts last, insert before </modules>

  # Extract all current modules
  CURRENT_MODULES=$(sed -n '/<modules>/,/<\/modules>/p' pom.xml | grep '<module>' | sed 's/.*<module>\(.*\)<\/module>.*/\1/')

  INSERT_BEFORE=""
  for mod in $CURRENT_MODULES; do
    if [[ "$mod" > "$MODULE_NAME" ]]; then
      INSERT_BEFORE="$mod"
      break
    fi
  done

  if [[ -n "$INSERT_BEFORE" ]]; then
    sed -i "s|<module>${INSERT_BEFORE}</module>|<module>${MODULE_NAME}</module>\n        <module>${INSERT_BEFORE}</module>|" pom.xml
  else
    # Insert before </modules> (it's alphabetically last)
    sed -i "s|</modules>|        <module>${MODULE_NAME}</module>\n    </modules>|" pom.xml
  fi
  echo "📝 Updated parent pom.xml"
fi

# ── Update root README.md — insert tracker row by descending problem number ──
if grep -q "| ${PROBLEM_NUMBER} " README.md; then
  echo "⚠️  Problem #${PROBLEM_NUMBER} already in README tracker — skipping"
else
  NEW_ROW="| ${PROBLEM_NUMBER} | [${PROBLEM_TITLE}](${LEETCODE_URL}) | 🚧 In Progress | [\`${MODULE_NAME}/\`](${MODULE_NAME}/) |"

  # Find the right row to insert after (descending problem number order)
  # We need to find the first row in the table with a number LESS than ours
  # and insert our row ABOVE it. If all existing rows have higher numbers, we
  # insert after the last row.
  HEADER_LINE=$(grep -n '"| # | Problem | Status | Solution |"' README.md | head -1 | cut -d: -f1)
  if [[ -z "$HEADER_LINE" ]]; then
    HEADER_LINE=$(grep -n '| # | Problem | Status | Solution |' README.md | head -1 | cut -d: -f1)
  fi
  if [[ -z "$HEADER_LINE" ]]; then
    HEADER_LINE=$(grep -n '|---|' README.md | head -2 | tail -1 | cut -d: -f1)
  fi

  # Extract data rows (after header + separator), find insertion point
  INSERT_LINE=""
  while IFS= read -r line; do
    # Extract problem number from row
    NUM=$(echo "$line" | sed 's/^| \([0-9]*\) .*/\1/' | tr -d ' ')
    if [[ "$NUM" =~ ^[0-9]+$ ]] && [[ "$NUM" -lt "$PROBLEM_NUMBER" ]]; then
      # Get line number of this row
      ROW_LINE=$(grep -nF "$line" README.md | head -1 | cut -d: -f1)
      INSERT_LINE="$ROW_LINE"
      break
    fi
  done < <(tail -n +$((HEADER_LINE + 2)) README.md | grep '^|')

  if [[ -n "$INSERT_LINE" ]]; then
    sed -i "${INSERT_LINE}i\\
${NEW_ROW}" README.md
  else
    # Ours is the smallest number — insert after the last table row
    # Find the last table row (line starting with | and within the table section)
    LAST_ROW_LINE=""
    while IFS= read -r line; do
      ROW_NUM=$(echo "$line" | grep -c '^|')
      if [[ "$ROW_NUM" -gt 0 ]]; then
        LINE_NUM=$(grep -nF "$line" README.md | head -1 | cut -d: -f1)
        if [[ -n "$LINE_NUM" ]] && [[ "$LINE_NUM" -gt "$HEADER_LINE" ]]; then
          LAST_ROW_LINE="$LINE_NUM"
        fi
      fi
    done < <(tail -n +$((HEADER_LINE + 2)) README.md | grep '^|')
    if [[ -n "$LAST_ROW_LINE" ]]; then
      sed -i "$((LAST_ROW_LINE + 1))i\\
${NEW_ROW}" README.md
    else
      # Fallback: insert right after the header separator
      sed -i "$((HEADER_LINE + 1))i\\
${NEW_ROW}" README.md
    fi
  fi
  echo "📝 Updated README.md tracker"
fi

echo ""
echo "✅ Module '${MODULE_NAME}' scaffolded successfully!"
echo "   Branch: add-${MODULE_NAME}"
echo "   Files:"
echo "     ${MODULE_DIR}/pom.xml"
echo "     ${MODULE_DIR}/README.md"
echo "     ${SRC_MAIN}/Solution.java"
echo "     ${SRC_TEST}/SolutionTest.java"
