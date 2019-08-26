# Doublade

In, our experiment studies, we conduct...

### Evaluating the Existing Tools

| Vulnerability (Precision Rate) | Slither      | Oyente       | Smartcheck   | Securify |
| ------------------------------ | ------------ | ------------ | ------------ | -------- |
| Reentrancy                     | 498 (9.24%)  | 108 (50.93%) | x            |          |
| Abuse of tx.origin             | 34 (100.0%)  | x            | 210 (29.05%) | x        |
| Unchecked low level call       | x            | x            | 551 (65.70%) | x        |
| Unexpected revert              | 666 (35.29%) | x            | 274 (93.79%) | x        |
| Self destruct                  | 46 (23.91%)  | x            | x            | x        |

As shown in Table~\ref{tab:rq1}, we apply the three scanners on the six types of vulnerabilities. % (out of the top ten  of vulnerabilities  for smart contracts \cite{dasp}) that are concerned by this study. \slither~as a static analysis tool from industry, can support most of them, except for \emph{unchecked low-level-call}.  Following that is \smartcheck, which can detect 4 out of 6 types, excluding \emph{reentrancy}  and \emph{self destruct}. Last, \oyento, as a dynamic analysis tool published in 2016, mainly focuses on two types, namely \emph{reentrancy} and \emph{time manipulation}.*

Overall, among these three scanners, \slither~seems to achieve the best results, reporting most vulnerabilities---totally 2631 vulnerability candidates of five types. In contrast, \smartcheck~reports 1072 candidates and \oyento~reports only 588 candidates.  However, due to the  internal detection mechanisms, each scanner inevitably yields some FPs.

 After manual inspection of human expertise, the TP rate is shown at the second row of each cell in Table~\ref{tab:rq1}. In generally, \slither~reports the most candidates, but suffers from a big issue of a high FP rate. Especially for {reentrancy}, the TP rate of \slither~is only about 9\%. As dynamic analysis is more accurate, \oyento's TP is still acceptable. To some extent, it is unexpected that the TP rate of \smartcheck~is good. We review some FPs of these scanners as below.