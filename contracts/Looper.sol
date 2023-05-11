// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Interfaces/IThreeStepQiZappah.sol";
import "./Interfaces/IStableQiVault.sol";
import "./Interfaces/IwEth.sol";
//import "./Interfaces/ICurveExchange.sol";
import "./Interfaces/IsoDai.sol";
import "./Interfaces/IUnitController.sol";
import "./Interfaces/IsoWstEth.sol";
import "./Interfaces/IVeloRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "hardhat/console.sol";

error AmountExceeded(uint256 requestedValue, uint256 senderValue);
error AllowanceExceeded(
    uint256 requestedValue,
    uint256 senderAllowance,
    uint256 contractAllowance
);
error collateralTooLow(uint256 actualPercentage, uint256 minimumPercentage);

struct userParams {
    uint256 fundsDeposited; //native blockchain currency (ETH, MATIC, etc)
    uint256 stakedTokenAmount;
    uint256 maiCollateral;
    uint256 maiDebt;
    uint256 maiVaultId;
    uint256 sonneCollateral;
    uint256 sonneDebt;
}

contract tmp {
    function getMsgSender() public view returns (address) {
        return msg.sender;
    }
}

contract Looper {
    //Polygon Mainnet addresses
    /* Ovix */
    //address UNIT_CONTROLLER = 0x8849f1a0cB6b5D6076aB150546EddEe193754F1C;
    //address O_ST_MATIC = 0xDc3C5E5c01817872599e5915999c0dE70722D07f;
    //address O_MAI = 0xC57E5e261d49Af3026446de3eC381172f17bB799;

    /* Mai */
    //address QI_VAULT = 0x9A05b116b56304F5f4B3F1D5DA4641bFfFfae6Ab; //_mooAssetVault

    /* Tokens */
    //address ST_MATIC = 0x3A58a54C066FdC0f2D55FC9C89F0415C92eBf3C4;
    //address WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    //address MAI = 0xa3Fa99A148fA48D14Ed51d610c367C61876997F1;

    /* Beefy */
    //address BEEFY_ZAPPER = 0x652195e546A272c5112DF3c1b5fAA65591320C95;
    //address MOO_ST_MATIC = 0x4c8DFb55D08bD030814cB6fE774420f3C01a5EdB; //	_perfToken

    /* Curve */
    //address CURVE_EXCHANGE = 0xFb6FE7802bA9290ef8b00CA16Af4Bc26eb663a28;

    //Optimism Mainnet addresses
    /* Sonne */
    address UNIT_CONTROLLER = 0x60CF091cD3f50420d50fD7f707414d0DF4751C58;
    address SO_WST_ETH = 0x26AaB17f27CD1c8d06a0Ad8E4a1Af8B1032171d5;
    address SO_DAI = 0x5569b83de187375d43FBd747598bfe64fC8f6436;

    /* Mai */
    address QI_VAULT = 0x86f78d3cbCa0636817AD9e27a44996C738Ec4932; //_mooAssetVault

    /* Tokens */
    address ST_ETH = 0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb;
    address WETH = 0x4200000000000000000000000000000000000006;
    address ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address MAI = 0xdFA46478F9e5EA86d57387849598dbFB2e964b02;
    address QI = 0x3F56e0c36d275367b8C502090EDF38289b3dEa0d;
    address DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

    /* Beefy */
    address BEEFY_ZAPPER = 0x1D864EDCA89b99580C46CEC4091103D7fb85aDCF;
    address MOO_ST_ETH = 0x926B92B15385981416a5E0Dcb4f8b31733d598Cf; //	_perfToken

    /* Curve */
    address CURVE_EXCHANGE = 0xFb6FE7802bA9290ef8b00CA16Af4Bc26eb663a28;

    /* VELO */
    address VELO_ROUTER = 0x9c12939390052919aF3155f41Bf4160Fd3666A6f; //0x9c12939390052919aF3155f41Bf4160Fd3666A6f;

    // contracts
    IThreeStepQiZappah beefyZapper;
    IStableQiVault qiVault;
    //ICurveExchange curveExchange;
    IwEth wEth;
    IsoDai soDai;
    IUnitController unitController;
    IsoWstEth soWstEth;
    IVeloRouter veloRouter;

    // Storages
    mapping(address => userParams) userToParams;

    constructor() {
        beefyZapper = IThreeStepQiZappah(BEEFY_ZAPPER);
        qiVault = IStableQiVault(QI_VAULT);
        //curveExchange = ICurveExchange(CURVE_EXCHANGE);
        wEth = IwEth(WETH);
        soDai = IsoDai(SO_DAI);
        unitController = IUnitController(UNIT_CONTROLLER);
        soWstEth = IsoWstEth(SO_WST_ETH);
        veloRouter = IVeloRouter(VELO_ROUTER);
    }

    /// @notice Swapping an Exact Token for an Enough Token on the vault
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    ) public returns (uint256 amountOut) {
        IERC20(tokenIn).approve(VELO_ROUTER, amountIn);

        IVeloRouter.route[] memory routes;
        routes = new IVeloRouter.route[](1);
        routes[0].from = 0x4200000000000000000000000000000000000006;
        routes[0].to = tokenOut;
        routes[0].stable = false;

        uint256[] memory amounts = veloRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            routes,
            address(this),
            block.timestamp
        );

        // /// Refund tokenIn when the expected minimum out is not met
        // if (amountOutMin > amounts[2]) {
        //     IERC20(tokenIn).transfer(msg.sender, amounts[0]);
        // }

        return amounts[1];
    }

    function swapEth(
        address tokenOut,
        uint256 amountOutMin
    ) public payable returns (uint256 amountOut) {
        IVeloRouter.route[] memory routes;
        routes = new IVeloRouter.route[](1);
        routes[0].from = 0x4200000000000000000000000000000000000006;
        routes[0].to = tokenOut;
        routes[0].stable = false;

        uint256[] memory amounts = veloRouter.swapExactETHForTokens{
            value: msg.value
        }(amountOutMin, routes, address(this), block.timestamp);

        // /// Refund tokenIn when the expected minimum out is not met
        // if (amountOutMin > amounts[2]) {
        //     IERC20(tokenIn).transfer(msg.sender, amounts[0]);
        // }

        return amounts[1];
    }

    function getStEth() public payable returns (uint256) {
        uint256 amount = msg.value;
        uint256 initialBalance = IERC20(ST_ETH).balanceOf(address(this));
        userToParams[msg.sender].fundsDeposited = amount;
        wEth.deposit{value: amount}();
        IERC20(WETH).approve(VELO_ROUTER, amount);
        uint256 amountOut = swap(WETH, ST_ETH, amount, 0);
        //uint256 amountOut = swapEth{value: amount}(ST_ETH, 0);
        uint256 finalBalance = IERC20(ST_ETH).balanceOf(address(this));
        //IERC20(ST_MATIC).transfer(msg.sender, dy);
        userToParams[msg.sender].stakedTokenAmount += (finalBalance -
            initialBalance);
        return amountOut; //amountOut;
    }

    function depositStEth(uint256 _amount) public returns (uint256) {
        uint256 currentBalance = userToParams[msg.sender].stakedTokenAmount;

        if (_amount > currentBalance) {
            revert AmountExceeded(_amount, currentBalance);
        }
        IERC20(ST_ETH).approve(BEEFY_ZAPPER, _amount);
        uint256 allowance = IERC20(ST_ETH).allowance(
            address(this),
            BEEFY_ZAPPER
        );
        if (_amount > allowance) {
            revert AllowanceExceeded(_amount, allowance, allowance);
        }
        userToParams[msg.sender].stakedTokenAmount -= _amount;
        if (userToParams[msg.sender].maiVaultId != 0) {
            qiVault.createVault();
            userToParams[msg.sender].maiVaultId = qiVault.vaultCount() - 1;
        }

        uint256 mooStAmount = beefyZapper.beefyZapToVault(
            _amount,
            userToParams[msg.sender].maiVaultId,
            ST_ETH,
            MOO_ST_ETH,
            QI_VAULT
        );
        uint256 stEthPrice = getPriceOfToken(ST_ETH);
        uint256 collateral = qiVault.vaultCollateral(
            userToParams[msg.sender].maiVaultId
        );
        userToParams[msg.sender].maiCollateral += ((collateral * stEthPrice) /
            10 ** 8);
        return userToParams[msg.sender].maiCollateral;
    }

    function borrowMai(uint256 _amount) public {
        uint256 vaultId = userToParams[msg.sender].maiVaultId;
        uint256 collateralPercentage = qiVault.checkCollateralPercentage(
            vaultId
        );
        console.log("Percentage: %s ", collateralPercentage);
        uint256 minimumPrecentage = qiVault._minimumCollateralPercentage();
        // if (
        //     (collateralPercentage - (collateralPercentage * 5) / 100) <=
        //     minimumPrecentage
        // ) {
        //     revert collateralTooLow(collateralPercentage, minimumPrecentage);
        // }
        console.log("minimumPrecentage: %s ", minimumPrecentage);
        uint256 maiPrice = getPriceOfToken(MAI);
        userToParams[msg.sender].maiDebt += maiPrice * _amount;
        console.log("Mai debt: %s ", userToParams[msg.sender].maiDebt);
        console.log(
            "Owner: %s\nSender: %s\nContract: %s",
            qiVault.ownerOf(vaultId),
            msg.sender,
            address(this)
        );
        qiVault.borrowToken(vaultId, _amount, 0);
    }

    function depositMai(uint256 _amount) public view returns (bool, bool) {
        bool isMaiMarketCreated = unitController.checkMembership(
            msg.sender,
            SO_DAI
        );
        bool isStMaticMarketCreated = unitController.checkMembership(
            msg.sender,
            SO_WST_ETH
        );
        /*if(false == (isStMaticMarketCreated && isMaiMarketCreated)){
            address [] memory oTokens = new address[](2);
            oTokens[0] = O_MAI;
            oTokens[1] = O_ST_MATIC;
            unitController.enterMarkets(oTokens);
        }
        uint256 maiPrice = getPriceOfToken(MAI);
        userToParams[msg.sender].ovixCollateral = maiPrice * _amount;

        IERC20(MAI).approve(O_MAI, _amount);
        soDai.mint(_amount);*/
        return (isMaiMarketCreated, isStMaticMarketCreated);
    }

    function borrowStEth(uint256 _amount) public {
        uint256 stEthPrice = getPriceOfToken(ST_ETH);
        userToParams[msg.sender].sonneDebt = stEthPrice * _amount;
        soWstEth.borrow(_amount);
    }

    function getTokenBalance(
        address _tokenAddress,
        address _walletAddress
    ) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(_walletAddress);
    }

    function getStEthUserBalance() external view returns (uint256) {
        return userToParams[msg.sender].stakedTokenAmount;
    }

    function getFundsDeposited() external view returns (uint256) {
        return userToParams[msg.sender].fundsDeposited;
    }

    function getMaiCollateral() external view returns (uint256) {
        return userToParams[msg.sender].maiCollateral;
    }

    function getMaiDebt() external view returns (uint256) {
        return userToParams[msg.sender].maiDebt;
    }

    function getSonneCollateral() external view returns (uint256) {
        return userToParams[msg.sender].sonneCollateral;
    }

    function getPriceOfToken(
        address _tokenAddress
    ) public view returns (uint256) {
        uint256 retVal = 0;
        if (_tokenAddress == ST_ETH) {
            retVal = 1970 * (10 ** 8);
        } else if (_tokenAddress == WETH) {
            retVal = 1920 * (10 ** 8);
        } else {
            /* stables */
            retVal = 10 ** 8;
        }
        return retVal;
    }

    function getBalanceOfNft(address owner) public view returns (uint256) {
        return IERC721(QI_VAULT).balanceOf(owner);
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        return IERC721(QI_VAULT).ownerOf(tokenId);
    }

    //tests
    function getNestedMsgSender(
        address _contract
    ) public returns (address, address, address) {
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("getMsgSender()")
        );
        (bool success1, bytes memory data1) = _contract.call(
            abi.encodeWithSignature("getMsgSender()")
        );
        require(success, "NOPE!");
        require(success1, "NOPE 11 !");
        return (
            abi.decode(data, (address)),
            abi.decode(data1, (address)),
            address(this)
        );
    }

    function getInfoAboutToken()
        public
        returns (uint256, uint256, address, bool)
    {
        uint256 tokenIdBefore = qiVault.vaultCount();
        qiVault.createVault();

        uint256 tokenIdAfter = qiVault.vaultCount();
        address owner = IERC721(QI_VAULT).ownerOf(tokenIdAfter - 1);
        bool doesExist = qiVault.exists(tokenIdAfter - 1);
        return (tokenIdBefore, tokenIdAfter, owner, doesExist);
    }

    function createVaultCall() public returns (uint256, uint256) {
        (bool success, bytes memory data) = QI_VAULT.call(
            abi.encodeWithSignature("createVault()")
        );
        uint256 senderBalance = getBalanceOfNft(msg.sender);
        uint256 contractBalance = getBalanceOfNft(address(this));
        require(success, "NOPE");
        return (senderBalance, contractBalance);
    }

    function createVaultDelegateCall() public returns (uint256, uint256) {
        (bool success, bytes memory data) = QI_VAULT.delegatecall(
            abi.encodeWithSignature("createVault()")
        );
        uint256 senderBalance = getBalanceOfNft(msg.sender);
        uint256 contractBalance = getBalanceOfNft(address(this));
        require(success, "NOPE");
        return (senderBalance, contractBalance);
    }

    /* function test_depositStMatic(uint256 _amount) public {
        uint256 currentBalance = IERC20(ST_MATIC).balanceOf(msg.sender);
        if(_amount > currentBalance){
            revert AmountExceeded(_amount, currentBalance);
        }
        (bool success, ) = ST_MATIC.delegatecall(abi.encodeWithSignature("approve(address,uint256)", BEEFY_ZAPPER, _amount));
        require(success, "Issue occured during approving");
        uint256 allowance = IERC20(ST_MATIC).allowance(msg.sender, BEEFY_ZAPPER);
        uint256 contractAllowance = IERC20(ST_MATIC).allowance(address(this), BEEFY_ZAPPER);
        if(_amount > allowance){
            revert AllowanceExceeded(_amount, allowance, contractAllowance);
        }
        (success, ) = QI_VAULT.delegatecall(abi.encodeWithSignature("qiVault.createVault()"));
        require(success, "Issue occured during creation of vault");
        (success, ) = BEEFY_ZAPPER.delegatecall(
            abi.encodeWithSignature(
                "beefyZapper.beefyZapToVault(uint256, uint256, address, address, address)",
                _amount, VAULT_ID, ST_MATIC, MOO_ST_MATIC, QI_VAULT));
        require(success, "Issue occured for beefy zap to vault");
    } */

    function getSoneDebt() public view returns (uint256) {
        return userToParams[msg.sender].sonneDebt;
    }
}
