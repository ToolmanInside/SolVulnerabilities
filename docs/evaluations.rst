#################################################
Evaluations and Analysis on 76354 Smart Contracts
#################################################

Extracting DMs From Detection Behaviors
---------------------------------------

**Table 1: The number of detected vulnerabilities at contract level and true positive (TP) rate of each scanner.**

+--------------------------+--------------+--------------+--------------+----------+
| Vulnerability (TP Rate)  | Slither      | Oyente       | Smartcheck   | Securify |
| -------------------------+--------------+--------------+--------------+----------+
| Reentrancy               | 498 (9.24%)  | 108 (50.93%) | x            |          |
+--------------------------+--------------+--------------+--------------+----------+
| Abuse of tx.origin       | 34 (100.0%)  | x            | 210 (29.05%) | x        |
+--------------------------+--------------+--------------+--------------+----------+
| Unchecked low level call | x            | x            | 551 (65.70%) | x        |
+--------------------------+--------------+--------------+--------------+----------+
| Unexpected revert        | 666 (35.29%) | x            | 274 (93.79%) | x        |
+--------------------------+--------------+--------------+--------------+----------+
| Self destruct            | 46 (23.91%)  | x            | x            | x        |
+--------------------------+--------------+--------------+--------------+----------+

As shown in Table 1, we apply the three scanners on the six types of vulnerabilities. Overall, among these three scanners, **Slither** seems to achieve the best results, reporting most vulnerabilities---totally 2631 vulnerability candidates of five types. In contrast, **Smartcheck** reports 1072 candidates and **Oyente** reports only 588 candidates.  However, due to the  internal detection mechanisms, each scanner inevitably yields some FPs.

After manual inspection of human expertise, the TP rate is shown at the second row of each cell in Table 1. In generally, **Slither** reports the most candidates, but suffers from a big issue of a high FP rate. Especially for reentrancy, the TP rate of **Slither** is only about 9%. As dynamic analysis is more accurate, **Oyente**'s TP is still acceptable. To some extent, it is unexpected that the TP rate of **Smartcheck** is good. We review some FPs of these scanners as below.

As the reentrancy caused some significant losses in the past `daoAttack <https://doi.org/10.1109/ICSAI.2017.8248566>`_, the real contracts on Ethereum have already adopted some DMs to prevent from the actual invocation of reentrancy.  We summarize the five main categories of DMs: 

-  Hard-coding the constant value for the address of payee or payer
-  Using ``private`` modifier for the function declaration
-  Adding the self-predefined modifier in the function declaration 
-  Using ``if`` lock(s) to prevent reentrancy. However, these DMs are seldom discussed in relevant studies or considered in existing scanners. Hence, the ignorance about possible DMs will result in the high FP rate of detection


For the first DM, in `CB1 <CBs/CB1_>`_, according to rule of **Slither**:

.. math::

    r(var_{g}) \vee w(var_{g}) \succ externCall \succ w(var_{g}) \Rightarrow \text{reentrancy}


CB1_ is reported as a reentrancy  by **Slither**---firstly, it writes to the public variable ``total_reward``; then calls external function ``buyTokens.value``; last, writes to the public variable ``winnerPoolTotal``. However, in reality, reentrancy will never be triggered by external attackers due to the hard-coded address value at line 13 in CB1_. Similarly, in CB2_, we show a FP for **Oyente**, according to its run-time detection rule below:


.. math::

    \big ( r(var_{g}) \wedge (gas_{trans}) > 2300) \wedge (amt_{bal} > amt_{trans}) \wedge var_{g} \text{changed before external call \big ) \Rightarrow \text{reentrancy}


where r(varg) means read operation(s) to a public variable, gas(trans) > 2300 means the gas for transaction must be larger than 2300, amt(bal) > amt(trans) means the balance amount must be larger than transfer amount, and lastly the global variable could be changed before external calls.


Although CB2_ satisfies all the four conditions, it actually could not be triggered by external attackers, again due to the only hard-coded address allowed in the transaction.


For the second DM of using private modifier, the existing scanners fail to consider that. In our manual inspection  of FPs, we consider the following defense is successful: if this private function (reported by **Slither** or **Oyente** as reentrancy) is never called by other public  functions in the same contract, or only called by the public functions that have no loop path in  their CFGs. Under such scenario, the reported function will actually never be recursively called by external attackers. For example, if we changed the modifier of  function ``buyOne`` from ``public`` to ``private`` at line 1 in CBoriginal_, **Slither** would still report it as a reentrancy vulnerability---but it could never be called by external attackers, as it is not called in other functions. We find that **Oyente** also suffers from this FP issue.


For the third DM of adopting user-defined modifier for protection, we find some interesting cases that are falsely reported by existing scanners. For example, CB3_ actually takes into account the security issue and adds the self-defined modifier *onlyAdmin* before the possibly vulnerable function ``regstDocs``. Since ``onlyAdmin`` restricts that the transaction can be only done by the ``admin`` or ``owner`` role, otherwise the transactions will be reverted. In such a way, ``regstDocs`` could not be recursively called by external attackers.


Different from the above three DMs on permission control to prevent external malicious calls, the last DM is to prevent the recursive entrance for the function---eliminating the issue from root. For instance, in CB4_, the internal instance variable ``reEntered`` will be checked at line 5 before processing the business logic between line 8 and 10. To prevent the reentering due to calling ``ZTHTKN.buyAndSetDivPercentage.value``, ``reEntered`` will switched to ``true``; after the transaction is done, it will be reverted to ``false`` to allow other transactions.


Totally, 457 FP cases are manually identified for **Slither**. Among them, 216 FPs are attributed for the first DM,  76 FPs for the second,  47 FPs for the third, and only 1 FP for the forth DM and 117 for other causes. In contrast, **Oyente** has fewer FP cases (only 53 in total), among which the distribution for the four caused DMs is 5, 5, 22 and 0. 


FPs of Unexpected Revert
------------------------


Though **Slither** and **Smartcheck** can detect some cases, their rules currently are so general that most reported cases are actually bad coding practices (e.g., warnings hinted by the IDE) rather than exploitable vulnerabilities. Specifically, **Slither** reports 666 cases of calls in loop, as long as an external call (e.g., ``send`` or ``transfer`` of other addresses) is inside a loop, regardless of its actual impact. For instance, CB5_ reported by **Slither** will not cause expected revert, as ``require`` is not used to check the return value of function ``send``. Similarly, **Smartcheck** also supports the detection of transfer in loop. As **Smartcheck** checks only ``transfer`` in a loop, it reports a much smaller number (274) than that of **Slither** (666). However, after manual auditing, we find that they report many common TPs, with 235 TPs for **Slither** and 257 TPs for **Smartcheck**. Most FPs of **Slither** are due to inconsideration of the key ``require`` check that causes reverting.


According to our observation, the rules of call/transaction in loop are neither sound nor complete to cover most of unexpected revert cases. At least, modifier ``require``  is ignored in these two rules, which makes **Slither** and **Smartcheck** incapable to check possible revert operations on multiple account addresses. Here,  multiple accounts must be involved for exploiting this attack---the failure on one account blocks other accounts via reverting the operations for the whole loop. Hence, CB6_ reported by **Smartcheck** is FP, as the operations in the loop are all on the same account (i.e., ``sender`` at line 8) and potential revert will not affect other accounts.


FPs of Tx.origin Abusing
------------------------


For this vulnerability, **Slither** reports 34 results, none of which are FPs. **Slither**'s rule is simple but effective:

.. math::

    access(Tx.origin) \wedge inContrFlowCondi(Tx.origin) \Rightarrow \text{Tx.origin abusing}


It finds all ``Tx.origin`` that appears in control flow condition. The rationale is that accessing ``Tx.Origin`` is just a bad programming practice by itself, not vulnerable. Only when used in control flow conditions, it could be manipulated for control flow hijack.

In contrast, **Smartcheck** reports much more cases (210) than **Slither** (34), as it is more complete in considering both control flow conditions inside a function  and the modifier code outside the function: 


.. math::

    access(Tx.origin) \wedge \big (inContrFlowCondi(Tx.origin) \vee inModifierCode(Tx.origin) \big ) \Rightarrow \text{Tx.origin abusing}

As shown in CB3_, self-defined modifier (e.g., ``onlyAdmin``) can be imported before the function. As such modifier is used for permission control, it also affects the control flow of the program. The 149 FPs of **Smartcheck** (70.95%) are due to the reason that ``Tx.origin`` is used for a parameter of a function call, and then the return value of the function call is neither check nor used---making ``Tx.origin`` have no actual impact on control flow.


FPs of Unchecked Low-Level-Call
-------------------------------

Only **Smartcheck** reports this vulnerability by checking whether the following functions are under the check: ``callcode()``, ``call()``, ``send()`` and ``delegatecall()``. Note that the check can be done in several ways: 

1.  Using the built-in keyword ``require`` and ``assert``
2.  Using the ``if`` condition check
3.  Using the self-defined exception-handler class to capture the error-prone low-level-call. According to `this paper <http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8445052&isnumber=8445042>`_, the rule in **Smartcheck** is called unchecked external call, which checks whether calls of the above 4 functions are inside ``if`` conditions


However, in its implementation, we find that it actually checks not only calls of the 4 low-level functions, but also calls of some user-defined functions. Hence, checking extra calls of user-defined functions yields 189 FPs out of 551 results.


FPs of Self-destruct Abusing
----------------------------


In the existing scanners, only **Slither** detects the misuse of self-destruct, which is called suicidal detection.  Totally, **Slither** reports 49 cases of suicidal via its built-in rule---as long  as function ``selfdestruct`` is used, no matter what the context is, **Slither** will report it. Obviously, the **Slither**'s rule is too simple and too board. It mainly works for the direct calling of ``selfdestruct``  without any permission control or conditions of business logic---under such circumstance (11 out of 46), the **Slither** rule can help to detect the abusing. In practice, in most cases (35 out of 46) ``selfdestruct`` is called with the ``admin`` or ``owner`` permission control or under some strict conditions of some business logic. For example, ``selfdestruct`` is indeed required in the business logic of the in CB7_, as the owner wants to reset the contract via calling ``selfdestruct`` after the transactions in a period are all done and the contract is not active (i.e., the condition at line 2). Note that  parameter ``burn`` is just padded to call ``selfdestruct`` in a correct way.

To sum up, no single scanner can dominate others by achieving the best precision and recall at the same time. In RQ1, we focus on their FPs to formulate  the refined rules that consider the DMs. 


Evaluating the Extracted AVS
----------------------------


Based on  the TPs reported by the existing scanners, we automatically extract the AVS. 

+------+------------+-----------+-----------------+-----------------+---------------+
|      | Reentrancy | Tx.origin | Unchecked L.L.C | Unexpect Revert | Self Destruct |
+------+------------+-----------+-----------------+-----------------+---------------+
| #AVS | 20         | 5         | 4               | 8               | 5             |
+------+------------+-----------+-----------------+-----------------+---------------+


In this table, we show the number of the extracted AVS for each vulnerability type. Totally, from the existing TPs we learn 47 AVS, 43% of which are of reentrancy. The rationale is that there exist similar business logic or implementation routines for the reentrancy vulnerability. For example, for the 96 TPs of reentrancy found by **Slither** and **Oyente**, we apply the AST tree-edit distance based clustering method and get 24 clusters (when setting the cluster width is 100 edits). After manual inspection, we find 20 clusters are representative and can serve as the AVS for discovering more unknown ones. For example,  for some functions (e.g., ``buyFirstTokens``,  ``sellOnApprove``, ``sendEthProportion`` and so on), we find their cloned instances of an extent of similarity due to the copy-paste-modify paradigm. For these cloned instances, we apply the code differencing to extract the AVS and further refine the AVS to retain the core parts via manual inspection.

For unexpected revert, we also find there exist some cloned instances between TPs. Especially, for the two typical scenario of  unexpected revert---the revert on single account and the revert due to failed operations on multiple accounts via a loop, we get totally 8 AVS via clustering  more than 200 TPs that are reported by **Slither** or **Oyente**.

For other vulnerability types, we cannot get clusters of cloned function instances due to the fact that the triggering of vulnerability requires not much context. Since the remaining four types are all about improper checks, we design 4 or 5 AVS for each type. For example, regarding ``Tx.origin`` abusing, the existing scanners mainly check whether it is inside ``if`` statement. According to the observation mentioned in examples, we extend this with more AVS, such as checking ``Tx.origin`` inside  ``require``, ``assert`` and ``if-throw``. Similarly, we derive 5 AVS for time manipulation. Last, for unchecked low-level-call, 4 AVS are proposed to catch the improper low-level calls in loop without any validation check on return values, for functions ``call()``, ``callcode()``, ``delegatecall()`` and ``send()``.