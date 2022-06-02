%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.token.erc20.library import ERC20


#
# Storage
#

@storage_var
func coop_initiator() -> (coop_initiator: felt):
end

@storage_var
func quorum() -> (quorum: felt):
end

@storage_var
func supermajority() -> (supermajority: felt):
end

@storage_var
func created() -> (created: felt):
end

@storage_var
func initial_mint() -> (initial_mint: Uint256):
end

@storage_var
func member_shares(account: felt) -> (amount: Uint256):
end

@storage_var
func members_count() -> (count: felt):
end

@storage_var
func members(index: felt) -> (account: felt):
end

@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        name: felt,
        symbol: felt,
        _initial_mint: Uint256,
        _coop_initiator: felt,
        _quorum: felt,
        _supermajority: felt
    ):
    alloc_locals
    ERC20.initializer(name, symbol, 18)
    let (local address) = get_caller_address()
    coop_initiator.write(_coop_initiator)
    initial_mint.write(_initial_mint)
    members_count.write(1)
    members.write(0, _coop_initiator)
    member_shares.write(_coop_initiator, _initial_mint)
    ERC20._mint(_coop_initiator, _initial_mint)
    return ()
end

@external
func join_coop{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}():
    return ()
end