package com.github.aarondavidhughes;

import java.util.ArrayList;
import java.util.List;

public class Solution {

    /**
     * @see <a href="https://leetcode.com/problems/zigzag-conversion/">LeetCode #6 — Zigzag Conversion</a>
     */
    public String convert(String s, int numRows) {
        List<StringBuilder> rows = new ArrayList<>();

        for (int i = 0; i < numRows; i++) {
            rows.add(new StringBuilder());
        }

        int currentRow = 0;
        boolean shouldIncrement = true;
        for (char c : s.toCharArray()) {
            rows.get(currentRow).append(c);

            //this logic is broken for edge case n is only ever 1
            if (currentRow == numRows - 1) {
                shouldIncrement = false;
            }

            if (currentRow == 0) {
                shouldIncrement = true;
            }


            if (numRows != 1 && shouldIncrement) {
                currentRow++;
            } else if (numRows != 1) {
                currentRow--;
            }
        }

        StringBuilder output = new StringBuilder();

        for (int i = 0; i < numRows; i++) {
            output.append(rows.get(i));
        }

        return output.toString();
    }
}
