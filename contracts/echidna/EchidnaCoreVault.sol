// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

import "./Setup.sol";

contract EchidnaCoreVault is Setup {
    function echidnaSetDevFee(uint16 _devFee) public {
        try coreVault.setDevFee(_devFee) {
            /* not reverted */
            uint16 DEV_FEE = coreVault.getDevFee();
            assert(DEV_FEE == _devFee);
        } catch Error(string memory reason) {
            /* reverted */
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Dev fee clamped at 10%"))
            );
        }
    }

    function echidnaDeposit(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        try token.mint(address(this), _amount) {
            /* not reverted */
            uint256 poolLength = coreVault.poolLength();
            uint256 balBefore = token.balanceOf(address(this));
            assert(balBefore == _amount);
            try coreVault.add(100, token, true, true) {
                /* not reverted */
                uint256 poolLengthAfter = coreVault.poolLength();
                assert(poolLengthAfter == poolLength.add(1));
                token.approve(address(coreVault), _amount);
                try coreVault.deposit(poolLength, _amount) {
                    /* not reverted */
                    uint256 balAfter = token.balanceOf(address(this));
                    assert(balAfter == 0);
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

    function echidnaDeposit_Revert_MissingApprove(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        if (_amount < 1e18) {
            _amount = _amount.add(1e18);
        }
        try token.mint(address(this), _amount) {
            /* not reverted */
            uint256 poolLength = coreVault.poolLength();
            uint256 balBefore = token.balanceOf(address(this));
            assert(balBefore == _amount);
            try coreVault.add(100, token, true, true) {
                /* not reverted */
                uint256 poolLengthAfter = coreVault.poolLength();
                assert(poolLengthAfter == poolLength.add(1));
                try coreVault.deposit(poolLength, _amount) {
                    assert(false);
                } catch Error(string memory reason) {
                    // assert(
                    //     keccak256(abi.encode(reason)) ==
                    //         keccak256(
                    //             abi.encode(
                    //                 "ERC20: transfer amount exceeds allowance"
                    //             )
                    //         )
                    // );
                }
            } catch {
                assert(false);
            }
        } catch {
            assert(false);
        }
    }

    function echidnaDepositFor(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        UserMock depositFor = new UserMock();
        try token.mint(address(this), _amount) {
            /* not reverted */
            uint256 poolLength = coreVault.poolLength();
            uint256 balBefore = token.balanceOf(address(this));
            assert(balBefore == _amount);
            try coreVault.add(100, token, true, true) {
                /* not reverted */
                uint256 poolLengthAfter = coreVault.poolLength();
                assert(poolLengthAfter == poolLength.add(1));
                try token.approve(address(coreVault), _amount) {
                    /* not reverted */
                    try
                        coreVault.depositFor(
                            address(depositFor),
                            poolLength,
                            _amount
                        )
                    {
                        uint256 balAfter = token.balanceOf(address(this));
                        assert(balAfter == 0);
                        try
                            depositFor.withdrawCallback(
                                address(coreVault),
                                poolLength,
                                _amount
                            )
                        {
                            /* not reverted */
                            uint256 balDepositFor = token.balanceOf(
                                address(depositFor)
                            );
                            assert(balDepositFor == _amount);
                        } catch {
                            assert(false);
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
        } catch {
            assert(false);
        }
    }

    function echidnaDepositFor_Revert_MissingApprove(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        UserMock depositFor = new UserMock();
        try token.mint(address(this), _amount) {
            /* not reverted */
            uint256 poolLength = coreVault.poolLength();
            uint256 balBefore = token.balanceOf(address(this));
            assert(balBefore == _amount);
            try coreVault.add(100, token, true, true) {
                /* not reverted */
                uint256 poolLengthAfter = coreVault.poolLength();
                assert(poolLengthAfter == poolLength.add(1));
                try
                    coreVault.depositFor(
                        address(depositFor),
                        poolLength,
                        _amount
                    )
                {
                    assert(false);
                } catch Error(string memory reason) {
                    // assert(
                    //     keccak256(abi.encode(reason)) ==
                    //         keccak256(abi.encode('ERC20: transfer amount exceeds allowance'))
                    // );
                }
            } catch {
                assert(false);
            }
        } catch {
            assert(false);
        }
    }

    function echidnaWithdraw(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        try token.mint(address(this), _amount) {
            /* not reverted */
            uint256 poolLength = coreVault.poolLength();
            uint256 balBefore = token.balanceOf(address(this));
            assert(balBefore == _amount);
            try coreVault.add(100, token, true, true) {
                /* not reverted */
                uint256 poolLengthAfter = coreVault.poolLength();
                assert(poolLengthAfter == poolLength.add(1));
                try token.approve(address(coreVault), _amount) {
                    /* not reverted */
                    try coreVault.deposit(poolLength, _amount) {
                        uint256 balAfter = token.balanceOf(address(this));
                        assert(balAfter == 0);
                        try coreVault.withdraw(poolLength, _amount) {
                            /* not reverted */
                            uint256 balAfterWithdraw = token.balanceOf(
                                address(this)
                            );
                            assert(balAfterWithdraw == _amount);
                        } catch {
                            assert(false);
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
        } catch {
            assert(false);
        }
    }

    function echidnaWithdrawFrom(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        UserMock depositFor = new UserMock();
        try token.mint(address(this), _amount) {
            /* not reverted */
            uint256 poolLength = coreVault.poolLength();
            uint256 balBefore = token.balanceOf(address(this));
            assert(balBefore == _amount);
            try coreVault.add(100, token, true, true) {
                /* not reverted */
                uint256 poolLengthAfter = coreVault.poolLength();
                assert(poolLengthAfter == poolLength.add(1));
                try token.approve(address(coreVault), _amount) {
                    /* not reverted */
                    try
                        coreVault.depositFor(
                            address(depositFor),
                            poolLength,
                            _amount
                        )
                    {
                        uint256 balAfter = token.balanceOf(address(this));
                        assert(balAfter == 0);
                        try
                            depositFor.setAllowanceForPoolTokenCallback(
                                address(coreVault),
                                address(this),
                                poolLength,
                                _amount
                            )
                        {
                            /* not reverted */
                            try
                                coreVault.withdrawFrom(
                                    address(depositFor),
                                    poolLength,
                                    _amount
                                )
                            {
                                /* not reverted */
                                uint256 balAfterWithdraw = token.balanceOf(
                                    address(this)
                                );
                                assert(balAfterWithdraw == _amount);
                            } catch {
                                assert(false);
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
            } catch {
                assert(false);
            }
        } catch {
            assert(false);
        }
    }

    function echidnaWithdrawFrom_Revert_MissingSetAllowanceForPoolTokenCallback(
        uint256 _amount
    ) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        UserMock depositFor = new UserMock();
        try token.mint(address(this), _amount) {
            /* not reverted */
            uint256 poolLength = coreVault.poolLength();
            uint256 balBefore = token.balanceOf(address(this));
            assert(balBefore == _amount);
            try coreVault.add(100, token, true, true) {
                /* not reverted */
                uint256 poolLengthAfter = coreVault.poolLength();
                assert(poolLengthAfter == poolLength.add(1));
                try token.approve(address(coreVault), _amount) {
                    /* not reverted */
                    try
                        coreVault.depositFor(
                            address(depositFor),
                            poolLength,
                            _amount
                        )
                    {
                        uint256 balAfter = token.balanceOf(address(this));
                        assert(balAfter == 0);
                        try
                            coreVault.withdrawFrom(
                                address(depositFor),
                                poolLength,
                                _amount
                            )
                        {
                            assert(false);
                        } catch Error(string memory reason) {
                            assert(
                                keccak256(abi.encode(reason)) ==
                                    keccak256(
                                        abi.encode(
                                            "withdraw: insufficient allowance"
                                        )
                                    )
                            );
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
        } catch {
            assert(false);
        }
    }
}
