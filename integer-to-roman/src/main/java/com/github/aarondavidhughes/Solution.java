package com.github.aarondavidhughes;

import java.util.function.Supplier;

public class Solution {

    public String intToRoman(int num) {
        StringBuilder roman = new StringBuilder();

        for (Symbol symbol : Symbol.values()) {
            while (num >= symbol.value) {
                roman.append(symbol.name());
                num -= symbol.value;
            }
            if (num == 0) {
                break;
            }
        }

        return roman.toString();
    }

    enum Symbol implements Supplier<Integer> {
        M(1000),
        CM(900),
        D(500),
        CD(400),
        C(100),
        XC(90),
        L(50),
        XL(40),
        X(10),
        IX(9),
        V(5),
        IV(4),
        I(1);

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
