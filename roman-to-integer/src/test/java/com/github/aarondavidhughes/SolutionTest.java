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
    void romanToIntTest(String s, int expected) {
        assertEquals(expected, solution.romanToInt(s));
    }

    private static Stream<Arguments> sample() {
        return Stream.of(
                Arguments.of("III", 3),
                Arguments.of("LVIII", 58),
                Arguments.of("MCMXCIV", 1994)
        );
    }
}