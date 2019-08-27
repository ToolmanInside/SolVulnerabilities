function destroyDeed() public {
	// assure the state is not active
	require(!active);
	// if the balance is sent to the owner, destruct it
	if (owner.send(address(this).balance)) {
		selfdestruct(burn);}
}