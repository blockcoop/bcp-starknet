%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

@storage_var
func parent() -> (address: felt):
end

@storage_var
func name() -> (value: felt):
end

@storage_var
func balance() -> (value: felt):
end

@constructor
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(name_ : felt, balance_ : felt):
    let (account) = get_caller_address()
    parent.write(account)
    name.write(name_)
    balance.write(balance_)
    return ()
end

@view
func get_parent{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = parent.read()
    return (value)
end

@view
func get_name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = name.read()
    return (value)
end

@view
func get_balance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = balance.read()
    return (value)
end

# Contract class hash: 0x3c5d19cb5f78112ccce921933c87557478bb1a34383c1f98f455c2944bb74ce
# Transaction hash: 0x5ed177487056fcd377c40f28dddeed64d775edd404846b76a10c8424ed642c3