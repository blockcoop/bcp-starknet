%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address, deploy

@storage_var
func coop_count() -> (count: felt):
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
    coop_class_hash.write(coop_class_hash_)
    return ()
end

@view
func coop_size{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (count: felt):
    let (count) = coop_count.read()
    return (count)
end

@view
func get_coops{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (array_len: felt, array: felt*):
    alloc_locals
    let (array_len) = coop_count.read()
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

@external
func create_coop{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        name: felt,
        symbol: felt,
        initial_mint: felt,
        quorum: felt,
        supermajority: felt
    ):
    let (account) = get_caller_address()
    let (current_salt) = coop_count.read()
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
    coop_count.write(value=current_salt + 1)
    coops.write(current_salt + 1, contract_address)

    return ()
end

# Contract address: 0x044db559556170b9dd2f8f17b1ed8fe076b8d54aa56f825796ebee046008093f