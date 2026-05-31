package com.github.aarondavidhughes;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.*;

class SolutionTest {

    private final Solution solution = new Solution();

    @ParameterizedTest(name = "should produce [{2}] when input [{0}] and number of rows [{1}]")
    @MethodSource("zigzagTestCases")
    void shouldProduceZigZagStringAsExpected(String input, int numRows, String expected) {
        assertEquals(expected, solution.convert(input, numRows));
    }

    private static Stream<Arguments> zigzagTestCases() {
        return Stream.of(
                Arguments.of("PAYPALISHIRING", 3, "PAHNAPLSIIGYIR"),
                Arguments.of("PAYPALISHIRING", 4, "PINALSIGYAHRPI"),
                Arguments.of("A", 1, "A"),
                Arguments.of("AB", 1, "AB"),
                Arguments.of("ABCDEFG", 1, "ABCDEFG"),
                Arguments.of("ABCDEFG", 2, "ACEGBDF")
        );
    }
}
