extern crate cc;

fn main() {
    if let Err(e) = cc::Build::new()
        .debug(true)
        .asm_flag("-no-pie")
        .file("src/main.c")
        .object("src/ex.o")
        .warnings(false)
        .try_compile("libmul.a"){
            println!("Error compile:{:?}",e);
        }
}