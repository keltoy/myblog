---
title: Mathematics for Thinking Code
date: 2016-10-02 14:42:21
tags: [code, math]
---
# Preface

>Histories make men wise; poets, witty; the mathematics, subtle; natural philosophy, deep; moral, grave; logic and rhetoric, able to contend.
>-- Francis Bacon, The Collected Works of Sir Francis Bacon


It is very significant that mathematics for programmer. A skilled programmer, who is good at mathematics, is able to simplify problems whatever in life or engineering.
A textbook, [Mathematics for Computer Science](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-042j-mathematics-for-computer-science-spring-2015/readings/MIT6_042JS15_textbook.pdf), makes me learn a lot.

# Proofs
Soon

# Structures
not prepared

# Counting
## Greatest Common Divisor

$$
GCD(m, n) =
\begin{cases}
GCD(n, m MOD n), & m \gt n
\\ m, & m & MOD & n = 0
\\ GCD(n, m) & m \lt n
\end{cases}
$$

## Least Common Multiple

$$
LCM(m, n) = (m * n)/GCD(m, n)
$$
# Probability
next version

# Combinatorics
## formula
### Permutations

$$ P_n^k = n(n-1)(n-2)\cdots(n-k+1) = \frac{n!}{(n-k)!} $$
### Combinations

$$ C_n^k = C_{n-1}^{k-1} + C_{n-1}^{k} $$

$$ C_n^k = \frac{P_n^k}{k!} = \frac{n!}{k!(n-k)!)} = C_n^{n-k} $$

# Conclusion

It is not the end, It is just beginning...
