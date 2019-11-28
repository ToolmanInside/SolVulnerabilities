CBs
========

.. _CB1:

CB1
---------

::

    interface P3DTakeout {
        function buyTokens() external payable;
    }
    contract Betting{
        ...
        uint public winnerPoolTotal;
        P3DTakeout P3DContract_;
        uint public total_reward; // reward to be awarded
        constructor() public payable {
            owner = msg.sender;
            horses.BTC = bytes32("BTC");
            P3DContract_ = P3DTakeout(0x72b2670e55139934D6445348DC6EaB4089B12576);
        ...}
        function reward() internal {
            total_reward = coinIndex[horses.BTC].total + ... ;
            P3DContract_.buyTokens.value(p3d_fee)();
            ...
            winnerPoolTotal = coinIndex[horses.BTC].total;
        ...}
    }


.. _CB2:

CB2
-------

::

    interface P3D {
        function buy(address _playerAddress) payable external returns(uint256);
    }
    contract Crop {
        ...
        function buy(address _playerAddress) external payable onlyOwner() {
            P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe).buy.value(msg.value)(_playerAddress);
        }
    ...
    }


.. _CB3:

CB3
--------

::

    contract RegDocuments {
    modifier onlyAdmin() {
        if (msg.sender!= admin && msg.sender!=owner) revert();
        ...
    }
    constructor() {
        admin = msg.sender;
        owner = 0xc238ff50c09787e7b920f711850dd945a40d3232;
    }
    function regstDocs(bytes32 _storKey) onlyAdmin payable{
        uint _value = Storage.regPrice();
        Storage.regstUser.value(_value)(_storKey);
    }		
    }
    contract GlobalStorageMultiId { // Interface for Storage
        uint256 public regPrice;
        function regstUser(bytes32 _id) payable returns(bool);
    }


CB4
--------

::

    contract ZethrBankroll is ERC223Receiving {
    ZTHInterface public ZTHTKN;
    bool internal reEntered;
    function receiveDividends() public payable {
        if (!reEntered) {
        ...
        if (ActualBalance > 0.01 ether) {
            reEntered = true;
            ZTHTKN.buyAndSetDivPercentage.value(ActualBalance)(address(0x0), 33, "");
            reEntered = false;	}
        }
    }
    }
    contract ZTHInterface {
        function buyAndSetDivPercentage(address _referredBy, uint8 _divChoice, string providedUnhashedPass) public payable returns (uint);
    }


CB5
--------

::

    function Payout(uint a, uint b) internal onlyowner {
        while (a>b) {
            uint c;
            a-=1;
            if(Tx[a].txvalue < 1000000000000000000) {
                c=4;}
            else if (Tx[a].txvalue >= 1000000000000000000) {
                c=6;}
            Tx[a].txuser.send((Tx[a].txvalue/100)*c);
        }
    }


CB6
----------

::

    function withdraw() private {
        for(uint i = 0; i < player_[uid].planCount; i++) {
            if (player_[uid].plans[i].isClose) { continue;  }
            // amount calculation
            ...
            // send the calculated amount directly to sender
            address sender = msg.sender;
            sender.transfer(amount);
            // record block number and the amount of this trans.
            player_[uid].plans[i].atBlock = block.number;
            player_[uid].plans[i].isClose = bClose;
            player_[uid].plans[i].payEth += amount;
        }
    }


CB7
--------

::

    function destroyDeed() public {
        // assure the state is not active
        require(!active);
        // if the balance is sent to the owner, destruct it
        if (owner.send(address(this).balance)) {
            selfdestruct(burn);}
    }


original CB
-----------

::

    function buyOne(ERC20 token, address _exchange, uint256 _value, bytes _data) payable public {
        uint256 tokenBalance = token.balanceOf(this);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        require(_exchange.call.value(_value)(_data));		
        balances[msg.sender] = balances[msg.sender].sub(_value);	
        tokenBalances[msg.sender][token] = tokenBalances[msg.sender][token].add(token.balanceOf(this)
                .sub(tokenBalance));
    }