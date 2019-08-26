 function buyOne(ERC20 token, address _exchange, uint256 _value, bytes _data) payable public {
   uint256 tokenBalance = token.balanceOf(this);
   balances[msg.sender] = balances[msg.sender].add(msg.value);
   require(_exchange.call.value(_value)(_data));		
   balances[msg.sender] = balances[msg.sender].sub(_value);	
   tokenBalances[msg.sender][token] = tokenBalances[msg.sender][token].add(token.balanceOf(this)
  		  .sub(tokenBalance));
 }