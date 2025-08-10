// test module for various errors that should trigger diagnostics in neovim

mod mymodule;

fn call_me() {
    print!("Hello, world!");
}

fn plus(x: i32) -> i32 {
    x + 1;
}

fn main() {
    plus(123);
    call_me();
    call_me_not()
}
