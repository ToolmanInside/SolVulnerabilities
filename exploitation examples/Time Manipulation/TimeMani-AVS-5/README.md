## Vulnerable Code

```javascript
**Instance_1**
function withdraw() 
        gasMin
        isHuman 
        public 
        returns (bool) 
    {
        address _user = msg.sender;
        uint256 _roundCount = roundCount;
        uint256 _currentTimestamp = now;   //Vulnerable position_1
        
        require(joined[_user][_roundCount] > 0);
        require(_currentTimestamp >= roundStartTime[_roundCount]);  //Vulnerable position_2
        if (roundEndTime[_roundCount] > 0)
            require(_currentTimestamp <= roundEndTime[_roundCount] + endCoolDown);
}	


**Instance_2**
function withdraw() 
        gasMin
        isHuman 
        public 
        returns (bool) 
        {
        address _user = msg.sender;
        uint256 _roundCount = roundCount;
        uint256 _currentTimestamp = now;

        require(joined[_user][_roundCount] > 0);
        require(_currentTimestamp >= roundStartTime[_roundCount]);
        if (roundEndTime[_roundCount] > 0)
            require(_currentTimestamp <= roundEndTime[_roundCount] + endCoolDown);
        //code different
        uint256 _userBalance;
        uint256 _balance = address(this).balance;
        uint256 _totalTokens = fairExchangeContract.myTokens();
        uint256 _tokens;
        uint256 _tokensTransferRatio;
        if (!roundEnded && withdrawBlock[block.number] <= maxNumBlock) {
            _userBalance = getBalance(_user);
            joined[_user][_roundCount] = 0;
            withdrawBlock[block.number]++;

            if (_balance > _userBalance) {
                if (_userBalance > 0) {
                    _user.transfer(_userBalance);
                    emit Withdraw(_user, _userBalance);
                }
                return true;
            } else {
                if (_userBalance > 0) {
                    _user.transfer(_balance);
                    if (investments[_user][_roundCount].mul(95).div(100) > _balance) {

                        _tokensTransferRatio = investments[_user][_roundCount] / 0.01 ether * 2;
                        _tokensTransferRatio = _tokensTransferRatio > 20000 ? 20000 : _tokensTransferRatio;
                        _tokens = _totalTokens
                            .mul(_tokensTransferRatio) / 100000;
                        fairExchangeContract.transfer(_user, _tokens);
                        emit FairTokenTransfer(_user, _tokens, _roundCount);
                    }
                    roundEnded = true;
                    roundEndTime[_roundCount] = _currentTimestamp;
                    emit Withdraw(_user, _balance);
                }
                return true;
            }
        } else {

            if (!roundEnded) {
                _userBalance = investments[_user][_roundCount].mul(refundRatio).div(100);
                if (_balance > _userBalance) {
                    _user.transfer(_userBalance);
                    emit Withdraw(_user, _userBalance);
                } else {
                    _user.transfer(_balance);
                    roundEnded = true;
                    roundEndTime[_roundCount] = _currentTimestamp;
                    emit Withdraw(_user, _balance);
                }
            }
            _tokensTransferRatio = investments[_user][_roundCount] / 0.01 ether * 2;
            _tokensTransferRatio = _tokensTransferRatio > 20000 ? 20000 : _tokensTransferRatio;
            _tokens = _totalTokens
                .mul(_tokensTransferRatio) / 100000;
            fairExchangeContract.transfer(_user, _tokens);
            joined[_user][_roundCount] = 0;
            emit FairTokenTransfer(_user, _tokens, _roundCount);
        }
        return true;
}//out3671.sol
```



## Exploit Code

```javascript

```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position_1 and Vulnerable position_2.As we all know manners can change the value of block.timestamp.To a certain extent, the location of comment of vulnerability position is danger
