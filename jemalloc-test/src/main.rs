use jemallocator::Jemalloc;

#[global_allocator]
static GLOBAL: Jemalloc = Jemalloc;

fn main() {
    println!("Hello from jemalloc-test on ARM64!");
    
    // Allocate some memory to test jemalloc
    let _vec = vec![0u8; 1024 * 1024];
    println!("Memory allocation successful!");
}
