%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func balance() -> (res: felt) {
}

@external
func increase_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: felt
) {
    with_attr error_message("Amount must be positive. Got: {amount}.") {
        assert_nn(amount);
    }

    let (current_balance) = balance.read();
    tempvar new_balance = current_balance + amount;
    balance.write(new_balance);
    // Debugging
    %{
        from requests import post
        json = { # armo el json que luego se va a imprimir en el script de python
            "balance": f"current: {ids.current_balance},  new: {ids.new_balance}",
        }
        post(url="http://localhost:5000", json=json) # envio la petición a nuestro pequeño "servidor"
    %}
    return ();
}

@view
func get_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (res) = balance.read();
    return (res,);
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    balance.write(0);
    return ();
}
