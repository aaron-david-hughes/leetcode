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
  # Extract return type (everything before the first space)
  RETURN_TYPE="${METHOD_SIGNATURE%% *}"
  # Extract method name (between first space and first open paren)
  REST="${METHOD_SIGNATURE#* }"
  METHOD_NAME="${REST%%(*}"
  # Trim trailing whitespace from method name
  METHOD_NAME="${METHOD_NAME%"${METHOD_NAME##*[! ]}"}"
  # Extract params between outermost parens
  PARAMS="${REST#*(}"
  PARAMS="${PARAMS%)}"

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
    List*|ArrayList*)
                DEFAULT_RETURN="new ArrayList<>()" ;;
    *)
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
  DEFAULT_STUB=""
elif [[ "$DEFAULT_RETURN" == "null" ]]; then
  DEFAULT_STUB="return null;"
else
  DEFAULT_STUB="return ${DEFAULT_RETURN};"
fi

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
if grep -q "<module>${MODULE_NAME}</module>" pom.xml; then
  echo "⚠️  Module '${MODULE_NAME}' already listed in parent pom.xml — skipping"
else
  # Use awk for reliable cross-platform insertion with newlines
  CURRENT_MODULES=$(awk '/<modules>/{found=1} found{print} /<\/modules>/{found=0}' pom.xml | grep '<module>' | sed 's|.*<module>\(.*\)</module>.*|\1|')

  INSERT_BEFORE=""
  for mod in $CURRENT_MODULES; do
    if [[ "$mod" > "$MODULE_NAME" ]]; then
      INSERT_BEFORE="$mod"
      break
    fi
  done

  if [[ -n "$INSERT_BEFORE" ]]; then
    awk -v new_mod="${MODULE_NAME}" -v insert_before="${INSERT_BEFORE}" '
      $0 ~ "<module>" insert_before "</module>" {
        print "        <module>" new_mod "</module>"
        print $0
        next
      }
      { print }
    ' pom.xml > pom.xml.tmp && mv pom.xml.tmp pom.xml
  else
    awk -v new_mod="${MODULE_NAME}" '
      /<\/modules>/ {
        print "        <module>" new_mod "</module>"
        print $0
        next
      }
      { print }
    ' pom.xml > pom.xml.tmp && mv pom.xml.tmp pom.xml
  fi
  echo "📝 Updated parent pom.xml"
fi

# ── Update root README.md — insert tracker row by descending problem number ──
if grep -q "| ${PROBLEM_NUMBER} " README.md; then
  echo "⚠️  Problem #${PROBLEM_NUMBER} already in README tracker — skipping"
else
  NEW_ROW="| ${PROBLEM_NUMBER} | [${PROBLEM_TITLE}](${LEETCODE_URL}) | [\`${MODULE_NAME}/\`](${MODULE_NAME}/) |"

  # Find the header line of the tracker table
  HEADER_LINE=$(grep -n '| # | Problem | Status | Solution |' README.md | head -1 | cut -d: -f1)
  if [[ -z "$HEADER_LINE" ]]; then
    HEADER_LINE=$(grep -n '|---|' README.md | head -2 | tail -1 | cut -d: -f1)
  fi

  # Find the insertion line: first row with a number less than ours
  # (table is in descending order, so we insert ABOVE that row)
  INSERT_LINE=""
  while IFS= read -r line; do
    NUM=$(echo "$line" | sed 's#^| \([0-9]*\) .*#\1#' | tr -d ' ')
    if [[ "$NUM" =~ ^[0-9]+$ ]] && [[ "$NUM" -lt "$PROBLEM_NUMBER" ]]; then
      ROW_LINE=$(grep -nF "$line" README.md | head -1 | cut -d: -f1)
      INSERT_LINE="$ROW_LINE"
      break
    fi
  done < <(tail -n +$((HEADER_LINE + 2)) README.md | grep '^|')

  if [[ -n "$INSERT_LINE" ]]; then
    # Insert new row before the found line
    awk -v line_num="$INSERT_LINE" -v new_row="$NEW_ROW" '
      NR == line_num { print new_row }
      { print }
    ' README.md > README.md.tmp && mv README.md.tmp README.md
  else
    # Ours is the smallest number — insert after the last table row
    LAST_ROW_LINE=""
    while IFS= read -r line; do
      if echo "$line" | grep -q '^|'; then
        LINE_NUM=$(grep -nF "$line" README.md | head -1 | cut -d: -f1)
        if [[ -n "$LINE_NUM" ]] && [[ "$LINE_NUM" -gt "$HEADER_LINE" ]]; then
          LAST_ROW_LINE="$LINE_NUM"
        fi
      fi
    done < <(tail -n +$((HEADER_LINE + 2)) README.md | grep '^|')
    if [[ -n "$LAST_ROW_LINE" ]]; then
      awk -v line_num="$((LAST_ROW_LINE + 1))" -v new_row="$NEW_ROW" '
        NR == line_num { print new_row }
        { print }
      ' README.md > README.md.tmp && mv README.md.tmp README.md
    else
      awk -v line_num="$((HEADER_LINE + 1))" -v new_row="$NEW_ROW" '
        NR == line_num { print new_row }
        { print }
      ' README.md > README.md.tmp && mv README.md.tmp README.md
    fi
  fi
  echo "📝 Updated README.md tracker"
fi

echo ""
echo "Module '${MODULE_NAME}' scaffolded successfully."
echo ""
echo "Branch: add-${MODULE_NAME}"
echo "URL: https://github.com/${GITHUB_REPOSITORY:-aaron-david-hughes/leetcode}/tree/add-${MODULE_NAME}"
echo ""
echo "Files created:"
echo "  ${MODULE_DIR}/pom.xml"
echo "  ${MODULE_DIR}/README.md"
echo "  ${SRC_MAIN}/Solution.java"
echo "  ${SRC_TEST}/SolutionTest.java"
