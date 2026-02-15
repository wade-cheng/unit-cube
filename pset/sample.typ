#import "@preview/chic-hdr:0.5.0": *

#let title = "494. Target Sum"

#set document(title: title)
#set page(
  paper: "us-letter",
  margin: 1in,
)
#set text(font: "EB Garamond", number-width: "proportional")
#show math.equation: set text(font: "Libertinus Math")
#set list(marker: [--])

#show heading: it => {
  pagebreak(weak: true)
  v(0.1in)
  block(text(it, style: "italic", weight: "regular"))
  v(4pt)
}

#set raw(theme: none)

#show: chic.with(
  chic-header(
    left-side: title,
    right-side: [Page #chic-page-number() of #context counter(page).final().at(0)]
  ),
  chic-separator(1pt),
  chic-offset(7pt),
  chic-height(2.5cm)
)

// #import "@preview/booktabs:0.0.4": *
// #show: booktabs-default-table-style

// #figure(
// //  caption: [Time with `-O0`],
//   table(
//     columns: 2,
//     toprule(),
//     [measured], [avg time (ms)],
//     midrule(),
//     $T\*$, $5094.2$,
//     $T_1$, $8957.6$,
//     $T_5$, $2040.6$,
//     $T_10$, $1418.4$,
//     $T_20$, $1235.8$,
//     bottomrule()
//   )
// )

= Problem Statement

You are given an integer array `nums` and an integer `target`.

You want to build an #strong[expression] out of nums by adding one of
the symbols `'+'` and `'-'` before each integer in nums and then
concatenate all the integers.

For example, if `nums = [2, 1]`, you can add a `'+'` before `2` and a
`'-'` before `1` and concatenate them to build the expression
`"+2-1"`.

Return the number of different #strong[expressions] that you can build,
which evaluates to `target`.

#strong[Example 1:]

```
Input: nums = [1,1,1,1,1], target = 3
Output: 5
Explanation: There are 5 ways to assign symbols to make the sum of nums be target 3.
-1 + 1 + 1 + 1 + 1 = 3
+1 - 1 + 1 + 1 + 1 = 3
+1 + 1 - 1 + 1 + 1 = 3
+1 + 1 + 1 - 1 + 1 = 3
+1 + 1 + 1 + 1 - 1 = 3
```

#strong[Example 2:]

```
Input: nums = [1], target = 1
Output: 1
```


#strong[Constraints:]

- `1 <= nums.length <= 20`
- `0 <= nums[i] <= 1000`
- `0 <= sum(nums[i]) <= 1000`
- `-1000 <= target <= 1000`

= Solution

We solve Target Sum with dynamic programming. 

We have some numbers. The problem states we must make a choice for each number: give it a positive or negative sign. Our goal is to sum these signed numbers to a target (and then count the number of times we reach our goal). 

First, let's consider an alternative view of the problem to make it easier to solve. We will start with the numbers all added together, and view our choice as between keeping the sign for a number positive or swapping the sign to negative.#footnote[The sum of these numbers will never increase, because we only ever stay the same from keeping a number positive or subtract from the sum by swapping a number to a negative. This property will be a surprise tool that will help us later.] The goal now becomes: "starting with the numbers all added together, flip signs until we get to the original target." Or equivalently, let the new target, a "bank" we are subtracting from, be set to the sum of the numbers minus the old target: we reach our goal when this bank reaches $0$.#footnote[Notice that this is now reminiscent of 322. Coin Change: #link("https://leetcode.com/problems/coin-change/description/").]

We can now define our DP recurrence. Let $op("target_sum_ways")(i, "bank")$ be the number of distinct ways to get to $"bank"$ with a summed $"nums"[0..i)$ by flipping signs in that $"nums"[0..i)$. The recurrence follows:

$
  op("target_sum_ways")(0, 0) &= 1 \
  op("target_sum_ways")(0, *) &= 0 \
  op("target_sum_ways")(i, "bank") &= op("sum") cases(
    op("target_sum_ways")(i - 1, "bank"),
    op("target_sum_ways")(i - 1, "bank"')\, "or" 0 " if bank"' < 0,
  )\
  "where bank"' &= "bank" - 2 dot "nums"[i-1] \
$

Notice we have our two cases: don't flip sign (keep $"bank"$) or do flip sign (going from a positive to a negative is like subtracting that number from $"bank"$ twice, but as defined, we can't do this if our bank goes below $0$).#footnote[This is the "surprise tool"; We can easily understand which when choices aren't possible because the sum of the numbers will never increase. Determining this is more difficult if we continued with the original problem formulation.]

To solve, just use $op("target_sum_ways")$ with $i = $ `nums.len()` and $ "bank"$ as described above. A solution in Rust, with memory-optimized DP,#footnote[Notice the direction of dependencies. We can just compute row by row. We do need to iterate over the $"bank"$ dimension in reverse so we don't influence future DP cells.] follows:

```rust
fn find_target_sum_ways(nums: Vec<i32>, target: i32) -> i32 {
    let original_bank = nums.iter().sum::<i32>() - target;
    let mut target_sum_ways = vec![0; original_bank as usize + 1];
    target_sum_ways[0] = 1;
    for i in 1..=nums.len() {
        for bank in (0..target_sum_ways.len()).rev() {
            let bank_if_sign_swap = bank as i32 - 2 * nums[i - 1];
            if bank_if_sign_swap >= 0 {
                target_sum_ways[bank] += 
                  target_sum_ways[bank_if_sign_swap as usize];
            }
        }
    }
    target_sum_ways[target_sum_ways.len() - 1]
}
```