// SPDX-License-Identifier : MIT

pragma solidity ^0.8.0;

interface ICryptoDevs {
    // retruns a tokenId owned by owner at a given index of its token list.
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    //  returns the no of tokens in the owner's account.
    function balanceOf(address owner) external view returns (uint256 balance);
}
