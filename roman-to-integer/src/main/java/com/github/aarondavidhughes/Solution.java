package com.github.aarondavidhughes;

import java.util.function.Supplier;

public class Solution {

    /**
     * Will convert a valid roman numeral to decimal.
     * We can assume:
     * <li>
     *     <ul>valid roman numeral: no error handling required</ul>
     *     <ul>upper case: no sanitization required</ul>
     *     <ul>will be between 1 and 3999 inclusive: no bound validation required</ul>
     * </li>
     * @param s roman numeral
     * @return base 10 value
     */
    public int romanToInt(String s) {
        int value = 0;
        int i = 0;

        while (i < s.length()) {
            Symbol current = Symbol.valueOf(s.substring(i, i + 1));

            if (isNotFinalChar(i, s)) {
                Symbol next = Symbol.valueOf(s.substring(i + 1, i + 2));

                if (shouldSubtract(current, next)) {
                    value += next.get() - current.get();
                    i += 2;
                    continue;
                }
            }

            i++;
            value += current.get();
        }

        return value;
    }

    private boolean isNotFinalChar(int i, String s) {
        return i < s.length() - 1;
    }

    /**
     * Valid roman numerals are mostly descending size wise so if a smaller numeral is before a larger, we subtract.
     * @param current roman symbol
     * @param next roman symbol
     * @return if current should be subtracted from next
     */
    private boolean shouldSubtract(Symbol current, Symbol next) {
        return next.get() > current.get();
    }

    enum Symbol implements Supplier<Integer> {
        I(1),
        V(5),
        X(10),
        L(50),
        C(100),
        D(500),
        M(1000);

        private final int value;

        Symbol(int value) {
            this.value = value;
        }

        @Override
        public Integer get() {
            return value;
        }
    }
}
