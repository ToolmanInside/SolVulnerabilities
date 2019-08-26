# Doublade

In, our experiment studies, we conduct...

### Evaluating the Existing Tools

##### Table 1: The number of detected vulnerabilities at contract level and true positive (TP) rate of each scanner.

| Vulnerability (TP Rate)  | Slither      | Oyente       | Smartcheck   | Securify |
| ------------------------ | ------------ | ------------ | ------------ | -------- |
| Reentrancy               | 498 (9.24%)  | 108 (50.93%) | x            |          |
| Abuse of tx.origin       | 34 (100.0%)  | x            | 210 (29.05%) | x        |
| Unchecked low level call | x            | x            | 551 (65.70%) | x        |
| Unexpected revert        | 666 (35.29%) | x            | 274 (93.79%) | x        |
| Self destruct            | 46 (23.91%)  | x            | x            | x        |

As shown in Table 1, we apply the three scanners on the six types of vulnerabilities. Overall, among these three scanners, **Slither** seems to achieve the best results, reporting most vulnerabilities---totally 2631 vulnerability candidates of five types. In contrast, **Smartcheck** reports 1072 candidates and **Oyente** reports only 588 candidates.  However, due to the  internal detection mechanisms, each scanner inevitably yields some FPs.

 After manual inspection of human expertise, the TP rate is shown at the second row of each cell in Table 1. In generally, **Slither** reports the most candidates, but suffers from a big issue of a high FP rate. Especially for *Reentrancy*, the TP rate of **Slither** is only about 9%. As dynamic analysis is more accurate, **Oyente**'s TP is still acceptable. To some extent, it is unexpected that the TP rate of **Smartcheck** is good. We review some FPs of these scanners as below.

##### Table 2: \textbf{CB8}: a real case of using constant value for the account address, which is a FP for \slither.

$$ \big ( r(var_{g}) \wedge (gas_{trans} > 2300) \wedge (amt_{bal} > amt_{trans}) \wedge var_{g} \text{~is changad before external call} \big )  \Rightarrow \text{reentrancy} $$

