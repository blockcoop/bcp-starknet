%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address, deploy

#
# Storage
#

@storage_var
func existing_symbols(symbol: felt) -> (exists: felt):
end

@storage_var
func coops_count() -> (count: felt):
end

@storage_var
func coops(index: felt) -> (address: felt):
end

@storage_var
func coop_class_hash() -> (value: felt):
end

@constructor
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(coop_class_hash_ : felt):
    coop_class_hash.write(value=coop_class_hash_)
    return ()
end

#
# Getters
#

@view
func coopsCount{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (count: felt):
    let (count) = coops_count.read()
    return (count)
end

@view
func getCoopByIndex{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(index: felt) -> (address: felt):
    let (address) = coops.read(index)
    return (address)
end

@view
func getCoops{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (array_len: felt, array: felt*):
    alloc_locals
    let (array_len) = coops_count.read()
    let (local array : felt*) = alloc()
    array_values(array_len, array)
    return (array_len, array)
end

func array_values{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(array_len : felt, array : felt*):
    if array_len == 0:
        return ()
    end

    let (item) = coops.read(array_len)
    assert [array] = item

    return array_values(array_len - 1, array + 1)
end

#
# Externals
#

@external
func createCoop{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        name: felt,
        symbol: felt,
        initial_mint: felt,
        quorum: felt,
        supermajority: felt
    ):
    alloc_locals
    let (isSymbol) = existing_symbols.read(symbol)
    assert_not_zero(isSymbol)
    let (account) = get_caller_address()
    let (current_salt) = coops_count.read()
    let (class_hash) = coop_class_hash.read()

    let (contract_address) = deploy(
        class_hash=class_hash,
        contract_address_salt=current_salt,
        constructor_calldata_size=6,
        constructor_calldata=cast(new (
            name,
            symbol,
            initial_mint,
            account,
            quorum,
            supermajority
        ), felt*),
    )
    coops_count.write(value=current_salt + 1)
    existing_symbols.write(symbol, 1)
    coops.write(current_salt + 1, contract_address)

    return ()
end 


# Contract address: 0x01f89c3d39cc8b0c6beb75e384da1e1f2dbd6405d15c7e9362bffa5c9ece0ec3