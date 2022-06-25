%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address, deploy

@storage_var
func child_count() -> (count: felt):
end

@storage_var
func children(index: felt) -> (address: felt):
end

@storage_var
func child_class_hash() -> (value: felt):
end

@constructor
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(child_class_hash_ : felt):
    child_class_hash.write(child_class_hash_)
    return ()
end

@view
func childCount{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (count: felt):
    let (count) = child_count.read()
    return (count)
end

@view
func getChildren{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (array_len: felt, array: felt*):
    alloc_locals
    let (array_len) = child_count.read()
    let (local array : felt*) = alloc()
    array_values(array_len, array)
    return (array_len, array)
end

func array_values{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(array_len : felt, array : felt*):
    if array_len == 0:
        return ()
    end

    let (item) = children.read(array_len)
    assert [array] = item

    return array_values(array_len - 1, array + 1)
end

@external
func create_child{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        name: felt,
        balance: felt,
    ):
    let (account) = get_caller_address()
    let (current_salt) = child_count.read()
    let (class_hash) = child_class_hash.read()

    let (contract_address) = deploy(
        class_hash=class_hash,
        contract_address_salt=current_salt,
        constructor_calldata_size=2,
        constructor_calldata=cast(new (
            name,
            balance,
        ), felt*),
    )
    child_count.write(value=current_salt + 1)
    children.write(current_salt + 1, contract_address)

    return ()
end

# Contract address: 0x04a55157202793a18ab3149680c6d6956e472c2dc9bea7f2688cca04c06fc0d9