%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.uint256 import Uint256, uint256_lt
from starkware.cairo.common.math import assert_lt, assert_not_zero
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.token.erc20.library import ERC20

# Contract class hash: 0x53a8eef51c243eaf215515b128132226bb7ee60c5b681374f51bcddf896c529

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
func initial_mint() -> (initial_mint: felt):
end

@storage_var
func member_shares(account: felt) -> (amount: felt):
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
        _initial_mint: felt,
        _coop_initiator: felt,
        _quorum: felt,
        _supermajority: felt
    ):
    alloc_locals
    ERC20.initializer(name, symbol, 18)
    coop_initiator.write(_coop_initiator)
    initial_mint.write(_initial_mint)
    members_count.write(1)
    members.write(0, _coop_initiator)
    member_shares.write(_coop_initiator, _initial_mint)
    ERC20._mint(_coop_initiator, Uint256(_initial_mint, 0))
    return ()
end

#
# Getters
#

@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    let (name) = ERC20.name()
    return (name)
end

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC20.symbol()
    return (symbol)
end

@view
func totalSupply{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (totalSupply: Uint256):
    let (totalSupply: Uint256) = ERC20.total_supply()
    return (totalSupply)
end

@view
func decimals{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (decimals: felt):
    let (decimals) = ERC20.decimals()
    return (decimals)
end

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC20.balance_of(account)
    return (balance)
end

@view
func allowance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, spender: felt) -> (remaining: Uint256):
    let (remaining: Uint256) = ERC20.allowance(owner, spender)
    return (remaining)
end

@view
func coopInitiator{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (initiator: felt):
    let (initiator) = coop_initiator.read()
    return (initiator)
end

@view
func coopQuorum{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = quorum.read()
    return (value)
end

@view
func coopSupermajority{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = supermajority.read()
    return (value)
end

@view
func createdAt{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = created.read()
    return (value)
end

@view
func initialMint{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = initial_mint.read()
    return (value)
end

@view
func memberShares{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account: felt) -> (value: felt):
    let (value) = member_shares.read(account)
    return (value)
end

@view
func membersCount{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = members_count.read()
    return (value)
end

@view
func getMembersByIndex{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(index: felt) -> (account: felt):
    let (account) = members.read(index)
    return (account)
end

@view
func getMembers{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (array_len: felt, array: felt*):
    alloc_locals
    let (array_len) = members_count.read()
    let (local array : felt*) = alloc()
    array_values(array_len, array)
    return (array_len, array)
end

func array_values{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(array_len : felt, array : felt*):
    if array_len == 0:
        return ()
    end

    let (item) = members.read(array_len)
    assert [array] = item

    return array_values(array_len - 1, array + 1)
end

#
# Externals
#

@external
func transfer{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(recipient: felt, amount: Uint256) -> (success: felt):
    ERC20.transfer(recipient, amount)
    return (TRUE)
end

@external
func transferFrom{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        sender: felt,
        recipient: felt,
        amount: Uint256
    ) -> (success: felt):
    ERC20.transfer_from(sender, recipient, amount)
    return (TRUE)
end

@external
func approve{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(spender: felt, amount: Uint256) -> (success: felt):
    ERC20.approve(spender, amount)
    return (TRUE)
end

@external
func increaseAllowance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(spender: felt, added_value: Uint256) -> (success: felt):
    ERC20.increase_allowance(spender, added_value)
    return (TRUE)
end

@external
func decreaseAllowance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(spender: felt, subtracted_value: Uint256) -> (success: felt):
    ERC20.decrease_allowance(spender, subtracted_value)
    return (TRUE)
end

@external
func join_coop{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}():
    alloc_locals
    let (local address) = get_caller_address()
    let (amount) = member_shares.read(address)
    assert_lt(0, amount)
    let (count) = members_count.read()
    members_count.write(count + 1)
    members.write(count ,address)
    let (_initial_mint) = initial_mint.read()
    member_shares.write(address, _initial_mint)
    ERC20._mint(address, Uint256(_initial_mint, 0))
    return ()
end


# Contract class hash: 0x44312473f31a2685a368ade27c9a1620b823230cb98b705fd5d30bb8e11c9f4