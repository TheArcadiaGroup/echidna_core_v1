// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

import "./Setup.sol";

contract EchidnaCoreVault2 is Setup {
    function echidnaAdd(
        uint256 _allocPoint,
        IERC20 _token,
        bool _withUpdate,
        bool _withdrawable
    ) public {
        uint256 poolLengthBefore = coreVault.poolLength();
        uint256 totalAllocPoint = coreVault.totalAllocPoint();
        if ((type(uint256).max).sub(_allocPoint) >= totalAllocPoint) {
            try coreVault.add(_allocPoint, _token, _withUpdate, _withdrawable) {
                uint256 poolLengthAfter = coreVault.poolLength();
                assert(poolLengthAfter == poolLengthBefore.add(1));
            } catch Error(string memory reason) {
                assert(
                    keccak256(abi.encode(reason)) ==
                        keccak256(abi.encode("Error pool already added"))
                );
            }
        } else {
            try coreVault.add(_allocPoint, _token, _withUpdate, _withdrawable) {
                assert(false);
            } catch Error(string memory reason) {
                assert(
                    keccak256(abi.encode(reason)) ==
                        keccak256(abi.encode("SafeMath: addition overflow"))
                );
            }
        }
    }

    function echidnaAdd_NotOwner(
        uint256 _allocPoint,
        IERC20 _token,
        bool _withUpdate,
        bool _withdrawable
    ) public {
        uint256 poolLengthBefore = coreVault.poolLength();
        UserMock user = new UserMock();
        try
            user.add(
                address(coreVault),
                _allocPoint,
                _token,
                _withUpdate,
                _withdrawable
            )
        {
            assert(false);
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Ownable: caller is not the owner"))
            );
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLengthBefore);
    }

    function echidnaSet(uint256 _allocPoint, bool _withUpdate) public {
        uint256 poolLength = coreVault.poolLength();
        ERC20Mock token = new ERC20Mock("Test", "Test");
        uint256 totalAllocPoint = coreVault.totalAllocPoint();
        if ((type(uint256).max).sub(100) >= totalAllocPoint) {
            try coreVault.add(100, token, true, true) {
                /* not reverted */
                uint256 poolLengthAfter = coreVault.poolLength();
                assert(poolLengthAfter == poolLength.add(1));
                uint256 _totalAllocPoint = coreVault.totalAllocPoint();
                if ((type(uint256).max).sub(_allocPoint) >= _totalAllocPoint) {
                    try coreVault.set(poolLength, _allocPoint, _withUpdate) {
                        /* not reverted */
                    } catch Error(string memory reason) {
                        assert(
                            keccak256(abi.encode(reason)) ==
                                keccak256(
                                    abi.encode("Error pool already added")
                                )
                        );
                    }
                } else {
                    try coreVault.set(poolLength, _allocPoint, _withUpdate) {
                        assert(false);
                    } catch Error(string memory reason) {
                        assert(
                            keccak256(abi.encode(reason)) ==
                                keccak256(
                                    abi.encode("SafeMath: addition overflow")
                                )
                        );
                    }
                }
            } catch {
                assert(false);
            }
        }
    }

    function echidnaSet_NotOwner(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public {
        UserMock user = new UserMock();
        uint256 poolLength = coreVault.poolLength();
        ERC20Mock token = new ERC20Mock("Test", "Test");
        try coreVault.add(100, token, true, true) {
            /* not reverted */
            uint256 poolLengthAfter = coreVault.poolLength();
            assert(poolLengthAfter == poolLength.add(1));
            try
                user.set(
                    address(coreVault),
                    poolLength,
                    _allocPoint,
                    _withUpdate
                )
            {
                assert(false);
            } catch Error(string memory reason) {
                assert(
                    keccak256(abi.encode(reason)) ==
                        keccak256(
                            abi.encode("Ownable: caller is not the owner")
                        )
                );
            }
        } catch {
            assert(false);
        }
    }
}
