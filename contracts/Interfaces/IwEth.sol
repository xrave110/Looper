// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IwEth {
    function deposit() external payable;

    function approve(address _spender, uint256 _amount) external;
}
