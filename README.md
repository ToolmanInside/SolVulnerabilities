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

As the reentrancy caused some significant losses in the past [daoAttack](https://doi.org/10.1109/ICSAI.2017.8248566), the real contracts on Ethereum have already adopted some DMs to prevent from the actual invocation of reentrancy.  We summarize the five main categories of DMs: 

* Hard-coding the constant value for the address of payee or payer
* Using `private` modifier for the function declaration
* Adding the self-predefined modifier in the function declaration 
* Using `if` lock(s) to prevent reentrancy. However, these DMs are seldom discussed in relevant studies or considered in existing scanners. Hence, the ignorance about possible DMs will result in the high FP rate of detection

For example, in Fig.~\ref{fig:evaluation:fp1}, according to Rule~\ref{rule:slither:reentrance}, CB8 is reported as a {reentrancy}  by \slither---firstly, it writes to the \codeff{public} variable \codeff{total\_reward}; then calls \codeff{external} function \codeff{buyTokens.value}; last, writes to the \codeff{public} variable \codeff{winnerPoolTotal}. However, in reality, reentrancy will never be triggered by external attackers due to the hard-coded address value at line 13 in Fig.~\ref{fig:evaluation:fp1}. Similarly, in Fig.~\ref{fig:evaluation:fp2}, we show a FP for \oyento, according to its run-time detection rule below\footnote{We summarize this rule from the implementation of \oyento.}:

![](fig/oyente_rule.png)

