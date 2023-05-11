// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IUnitController {
    function enterMarkets(address[] memory oTokens) external;

    function checkMembership(
        address account,
        address oToken
    ) external view returns (bool);
}
