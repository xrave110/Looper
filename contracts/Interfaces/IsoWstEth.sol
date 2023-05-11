// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IsoWstEth {
    function borrow(uint256 borrowAmount) external returns (uint256);
}
