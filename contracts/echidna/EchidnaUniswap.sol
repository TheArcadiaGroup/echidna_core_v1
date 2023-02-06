// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

import "./Setup.sol";
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

contract EchidnaUniswap {
    using SafeMath for uint256;

    UniswapV2Factory factory;
    UniswapV2Router02 router;
    WETH9 weth;
    CoreMock core;
    FeeApprover feeApprover;
    CoreVaultMock coreVault;

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
    }

    function echidnaPendingFeesCorrectlyAndCorrectBalance(address receiver)
        public
        payable
    {
        core.setContractStartTimestamp(block.timestamp);
        try core.addLiquidity{value: msg.value}(true) {
            /* not reverted */
            core.setContractStartTimestamp(1000);
            try core.addLiquidityToUniswapCORExWETHPair() {
                /* not reverted */
                try core.claimLPTokens() {
                    /* not reverted */
                    try core.setFeeDistributor(address(coreVault)) {
                        /* not reverted */
                        uint256 pendingRewardsBefore = coreVault
                            .pendingRewards();
                        uint256 balCoreVaultBefore = core.balanceOf(
                            address(coreVault)
                        );
                        uint256 balBefore = core.balanceOf(address(this));
                        try core.transfer(receiver, balBefore) {
                            /* not reverted */
                            uint256 pendingRewardsAfter = coreVault
                                .pendingRewards();
                            uint256 balAfter = core.balanceOf(
                                address(coreVault)
                            );
                            assert(
                                pendingRewardsAfter.sub(pendingRewardsBefore) ==
                                    balBefore.div(100)
                            );
                            assert(
                                balAfter.sub(balBefore) == balBefore.div(100)
                            );
                        } catch {
                            assert(false);
                        }
                    } catch {
                        assert(false);
                    }
                } catch {
                    assert(false);
                }
            } catch Error(string memory reason) {
                assert(
                    keccak256(abi.encode(reason)) ==
                        keccak256(
                            abi.encode("Liquidity generation already finished")
                        )
                );
            }
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Liquidity Generation Event over"))
            );
        }
    }

    function echidnaSetFeeMultiplier(uint8 fee) public {
        try feeApprover.setFeeMultiplier(fee) {
            /* not reverted */
            assert(feeApprover.feePercentX100() == fee);
        } catch {
            assert(false);
        }
    }

    function echidnaSetFeeDistributor(address feeDistributor) public {
        try core.setFeeDistributor(feeDistributor) {
            /* not reverted */
            assert(core.feeDistributor() == feeDistributor);
        } catch {
            assert(false);
        }
    }

    function echidnaCalculateFees(
        uint8 fee,
        address feeDistributor,
        address receiver
    ) public payable {
        uint256 bal = 1000;
        core.setContractStartTimestamp(block.timestamp);
        if (core.getLPGenerationCompleted() == false) {
            try core.addLiquidity{value: 1e18}(true) {
                /* not reverted */
                core.setContractStartTimestamp(1000);
                try core.addLiquidityToUniswapCORExWETHPair() {
                    /* not reverted */
                    try core.claimLPTokens() {
                        /* not reverted */
                        if (
                            keccak256(abi.encode(feeDistributor)) ==
                            keccak256(
                                abi.encode(
                                    "0x0000000000000000000000000000000000000000"
                                )
                            )
                        ) {
                            try
                                core.setFeeDistributor(address(feeDistributor))
                            {
                                /* not reverted */
                                assert(core.feeDistributor() == feeDistributor);
                                try feeApprover.setFeeMultiplier(fee) {
                                    uint256 balCoreVaultBefore = core.balanceOf(
                                        address(feeDistributor)
                                    );
                                    uint256 balBefore = core.balanceOf(
                                        address(this)
                                    );
                                    assert(balBefore > bal);
                                    try core.transfer(receiver, bal) {
                                        /* not reverted */
                                        uint256 balAfter = core.balanceOf(
                                            address(feeDistributor)
                                        );
                                        assert(
                                            balAfter.sub(balBefore) ==
                                                bal.mul(uint256(fee)).div(1000)
                                        );
                                    } catch {
                                        assert(false);
                                    }
                                } catch {
                                    assert(false);
                                }
                            } catch {
                                assert(false);
                            }
                        }
                    } catch {
                        assert(false);
                    }
                } catch {
                    assert(false);
                }
            } catch {
                assert(false);
            }
        } else {
            if (
                keccak256(abi.encode(feeDistributor)) ==
                keccak256(
                    abi.encode("0x0000000000000000000000000000000000000000")
                )
            ) {
                try core.setFeeDistributor(address(feeDistributor)) {
                    /* not reverted */
                    assert(core.feeDistributor() == feeDistributor);
                    try feeApprover.setFeeMultiplier(fee) {
                        uint256 balCoreVaultBefore = core.balanceOf(
                            address(feeDistributor)
                        );
                        uint256 balBefore = core.balanceOf(address(this));
                        assert(balBefore > bal);
                        try core.transfer(receiver, bal) {
                            /* not reverted */
                            uint256 balAfter = core.balanceOf(
                                address(feeDistributor)
                            );
                            assert(
                                balAfter.sub(balBefore) ==
                                    bal.mul(uint256(fee)).div(1000)
                            );
                        } catch {
                            assert(false);
                        }
                    } catch {
                        assert(false);
                    }
                } catch {
                    assert(false);
                }
            }
        }
    }
}
