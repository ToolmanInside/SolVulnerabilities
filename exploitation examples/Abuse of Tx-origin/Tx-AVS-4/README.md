## Vulnerable Code

```javascript
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
    //out10469
```



## Exploit Code

```javascript
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
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position. Due to the 'tx.origin' ,whoever call this victim's method such as "stake", 'tx.origin' do not change.so the location of comment of vulnerability position is possible always success.ps:"...." represent an appropriate parameter

