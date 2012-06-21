;Gets multiboot information + multiboot modules
;typedef struct multiboot_info
;{
;  unsigned long flags; 0
;  unsigned long mem_lower; 4
;  unsigned long mem_upper; 8
;  unsigned long boot_device; 12
;  unsigned long cmdline; 16
;  unsigned long mods_count; 20
;  unsigned long mods_addr; 24
;  union
;  {
;    aout_symbol_table_t aout_sym;
;    elf_section_header_table_t elf_sec;
;  } u;
;  unsigned long mmap_length;
;  unsigned long mmap_addr;
;} multiboot_info_t;
;
;/* The module structure. */
;typedef struct module
;{
;  unsigned long mod_start; 0
;  unsigned long mod_end; 4
;  unsigned long string; 8
;  unsigned long reserved;
;} module_t;

	