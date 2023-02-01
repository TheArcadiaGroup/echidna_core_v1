// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

import "../uniswapv2/UniswapV2Pair.sol";
import "../uniswapv2/UniswapV2ERC20.sol";
import "../uniswapv2/UniswapV2Factory.sol";
import "../uniswapv2/libraries/UniswapV2Library.sol";
import "../uniswapv2/UniswapV2Router02.sol";
import "../WETH9.sol";
import "../CORE.sol";
import "../FeeApprover.sol";
import "../CoreVault.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Setup {
    using SafeMath for uint256;

    UniswapV2Factory factory;
    UniswapV2Router02 router;
    WETH9 weth;
    CoreMock core;
    FeeApprover feeApprover;
    CoreVaultMock coreVault;
    UniswapV2Pair coreWETHPair;

    constructor() public {
        factory = new UniswapV2Factory(address(this));
        weth = new WETH9();
        router = new UniswapV2Router02(address(factory), address(weth));
        core = new CoreMock(address(router), address(factory));
        feeApprover = new FeeApprover();
        feeApprover.initialize(address(core), address(weth), address(factory));
        feeApprover.setPaused(false);
        core.setShouldTransferChecker(address(feeApprover));
        coreVault = new CoreVaultMock();
        coreVault.initialize(core, address(this), address(this));
        feeApprover.setCoreVaultAddress(address(coreVault));
        coreWETHPair = UniswapV2Pair(factory.getPair(address(weth), address(core)));
    }
}
contract CoreVaultMock is CoreVault {
    function getDevFee() public returns (uint16) {
        return DEV_FEE;
    }
}

contract CoreMock is CORE {
    constructor(address router, address factory) public CORE(router, factory) {   
    }

    function setContractStartTimestamp(uint256 newBlockNumber) public {
        contractStartTimestamp = newBlockNumber;
    }

    function getContractStartTimestamp() public returns (uint256) {
        return contractStartTimestamp;
    }
}

contract ERC20Mock is ERC20 {
    constructor(string memory name, string memory symbol)
        public
        ERC20(name, symbol)
    {
        // _mint(msg.sender, 1000000e18);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}

contract UserMock {
    function add(
        address coreVault,
        uint256 _allocPoint,
        IERC20 _token,
        bool _withUpdate,
        bool _withdrawable
    ) public {
        CoreVault(coreVault).add(
            _allocPoint,
            _token,
            _withUpdate,
            _withdrawable
        );
    }

    function set(
        address coreVault,
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public {
        CoreVault(coreVault).set(_pid, _allocPoint, _withUpdate);
    }

    function withdrawCallback(
        address coreVault,
        uint256 pid,
        uint256 amount
    ) public {
        CoreVault(coreVault).withdraw(pid, amount);
    }

    function setAllowanceForPoolTokenCallback(
        address coreVault,
        address spender,
        uint256 pid,
        uint256 amount
    ) public {
        CoreVault(coreVault).setAllowanceForPoolToken(spender, pid, amount);
    }

    function setStrategyContractOrDistributionContractAllowance(
        address coreVault,
        address tokenAddress,
        uint256 _amount,
        address contractAddress
    ) public {
        CoreVault(coreVault).setStrategyContractOrDistributionContractAllowance(
                tokenAddress,
                _amount,
                contractAddress
            );
    }
}
