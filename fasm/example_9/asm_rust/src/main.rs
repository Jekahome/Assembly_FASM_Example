// https://doc.rust-lang.org/reference/inline-assembly.html
use std::arch::asm;

/*
 GNU Assembler GAS = AT&T = `mov $10, %rax` (rax=10 т.е. слева на право)
 Assembler FASM   = INTEL = `mov rax, 10` (rax=10 с права на лево)

GAS =  [mov $10, %rax]
FASM = [mov rax, 10]

GNU GAS Assembler for FFI C:
    rdi/edi/di = первый аргумент
    rsi/esi/si = второй аргумент
    rdx/edx/dx = третий аргумент
    rcx/ecx/cx = четвертый аргумент
    r8/r8d/r8w = пятый аргумент
    r9/r9d/r9w = шестой аргумент
    stack = остальные аргумент
    rax = возвращаемое значение
*/
fn mul_rust(x:i32, y:i32)->i32{
    let result:i32;
    unsafe {
         asm!(
            "mov rdi, {buf_x}",  // rdi=x
            "mov rsi, {buf_y}",  // rsi=y
            "mov {reg}, rdi",    // mov rax, rdi ; rax=rdi
            "mul rsi",           // rax=rax*rsi
             buf_x = in(reg) x,
             buf_y = in(reg) y,
             reg = out(reg) result,
            
          );
          return result;
     }
     0
}

// extern ---------------------------------------------------------
extern crate libc;
extern {
    // extern C
    fn mul_c(x: libc::c_int, y: libc::c_int)-> libc::c_int;
    // extern ASM
    fn mul_from_asm(x: libc::c_int, y: libc::c_int) -> libc::c_int;
    // extern ASM
    fn gas_print_string(s:*const std::os::raw::c_char) -> libc::c_int;
    fn c_print() -> libc::c_int;
}
// ----------------------------------------------------------------

fn main() {

    let output = mul_rust(5,10);
    println!("mul_rust:{output}");
    assert_eq!(5*10, output);

    let output = unsafe { mul_c(5,10) };
    println!("mul_c:{output}");
    assert_eq!(5*10, output);

    let output = unsafe { mul_from_asm(5,10) };
    println!("mul_from_asm:{output}");
    assert_eq!(5*10, output);

// not working ----------------------------------------------------- 
/* 
    use std::ffi::CString;
    let rust_str = "Hello, World!".to_owned();
    let c_string = CString::new(rust_str).expect("CString::new failed");
    let c_char_ptr: *const libc::c_char = c_string.into_raw();
*/
    let s = std::ffi::CString::new("data data data data").expect("CString::new failed");

    unsafe { 
        //gas_print_string(s.as_ptr());  
        let res = c_print(); 
        println!("res:{res}");
    };
 
}