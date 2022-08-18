// SPDX-License-Identifier : MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    // Price of one Crypto Dev token
    uint256 public constant tokenPrice = 0.001 ether;

    // Each NFT would give the user 10 tokens
    uint256 public constant tokensPerNFT = 10 * 10**18;

    // the max total supply
    uint256 public constant maxTotalSupply = 10000 * 10**18;

    // CryptoDevsNFT contract instance
    ICryptoDevs CryptoDevsNFT;

    //Mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    // amount -> no of CryptoDevTokens
    function mint(uint256 amount) public payable {
        // the value of ether that should be equal to or greater than tokenPrice * amount
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");

        //  total tokens(tokens already in supply) + amount <= 10000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        require(
            totalSupply() + amountWithDecimals <= maxTotalSupply,
            "Exceeds the max total supply available"
        );

        // call the internal function from Openzeppelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
    }

    // Mints tokens based on the number of NFT's held by the sender
    function claim() public {
        address sender = msg.sender;
        // Get the number of CryptoDev NFT'S held by a given sender address
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        // If the balance is zero, revert the transaction
        require(balance > 0, "You don't own any Crypto Dev NFT's");
        //amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;
        // loop over the balance and get the token ID owned by 'sender' at a given 'index' of its token list.
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            // if the tokenId  has not been claimed, increase the amount
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }

        // If all the token Ids have been claimed, revert the transaction
        require(amount > 0, "You have already claimed all the tokens");
        // calling the internal function from openzeppelin's ERC20 contract
        // Mint --> (amount * 10) tokens for each NFT
        _mint(msg.sender, amount * tokensPerNFT);
    }

    // withdraws all ETH and tokens sent to the contract
    // Requirements : wallet must be connected to owner's address
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether, msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is nnot empty
    fallback() external payable {}
}
