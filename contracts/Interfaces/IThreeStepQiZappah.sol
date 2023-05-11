// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IThreeStepQiZappah {
    /* @dev returns: balance of perfToken */
    function beefyZapToVault(
        uint256 amount,
        uint256 vaultId,
        address _asset,
        address _perfToken,
        address _mooAssetVault
    ) external returns (uint256);
}
