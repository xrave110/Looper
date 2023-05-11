// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IStableQiVault {
    /// @param vaultID is the token id of the vault being interacted with.
    /// @param amount is the amount of borrowable asset to borrow
    /// @param _front is hardcoded as 0 ?
    /// @notice borrows asset based on the collateral held and the price of the collateral.
    /// @dev Borrowing is limited by the CDR of the vault
    /// If there's opening fee, it will be charged here.
    function borrowToken(
        uint256 vaultID,
        uint256 amount,
        uint256 _front
    ) external;

    function createVault() external;

    function exists(uint256 vaultID) external view returns (bool);

    function checkCollateralPercentage(
        uint256 vaultID
    ) external view returns (uint256);

    /// @param _collateral is the amount of collateral tokens held by vault.
    /// @param debt is the debt owed by the vault.
    /// @notice Calculates if the CDR is valid before taking a further action with a user
    /// @return boolean describing if the new CDR is valid.
    function isValidCollateral(
        uint256 _collateral,
        uint256 debt
    ) external view returns (bool);

    //Public variables
    function vaultCount() external view returns (uint256);

    function _minimumCollateralPercentage() external view returns (uint256);

    function vaultCollateral(uint256 vaultId) external view returns (uint256);

    function vaultDebt(uint256 vaultId) external view returns (uint256);

    function ownerOf(uint256 vaultId) external view returns (address);
}
