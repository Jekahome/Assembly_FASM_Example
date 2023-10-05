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
    fn gas_print_string(s:*const std::os::raw::c_char) -> *mut std::os::raw::c_char;
    fn c_print() -> *const std::os::raw::c_char;
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



    use std::ffi::CString;  
    let c_string = CString::new("aaa   bbb   ccc").expect("CString::new failed");
    let raw = c_string.into_raw();
     unsafe { 
        let res:*mut i8 = gas_print_string(raw);  
        let c_string = CString::from_raw(res);
        println!("res:{:?}",c_string);
    }; 
 
}