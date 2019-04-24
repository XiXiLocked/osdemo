;------------------------------------------------------------
%include "boot.inc"
;----------------- initialization for registers ds,es,ss,fs,sp,gs
SECTION MBR vstart=0x7c00
   mov ax,cs
   mov ds,ax
   mov es,ax
   mov ss,ax
   mov fs,ax
   mov sp,0x7c00
   mov ax,0xb800
   mov gs,ax


;------------------call rd_disk_m_16
   mov eax,LOADER_START_SECTOR
   mov bx,LOADER_BASE_ADDR
   mov cx,1
   call rd_disk_m_16

   jmp LOADER_BASE_ADDR
;----------- function: read from 'eax'(disk, LBA), to 'bx'(memory) for 'cx' sectors
rd_disk_m_16:
;---------- set read section count,
;-----------out 0x1f2, cx
      mov esi,eax
      mov di,cx

      mov dx,0x1f2
      mov al,cl
      out dx,al

      mov eax,esi

;-----------set LBA address
;-----------out 0x1f3~, eax
;第2步：将LBA地址存入0x1f3 ~ 0x1f6

      mov cl,8

      mov dx,0x1f3
      out dx,al

      shr eax,cl
      mov dx,0x1f4
      out dx,al

      shr eax,cl
      mov dx,0x1f5
      out dx,al

      shr eax,cl
      and al, 0x0f ; extract low 4 bit
      or al,0xe0 ; set LBA mode
      mov dx,0x1f6
      out dx,al

;------------set read command
;-------- out 0x1f7, 0x20
      mov dx,0x1f7
      mov al,0x20
      out dx,al

;---------- check disk until ready
;----------- read al, 0x1f7   and check (al & 0x88 == 0x08)
  .not_ready:
      nop
      in al,dx
      and al,0x88
      cmp al,0x08
      jnz .not_ready

;-----------read 512*cx bytes data in ax,0x1f0
;----------one loop 2 bytes, loop 512*cx/2 times
      mov ax, di
      mov dx, 256
      mul dx
      mov cx, ax

      mov dx, 0x1f0
  .go_on_read:
      in ax,dx
      mov [bx],ax
      add bx,2
      loop .go_on_read
      ret

; padding
   times 510-($-$$) db 0
   db 0x55,0xaa

