pub fn sum(x:u8,y:u8)->u8{
    x * y 
}
/*
Как найти нужный кусок кода?
*/
fn main() {

    let x = 4u8;// 0000 0100
    let mut y = 6u8;//  0000 0110
    let res = sum(x,y);
    println!("{res}");
}
/*
$ objdump -S -M intel -d target/debug/asm_rust > disassembly.dump

$ ghex target/debug/asm_rust
*/