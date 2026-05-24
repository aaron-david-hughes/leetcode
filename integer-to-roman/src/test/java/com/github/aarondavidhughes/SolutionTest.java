package com.github.aarondavidhughes;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.*;

class SolutionTest {

    private final Solution solution = new Solution();

    @ParameterizedTest(name = "input [{0}] should produce [{1}]")
    @MethodSource("sample")
    void romanToIntTest(int num, String expected) {
        assertEquals(expected, solution.intToRoman(num));
    }

    private static Stream<Arguments> sample() {
        return Stream.of(
                Arguments.of(3749, "MMMDCCXLIX"),
                Arguments.of(58, "LVIII"),
                Arguments.of(1994, "MCMXCIV")
        );
    }
}