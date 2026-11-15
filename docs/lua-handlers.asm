
; ---- handler 0  va=0x01344E1C  next=0x01344E8E ----
  0x01344E1C  add     edi, 4
  0x01344E1F  lea     ecx, [esi + 0x18]
  0x01344E22  mov     eax, dword ptr [ecx]
  0x01344E24  xor     eax, ecx
  0x01344E26  cmp     dword ptr [eax + 0x3b8], 0
  0x01344E2D  je      0x1344e76
  0x01344E2F  mov     al, byte ptr [edi]
  0x01344E31  cmp     al, 0xc0
  0x01344E33  je      0x1344e41
  0x01344E35  cmp     al, 0xa3
  0x01344E37  je      0x1344e41
  0x01344E39  cmp     al, 0xe3
  0x01344E3B  je      0x1344e41
  0x01344E3D  xor     al, al
  0x01344E3F  jmp     0x1344e43
  0x01344E41  mov     al, 1
  0x01344E43  test    al, al
  0x01344E45  jne     0x1344e76
  0x01344E47  mov     eax, dword ptr [esi + 8]
  0x01344E4A  lea     edx, [esi + 0x18]
  0x01344E4D  push    0
  0x01344E4F  mov     dword ptr [eax + 4], edi
  0x01344E52  mov     eax, dword ptr [edx]
  0x01344E54  xor     eax, edx
  0x01344E56  push    dword ptr [eax + 0x3b8]
  0x01344E5C  push    esi
  0x01344E5D  call    0x134c580   ; ->RVA 0xF4C580
  0x01344E62  mov     edx, dword ptr [esi + 0x14]
  0x01344E65  add     esp, 0xc
  0x01344E68  cmp     byte ptr [esi + 6], 0
  0x01344E6C  mov     dword ptr [esp + 0x14], edx
  0x01344E70  jne     0x13484c3
  0x01344E76  movzx   eax, byte ptr [edi]
  0x01344E79  nop     dword ptr [eax]
  0x01344E80  movzx   eax, byte ptr [eax + 0x13485e8]
  0x01344E87  jmp     dword ptr [eax*4 + 0x13484cc]

; ---- handler 1  va=0x013473FD  next=0x013474EE ----
  0x013473FD  mov     ecx, dword ptr [edi]
  0x013473FF  mov     eax, ecx
  0x01347401  shr     eax, 8
  0x01347404  add     edi, 4
  0x01347407  movzx   eax, al
  0x0134740A  shl     eax, 4
  0x0134740D  add     eax, edx
  0x0134740F  mov     dword ptr [esp + 0x18], eax
  0x01347413  mov     eax, ecx
  0x01347415  shr     eax, 0x10
  0x01347418  movzx   eax, al
  0x0134741B  shl     eax, 4
  0x0134741E  shr     ecx, 0x18
  0x01347421  add     eax, edx
  0x01347423  shl     ecx, 4
  0x01347426  add     ecx, dword ptr [esp + 0x30]
  0x0134742A  mov     dword ptr [esp + 0x24], eax
  0x0134742E  cmp     dword ptr [eax + 0xc], 4
  0x01347432  jne     0x13474c7
  0x01347438  movaps  xmm2, xmmword ptr [0x28ad240]
  0x0134743F  movsd   xmm1, qword ptr [eax]
  0x01347443  movups  xmmword ptr [esp + 0x40], xmm2
  0x01347448  xorps   xmm1, xmm2
  0x0134744B  movsd   xmm2, qword ptr [ecx]
  0x0134744F  xorps   xmm2, xmmword ptr [esp + 0x40]
  0x01347454  ucomisd xmm2, qword ptr [0x1f80428]
  0x0134745C  lahf    
  0x0134745D  test    ah, 0x44
  0x01347460  jp      0x1347468
  0x01347462  mulsd   xmm1, xmm1
  0x01347466  jmp     0x13474a7
  0x01347468  ucomisd xmm2, qword ptr [0x1f5deb0]
  0x01347470  movaps  xmm0, xmm1
  0x01347473  lahf    
  0x01347474  test    ah, 0x44
  0x01347477  jp      0x1347480
  0x01347479  call    0x19273f0   ; ->RVA 0x15273F0
  0x0134747E  jmp     0x13474a0
  0x01347480  ucomisd xmm2, qword ptr [0x1f53448]
  0x01347488  lahf    
  0x01347489  test    ah, 0x44
  0x0134748C  jp      0x1347498
  0x0134748E  mulsd   xmm0, xmm1
  0x01347492  mulsd   xmm1, xmm0
  0x01347496  jmp     0x13474a7
  0x01347498  movaps  xmm1, xmm2
  0x0134749B  call    0x1927850   ; ->RVA 0x1527850
  0x013474A0  mov     edx, dword ptr [esp + 0x14]
  0x013474A4  movaps  xmm1, xmm0
  0x013474A7  mov     eax, dword ptr [esp + 0x18]
  0x013474AB  xorps   xmm0, xmm0
  0x013474AE  movsd   xmm0, xmm1
  0x013474B2  xorps   xmm0, xmmword ptr [esp + 0x40]
  0x013474B7  movsd   qword ptr [eax], xmm0
  0x013474BB  mov     dword ptr [eax + 0xc], 4
  0x013474C2  jmp     0x1344e1f
  0x013474C7  push    5
  0x013474C9  push    ecx
  0x013474CA  push    dword ptr [esp + 0x2c]
  0x013474CE  mov     eax, dword ptr [esi + 8]
  0x013474D1  mov     dword ptr [eax + 4], edi
  0x013474D4  mov     eax, dword ptr [esp + 0x24]
  0x013474D8  push    eax
  0x013474D9  push    esi
  0x013474DA  call    0x1358ab0   ; ->RVA 0xF58AB0
  0x013474DF  mov     edx, dword ptr [esi + 0x14]
  0x013474E2  add     esp, 0x14
  0x013474E5  mov     dword ptr [esp + 0x14], edx
  0x013474E9  jmp     0x1344e1f

; ---- handler 2  va=0x01346D2B  next=0x01346E38 ----
  0x01346D2B  mov     esi, dword ptr [edi]
  0x01346D2D  mov     eax, esi
  0x01346D2F  shr     eax, 8
  0x01346D32  add     edi, 4
  0x01346D35  movzx   eax, al
  0x01346D38  mov     dword ptr [esp + 0x2c], eax
  0x01346D3C  shl     eax, 4
  0x01346D3F  add     eax, edx
  0x01346D41  mov     dword ptr [esp + 0x18], eax
  0x01346D45  mov     eax, esi
  0x01346D47  shr     eax, 0x10
  0x01346D4A  movzx   eax, al
  0x01346D4D  mov     ecx, eax
  0x01346D4F  shr     esi, 0x18
  0x01346D52  shl     ecx, 4
  0x01346D55  add     ecx, edx
  0x01346D57  mov     dword ptr [esp + 0x10], esi
  0x01346D5B  mov     dword ptr [esp + 0x20], ecx
  0x01346D5F  mov     ecx, esi
  0x01346D61  mov     esi, dword ptr [esp + 0x20]
  0x01346D65  shl     ecx, 4
  0x01346D68  add     ecx, edx
  0x01346D6A  mov     dword ptr [esp + 0x1c], ecx
  0x01346D6E  mov     esi, dword ptr [esi + 0xc]
  0x01346D71  cmp     esi, 4
  0x01346D74  mov     dword ptr [esp + 0x24], esi
  0x01346D78  mov     esi, dword ptr [ebp + 8]
  0x01346D7B  jne     0x1346da9
  0x01346D7D  cmp     dword ptr [ecx + 0xc], 4
  0x01346D81  jne     0x1346da9
  0x01346D83  mov     eax, dword ptr [esp + 0x20]
  0x01346D87  movaps  xmm3, xmmword ptr [0x28ad240]
  0x01346D8E  movsd   xmm2, qword ptr [ecx]
  0x01346D92  xorps   xmm2, xmm3
  0x01346D95  movsd   xmm1, qword ptr [eax]
  0x01346D99  mov     eax, dword ptr [esp + 0x18]
  0x01346D9D  xorps   xmm1, xmm3
  0x01346DA0  mulsd   xmm2, xmm1
  0x01346DA4  jmp     0x134728c
  0x01346DA9  cmp     dword ptr [esp + 0x24], 4
  0x01346DAE  cmove   eax, dword ptr [esp + 0x10]
  0x01346DB3  shl     eax, 4
  0x01346DB6  add     eax, edx
  0x01346DB8  cmp     dword ptr [eax + 0xc], 9
  0x01346DBC  jne     0x1346e2c
  0x01346DBE  push    8
  0x01346DC0  push    eax
  0x01346DC1  push    esi
  0x01346DC2  call    0x13593c0   ; ->RVA 0xF593C0
  0x01346DC7  mov     edx, eax
  0x01346DC9  add     esp, 0xc
  0x01346DCC  test    edx, edx
  0x01346DCE  je      0x1346e28
  0x01346DD0  cmp     dword ptr [edx + 0xc], 6
  0x01346DD4  jne     0x1346e28
  0x01346DD6  mov     ecx, dword ptr [edx]
  0x01346DD8  cmp     byte ptr [ecx + 6], 0
  0x01346DDC  je      0x1346e28
  0x01346DDE  mov     eax, dword ptr [esi + 0x10]
  0x01346DE1  movups  xmm0, xmmword ptr [edx]
  0x01346DE4  mov     ecx, dword ptr [esp + 0x20]
  0x01346DE8  push    dword ptr [esp + 0x2c]
  0x01346DEC  movups  xmmword ptr [eax], xmm0
  0x01346DEF  mov     eax, dword ptr [esi + 0x10]
  0x01346DF2  movups  xmm0, xmmword ptr [ecx]
  0x01346DF5  mov     ecx, dword ptr [esp + 0x20]
  0x01346DF9  push    2
  0x01346DFB  movups  xmmword ptr [eax + 0x10], xmm0
  0x01346DFF  mov     eax, dword ptr [esi + 0x10]
  0x01346E02  movups  xmm0, xmmword ptr [ecx]
  0x01346E05  push    esi
  0x01346E06  movups  xmmword ptr [eax + 0x20], xmm0
  0x01346E0A  mov     eax, dword ptr [esi + 8]
  0x01346E0D  add     dword ptr [esi + 0x10], 0x30
  0x01346E11  mov     dword ptr [eax + 4], edi
  0x01346E14  call    0x134c460   ; ->RVA 0xF4C460
  0x01346E19  mov     edx, dword ptr [esi + 0x14]
  0x01346E1C  add     esp, 0xc
  0x01346E1F  mov     dword ptr [esp + 0x14], edx
  0x01346E23  jmp     0x1344e1f
  0x01346E28  mov     ecx, dword ptr [esp + 0x1c]
  0x01346E2C  push    8
  0x01346E2E  push    ecx
  0x01346E2F  push    dword ptr [esp + 0x28]
  0x01346E33  jmp     0x13474ce

; ---- handler 3  va=0x013461C1  next=0x013461F5 ----
  0x013461C1  mov     edx, dword ptr [edi]
  0x013461C3  mov     eax, edx
  0x013461C5  shr     eax, 8
  0x013461C8  movzx   ecx, al
  0x013461CB  shl     ecx, 4
  0x013461CE  add     ecx, dword ptr [esp + 0x14]
  0x013461D2  sar     edx, 0x10
  0x013461D5  mov     eax, dword ptr [ecx]
  0x013461D7  mov     ecx, dword ptr [ecx + 0xc]
  0x013461DA  or      eax, 0xfffffffe
  0x013461DD  and     ecx, eax
  0x013461DF  xor     eax, eax
  0x013461E1  test    ecx, ecx
  0x013461E3  cmovne  edx, eax
  0x013461E6  lea     edi, [edi + edx*4]
  0x013461E9  mov     edx, dword ptr [esp + 0x14]
  0x013461ED  add     edi, 4
  0x013461F0  jmp     0x1344e1f

; ---- handler 4  va=0x0134587A  next=0x01345935 ----
  0x0134587A  mov     ecx, dword ptr [edi]
  0x0134587C  mov     eax, ecx
  0x0134587E  shr     eax, 8
  0x01345881  add     edi, 4
  0x01345884  movzx   eax, al
  0x01345887  shl     eax, 4
  0x0134588A  add     eax, edx
  0x0134588C  mov     dword ptr [esp + 0x10], eax
  0x01345890  mov     eax, ecx
  0x01345892  shr     eax, 0x10
  0x01345895  movzx   eax, al
  0x01345898  shl     eax, 4
  0x0134589B  add     eax, edx
  0x0134589D  shr     ecx, 0x18
  0x013458A0  mov     dword ptr [esp + 0x20], eax
  0x013458A4  mov     dword ptr [esp + 0x18], ecx
  0x013458A8  cmp     dword ptr [eax + 0xc], 8
  0x013458AC  jne     0x13458e3
  0x013458AE  mov     eax, dword ptr [eax]
  0x013458B0  mov     dword ptr [esp + 0x1c], eax
  0x013458B4  cmp     ecx, dword ptr [eax + 0xc]
  0x013458B7  jae     0x13458e3
  0x013458B9  lea     ecx, [eax + 0x1c]
  0x013458BC  mov     eax, dword ptr [ecx]
  0x013458BE  add     eax, ecx
  0x013458C0  mov     ecx, dword ptr [esp + 0x18]
  0x013458C4  jne     0x13458e3
  0x013458C6  mov     eax, dword ptr [esp + 0x1c]
  0x013458CA  add     eax, 0x14
  0x013458CD  shl     ecx, 4
  0x013458D0  add     ecx, eax
  0x013458D2  add     ecx, dword ptr [eax]
  0x013458D4  mov     eax, dword ptr [esp + 0x10]
  0x013458D8  movups  xmm0, xmmword ptr [ecx]
  0x013458DB  movups  xmmword ptr [eax], xmm0
  0x013458DE  jmp     0x1344e1f
  0x013458E3  lea     eax, [ecx + 1]
  0x013458E6  mov     dword ptr [esp + 0xac], 4
  0x013458F1  movd    xmm0, eax
  0x013458F5  mov     eax, dword ptr [esi + 8]
  0x013458F8  cvtdq2pd xmm1, xmm0
  0x013458FC  xorps   xmm1, xmmword ptr [0x28ad240]
  0x01345903  movsd   qword ptr [esp + 0xa0], xmm1
  0x0134590C  mov     dword ptr [eax + 4], edi
  0x0134590F  mov     eax, dword ptr [esp + 0x10]
  0x01345913  push    eax
  0x01345914  lea     eax, [esp + 0xa4]
  0x0134591B  push    eax
  0x0134591C  push    dword ptr [esp + 0x28]
  0x01345920  push    esi
  0x01345921  call    0x1358ec0   ; ->RVA 0xF58EC0
  0x01345926  mov     edx, dword ptr [esi + 0x14]
  0x01345929  add     esp, 0x10
  0x0134592C  mov     dword ptr [esp + 0x14], edx
  0x01345930  jmp     0x1344e1f

; ---- handler 5  va=0x01347E3B  next=0x01347EA4 ----
  0x01347E3B  mov     eax, dword ptr [edi]
  0x01347E3D  mov     dword ptr [esp + 0x18], eax
  0x01347E41  shr     eax, 8
  0x01347E44  movzx   eax, al
  0x01347E47  shl     eax, 4
  0x01347E4A  add     eax, edx
  0x01347E4C  mov     dword ptr [esp + 0x24], eax
  0x01347E50  cmp     dword ptr [eax + 0xc], 6
  0x01347E54  jne     0x1344e12
  0x01347E5A  mov     ecx, dword ptr [eax]
  0x01347E5C  cmp     byte ptr [ecx + 6], 0
  0x01347E60  je      0x1344e12
  0x01347E66  mov     eax, dword ptr [ecx + 0x18]
  0x01347E69  add     ecx, 0x18
  0x01347E6C  xor     eax, ecx
  0x01347E6E  cmp     eax, 0x134ef50
  0x01347E73  jne     0x1344e12
  0x01347E79  mov     eax, dword ptr [esp + 0x24]
  0x01347E7D  cmp     dword ptr [eax + 0x1c], 8
  0x01347E81  jne     0x1344e12
  0x01347E87  cmp     dword ptr [eax + 0x2c], 0
  0x01347E8B  jne     0x1344e12
  0x01347E91  mov     dword ptr [eax + 0x20], 0
  0x01347E98  mov     dword ptr [eax + 0x2c], 3
  0x01347E9F  jmp     0x1344e12

; ---- handler 6  va=0x0134508A  next=0x01345167 ----
  0x0134508A  mov     ecx, dword ptr [edi]
  0x0134508C  mov     eax, ecx
  0x0134508E  shr     eax, 8
  0x01345091  movzx   eax, al
  0x01345094  shl     eax, 4
  0x01345097  add     eax, edx
  0x01345099  shr     ecx, 0x18
  0x0134509C  mov     dword ptr [esp + 0x1c], eax
  0x013450A0  mov     eax, dword ptr [edi + 4]
  0x013450A3  add     edi, 8
  0x013450A6  shl     eax, 4
  0x013450A9  add     eax, dword ptr [esp + 0x30]
  0x013450AD  mov     dword ptr [esp + 0x2c], eax
  0x013450B1  mov     eax, dword ptr [esp + 0x34]
  0x013450B5  mov     eax, dword ptr [eax + 0x10]
  0x013450B8  mov     dword ptr [esp + 0x20], eax
  0x013450BC  movzx   esi, byte ptr [eax + 0xa]
  0x013450C0  add     eax, 0x20
  0x013450C3  and     esi, ecx
  0x013450C5  mov     ecx, esi
  0x013450C7  mov     dword ptr [esp + 0x10], esi
  0x013450CB  mov     esi, dword ptr [ebp + 8]
  0x013450CE  shl     ecx, 5
  0x013450D1  add     ecx, dword ptr [eax]
  0x013450D3  add     ecx, eax
  0x013450D5  mov     eax, dword ptr [ecx + 0x1c]
  0x013450D8  and     eax, 0xf
  0x013450DB  cmp     al, 5
  0x013450DD  jne     0x1345119
  0x013450DF  mov     esi, dword ptr [esp + 0x2c]
  0x013450E3  mov     eax, dword ptr [ecx + 0x10]
  0x013450E6  cmp     eax, dword ptr [esi]
  0x013450E8  mov     esi, dword ptr [ebp + 8]
  0x013450EB  mov     eax, dword ptr [esp + 0x20]
  0x013450EF  jne     0x134511d
  0x013450F1  cmp     dword ptr [ecx + 0xc], 0
  0x013450F5  je      0x134511d
  0x013450F7  cmp     byte ptr [eax + 7], 0
  0x013450FB  jne     0x134511d
  0x013450FD  mov     esi, dword ptr [esp + 0x1c]
  0x01345101  movups  xmm0, xmmword ptr [esi]
  0x01345104  mov     esi, dword ptr [ebp + 8]
  0x01345107  movups  xmmword ptr [ecx], xmm0
  0x0134510A  cmp     dword ptr [ecx + 0xc], 5
  0x0134510E  jl      0x1344e1f
  0x01345114  jmp     0x1345823
  0x01345119  mov     eax, dword ptr [esp + 0x20]
  0x0134511D  push    dword ptr [esp + 0x1c]
  0x01345121  mov     dword ptr [esp + 0x94], eax
  0x01345128  mov     eax, dword ptr [esp + 0x14]
  0x0134512C  push    dword ptr [esp + 0x30]
  0x01345130  mov     dword ptr [esi + 0x68], eax
  0x01345133  mov     eax, dword ptr [esi + 8]
  0x01345136  mov     dword ptr [esp + 0xa4], 8
  0x01345141  mov     dword ptr [eax + 4], edi
  0x01345144  lea     eax, [esp + 0x98]
  0x0134514B  push    eax
  0x0134514C  push    esi
  0x0134514D  call    0x1359130   ; ->RVA 0xF59130
  0x01345152  mov     edx, dword ptr [esi + 0x14]
  0x01345155  add     esp, 0x10
  0x01345158  mov     al, byte ptr [esi + 0x68]
  0x0134515B  mov     dword ptr [esp + 0x14], edx
  0x0134515F  mov     byte ptr [edi - 5], al
  0x01345162  jmp     0x1344e1f

; ---- handler 7  va=0x01347789  next=0x01347842 ----
  0x01347789  mov     ecx, dword ptr [edi]
  0x0134778B  mov     eax, ecx
  0x0134778D  shr     ecx, 0x10
  0x01347790  add     edi, 4
  0x01347793  shr     eax, 8
  0x01347796  movzx   ecx, cl
  0x01347799  movzx   eax, al
  0x0134779C  shl     ecx, 4
  0x0134779F  shl     eax, 4
  0x013477A2  add     ecx, edx
  0x013477A4  add     eax, edx
  0x013477A6  mov     dword ptr [esp + 0x10], eax
  0x013477AA  mov     eax, dword ptr [ecx + 0xc]
  0x013477AD  cmp     eax, 8
  0x013477B0  jne     0x13477e3
  0x013477B2  push    dword ptr [ecx]
  0x013477B4  call    0x13574c0   ; ->RVA 0xF574C0
  0x013477B9  mov     edx, dword ptr [esp + 0x18]
  0x013477BD  add     esp, 4
  0x013477C0  movd    xmm0, eax
  0x013477C4  mov     eax, dword ptr [esp + 0x10]
  0x013477C8  cvtdq2pd xmm1, xmm0
  0x013477CC  xorps   xmm1, xmmword ptr [0x28ad240]
  0x013477D3  movsd   qword ptr [eax], xmm1
  0x013477D7  mov     dword ptr [eax + 0xc], 4
  0x013477DE  jmp     0x1344e1f
  0x013477E3  cmp     eax, 5
  0x013477E6  jne     0x1347821
  0x013477E8  mov     eax, dword ptr [ecx]
  0x013477EA  add     eax, 0xc
  0x013477ED  sub     eax, dword ptr [eax]
  0x013477EF  movd    xmm0, eax
  0x013477F3  cvtdq2pd xmm0, xmm0
  0x013477F7  shr     eax, 0x1f
  0x013477FA  addsd   xmm0, qword ptr [eax*8 + 0x1c74ea0]
  0x01347803  mov     eax, dword ptr [esp + 0x10]
  0x01347807  movaps  xmm1, xmm0
  0x0134780A  xorps   xmm1, xmmword ptr [0x28ad240]
  0x01347811  movsd   qword ptr [eax], xmm1
  0x01347815  mov     dword ptr [eax + 0xc], 4
  0x0134781C  jmp     0x1344e1f
  0x01347821  mov     eax, dword ptr [esi + 8]
  0x01347824  push    ecx
  0x01347825  mov     dword ptr [eax + 4], edi
  0x01347828  mov     eax, dword ptr [esp + 0x14]
  0x0134782C  push    eax
  0x0134782D  push    esi
  0x0134782E  call    0x1358ce0   ; ->RVA 0xF58CE0
  0x01347833  mov     edx, dword ptr [esi + 0x14]
  0x01347836  add     esp, 0xc
  0x01347839  mov     dword ptr [esp + 0x14], edx
  0x0134783D  jmp     0x1344e1f

; ---- handler 8  va=0x01347342  next=0x013473FD ----
  0x01347342  mov     ecx, dword ptr [edi]
  0x01347344  mov     eax, ecx
  0x01347346  shr     eax, 8
  0x01347349  add     edi, 4
  0x0134734C  movzx   eax, al
  0x0134734F  shl     eax, 4
  0x01347352  add     eax, edx
  0x01347354  mov     dword ptr [esp + 0x18], eax
  0x01347358  mov     eax, ecx
  0x0134735A  shr     eax, 0x10
  0x0134735D  movzx   eax, al
  0x01347360  shl     eax, 4
  0x01347363  shr     ecx, 0x18
  0x01347366  add     eax, edx
  0x01347368  shl     ecx, 4
  0x0134736B  add     ecx, dword ptr [esp + 0x30]
  0x0134736F  mov     dword ptr [esp + 0x24], eax
  0x01347373  cmp     dword ptr [eax + 0xc], 4
  0x01347377  jne     0x1346fea
  0x0134737D  movaps  xmm3, xmmword ptr [0x28ad240]
  0x01347384  sub     esp, 8
  0x01347387  movsd   xmm2, qword ptr [eax]
  0x0134738B  movsd   xmm1, qword ptr [ecx]
  0x0134738F  xorps   xmm2, xmm3
  0x01347392  xorps   xmm1, xmm3
  0x01347395  movaps  xmm0, xmm2
  0x01347398  divsd   xmm0, xmm1
  0x0134739C  movups  xmmword ptr [esp + 0x68], xmm3
  0x013473A1  movsd   qword ptr [esp + 0x48], xmm0
  0x013473A7  fld     qword ptr [esp + 0x48]
  0x013473AB  fstp    qword ptr [esp]
  0x013473AE  movups  xmmword ptr [esp + 0x78], xmm2
  0x013473B3  movups  xmmword ptr [esp + 0x58], xmm1
  0x013473B8  call    0x1924ea0   ; ->RVA 0x1524EA0
  0x013473BD  movups  xmm1, xmmword ptr [esp + 0x78]
  0x013473C2  fstp    qword ptr [esp + 0x48]
  0x013473C6  movsd   xmm0, qword ptr [esp + 0x48]
  0x013473CC  mulsd   xmm0, qword ptr [esp + 0x58]
  0x013473D2  subsd   xmm1, xmm0
  0x013473D6  xorps   xmm0, xmm0
  0x013473D9  movsd   xmm0, xmm1
  0x013473DD  xorps   xmm0, xmmword ptr [esp + 0x68]
  0x013473E2  mov     eax, dword ptr [esp + 0x20]
  0x013473E6  add     esp, 8
  0x013473E9  mov     edx, dword ptr [esp + 0x14]
  0x013473ED  movsd   qword ptr [eax], xmm0
  0x013473F1  mov     dword ptr [eax + 0xc], 4
  0x013473F8  jmp     0x1344e1f

; ---- handler 9  va=0x01346C2E  next=0x01346D2B ----
  0x01346C2E  mov     ecx, dword ptr [edi]
  0x01346C30  mov     eax, ecx
  0x01346C32  shr     eax, 8
  0x01346C35  add     edi, 4
  0x01346C38  movzx   eax, al
  0x01346C3B  mov     dword ptr [esp + 0x24], eax
  0x01346C3F  shl     eax, 4
  0x01346C42  add     eax, edx
  0x01346C44  mov     dword ptr [esp + 0x10], eax
  0x01346C48  mov     eax, ecx
  0x01346C4A  shr     eax, 0x10
  0x01346C4D  movzx   eax, al
  0x01346C50  shl     eax, 4
  0x01346C53  shr     ecx, 0x18
  0x01346C56  add     eax, edx
  0x01346C58  shl     ecx, 4
  0x01346C5B  add     ecx, edx
  0x01346C5D  mov     dword ptr [esp + 0x18], eax
  0x01346C61  mov     dword ptr [esp + 0x1c], ecx
  0x01346C65  cmp     dword ptr [eax + 0xc], 4
  0x01346C69  jne     0x1346c8f
  0x01346C6B  cmp     dword ptr [ecx + 0xc], 4
  0x01346C6F  jne     0x1346c8f
  0x01346C71  movaps  xmm3, xmmword ptr [0x28ad240]
  0x01346C78  movsd   xmm2, qword ptr [eax]
  0x01346C7C  movsd   xmm1, qword ptr [ecx]
  0x01346C80  xorps   xmm2, xmm3
  0x01346C83  xorps   xmm1, xmm3
  0x01346C86  subsd   xmm2, xmm1
  0x01346C8A  jmp     0x1347288
  0x01346C8F  cmp     dword ptr [eax + 0xc], 9
  0x01346C93  jne     0x1346d03
  0x01346C95  push    6
  0x01346C97  push    eax
  0x01346C98  push    esi
  0x01346C99  call    0x13593c0   ; ->RVA 0xF593C0
  0x01346C9E  mov     edx, eax
  0x01346CA0  add     esp, 0xc
  0x01346CA3  test    edx, edx
  0x01346CA5  je      0x1346cff
  0x01346CA7  cmp     dword ptr [edx + 0xc], 6
  0x01346CAB  jne     0x1346cff
  0x01346CAD  mov     ecx, dword ptr [edx]
  0x01346CAF  cmp     byte ptr [ecx + 6], 0
  0x01346CB3  je      0x1346cff
  0x01346CB5  mov     eax, dword ptr [esi + 0x10]
  0x01346CB8  movups  xmm0, xmmword ptr [edx]
  0x01346CBB  mov     ecx, dword ptr [esp + 0x18]
  0x01346CBF  push    dword ptr [esp + 0x24]
  0x01346CC3  movups  xmmword ptr [eax], xmm0
  0x01346CC6  mov     eax, dword ptr [esi + 0x10]
  0x01346CC9  movups  xmm0, xmmword ptr [ecx]
  0x01346CCC  mov     ecx, dword ptr [esp + 0x20]
  0x01346CD0  push    2
  0x01346CD2  movups  xmmword ptr [eax + 0x10], xmm0
  0x01346CD6  mov     eax, dword ptr [esi + 0x10]
  0x01346CD9  movups  xmm0, xmmword ptr [ecx]
  0x01346CDC  push    esi
  0x01346CDD  movups  xmmword ptr [eax + 0x20], xmm0
  0x01346CE1  mov     eax, dword ptr [esi + 8]
  0x01346CE4  add     dword ptr [esi + 0x10], 0x30
  0x01346CE8  mov     dword ptr [eax + 4], edi
  0x01346CEB  call    0x134c460   ; ->RVA 0xF4C460
  0x01346CF0  mov     edx, dword ptr [esi + 0x14]
  0x01346CF3  add     esp, 0xc
  0x01346CF6  mov     dword ptr [esp + 0x14], edx
  0x01346CFA  jmp     0x1344e1f
  0x01346CFF  mov     ecx, dword ptr [esp + 0x1c]
  0x01346D03  mov     eax, dword ptr [esi + 8]
  0x01346D06  push    6
  0x01346D08  push    ecx
  0x01346D09  mov     ecx, dword ptr [esp + 0x20]
  0x01346D0D  push    ecx
  0x01346D0E  mov     dword ptr [eax + 4], edi
  0x01346D11  mov     eax, dword ptr [esp + 0x1c]
  0x01346D15  push    eax
  0x01346D16  push    esi
  0x01346D17  call    0x1358ab0   ; ->RVA 0xF58AB0
  0x01346D1C  mov     edx, dword ptr [esi + 0x14]
  0x01346D1F  add     esp, 0x14
  0x01346D22  mov     dword ptr [esp + 0x14], edx
  0x01346D26  jmp     0x1344e1f

; ---- handler 10  va=0x0134618E  next=0x013461C1 ----
  0x0134618E  mov     edx, dword ptr [edi]
  0x01346190  mov     eax, edx
  0x01346192  shr     eax, 8
  0x01346195  movzx   ecx, al
  0x01346198  shl     ecx, 4
  0x0134619B  add     ecx, dword ptr [esp + 0x14]
  0x0134619F  sar     edx, 0x10
  0x013461A2  mov     eax, dword ptr [ecx]
  0x013461A4  mov     ecx, dword ptr [ecx + 0xc]
  0x013461A7  or      eax, 0xfffffffe
  0x013461AA  and     ecx, eax
  0x013461AC  neg     ecx
  0x013461AE  sbb     ecx, ecx
  0x013461B0  and     ecx, edx
  0x013461B2  mov     edx, dword ptr [esp + 0x14]
  0x013461B6  lea     edi, [edi + ecx*4]
  0x013461B9  add     edi, 4
  0x013461BC  jmp     0x1344e1f

; ---- handler 11  va=0x0134849E  next=0x013486BE ----
  0x0134849E  mov     ecx, dword ptr [edi]
  0x013484A0  add     edi, 4
  0x013484A3  sar     ecx, 8
  0x013484A6  cmp     ecx, 0x7fffff
  0x013484AC  lea     eax, [ecx + 1]
  0x013484AF  cmovge  eax, ecx
  0x013484B2  shl     eax, 8
  0x013484B5  or      eax, 0x2f
  0x013484B8  mov     dword ptr [edi - 4], eax
  0x013484BB  jmp     0x1344e1f
  0x013484C0  mov     dword ptr [esi + 0x10], edi
  0x013484C3  pop     edi
  0x013484C4  pop     esi
  0x013484C5  mov     esp, ebp
  0x013484C7  pop     ebp
  0x013484C8  ret     

; ---- handler 12  va=0x01345476  next=0x0134567E ----
  0x01345476  mov     ecx, dword ptr [edi]
  0x01345478  mov     eax, ecx
  0x0134547A  shr     eax, 8
  0x0134547D  movzx   eax, al
  0x01345480  shl     eax, 4
  0x01345483  add     eax, edx
  0x01345485  mov     dword ptr [esp + 0x18], ecx
  0x01345489  mov     dword ptr [esp + 0x20], eax
  0x0134548D  mov     eax, ecx
  0x0134548F  mov     ecx, dword ptr [edi + 4]
  0x01345492  add     edi, 8
  0x01345495  shr     eax, 0x10
  0x01345498  movzx   eax, al
  0x0134549B  shl     eax, 4
  0x0134549E  add     eax, edx
  0x013454A0  shl     ecx, 4
  0x013454A3  add     ecx, dword ptr [esp + 0x30]
  0x013454A7  mov     dword ptr [esp + 0x2c], eax
  0x013454AB  mov     dword ptr [esp + 0x28], ecx
  0x013454AF  cmp     dword ptr [eax + 0xc], 8
  0x013454B3  jne     0x1345584
  0x013454B9  mov     ecx, dword ptr [eax]
  0x013454BB  mov     dword ptr [esp + 0x10], ecx
  0x013454BF  movzx   eax, byte ptr [ecx + 0xa]
  0x013454C3  mov     dword ptr [esp + 0x1c], eax
  0x013454C7  mov     eax, dword ptr [esp + 0x18]
  0x013454CB  shr     eax, 0x18
  0x013454CE  and     dword ptr [esp + 0x1c], eax
  0x013454D2  lea     eax, [ecx + 0x20]
  0x013454D5  mov     ecx, dword ptr [esp + 0x1c]
  0x013454D9  shl     ecx, 5
  0x013454DC  add     ecx, dword ptr [eax]
  0x013454DE  add     ecx, eax
  0x013454E0  mov     eax, dword ptr [ecx + 0x1c]
  0x013454E3  and     eax, 0xf
  0x013454E6  cmp     al, 5
  0x013454E8  jne     0x134554f
  0x013454EA  mov     esi, dword ptr [esp + 0x28]
  0x013454EE  mov     eax, dword ptr [ecx + 0x10]
  0x013454F1  cmp     eax, dword ptr [esi]
  0x013454F3  mov     esi, dword ptr [ebp + 8]
  0x013454F6  jne     0x134554f
  0x013454F8  cmp     dword ptr [ecx + 0xc], 0
  0x013454FC  je      0x134554f
  0x013454FE  mov     eax, dword ptr [esp + 0x10]
  0x01345502  cmp     byte ptr [eax + 7], 0
  0x01345506  jne     0x134554f
  0x01345508  mov     eax, dword ptr [esp + 0x20]
  0x0134550C  movups  xmm0, xmmword ptr [eax]
  0x0134550F  movups  xmmword ptr [ecx], xmm0
  0x01345512  cmp     dword ptr [ecx + 0xc], 5
  0x01345516  jl      0x1344e1f
  0x0134551C  mov     eax, dword ptr [esp + 0x10]
  0x01345520  test    byte ptr [eax + 5], 4
  0x01345524  je      0x1344e1f
  0x0134552A  mov     eax, dword ptr [ecx]
  0x0134552C  lea     ecx, [esi + 0x18]
  0x0134552F  test    byte ptr [eax + 5], 3
  0x01345533  je      0x1344e22
  0x01345539  push    dword ptr [esp + 0x10]
  0x0134553D  push    esi
  0x0134553E  call    0x1355b60   ; ->RVA 0xF55B60
  0x01345543  mov     edx, dword ptr [esp + 0x1c]
  0x01345547  add     esp, 8
  0x0134554A  jmp     0x1344e1f
  0x0134554F  push    dword ptr [esp + 0x20]
  0x01345553  mov     eax, dword ptr [esp + 0x20]
  0x01345557  push    dword ptr [esp + 0x2c]
  0x0134555B  mov     ecx, dword ptr [esp + 0x34]
  0x0134555F  mov     dword ptr [esi + 0x68], eax
  0x01345562  mov     eax, dword ptr [esi + 8]
  0x01345565  push    ecx
  0x01345566  push    esi
  0x01345567  mov     dword ptr [eax + 4], edi
  0x0134556A  call    0x1359130   ; ->RVA 0xF59130
  0x0134556F  mov     edx, dword ptr [esi + 0x14]
  0x01345572  add     esp, 0x10
  0x01345575  mov     al, byte ptr [esi + 0x68]
  0x01345578  mov     dword ptr [esp + 0x14], edx
  0x0134557C  mov     byte ptr [edi - 5], al
  0x0134557F  jmp     0x1344e1f
  0x01345584  cmp     dword ptr [eax + 0xc], 9
  0x01345588  jne     0x1345659
  0x0134558E  mov     edx, dword ptr [eax]
  0x01345590  mov     eax, dword ptr [edx + 0xc]
  0x01345593  add     edx, 0xc
  0x01345596  mov     dword ptr [esp + 0x10], eax
  0x0134559A  mov     eax, edx
  0x0134559C  sub     eax, dword ptr [esp + 0x10]
  0x013455A0  je      0x1345659
  0x013455A6  mov     eax, edx
  0x013455A8  sub     eax, dword ptr [esp + 0x10]
  0x013455AC  test    byte ptr [eax + 6], 1
  0x013455B0  jne     0x1345659
  0x013455B6  mov     eax, dword ptr [esi + 0x18]
  0x013455B9  lea     ecx, [esi + 0x18]
  0x013455BC  sub     edx, dword ptr [esp + 0x10]
  0x013455C0  xor     eax, ecx
  0x013455C2  mov     ecx, dword ptr [eax + 0xd4]
  0x013455C8  add     eax, 0xd4
  0x013455CD  add     ecx, eax
  0x013455CF  push    ecx
  0x013455D0  push    0
  0x013455D2  push    edx
  0x013455D3  call    0x1359390   ; ->RVA 0xF59390
  0x013455D8  mov     edx, eax
  0x013455DA  add     esp, 0xc
  0x013455DD  test    edx, edx
  0x013455DF  je      0x1345655
  0x013455E1  cmp     dword ptr [edx + 0xc], 6
  0x013455E5  jne     0x1345655
  0x013455E7  mov     ecx, dword ptr [edx]
  0x013455E9  cmp     byte ptr [ecx + 6], 0
  0x013455ED  je      0x1345655
  0x013455EF  mov     eax, dword ptr [esi + 0x10]
  0x013455F2  movups  xmm0, xmmword ptr [edx]
  0x013455F5  mov     ecx, dword ptr [esp + 0x2c]
  0x013455F9  push    -1
  0x013455FB  movups  xmmword ptr [eax], xmm0
  0x013455FE  mov     eax, dword ptr [esi + 0x10]
  0x01345601  movups  xmm0, xmmword ptr [ecx]
  0x01345604  mov     ecx, dword ptr [esp + 0x2c]
  0x01345608  push    3
  0x0134560A  movups  xmmword ptr [eax + 0x10], xmm0
  0x0134560E  mov     eax, dword ptr [esi + 0x10]
  0x01345611  movups  xmm0, xmmword ptr [ecx]
  0x01345614  mov     ecx, dword ptr [esp + 0x28]
  0x01345618  movups  xmmword ptr [eax + 0x20], xmm0
  0x0134561C  mov     eax, dword ptr [esi + 0x10]
  0x0134561F  movups  xmm0, xmmword ptr [ecx]
  0x01345622  movups  xmmword ptr [eax + 0x30], xmm0
  0x01345626  mov     eax, dword ptr [esp + 0x20]
  0x0134562A  add     dword ptr [esi + 0x10], 0x40
  0x0134562E  shr     eax, 0x18
  0x01345631  mov     dword ptr [esi + 0x68], eax
  0x01345634  mov     eax, dword ptr [esi + 8]
  0x01345637  push    esi
  0x01345638  mov     dword ptr [eax + 4], edi
  0x0134563B  call    0x134c460   ; ->RVA 0xF4C460
  0x01345640  mov     edx, dword ptr [esi + 0x14]
  0x01345643  add     esp, 0xc
  0x01345646  mov     al, byte ptr [esi + 0x68]
  0x01345649  mov     dword ptr [esp + 0x14], edx
  0x0134564D  mov     byte ptr [edi - 5], al
  0x01345650  jmp     0x1344e1f
  0x01345655  mov     ecx, dword ptr [esp + 0x28]
  0x01345659  push    dword ptr [esp + 0x20]
  0x0134565D  mov     eax, dword ptr [esi + 8]
  0x01345660  push    ecx
  0x01345661  mov     ecx, dword ptr [esp + 0x34]
  0x01345665  push    ecx
  0x01345666  push    esi
  0x01345667  mov     dword ptr [eax + 4], edi
  0x0134566A  call    0x1359130   ; ->RVA 0xF59130
  0x0134566F  mov     edx, dword ptr [esi + 0x14]
  0x01345672  add     esp, 0x10
  0x01345675  mov     dword ptr [esp + 0x14], edx
  0x01345679  jmp     0x1344e1f

; ---- handler 13  va=0x01347C84  next=0x01347E3B ----
  0x01347C84  mov     eax, dword ptr [esi + 0x18]
  0x01347C87  lea     ecx, [esi + 0x18]
  0x01347C8A  xor     eax, ecx
  0x01347C8C  mov     ecx, dword ptr [eax + 0x3a8]
  0x01347C92  add     eax, 0x3a8
  0x01347C97  add     ecx, eax
  0x01347C99  mov     dword ptr [esp + 0x24], ecx
  0x01347C9D  je      0x1347cc3
  0x01347C9F  mov     eax, dword ptr [esi + 8]
  0x01347CA2  mov     dword ptr [eax + 4], edi
  0x01347CA5  mov     eax, dword ptr [0x2941254]
  0x01347CAA  sub     ecx, eax
  0x01347CAC  cmp     ecx, dword ptr [0x2941258]
  0x01347CB2  jae     0x1347cbc
  0x01347CB4  push    esi
  0x01347CB5  call    dword ptr [esp + 0x28]
  0x01347CB9  add     esp, 4
  0x01347CBC  mov     edx, dword ptr [esi + 0x14]
  0x01347CBF  mov     dword ptr [esp + 0x14], edx
  0x01347CC3  mov     eax, dword ptr [edi]
  0x01347CC5  add     edi, 4
  0x01347CC8  mov     dword ptr [esp + 0x10], eax
  0x01347CCC  shr     eax, 8
  0x01347CCF  movzx   eax, al
  0x01347CD2  mov     ecx, eax
  0x01347CD4  mov     dword ptr [esp + 0x24], eax
  0x01347CD8  shl     ecx, 4
  0x01347CDB  add     ecx, edx
  0x01347CDD  mov     dword ptr [esp + 0x18], ecx
  0x01347CE1  cmp     dword ptr [ecx + 0x1c], 8
  0x01347CE5  jne     0x1347e02
  0x01347CEB  cmp     dword ptr [ecx + 0x2c], 3
  0x01347CEF  jne     0x1347e02
  0x01347CF5  mov     eax, dword ptr [ecx + 0x10]
  0x01347CF8  mov     esi, dword ptr [ecx + 0x20]
  0x01347CFB  mov     dword ptr [esp + 0x24], esi
  0x01347CFF  mov     dword ptr [esp + 0x20], eax
  0x01347D03  cmp     esi, dword ptr [eax + 0xc]
  0x01347D06  mov     esi, dword ptr [ebp + 8]
  0x01347D09  jae     0x1347d82
  0x01347D0B  mov     esi, dword ptr [ecx + 0x20]
  0x01347D0E  mov     eax, dword ptr [eax + 0x14]
  0x01347D11  shl     esi, 4
  0x01347D14  add     eax, esi
  0x01347D16  mov     dword ptr [esp + 0x24], esi
  0x01347D1A  mov     esi, dword ptr [esp + 0x20]
  0x01347D1E  cmp     dword ptr [eax + esi + 0x20], 0
  0x01347D23  mov     esi, dword ptr [ebp + 8]
  0x01347D26  je      0x1344e1f
  0x01347D2C  mov     eax, dword ptr [ecx + 0x20]
  0x01347D2F  mov     esi, dword ptr [esp + 0x24]
  0x01347D33  inc     eax
  0x01347D34  mov     dword ptr [ecx + 0x20], eax
  0x01347D37  add     esi, 0x14
  0x01347D3A  mov     dword ptr [ecx + 0x2c], 3
  0x01347D41  movd    xmm0, eax
  0x01347D45  mov     eax, dword ptr [esp + 0x20]
  0x01347D49  cvtdq2pd xmm1, xmm0
  0x01347D4D  add     eax, esi
  0x01347D4F  mov     esi, dword ptr [esp + 0x20]
  0x01347D53  xorps   xmm1, xmmword ptr [0x28ad240]
  0x01347D5A  movsd   qword ptr [ecx + 0x30], xmm1
  0x01347D5F  mov     dword ptr [ecx + 0x3c], 4
  0x01347D66  add     eax, dword ptr [esi + 0x14]
  0x01347D69  mov     esi, dword ptr [ebp + 8]
  0x01347D6C  movups  xmm0, xmmword ptr [eax]
  0x01347D6F  mov     eax, dword ptr [esp + 0x10]
  0x01347D73  sar     eax, 0x10
  0x01347D76  movups  xmmword ptr [ecx + 0x40], xmm0
  0x01347D7A  lea     edi, [edi + eax*4]
  0x01347D7D  jmp     0x1344e1f
  0x01347D82  cmp     byte ptr [eax + 8], 0
  0x01347D86  jne     0x1347da1
  0x01347D88  mov     ecx, dword ptr [esp + 0x20]
  0x01347D8C  mov     eax, dword ptr [eax + 0x20]
  0x01347D8F  cmp     dword ptr [eax + ecx + 0x2c], 0
  0x01347D94  lea     ecx, [esi + 0x18]
  0x01347D97  je      0x1344e22
  0x01347D9D  mov     eax, dword ptr [esp + 0x20]
  0x01347DA1  mov     esi, dword ptr [esp + 0x24]
  0x01347DA5  inc     esi
  0x01347DA6  push    esi
  0x01347DA7  push    eax
  0x01347DA8  call    0x1357540   ; ->RVA 0xF57540
  0x01347DAD  mov     ecx, dword ptr [esp + 0x20]
  0x01347DB1  add     esp, 8
  0x01347DB4  mov     edx, dword ptr [esp + 0x10]
  0x01347DB8  movd    xmm0, esi
  0x01347DBC  cvtdq2pd xmm1, xmm0
  0x01347DC0  mov     dword ptr [ecx + 0x20], esi
  0x01347DC3  mov     esi, dword ptr [ebp + 8]
  0x01347DC6  mov     dword ptr [ecx + 0x2c], 3
  0x01347DCD  sar     edx, 0x10
  0x01347DD0  xorps   xmm1, xmmword ptr [0x28ad240]
  0x01347DD7  movsd   qword ptr [ecx + 0x30], xmm1
  0x01347DDC  mov     dword ptr [ecx + 0x3c], 4
  0x01347DE3  movups  xmm0, xmmword ptr [eax]
  0x01347DE6  xor     eax, eax
  0x01347DE8  movups  xmmword ptr [ecx + 0x40], xmm0
  0x01347DEC  cmp     dword ptr [ecx + 0x4c], eax
  0x01347DEF  mov     ecx, dword ptr [esp + 0x38]
  0x01347DF3  cmovne  eax, edx
  0x01347DF6  mov     edx, dword ptr [esp + 0x14]
  0x01347DFA  lea     edi, [edi + eax*4]
  0x01347DFD  jmp     0x1344e22
  0x01347E02  mov     eax, dword ptr [esi + 8]
  0x01347E05  push    2
  0x01347E07  push    dword ptr [esp + 0x28]
  0x01347E0B  push    esi
  0x01347E0C  mov     dword ptr [eax + 4], edi
  0x01347E0F  call    0x134d160   ; ->RVA 0xF4D160
  0x01347E14  mov     edx, dword ptr [esi + 0x14]
  0x01347E17  add     esp, 0xc
  0x01347E1A  mov     dword ptr [esp + 0x14], edx
  0x01347E1E  test    al, al
  0x01347E20  je      0x1347e2c
  0x01347E22  xor     eax, eax
  0x01347E24  lea     edi, [edi + eax*4]
  0x01347E27  jmp     0x1344e1f
  0x01347E2C  mov     eax, dword ptr [esp + 0x10]
  0x01347E30  sar     eax, 0x10
  0x01347E33  lea     edi, [edi + eax*4]
  0x01347E36  jmp     0x1344e1f

; ---- handler 14  va=0x01344FBE  next=0x0134508A ----
  0x01344FBE  mov     ecx, dword ptr [edi]
  0x01344FC0  mov     eax, ecx
  0x01344FC2  shr     eax, 8
  0x01344FC5  movzx   eax, al
  0x01344FC8  shl     eax, 4
  0x01344FCB  add     eax, edx
  0x01344FCD  shr     ecx, 0x18
  0x01344FD0  mov     dword ptr [esp + 0x1c], eax
  0x01344FD4  mov     eax, dword ptr [edi + 4]
  0x01344FD7  add     edi, 8
  0x01344FDA  shl     eax, 4
  0x01344FDD  add     eax, dword ptr [esp + 0x30]
  0x01344FE1  mov     dword ptr [esp + 0x20], eax
  0x01344FE5  mov     eax, dword ptr [esp + 0x34]
  0x01344FE9  mov     eax, dword ptr [eax + 0x10]
  0x01344FEC  movzx   eax, byte ptr [eax + 0xa]
  0x01344FF0  and     eax, ecx
  0x01344FF2  mov     ecx, dword ptr [esp + 0x34]
  0x01344FF6  mov     dword ptr [esp + 0x10], eax
  0x01344FFA  mov     eax, dword ptr [ecx + 0x10]
  0x01344FFD  mov     ecx, dword ptr [esp + 0x10]
  0x01345001  add     eax, 0x20
  0x01345004  shl     ecx, 5
  0x01345007  add     ecx, dword ptr [eax]
  0x01345009  add     ecx, eax
  0x0134500B  mov     eax, dword ptr [ecx + 0x1c]
  0x0134500E  and     eax, 0xf
  0x01345011  cmp     al, 5
  0x01345013  jne     0x1345038
  0x01345015  mov     esi, dword ptr [esp + 0x20]
  0x01345019  mov     eax, dword ptr [ecx + 0x10]
  0x0134501C  cmp     eax, dword ptr [esi]
  0x0134501E  mov     esi, dword ptr [ebp + 8]
  0x01345021  jne     0x1345038
  0x01345023  cmp     dword ptr [ecx + 0xc], 0
  0x01345027  je      0x1345038
  0x01345029  mov     eax, dword ptr [esp + 0x1c]
  0x0134502D  movups  xmm0, xmmword ptr [ecx]
  0x01345030  movups  xmmword ptr [eax], xmm0
  0x01345033  jmp     0x1344e1f
  0x01345038  mov     ecx, dword ptr [esp + 0x34]
  0x0134503C  mov     dword ptr [esp + 0x8c], 8
  0x01345047  mov     eax, dword ptr [ecx + 0x10]
  0x0134504A  mov     dword ptr [esp + 0x80], eax
  0x01345051  mov     eax, dword ptr [esp + 0x10]
  0x01345055  mov     dword ptr [esi + 0x68], eax
  0x01345058  mov     eax, dword ptr [esi + 8]
  0x0134505B  mov     dword ptr [eax + 4], edi
  0x0134505E  mov     eax, dword ptr [esp + 0x1c]
  0x01345062  push    eax
  0x01345063  push    dword ptr [esp + 0x24]
  0x01345067  lea     eax, [esp + 0x88]
  0x0134506E  push    eax
  0x0134506F  push    esi
  0x01345070  call    0x1358ec0   ; ->RVA 0xF58EC0
  0x01345075  mov     edx, dword ptr [esi + 0x14]
  0x01345078  add     esp, 0x10
  0x0134507B  mov     al, byte ptr [esi + 0x68]
  0x0134507E  mov     dword ptr [esp + 0x14], edx
  0x01345082  mov     byte ptr [edi - 5], al
  0x01345085  jmp     0x1344e1f

; ---- handler 15  va=0x0134769F  next=0x01347789 ----
  0x0134769F  mov     ecx, dword ptr [edi]
  0x013476A1  mov     eax, ecx
  0x013476A3  shr     eax, 8
  0x013476A6  add     edi, 4
  0x013476A9  movzx   eax, al
  0x013476AC  mov     dword ptr [esp + 0x24], eax
  0x013476B0  shl     eax, 4
  0x013476B3  add     eax, edx
  0x013476B5  shr     ecx, 0x10
  0x013476B8  mov     dword ptr [esp + 0x10], eax
  0x013476BC  movzx   eax, cl
  0x013476BF  shl     eax, 4
  0x013476C2  add     eax, edx
  0x013476C4  mov     dword ptr [esp + 0x18], eax
  0x013476C8  mov     ecx, dword ptr [eax + 0xc]
  0x013476CB  cmp     ecx, 4
  0x013476CE  jne     0x1347700
  0x013476D0  movsd   xmm1, qword ptr [eax]
  0x013476D4  xorps   xmm0, xmm0
  0x013476D7  xorps   xmm1, xmmword ptr [0x28ad240]
  0x013476DE  xorps   xmm1, xmmword ptr [0x1f659e0]
  0x013476E5  mov     eax, dword ptr [esp + 0x10]
  0x013476E9  movsd   xmm0, xmm1
  0x013476ED  xorps   xmm0, xmmword ptr [0x28ad240]
  0x013476F4  movsd   qword ptr [eax], xmm0
  0x013476F8  mov     dword ptr [eax + 0xc], ecx
  0x013476FB  jmp     0x1344e1f
  0x01347700  cmp     ecx, 9
  0x01347703  jne     0x1347761
  0x01347705  push    7
  0x01347707  push    eax
  0x01347708  push    esi
  0x01347709  call    0x13593c0   ; ->RVA 0xF593C0
  0x0134770E  mov     edx, eax
  0x01347710  add     esp, 0xc
  0x01347713  test    edx, edx
  0x01347715  je      0x1347761
  0x01347717  cmp     dword ptr [edx + 0xc], 6
  0x0134771B  jne     0x1347761
  0x0134771D  mov     ecx, dword ptr [edx]
  0x0134771F  cmp     byte ptr [ecx + 6], 0
  0x01347723  je      0x1347761
  0x01347725  mov     eax, dword ptr [esi + 0x10]
  0x01347728  movups  xmm0, xmmword ptr [edx]
  0x0134772B  mov     ecx, dword ptr [esp + 0x18]
  0x0134772F  push    dword ptr [esp + 0x24]
  0x01347733  movups  xmmword ptr [eax], xmm0
  0x01347736  mov     eax, dword ptr [esi + 0x10]
  0x01347739  movups  xmm0, xmmword ptr [ecx]
  0x0134773C  push    1
  0x0134773E  push    esi
  0x0134773F  movups  xmmword ptr [eax + 0x10], xmm0
  0x01347743  mov     eax, dword ptr [esi + 8]
  0x01347746  add     dword ptr [esi + 0x10], 0x20
  0x0134774A  mov     dword ptr [eax + 4], edi
  0x0134774D  call    0x134c460   ; ->RVA 0xF4C460
  0x01347752  mov     edx, dword ptr [esi + 0x14]
  0x01347755  add     esp, 0xc
  0x01347758  mov     dword ptr [esp + 0x14], edx
  0x0134775C  jmp     0x1344e1f
  0x01347761  mov     eax, dword ptr [esi + 8]
  0x01347764  mov     ecx, dword ptr [esp + 0x18]
  0x01347768  push    7
  0x0134776A  push    ecx
  0x0134776B  push    ecx
  0x0134776C  mov     dword ptr [eax + 4], edi
  0x0134776F  mov     eax, dword ptr [esp + 0x1c]
  0x01347773  push    eax
  0x01347774  push    esi
  0x01347775  call    0x1358ab0   ; ->RVA 0xF58AB0
  0x0134777A  mov     edx, dword ptr [esi + 0x14]
  0x0134777D  add     esp, 0x14
  0x01347780  mov     dword ptr [esp + 0x14], edx
  0x01347784  jmp     0x1344e1f

; ---- handler 16  va=0x01347230  next=0x01347342 ----
  0x01347230  mov     ecx, dword ptr [edi]
  0x01347232  mov     eax, ecx
  0x01347234  shr     eax, 8
  0x01347237  add     edi, 4
  0x0134723A  movzx   eax, al
  0x0134723D  mov     dword ptr [esp + 0x24], eax
  0x01347241  shl     eax, 4
  0x01347244  add     eax, edx
  0x01347246  mov     dword ptr [esp + 0x10], eax
  0x0134724A  mov     eax, ecx
  0x0134724C  shr     eax, 0x10
  0x0134724F  movzx   eax, al
  0x01347252  shl     eax, 4
  0x01347255  shr     ecx, 0x18
  0x01347258  add     eax, edx
  0x0134725A  shl     ecx, 4
  0x0134725D  add     ecx, dword ptr [esp + 0x30]
  0x01347261  mov     dword ptr [esp + 0x18], eax
  0x01347265  cmp     dword ptr [eax + 0xc], 4
  0x01347269  mov     dword ptr [esp + 0x1c], ecx
  0x0134726D  jne     0x13472a6
  0x0134726F  movaps  xmm3, xmmword ptr [0x28ad240]
  0x01347276  movsd   xmm2, qword ptr [eax]
  0x0134727A  movsd   xmm1, qword ptr [ecx]
  0x0134727E  xorps   xmm2, xmm3
  0x01347281  xorps   xmm1, xmm3
  0x01347284  divsd   xmm2, xmm1
  0x01347288  mov     eax, dword ptr [esp + 0x10]
  0x0134728C  xorps   xmm0, xmm0
  0x0134728F  movsd   xmm0, xmm2
  0x01347293  xorps   xmm0, xmm3
  0x01347296  movsd   qword ptr [eax], xmm0
  0x0134729A  mov     dword ptr [eax + 0xc], 4
  0x013472A1  jmp     0x1344e1f
  0x013472A6  cmp     dword ptr [eax + 0xc], 9
  0x013472AA  jne     0x134731a
  0x013472AC  push    0xa
  0x013472AE  push    eax
  0x013472AF  push    esi
  0x013472B0  call    0x13593c0   ; ->RVA 0xF593C0
  0x013472B5  mov     edx, eax
  0x013472B7  add     esp, 0xc
  0x013472BA  test    edx, edx
  0x013472BC  je      0x1347316
  0x013472BE  cmp     dword ptr [edx + 0xc], 6
  0x013472C2  jne     0x1347316
  0x013472C4  mov     ecx, dword ptr [edx]
  0x013472C6  cmp     byte ptr [ecx + 6], 0
  0x013472CA  je      0x1347316
  0x013472CC  mov     eax, dword ptr [esi + 0x10]
  0x013472CF  movups  xmm0, xmmword ptr [edx]
  0x013472D2  mov     ecx, dword ptr [esp + 0x18]
  0x013472D6  push    dword ptr [esp + 0x24]
  0x013472DA  movups  xmmword ptr [eax], xmm0
  0x013472DD  mov     eax, dword ptr [esi + 0x10]
  0x013472E0  movups  xmm0, xmmword ptr [ecx]
  0x013472E3  mov     ecx, dword ptr [esp + 0x20]
  0x013472E7  push    2
  0x013472E9  movups  xmmword ptr [eax + 0x10], xmm0
  0x013472ED  mov     eax, dword ptr [esi + 0x10]
  0x013472F0  movups  xmm0, xmmword ptr [ecx]
  0x013472F3  push    esi
  0x013472F4  movups  xmmword ptr [eax + 0x20], xmm0
  0x013472F8  mov     eax, dword ptr [esi + 8]
  0x013472FB  add     dword ptr [esi + 0x10], 0x30
  0x013472FF  mov     dword ptr [eax + 4], edi
  0x01347302  call    0x134c460   ; ->RVA 0xF4C460
  0x01347307  mov     edx, dword ptr [esi + 0x14]
  0x0134730A  add     esp, 0xc
  0x0134730D  mov     dword ptr [esp + 0x14], edx
  0x01347311  jmp     0x1344e1f
  0x01347316  mov     ecx, dword ptr [esp + 0x1c]
  0x0134731A  mov     eax, dword ptr [esi + 8]
  0x0134731D  push    0xa
  0x0134731F  push    ecx
  0x01347320  mov     ecx, dword ptr [esp + 0x20]
  0x01347324  push    ecx
  0x01347325  mov     dword ptr [eax + 4], edi
  0x01347328  mov     eax, dword ptr [esp + 0x1c]
  0x0134732C  push    eax
  0x0134732D  push    esi
  0x0134732E  call    0x1358ab0   ; ->RVA 0xF58AB0
  0x01347333  mov     edx, dword ptr [esi + 0x14]
  0x01347336  add     esp, 0x14
  0x01347339  mov     dword ptr [esp + 0x14], edx
  0x0134733D  jmp     0x1344e1f

; ---- handler 17  va=0x01346B31  next=0x01346C2E ----
  0x01346B31  mov     ecx, dword ptr [edi]
  0x01346B33  mov     eax, ecx
  0x01346B35  shr     eax, 8
  0x01346B38  add     edi, 4
  0x01346B3B  movzx   eax, al
  0x01346B3E  mov     dword ptr [esp + 0x24], eax
  0x01346B42  shl     eax, 4
  0x01346B45  add     eax, edx
  0x01346B47  mov     dword ptr [esp + 0x10], eax
  0x01346B4B  mov     eax, ecx
  0x01346B4D  shr     eax, 0x10
  0x01346B50  movzx   eax, al
  0x01346B53  shl     eax, 4
  0x01346B56  shr     ecx, 0x18
  0x01346B59  add     eax, edx
  0x01346B5B  shl     ecx, 4
  0x01346B5E  add     ecx, edx
  0x01346B60  mov     dword ptr [esp + 0x18], eax
  0x01346B64  mov     dword ptr [esp + 0x1c], ecx
  0x01346B68  cmp     dword ptr [eax + 0xc], 4
  0x01346B6C  jne     0x1346b92
  0x01346B6E  cmp     dword ptr [ecx + 0xc], 4
  0x01346B72  jne     0x1346b92
  0x01346B74  movaps  xmm3, xmmword ptr [0x28ad240]
  0x01346B7B  movsd   xmm2, qword ptr [ecx]
  0x01346B7F  movsd   xmm1, qword ptr [eax]
  0x01346B83  xorps   xmm2, xmm3
  0x01346B86  xorps   xmm1, xmm3
  0x01346B89  addsd   xmm2, xmm1
  0x01346B8D  jmp     0x1347288
  0x01346B92  cmp     dword ptr [eax + 0xc], 9
  0x01346B96  jne     0x1346c06
  0x01346B98  push    9
  0x01346B9A  push    eax
  0x01346B9B  push    esi
  0x01346B9C  call    0x13593c0   ; ->RVA 0xF593C0
  0x01346BA1  mov     edx, eax
  0x01346BA3  add     esp, 0xc
  0x01346BA6  test    edx, edx
  0x01346BA8  je      0x1346c02
  0x01346BAA  cmp     dword ptr [edx + 0xc], 6
  0x01346BAE  jne     0x1346c02
  0x01346BB0  mov     ecx, dword ptr [edx]
  0x01346BB2  cmp     byte ptr [ecx + 6], 0
  0x01346BB6  je      0x1346c02
  0x01346BB8  mov     eax, dword ptr [esi + 0x10]
  0x01346BBB  movups  xmm0, xmmword ptr [edx]
  0x01346BBE  mov     ecx, dword ptr [esp + 0x18]
  0x01346BC2  push    dword ptr [esp + 0x24]
  0x01346BC6  movups  xmmword ptr [eax], xmm0
  0x01346BC9  mov     eax, dword ptr [esi + 0x10]
  0x01346BCC  movups  xmm0, xmmword ptr [ecx]
  0x01346BCF  mov     ecx, dword ptr [esp + 0x20]
  0x01346BD3  push    2
  0x01346BD5  movups  xmmword ptr [eax + 0x10], xmm0
  0x01346BD9  mov     eax, dword ptr [esi + 0x10]
  0x01346BDC  movups  xmm0, xmmword ptr [ecx]
  0x01346BDF  push    esi
  0x01346BE0  movups  xmmword ptr [eax + 0x20], xmm0
  0x01346BE4  mov     eax, dword ptr [esi + 8]
  0x01346BE7  add     dword ptr [esi + 0x10], 0x30
  0x01346BEB  mov     dword ptr [eax + 4], edi
  0x01346BEE  call    0x134c460   ; ->RVA 0xF4C460
  0x01346BF3  mov     edx, dword ptr [esi + 0x14]
  0x01346BF6  add     esp, 0xc
  0x01346BF9  mov     dword ptr [esp + 0x14], edx
  0x01346BFD  jmp     0x1344e1f
  0x01346C02  mov     ecx, dword ptr [esp + 0x1c]
  0x01346C06  mov     eax, dword ptr [esi + 8]
  0x01346C09  push    9
  0x01346C0B  push    ecx
  0x01346C0C  mov     ecx, dword ptr [esp + 0x20]
  0x01346C10  push    ecx
  0x01346C11  mov     dword ptr [eax + 4], edi
  0x01346C14  mov     eax, dword ptr [esp + 0x1c]
  0x01346C18  push    eax
  0x01346C19  push    esi
  0x01346C1A  call    0x1358ab0   ; ->RVA 0xF58AB0
  0x01346C1F  mov     edx, dword ptr [esi + 0x14]
  0x01346C22  add     esp, 0x14
  0x01346C25  mov     dword ptr [esp + 0x14], edx
  0x01346C29  jmp     0x1344e1f

; ---- handler 18  va=0x01348319  next=0x01348358 ----
  0x01348319  mov     eax, dword ptr [esi + 0x18]
  0x0134831C  lea     ecx, [esi + 0x18]
  0x0134831F  xor     eax, ecx
  0x01348321  mov     ecx, dword ptr [eax + 0x3a8]
  0x01348327  add     eax, 0x3a8
  0x0134832C  add     ecx, eax
  0x0134832E  mov     dword ptr [esp + 0x40], ecx
  0x01348332  je      0x1348358
  0x01348334  mov     eax, dword ptr [esi + 8]
  0x01348337  mov     dword ptr [eax + 4], edi
  0x0134833A  mov     eax, dword ptr [0x2941254]
  0x0134833F  sub     ecx, eax
  0x01348341  cmp     ecx, dword ptr [0x2941258]
  0x01348347  jae     0x1348351
  0x01348349  push    esi
  0x0134834A  call    dword ptr [esp + 0x44]
  0x0134834E  add     esp, 4
  0x01348351  mov     edx, dword ptr [esi + 0x14]
  0x01348354  mov     dword ptr [esp + 0x14], edx

; ---- handler 19  va=0x013483CD  next=0x0134849E ----
  0x013483CD  mov     ecx, dword ptr [edi]
  0x013483CF  mov     eax, ecx
  0x013483D1  shr     eax, 8
  0x013483D4  add     edi, 4
  0x013483D7  movzx   eax, al
  0x013483DA  mov     dword ptr [esp + 0x40], eax
  0x013483DE  shr     ecx, 0x18
  0x013483E1  lea     eax, [edi + ecx*4]
  0x013483E4  mov     ecx, dword ptr [eax]
  0x013483E6  mov     dword ptr [esp + 0x24], eax
  0x013483EA  mov     eax, ecx
  0x013483EC  shr     eax, 8
  0x013483EF  movzx   eax, al
  0x013483F2  shl     eax, 4
  0x013483F5  add     eax, edx
  0x013483F7  mov     dword ptr [esp + 0x10], ecx
  0x013483FB  mov     dword ptr [esp + 0x1c], eax
  0x013483FF  mov     eax, ecx
  0x01348401  shr     eax, 0x10
  0x01348404  movzx   ecx, al
  0x01348407  mov     eax, dword ptr [esp + 0x10]
  0x0134840B  dec     ecx
  0x0134840C  shr     eax, 0x18
  0x0134840F  dec     eax
  0x01348410  mov     dword ptr [esp + 0x10], eax
  0x01348414  cmp     ecx, -1
  0x01348417  jne     0x1348424
  0x01348419  mov     ecx, dword ptr [esi + 0x10]
  0x0134841C  sub     ecx, dword ptr [esp + 0x1c]
  0x01348420  sar     ecx, 4
  0x01348423  dec     ecx
  0x01348424  mov     eax, dword ptr [esp + 0x40]
  0x01348428  mov     eax, dword ptr [eax*4 + 0x255a1e8]
  0x0134842F  mov     dword ptr [esp + 0x40], eax
  0x01348433  mov     eax, dword ptr [esp + 0x34]
  0x01348437  mov     eax, dword ptr [eax + 0x10]
  0x0134843A  cmp     byte ptr [eax + 9], 0
  0x0134843E  je      0x1344e1f
  0x01348444  mov     eax, dword ptr [esp + 0x40]
  0x01348448  test    eax, eax
  0x0134844A  je      0x1344e1f
  0x01348450  push    dword ptr [esp + 0x10]
  0x01348454  push    ecx
  0x01348455  push    dword ptr [esp + 0x24]
  0x01348459  push    esi
  0x0134845A  call    eax
  0x0134845C  mov     edx, dword ptr [esp + 0x24]
  0x01348460  lea     ecx, [esi + 0x18]
  0x01348463  add     esp, 0x10
  0x01348466  test    eax, eax
  0x01348468  js      0x1344e22
  0x0134846E  cmp     dword ptr [esp + 0x10], -1
  0x01348473  jne     0x1348488
  0x01348475  mov     edi, dword ptr [esp + 0x24]
  0x01348479  shl     eax, 4
  0x0134847C  add     eax, dword ptr [esp + 0x1c]
  0x01348480  mov     dword ptr [esi + 0x10], eax
  0x01348483  jmp     0x1344e1c
  0x01348488  mov     eax, dword ptr [esi + 8]
  0x0134848B  mov     edi, dword ptr [esp + 0x24]
  0x0134848F  mov     edx, dword ptr [esp + 0x14]
  0x01348493  mov     eax, dword ptr [eax + 0xc]
  0x01348496  mov     dword ptr [esi + 0x10], eax
  0x01348499  jmp     0x1344e1c

; ---- handler 20  va=0x013452DA  next=0x01345476 ----
  0x013452DA  mov     ecx, dword ptr [edi]
  0x013452DC  mov     eax, ecx
  0x013452DE  shr     eax, 8
  0x013452E1  movzx   eax, al
  0x013452E4  mov     dword ptr [esp + 0x1c], eax
  0x013452E8  shl     eax, 4
  0x013452EB  add     eax, edx
  0x013452ED  mov     dword ptr [esp + 0x18], ecx
  0x013452F1  mov     dword ptr [esp + 0x20], eax
  0x013452F5  mov     eax, ecx
  0x013452F7  mov     ecx, dword ptr [edi + 4]
  0x013452FA  add     edi, 8
  0x013452FD  shr     eax, 0x10
  0x01345300  movzx   eax, al
  0x01345303  shl     eax, 4
  0x01345306  add     eax, edx
  0x01345308  shl     ecx, 4
  0x0134530B  add     ecx, dword ptr [esp + 0x30]
  0x0134530F  mov     dword ptr [esp + 0x2c], eax
  0x01345313  mov     dword ptr [esp + 0x28], ecx
  0x01345317  cmp     dword ptr [eax + 0xc], 8
  0x0134531B  jne     0x13453a7
  0x01345321  mov     eax, dword ptr [eax]
  0x01345323  movzx   ecx, byte ptr [eax + 0xa]
  0x01345327  add     eax, 0x20
  0x0134532A  mov     dword ptr [esp + 0x1c], ecx
  0x0134532E  mov     ecx, dword ptr [esp + 0x18]
  0x01345332  shr     ecx, 0x18
  0x01345335  and     dword ptr [esp + 0x1c], ecx
  0x01345339  mov     ecx, dword ptr [esp + 0x1c]
  0x0134533D  shl     ecx, 5
  0x01345340  add     ecx, dword ptr [eax]
  0x01345342  add     ecx, eax
  0x01345344  mov     eax, dword ptr [ecx + 0x1c]
  0x01345347  and     eax, 0xf
  0x0134534A  cmp     al, 5
  0x0134534C  jne     0x1345371
  0x0134534E  mov     esi, dword ptr [esp + 0x28]
  0x01345352  mov     eax, dword ptr [ecx + 0x10]
  0x01345355  cmp     eax, dword ptr [esi]
  0x01345357  mov     esi, dword ptr [ebp + 8]
  0x0134535A  jne     0x1345371
  0x0134535C  cmp     dword ptr [ecx + 0xc], 0
  0x01345360  je      0x1345371
  0x01345362  mov     eax, dword ptr [esp + 0x20]
  0x01345366  movups  xmm0, xmmword ptr [ecx]
  0x01345369  movups  xmmword ptr [eax], xmm0
  0x0134536C  jmp     0x1344e1f
  0x01345371  mov     eax, dword ptr [esp + 0x1c]
  0x01345375  mov     ecx, dword ptr [esp + 0x2c]
  0x01345379  mov     dword ptr [esi + 0x68], eax
  0x0134537C  mov     eax, dword ptr [esi + 8]
  0x0134537F  mov     dword ptr [eax + 4], edi
  0x01345382  mov     eax, dword ptr [esp + 0x20]
  0x01345386  push    eax
  0x01345387  push    dword ptr [esp + 0x2c]
  0x0134538B  push    ecx
  0x0134538C  push    esi
  0x0134538D  call    0x1358ec0   ; ->RVA 0xF58EC0
  0x01345392  mov     edx, dword ptr [esi + 0x14]
  0x01345395  add     esp, 0x10
  0x01345398  mov     al, byte ptr [esi + 0x68]
  0x0134539B  mov     dword ptr [esp + 0x14], edx
  0x0134539F  mov     byte ptr [edi - 5], al
  0x013453A2  jmp     0x1344e1f
  0x013453A7  cmp     dword ptr [eax + 0xc], 9
  0x013453AB  jne     0x1345450
  0x013453B1  mov     edx, dword ptr [eax]
  0x013453B3  mov     eax, dword ptr [edx + 0xc]
  0x013453B6  add     edx, 0xc
  0x013453B9  mov     dword ptr [esp + 0x10], eax
  0x013453BD  mov     eax, edx
  0x013453BF  sub     eax, dword ptr [esp + 0x10]
  0x013453C3  je      0x1345450
  0x013453C9  mov     eax, edx
  0x013453CB  sub     eax, dword ptr [esp + 0x10]
  0x013453CF  test    byte ptr [eax + 6], 4
  0x013453D3  jne     0x1345450
  0x013453D5  mov     eax, dword ptr [esi + 0x18]
  0x013453D8  lea     ecx, [esi + 0x18]
  0x013453DB  sub     edx, dword ptr [esp + 0x10]
  0x013453DF  xor     eax, ecx
  0x013453E1  mov     ecx, dword ptr [eax + 0xdc]
  0x013453E7  add     eax, 0xdc
  0x013453EC  add     ecx, eax
  0x013453EE  push    ecx
  0x013453EF  push    2
  0x013453F1  push    edx
  0x013453F2  call    0x1359390   ; ->RVA 0xF59390
  0x013453F7  mov     edx, eax
  0x013453F9  add     esp, 0xc
  0x013453FC  test    edx, edx
  0x013453FE  je      0x134544c
  0x01345400  cmp     dword ptr [edx + 0xc], 6
  0x01345404  jne     0x134544c
  0x01345406  mov     ecx, dword ptr [edx]
  0x01345408  cmp     byte ptr [ecx + 6], 0
  0x0134540C  je      0x134544c
  0x0134540E  mov     eax, dword ptr [esi + 0x10]
  0x01345411  movups  xmm0, xmmword ptr [edx]
  0x01345414  mov     ecx, dword ptr [esp + 0x2c]
  0x01345418  push    dword ptr [esp + 0x1c]
  0x0134541C  movups  xmmword ptr [eax], xmm0
  0x0134541F  mov     eax, dword ptr [esi + 0x10]
  0x01345422  movups  xmm0, xmmword ptr [ecx]
  0x01345425  mov     ecx, dword ptr [esp + 0x2c]
  0x01345429  push    2
  0x0134542B  movups  xmmword ptr [eax + 0x10], xmm0
  0x0134542F  mov     eax, dword ptr [esi + 0x10]
  0x01345432  movups  xmm0, xmmword ptr [ecx]
  0x01345435  mov     ecx, dword ptr [esp + 0x20]
  0x01345439  movups  xmmword ptr [eax + 0x20], xmm0
  0x0134543D  add     dword ptr [esi + 0x10], 0x30
  0x01345441  shr     ecx, 0x18
  0x01345444  mov     dword ptr [esi + 0x68], ecx
  0x01345447  jmp     0x1345634
  0x0134544C  mov     ecx, dword ptr [esp + 0x28]
  0x01345450  mov     eax, dword ptr [esi + 8]
  0x01345453  mov     dword ptr [eax + 4], edi
  0x01345456  mov     eax, dword ptr [esp + 0x20]
  0x0134545A  push    eax
  0x0134545B  push    ecx
  0x0134545C  mov     ecx, dword ptr [esp + 0x34]
  0x01345460  push    ecx
  0x01345461  push    esi
  0x01345462  call    0x1358ec0   ; ->RVA 0xF58EC0
  0x01345467  mov     edx, dword ptr [esi + 0x14]
  0x0134546A  add     esp, 0x10
  0x0134546D  mov     dword ptr [esp + 0x14], edx
  0x01345471  jmp     0x1344e1f

; ---- handler 21  va=0x01347BFB  next=0x01347C84 ----
  0x01347BFB  mov     eax, dword ptr [edi]
  0x01347BFD  mov     dword ptr [esp + 0x18], eax
  0x01347C01  shr     eax, 8
  0x01347C04  movzx   eax, al
  0x01347C07  shl     eax, 4
  0x01347C0A  add     eax, edx
  0x01347C0C  mov     dword ptr [esp + 0x24], eax
  0x01347C10  cmp     dword ptr [eax + 0xc], 6
  0x01347C14  jne     0x1344e12
  0x01347C1A  mov     ecx, dword ptr [eax]
  0x01347C1C  cmp     byte ptr [ecx + 6], 0
  0x01347C20  je      0x1344e12
  0x01347C26  mov     eax, dword ptr [ecx + 0x18]
  0x01347C29  add     ecx, 0x18
  0x01347C2C  xor     eax, ecx
  0x01347C2E  cmp     eax, 0x134f080
  0x01347C33  jne     0x1344e12
  0x01347C39  mov     ecx, dword ptr [esp + 0x24]
  0x01347C3D  cmp     dword ptr [ecx + 0x1c], 8
  0x01347C41  jne     0x1344e12
  0x01347C47  cmp     dword ptr [ecx + 0x2c], 4
  0x01347C4B  jne     0x1344e12
  0x01347C51  movaps  xmm2, xmmword ptr [0x28ad240]
  0x01347C58  xorps   xmm0, xmm0
  0x01347C5B  movsd   xmm1, qword ptr [ecx + 0x20]
  0x01347C60  xorps   xmm2, xmm1
  0x01347C63  ucomisd xmm2, xmm0
  0x01347C67  lahf    
  0x01347C68  test    ah, 0x44
  0x01347C6B  jp      0x1344e12
  0x01347C71  mov     dword ptr [ecx + 0x20], 0
  0x01347C78  mov     dword ptr [ecx + 0x2c], 3
  0x01347C7F  jmp     0x1344e12

; ---- handler 22  va=0x01344F8E  next=0x01344FBE ----
  0x01344F8E  mov     ecx, dword ptr [edi]
  0x01344F90  mov     eax, ecx
  0x01344F92  shr     eax, 0x10
  0x01344F95  add     edi, 4
  0x01344F98  movzx   edx, al
  0x01344F9B  shl     edx, 4
  0x01344F9E  add     edx, dword ptr [esp + 0x14]
  0x01344FA2  shr     ecx, 8
  0x01344FA5  movzx   eax, cl
  0x01344FA8  shl     eax, 4
  0x01344FAB  add     eax, dword ptr [esp + 0x14]
  0x01344FAF  movups  xmm0, xmmword ptr [edx]
  0x01344FB2  mov     edx, dword ptr [esp + 0x14]
  0x01344FB6  movups  xmmword ptr [eax], xmm0
  0x01344FB9  jmp     0x1344e1f

; ---- handler 23  va=0x01347656  next=0x0134769F ----
  0x01347656  mov     ecx, dword ptr [edi]
  0x01347658  mov     eax, ecx
  0x0134765A  shr     eax, 0x10
  0x0134765D  add     edi, 4
  0x01347660  movzx   edx, al
  0x01347663  shl     edx, 4
  0x01347666  add     edx, dword ptr [esp + 0x14]
  0x0134766A  shr     ecx, 8
  0x0134766D  movzx   esi, cl
  0x01347670  shl     esi, 4
  0x01347673  mov     eax, dword ptr [edx]
  0x01347675  mov     ecx, dword ptr [edx + 0xc]
  0x01347678  or      eax, 0xfffffffe
  0x0134767B  add     esi, dword ptr [esp + 0x14]
  0x0134767F  and     ecx, eax
  0x01347681  mov     edx, dword ptr [esp + 0x14]
  0x01347685  neg     ecx
  0x01347687  sbb     ecx, ecx
  0x01347689  inc     ecx
  0x0134768A  mov     dword ptr [esi + 0xc], 1
  0x01347691  mov     dword ptr [esi], ecx
  0x01347693  mov     esi, dword ptr [ebp + 8]
  0x01347696  mov     ecx, dword ptr [esp + 0x38]
  0x0134769A  jmp     0x1344e22

; ---- handler 24  va=0x01347137  next=0x01347230 ----
  0x01347137  mov     ecx, dword ptr [edi]
  0x01347139  mov     eax, ecx
  0x0134713B  shr     eax, 8
  0x0134713E  add     edi, 4
  0x01347141  movzx   eax, al
  0x01347144  mov     dword ptr [esp + 0x24], eax
  0x01347148  shl     eax, 4
  0x0134714B  add     eax, edx
  0x0134714D  mov     dword ptr [esp + 0x10], eax
  0x01347151  mov     eax, ecx
  0x01347153  shr     eax, 0x10
  0x01347156  movzx   eax, al
  0x01347159  shl     eax, 4
  0x0134715C  shr     ecx, 0x18
  0x0134715F  add     eax, edx
  0x01347161  shl     ecx, 4
  0x01347164  add     ecx, dword ptr [esp + 0x30]
  0x01347168  mov     dword ptr [esp + 0x18], eax
  0x0134716C  cmp     dword ptr [eax + 0xc], 4
  0x01347170  mov     dword ptr [esp + 0x1c], ecx
  0x01347174  jne     0x1347194
  0x01347176  movaps  xmm3, xmmword ptr [0x28ad240]
  0x0134717D  movsd   xmm2, qword ptr [ecx]
  0x01347181  movsd   xmm1, qword ptr [eax]
  0x01347185  xorps   xmm2, xmm3
  0x01347188  xorps   xmm1, xmm3
  0x0134718B  mulsd   xmm2, xmm1
  0x0134718F  jmp     0x1347288
  0x01347194  cmp     dword ptr [eax + 0xc], 9
  0x01347198  jne     0x1347208
  0x0134719A  push    8
  0x0134719C  push    eax
  0x0134719D  push    esi
  0x0134719E  call    0x13593c0   ; ->RVA 0xF593C0
  0x013471A3  mov     edx, eax
  0x013471A5  add     esp, 0xc
  0x013471A8  test    edx, edx
  0x013471AA  je      0x1347204
  0x013471AC  cmp     dword ptr [edx + 0xc], 6
  0x013471B0  jne     0x1347204
  0x013471B2  mov     ecx, dword ptr [edx]
  0x013471B4  cmp     byte ptr [ecx + 6], 0
  0x013471B8  je      0x1347204
  0x013471BA  mov     eax, dword ptr [esi + 0x10]
  0x013471BD  movups  xmm0, xmmword ptr [edx]
  0x013471C0  mov     ecx, dword ptr [esp + 0x18]
  0x013471C4  push    dword ptr [esp + 0x24]
  0x013471C8  movups  xmmword ptr [eax], xmm0
  0x013471CB  mov     eax, dword ptr [esi + 0x10]
  0x013471CE  movups  xmm0, xmmword ptr [ecx]
  0x013471D1  mov     ecx, dword ptr [esp + 0x20]
  0x013471D5  push    2
  0x013471D7  movups  xmmword ptr [eax + 0x10], xmm0
  0x013471DB  mov     eax, dword ptr [esi + 0x10]
  0x013471DE  movups  xmm0, xmmword ptr [ecx]
  0x013471E1  push    esi
  0x013471E2  movups  xmmword ptr [eax + 0x20], xmm0
  0x013471E6  mov     eax, dword ptr [esi + 8]
  0x013471E9  add     dword ptr [esi + 0x10], 0x30
  0x013471ED  mov     dword ptr [eax + 4], edi
  0x013471F0  call    0x134c460   ; ->RVA 0xF4C460
  0x013471F5  mov     edx, dword ptr [esi + 0x14]
  0x013471F8  add     esp, 0xc
  0x013471FB  mov     dword ptr [esp + 0x14], edx
  0x013471FF  jmp     0x1344e1f
  0x01347204  mov     ecx, dword ptr [esp + 0x1c]
  0x01347208  mov     eax, dword ptr [esi + 8]
  0x0134720B  push    8
  0x0134720D  push    ecx
  0x0134720E  mov     ecx, dword ptr [esp + 0x20]
  0x01347212  push    ecx
  0x01347213  mov     dword ptr [eax + 4], edi
  0x01347216  mov     eax, dword ptr [esp + 0x1c]
  0x0134721A  push    eax
  0x0134721B  push    esi
  0x0134721C  call    0x1358ab0   ; ->RVA 0xF58AB0
  0x01347221  mov     edx, dword ptr [esi + 0x14]
  0x01347224  add     esp, 0x14
  0x01347227  mov     dword ptr [esp + 0x14], edx
  0x0134722B  jmp     0x1344e1f

; ---- handler 25  va=0x01346A35  next=0x01346B31 ----
  0x01346A35  mov     ecx, dword ptr [edi]
  0x01346A37  mov     eax, ecx
  0x01346A39  shr     eax, 8
  0x01346A3C  add     edi, 4
  0x01346A3F  movzx   eax, al
  0x01346A42  shl     eax, 4
  0x01346A45  add     eax, edx
  0x01346A47  mov     dword ptr [esp + 0x18], ecx
  0x01346A4B  mov     dword ptr [esp + 0x1c], eax
  0x01346A4F  mov     esi, dword ptr [esp + 0x1c]
  0x01346A53  mov     eax, dword ptr [edi]
  0x01346A55  shl     eax, 4
  0x01346A58  add     eax, edx
  0x01346A5A  mov     esi, dword ptr [esi + 0xc]
  0x01346A5D  cmp     esi, 4
  0x01346A60  mov     dword ptr [esp + 0x24], esi
  0x01346A64  mov     esi, dword ptr [ebp + 8]
  0x01346A67  mov     dword ptr [esp + 0x10], eax
  0x01346A6B  jne     0x1346aae
  0x01346A6D  cmp     dword ptr [eax + 0xc], 4
  0x01346A71  jne     0x1346aae
  0x01346A73  mov     esi, dword ptr [esp + 0x1c]
  0x01346A77  movsd   xmm1, qword ptr [eax]
  0x01346A7B  xorps   xmm1, xmmword ptr [0x28ad240]
  0x01346A82  movsd   xmm2, qword ptr [esi]
  0x01346A86  xorps   xmm2, xmmword ptr [0x28ad240]
  0x01346A8D  comisd  xmm1, xmm2
  0x01346A91  mov     esi, dword ptr [ebp + 8]
  0x01346A94  ja      0x1346aa1
  0x01346A96  sar     ecx, 0x10
  0x01346A99  lea     edi, [edi + ecx*4]
  0x01346A9C  jmp     0x1344e1f
  0x01346AA1  mov     ecx, 1
  0x01346AA6  lea     edi, [edi + ecx*4]
  0x01346AA9  jmp     0x1344e1f
  0x01346AAE  cmp     dword ptr [esp + 0x24], 5
  0x01346AB3  jne     0x1346af3
  0x01346AB5  cmp     dword ptr [eax + 0xc], 5
  0x01346AB9  jne     0x1346af3
  0x01346ABB  push    dword ptr [eax]
  0x01346ABD  mov     eax, dword ptr [esp + 0x20]
  0x01346AC1  push    dword ptr [eax]
  0x01346AC3  call    0x134d540   ; ->RVA 0xF4D540
  0x01346AC8  add     esp, 8
  0x01346ACB  test    eax, eax
  0x01346ACD  js      0x1346ae2
  0x01346ACF  mov     eax, dword ptr [esp + 0x18]
  0x01346AD3  mov     edx, dword ptr [esp + 0x14]
  0x01346AD7  sar     eax, 0x10
  0x01346ADA  lea     edi, [edi + eax*4]
  0x01346ADD  jmp     0x1344e1f
  0x01346AE2  mov     edx, dword ptr [esp + 0x14]
  0x01346AE6  mov     eax, 1
  0x01346AEB  lea     edi, [edi + eax*4]
  0x01346AEE  jmp     0x1344e1f
  0x01346AF3  push    dword ptr [esp + 0x10]
  0x01346AF7  mov     eax, dword ptr [esi + 8]
  0x01346AFA  push    dword ptr [esp + 0x20]
  0x01346AFE  push    esi
  0x01346AFF  mov     dword ptr [eax + 4], edi
  0x01346B02  call    0x1359090   ; ->RVA 0xF59090
  0x01346B07  mov     edx, dword ptr [esi + 0x14]
  0x01346B0A  add     esp, 0xc
  0x01346B0D  mov     dword ptr [esp + 0x14], edx
  0x01346B11  test    eax, eax
  0x01346B13  jne     0x1346b24
  0x01346B15  mov     eax, dword ptr [esp + 0x18]
  0x01346B19  sar     eax, 0x10
  0x01346B1C  lea     edi, [edi + eax*4]
  0x01346B1F  jmp     0x1344e1f
  0x01346B24  mov     eax, 1
  0x01346B29  lea     edi, [edi + eax*4]
  0x01346B2C  jmp     0x1344e1f

; ---- handler 26  va=0x01348358  next=0x01348361 ----
  0x01348358  movsx   eax, word ptr [edi + 2]
  0x0134835C  jmp     0x1344e19

; ---- handler 27  va=0x01348384  next=0x013483CD ----
  0x01348384  mov     eax, dword ptr [esi + 0x18]
  0x01348387  lea     ecx, [esi + 0x18]
  0x0134838A  xor     eax, ecx
  0x0134838C  mov     ecx, dword ptr [eax + 0x3a8]
  0x01348392  add     eax, 0x3a8
  0x01348397  add     ecx, eax
  0x01348399  mov     dword ptr [esp + 0x40], ecx
  0x0134839D  je      0x13483c3
  0x0134839F  mov     eax, dword ptr [esi + 8]
  0x013483A2  mov     dword ptr [eax + 4], edi
  0x013483A5  mov     eax, dword ptr [0x2941254]
  0x013483AA  sub     ecx, eax
  0x013483AC  cmp     ecx, dword ptr [0x2941258]
  0x013483B2  jae     0x13483bc
  0x013483B4  push    esi
  0x013483B5  call    dword ptr [esp + 0x44]
  0x013483B9  add     esp, 4
  0x013483BC  mov     edx, dword ptr [esi + 0x14]
  0x013483BF  mov     dword ptr [esp + 0x14], edx
  0x013483C3  mov     eax, dword ptr [edi]
  0x013483C5  sar     eax, 8
  0x013483C8  jmp     0x1344e19

; ---- handler 28  va=0x01345752  next=0x0134587A ----
  0x01345752  mov     ecx, dword ptr [edi]
  0x01345754  mov     eax, ecx
  0x01345756  shr     eax, 8
  0x01345759  add     edi, 4
  0x0134575C  movzx   eax, al
  0x0134575F  shl     eax, 4
  0x01345762  add     eax, edx
  0x01345764  mov     dword ptr [esp + 0x10], eax
  0x01345768  mov     eax, ecx
  0x0134576A  shr     eax, 0x10
  0x0134576D  movzx   eax, al
  0x01345770  shl     eax, 4
  0x01345773  shr     ecx, 0x18
  0x01345776  add     eax, edx
  0x01345778  shl     ecx, 4
  0x0134577B  add     ecx, edx
  0x0134577D  mov     dword ptr [esp + 0x2c], eax
  0x01345781  mov     dword ptr [esp + 0x18], ecx
  0x01345785  cmp     dword ptr [eax + 0xc], 8
  0x01345789  jne     0x1345856
  0x0134578F  cmp     dword ptr [ecx + 0xc], 4
  0x01345793  jne     0x1345856
  0x01345799  mov     eax, dword ptr [eax]
  0x0134579B  movsd   xmm1, qword ptr [ecx]
  0x0134579F  xorps   xmm1, xmmword ptr [0x28ad240]
  0x013457A6  mov     dword ptr [esp + 0x20], eax
  0x013457AA  cvttsd2si eax, xmm1
  0x013457AE  mov     dword ptr [esp + 0x1c], eax
  0x013457B2  movd    xmm0, eax
  0x013457B6  cvtdq2pd xmm0, xmm0
  0x013457BA  ucomisd xmm0, xmm1
  0x013457BE  lahf    
  0x013457BF  test    ah, 0x44
  0x013457C2  jp      0x1345856
  0x013457C8  mov     esi, dword ptr [esp + 0x20]
  0x013457CC  mov     eax, dword ptr [esp + 0x1c]
  0x013457D0  dec     eax
  0x013457D1  cmp     eax, dword ptr [esi + 0xc]
  0x013457D4  mov     esi, dword ptr [ebp + 8]
  0x013457D7  jae     0x1345856
  0x013457D9  mov     ecx, dword ptr [esp + 0x20]
  0x013457DD  add     ecx, 0x1c
  0x013457E0  mov     eax, dword ptr [ecx]
  0x013457E2  add     eax, ecx
  0x013457E4  jne     0x1345852
  0x013457E6  mov     eax, dword ptr [esp + 0x20]
  0x013457EA  cmp     byte ptr [eax + 7], 0
  0x013457EE  jne     0x1345852
  0x013457F0  mov     ecx, dword ptr [esp + 0x1c]
  0x013457F4  add     eax, 0x14
  0x013457F7  shl     ecx, 4
  0x013457FA  add     ecx, eax
  0x013457FC  mov     dword ptr [esp + 0x1c], ecx
  0x01345800  mov     ecx, dword ptr [esp + 0x10]
  0x01345804  mov     esi, dword ptr [esp + 0x1c]
  0x01345808  mov     eax, dword ptr [eax]
  0x0134580A  movups  xmm0, xmmword ptr [ecx]
  0x0134580D  movups  xmmword ptr [esi + eax - 0x10], xmm0
  0x01345812  cmp     dword ptr [ecx + 0xc], 5
  0x01345816  mov     esi, dword ptr [ebp + 8]
  0x01345819  jl      0x1344e1f
  0x0134581F  mov     eax, dword ptr [esp + 0x20]
  0x01345823  test    byte ptr [eax + 5], 4
  0x01345827  je      0x1344e1f
  0x0134582D  mov     eax, dword ptr [ecx]
  0x0134582F  lea     ecx, [esi + 0x18]
  0x01345832  test    byte ptr [eax + 5], 3
  0x01345836  je      0x1344e22
  0x0134583C  push    dword ptr [esp + 0x20]
  0x01345840  push    esi
  0x01345841  call    0x1355b60   ; ->RVA 0xF55B60
  0x01345846  mov     edx, dword ptr [esp + 0x1c]
  0x0134584A  add     esp, 8
  0x0134584D  jmp     0x1344e1f
  0x01345852  mov     ecx, dword ptr [esp + 0x18]
  0x01345856  push    dword ptr [esp + 0x10]
  0x0134585A  mov     eax, dword ptr [esi + 8]
  0x0134585D  push    ecx
  0x0134585E  push    dword ptr [esp + 0x34]
  0x01345862  push    esi
  0x01345863  mov     dword ptr [eax + 4], edi
  0x01345866  call    0x1359130   ; ->RVA 0xF59130
  0x0134586B  mov     edx, dword ptr [esi + 0x14]
  0x0134586E  add     esp, 0x10
  0x01345871  mov     dword ptr [esp + 0x14], edx
  0x01345875  jmp     0x1344e1f

; ---- handler 29  va=0x01347B7C  next=0x01347BFB ----
  0x01347B7C  mov     eax, dword ptr [esi + 0x18]
  0x01347B7F  lea     edx, [esi + 0x18]
  0x01347B82  xor     eax, edx
  0x01347B84  mov     edx, dword ptr [eax + 0x3a8]
  0x01347B8A  add     eax, 0x3a8
  0x01347B8F  add     edx, eax
  0x01347B91  je      0x1347bb0
  0x01347B93  mov     eax, dword ptr [esi + 8]
  0x01347B96  mov     ecx, edx
  0x01347B98  mov     dword ptr [eax + 4], edi
  0x01347B9B  mov     eax, dword ptr [0x2941254]
  0x01347BA0  sub     ecx, eax
  0x01347BA2  cmp     ecx, dword ptr [0x2941258]
  0x01347BA8  jae     0x1347bb0
  0x01347BAA  push    esi
  0x01347BAB  call    edx
  0x01347BAD  add     esp, 4
  0x01347BB0  mov     edx, dword ptr [edi]
  0x01347BB2  add     edi, 4
  0x01347BB5  mov     eax, dword ptr [esi + 8]
  0x01347BB8  mov     dword ptr [esp + 0x24], edx
  0x01347BBC  mov     ecx, dword ptr [edi]
  0x01347BBE  mov     dword ptr [eax + 4], edi
  0x01347BC1  mov     eax, edx
  0x01347BC3  shr     eax, 8
  0x01347BC6  push    ecx
  0x01347BC7  movzx   eax, al
  0x01347BCA  push    eax
  0x01347BCB  push    esi
  0x01347BCC  call    0x134d160   ; ->RVA 0xF4D160
  0x01347BD1  mov     edx, dword ptr [esi + 0x14]
  0x01347BD4  add     esp, 0xc
  0x01347BD7  mov     dword ptr [esp + 0x14], edx
  0x01347BDB  test    al, al
  0x01347BDD  je      0x1347bec
  0x01347BDF  mov     eax, 1
  0x01347BE4  lea     edi, [edi + eax*4]
  0x01347BE7  jmp     0x1344e1f
  0x01347BEC  mov     eax, dword ptr [esp + 0x24]
  0x01347BF0  sar     eax, 0x10
  0x01347BF3  lea     edi, [edi + eax*4]
  0x01347BF6  jmp     0x1344e1f

; ---- handler 30  va=0x01344F7F  next=0x01344F8E ----
  0x01344F7F  mov     eax, dword ptr [edi]
  0x01344F81  mov     ecx, eax
  0x01344F83  add     edi, 4
  0x01344F86  sar     ecx, 0x10
  0x01344F89  jmp     0x1348369

; ---- handler 31  va=0x0134760A  next=0x01347656 ----
  0x0134760A  mov     ecx, dword ptr [edi]
  0x0134760C  add     edi, 4
  0x0134760F  mov     edx, dword ptr [ebp + 8]
  0x01347612  mov     eax, ecx
  0x01347614  mov     dword ptr [esp + 0x24], ecx
  0x01347618  shr     eax, 0x10
  0x0134761B  shr     ecx, 0x18
  0x0134761E  push    ecx
  0x0134761F  movzx   esi, al
  0x01347622  mov     eax, dword ptr [edx + 8]
  0x01347625  sub     ecx, esi
  0x01347627  inc     ecx
  0x01347628  push    ecx
  0x01347629  push    edx
  0x0134762A  mov     dword ptr [eax + 4], edi
  0x0134762D  call    0x1358770   ; ->RVA 0xF58770
  0x01347632  mov     eax, dword ptr [ebp + 8]
  0x01347635  add     esi, esi
  0x01347637  add     esp, 0xc
  0x0134763A  mov     ecx, dword ptr [eax + 0x14]
  0x0134763D  mov     eax, dword ptr [esp + 0x24]
  0x01347641  shr     eax, 8
  0x01347644  movzx   eax, al
  0x01347647  movups  xmm0, xmmword ptr [ecx + esi*8]
  0x0134764B  add     eax, eax
  0x0134764D  movups  xmmword ptr [ecx + eax*8], xmm0
  0x01347651  jmp     0x13478cb

; ---- handler 32  va=0x013470D7  next=0x01347137 ----
  0x013470D7  mov     ecx, dword ptr [edi]
  0x013470D9  mov     eax, ecx
  0x013470DB  shr     eax, 8
  0x013470DE  add     edi, 4
  0x013470E1  movzx   eax, al
  0x013470E4  shl     eax, 4
  0x013470E7  add     eax, edx
  0x013470E9  mov     dword ptr [esp + 0x18], eax
  0x013470ED  mov     eax, ecx
  0x013470EF  shr     eax, 0x10
  0x013470F2  movzx   eax, al
  0x013470F5  shl     eax, 4
  0x013470F8  shr     ecx, 0x18
  0x013470FB  add     eax, edx
  0x013470FD  shl     ecx, 4
  0x01347100  add     ecx, dword ptr [esp + 0x30]
  0x01347104  mov     dword ptr [esp + 0x24], eax
  0x01347108  cmp     dword ptr [eax + 0xc], 4
  0x0134710C  jne     0x1347130
  0x0134710E  movaps  xmm3, xmmword ptr [0x28ad240]
  0x01347115  movsd   xmm2, qword ptr [eax]
  0x01347119  movsd   xmm1, qword ptr [ecx]
  0x0134711D  xorps   xmm2, xmm3
  0x01347120  mov     eax, dword ptr [esp + 0x18]
  0x01347124  xorps   xmm1, xmm3
  0x01347127  subsd   xmm2, xmm1
  0x0134712B  jmp     0x134728c
  0x01347130  push    6
  0x01347132  jmp     0x13474c9

; ---- handler 33  va=0x0134687A  next=0x01346957 ----
  0x0134687A  mov     ecx, dword ptr [edi]
  0x0134687C  mov     eax, ecx
  0x0134687E  shr     eax, 8
  0x01346881  add     edi, 4
  0x01346884  movzx   eax, al
  0x01346887  shl     eax, 4
  0x0134688A  add     eax, edx
  0x0134688C  mov     dword ptr [esp + 0x18], ecx
  0x01346890  mov     dword ptr [esp + 0x1c], eax
  0x01346894  mov     esi, dword ptr [esp + 0x1c]
  0x01346898  mov     eax, dword ptr [edi]
  0x0134689A  shl     eax, 4
  0x0134689D  add     eax, edx
  0x0134689F  mov     esi, dword ptr [esi + 0xc]
  0x013468A2  cmp     esi, 4
  0x013468A5  mov     dword ptr [esp + 0x24], esi
  0x013468A9  mov     esi, dword ptr [ebp + 8]
  0x013468AC  mov     dword ptr [esp + 0x10], eax
  0x013468B0  jne     0x13468ea
  0x013468B2  cmp     dword ptr [eax + 0xc], 4
  0x013468B6  jne     0x13468ea
  0x013468B8  mov     esi, dword ptr [esp + 0x1c]
  0x013468BC  movsd   xmm1, qword ptr [eax]
  0x013468C0  xorps   xmm1, xmmword ptr [0x28ad240]
  0x013468C7  movsd   xmm2, qword ptr [esi]
  0x013468CB  xorps   xmm2, xmmword ptr [0x28ad240]
  0x013468D2  comisd  xmm1, xmm2
  0x013468D6  mov     esi, dword ptr [ebp + 8]
  0x013468D9  jae     0x1346aa1
  0x013468DF  sar     ecx, 0x10
  0x013468E2  lea     edi, [edi + ecx*4]
  0x013468E5  jmp     0x1344e1f
  0x013468EA  cmp     dword ptr [esp + 0x24], 5
  0x013468EF  jne     0x1346922
  0x013468F1  cmp     dword ptr [eax + 0xc], 5
  0x013468F5  jne     0x1346922
  0x013468F7  push    dword ptr [eax]
  0x013468F9  mov     eax, dword ptr [esp + 0x20]
  0x013468FD  push    dword ptr [eax]
  0x013468FF  call    0x134d540   ; ->RVA 0xF4D540
  0x01346904  add     esp, 8
  0x01346907  test    eax, eax
  0x01346909  jle     0x1346ae2
  0x0134690F  mov     eax, dword ptr [esp + 0x18]
  0x01346913  mov     edx, dword ptr [esp + 0x14]
  0x01346917  sar     eax, 0x10
  0x0134691A  lea     edi, [edi + eax*4]
  0x0134691D  jmp     0x1344e1f
  0x01346922  push    dword ptr [esp + 0x10]
  0x01346926  mov     eax, dword ptr [esi + 8]
  0x01346929  push    dword ptr [esp + 0x20]
  0x0134692D  push    esi
  0x0134692E  mov     dword ptr [eax + 4], edi
  0x01346931  call    0x1358ff0   ; ->RVA 0xF58FF0
  0x01346936  mov     edx, dword ptr [esi + 0x14]
  0x01346939  add     esp, 0xc
  0x0134693C  mov     dword ptr [esp + 0x14], edx
  0x01346940  test    eax, eax
  0x01346942  jne     0x1346b24
  0x01346948  mov     eax, dword ptr [esp + 0x18]
  0x0134694C  sar     eax, 0x10
  0x0134694F  lea     edi, [edi + eax*4]
  0x01346952  jmp     0x1344e1f

; ---- handler 34  va=0x013460B4  next=0x0134618E ----
  0x013460B4  mov     ecx, dword ptr [edi]
  0x013460B6  mov     eax, ecx
  0x013460B8  mov     edi, dword ptr [esi + 8]
  0x013460BB  shr     eax, 8
  0x013460BE  shr     ecx, 0x10
  0x013460C1  movzx   eax, al
  0x013460C4  shl     eax, 4
  0x013460C7  movzx   ecx, cl
  0x013460CA  add     eax, edx
  0x013460CC  dec     ecx
  0x013460CD  mov     dword ptr [esp + 0x10], edi
  0x013460D1  mov     edi, dword ptr [edi]
  0x013460D3  mov     dword ptr [esp + 0x24], eax
  0x013460D7  cmp     ecx, -1
  0x013460DA  jne     0x13460e1
  0x013460DC  mov     ecx, dword ptr [esi + 0x10]
  0x013460DF  jmp     0x13460e6
  0x013460E1  shl     ecx, 4
  0x013460E4  add     ecx, eax
  0x013460E6  mov     eax, dword ptr [esp + 0x10]
  0x013460EA  mov     dword ptr [esp + 0x18], ecx
  0x013460EE  mov     edx, dword ptr [eax + 0x10]
  0x013460F1  test    edx, edx
  0x013460F3  je      0x134613f
  0x013460F5  mov     esi, dword ptr [esp + 0x24]
  0x013460F9  nop     dword ptr [eax]
  0x01346100  cmp     esi, ecx
  0x01346102  jae     0x134611d
  0x01346104  mov     ecx, esi
  0x01346106  mov     eax, edi
  0x01346108  add     esi, 0x10
  0x0134610B  add     edi, 0x10
  0x0134610E  movups  xmm0, xmmword ptr [ecx]
  0x01346111  mov     ecx, dword ptr [esp + 0x18]
  0x01346115  movups  xmmword ptr [eax], xmm0
  0x01346118  sub     edx, 1
  0x0134611B  jne     0x1346100
  0x0134611D  mov     esi, dword ptr [ebp + 8]
  0x01346120  mov     eax, dword ptr [esp + 0x10]
  0x01346124  test    edx, edx
  0x01346126  jle     0x134613f
  0x01346128  nop     dword ptr [eax + eax]
  0x01346130  dec     edx
  0x01346131  mov     dword ptr [edi + 0xc], 0
  0x01346138  add     edi, 0x10
  0x0134613B  test    edx, edx
  0x0134613D  jg      0x1346130
  0x0134613F  lea     ecx, [eax - 0x18]
  0x01346142  mov     dword ptr [esi + 8], ecx
  0x01346145  mov     edx, dword ptr [ecx + 8]
  0x01346148  mov     dword ptr [esi + 0x14], edx
  0x0134614B  cmp     dword ptr [eax + 0x10], -1
  0x0134614F  mov     eax, edi
  0x01346151  mov     dword ptr [esp + 0x14], edx
  0x01346155  je      0x134615a
  0x01346157  mov     eax, dword ptr [ecx + 0xc]
  0x0134615A  mov     dword ptr [esi + 0x10], eax
  0x0134615D  mov     eax, dword ptr [esp + 0x10]
  0x01346161  test    byte ptr [eax + 0x14], 1
  0x01346165  jne     0x13484c0
  0x0134616B  mov     eax, dword ptr [ecx]
  0x0134616D  mov     edi, dword ptr [ecx + 4]
  0x01346170  mov     eax, dword ptr [eax]
  0x01346172  mov     dword ptr [esp + 0x34], eax
  0x01346176  add     eax, 0x18
  0x01346179  mov     ecx, dword ptr [eax]
  0x0134617B  xor     ecx, eax
  0x0134617D  mov     eax, dword ptr [ecx + 0x24]
  0x01346180  add     ecx, 0x24
  0x01346183  sub     eax, ecx
  0x01346185  mov     dword ptr [esp + 0x30], eax
  0x01346189  jmp     0x1344e1f

; ---- handler 35  va=0x01348361  next=0x01348384 ----
  0x01348361  mov     eax, dword ptr [edi]
  0x01348363  mov     ecx, dword ptr [edi + 4]
  0x01348366  add     edi, 8
  0x01348369  shl     ecx, 4
  0x0134836C  add     ecx, dword ptr [esp + 0x30]
  0x01348370  shr     eax, 8
  0x01348373  movzx   eax, al
  0x01348376  add     eax, eax
  0x01348378  movups  xmm0, xmmword ptr [ecx]
  0x0134837B  movups  xmmword ptr [edx + eax*8], xmm0
  0x0134837F  jmp     0x1344e1f

; ---- handler 36  va=0x0134567E  next=0x01345752 ----
  0x0134567E  mov     ecx, dword ptr [edi]
  0x01345680  mov     eax, ecx
  0x01345682  shr     eax, 8
  0x01345685  add     edi, 4
  0x01345688  movzx   eax, al
  0x0134568B  shl     eax, 4
  0x0134568E  add     eax, edx
  0x01345690  mov     dword ptr [esp + 0x1c], eax
  0x01345694  mov     eax, ecx
  0x01345696  shr     eax, 0x10
  0x01345699  movzx   eax, al
  0x0134569C  shl     eax, 4
  0x0134569F  shr     ecx, 0x18
  0x013456A2  add     eax, edx
  0x013456A4  shl     ecx, 4
  0x013456A7  add     ecx, edx
  0x013456A9  mov     dword ptr [esp + 0x20], eax
  0x013456AD  mov     dword ptr [esp + 0x2c], ecx
  0x013456B1  cmp     dword ptr [eax + 0xc], 8
  0x013456B5  jne     0x134572d
  0x013456B7  cmp     dword ptr [ecx + 0xc], 4
  0x013456BB  jne     0x134572d
  0x013456BD  mov     eax, dword ptr [eax]
  0x013456BF  movsd   xmm1, qword ptr [ecx]
  0x013456C3  xorps   xmm1, xmmword ptr [0x28ad240]
  0x013456CA  mov     dword ptr [esp + 0x10], eax
  0x013456CE  cvttsd2si eax, xmm1
  0x013456D2  mov     dword ptr [esp + 0x18], eax
  0x013456D6  movd    xmm0, eax
  0x013456DA  cvtdq2pd xmm0, xmm0
  0x013456DE  ucomisd xmm0, xmm1
  0x013456E2  lahf    
  0x013456E3  test    ah, 0x44
  0x013456E6  jp      0x134572d
  0x013456E8  mov     esi, dword ptr [esp + 0x10]
  0x013456EC  mov     eax, dword ptr [esp + 0x18]
  0x013456F0  dec     eax
  0x013456F1  cmp     eax, dword ptr [esi + 0xc]
  0x013456F4  mov     esi, dword ptr [ebp + 8]
  0x013456F7  jae     0x134572d
  0x013456F9  mov     ecx, dword ptr [esp + 0x10]
  0x013456FD  add     ecx, 0x1c
  0x01345700  mov     eax, dword ptr [ecx]
  0x01345702  add     eax, ecx
  0x01345704  jne     0x1345729
  0x01345706  mov     eax, dword ptr [esp + 0x10]
  0x0134570A  mov     ecx, dword ptr [esp + 0x18]
  0x0134570E  add     eax, 0x14
  0x01345711  shl     ecx, 4
  0x01345714  add     ecx, eax
  0x01345716  mov     eax, dword ptr [eax]
  0x01345718  movups  xmm0, xmmword ptr [ecx + eax - 0x10]
  0x0134571D  mov     eax, dword ptr [esp + 0x1c]
  0x01345721  movups  xmmword ptr [eax], xmm0
  0x01345724  jmp     0x1344e1f
  0x01345729  mov     ecx, dword ptr [esp + 0x2c]
  0x0134572D  mov     eax, dword ptr [esi + 8]
  0x01345730  mov     dword ptr [eax + 4], edi
  0x01345733  mov     eax, dword ptr [esp + 0x1c]
  0x01345737  push    eax
  0x01345738  push    ecx
  0x01345739  push    dword ptr [esp + 0x28]
  0x0134573D  push    esi
  0x0134573E  call    0x1358ec0   ; ->RVA 0xF58EC0
  0x01345743  mov     edx, dword ptr [esi + 0x14]
  0x01345746  add     esp, 0x10
  0x01345749  mov     dword ptr [esp + 0x14], edx
  0x0134574D  jmp     0x1344e1f

; ---- handler 37  va=0x01347AC8  next=0x01347B7C ----
  0x01347AC8  mov     eax, dword ptr [esi + 0x18]
  0x01347ACB  lea     ecx, [esi + 0x18]
  0x01347ACE  xor     eax, ecx
  0x01347AD0  mov     ecx, dword ptr [eax + 0x3a8]
  0x01347AD6  add     eax, 0x3a8
  0x01347ADB  add     ecx, eax
  0x01347ADD  mov     dword ptr [esp + 0x24], ecx
  0x01347AE1  je      0x1347b07
  0x01347AE3  mov     eax, dword ptr [esi + 8]
  0x01347AE6  mov     dword ptr [eax + 4], edi
  0x01347AE9  mov     eax, dword ptr [0x2941254]
  0x01347AEE  sub     ecx, eax
  0x01347AF0  cmp     ecx, dword ptr [0x2941258]
  0x01347AF6  jae     0x1347b00
  0x01347AF8  push    esi
  0x01347AF9  call    dword ptr [esp + 0x28]
  0x01347AFD  add     esp, 4
  0x01347B00  mov     edx, dword ptr [esi + 0x14]
  0x01347B03  mov     dword ptr [esp + 0x14], edx
  0x01347B07  mov     ecx, dword ptr [edi]
  0x01347B09  xorps   xmm0, xmm0
  0x01347B0C  movaps  xmm2, xmmword ptr [0x28ad240]
  0x01347B13  mov     eax, ecx
  0x01347B15  shr     eax, 8
  0x01347B18  add     edi, 4
  0x01347B1B  movzx   eax, al
  0x01347B1E  shl     eax, 4
  0x01347B21  add     eax, edx
  0x01347B23  movsd   xmm1, qword ptr [eax + 0x10]
  0x01347B28  movsd   xmm3, qword ptr [eax + 0x20]
  0x01347B2D  xorps   xmm1, xmm2
  0x01347B30  movsd   xmm4, qword ptr [eax]
  0x01347B34  xorps   xmm3, xmm2
  0x01347B37  addsd   xmm3, xmm1
  0x01347B3B  mov     dword ptr [eax + 0x2c], 4
  0x01347B42  xorps   xmm4, xmm2
  0x01347B45  movsd   xmm0, xmm3
  0x01347B49  xorps   xmm0, xmm2
  0x01347B4C  movsd   qword ptr [eax + 0x20], xmm0
  0x01347B51  xorps   xmm0, xmm0
  0x01347B54  xor     eax, eax
  0x01347B56  comisd  xmm1, xmm0
  0x01347B5A  jbe     0x1347b62
  0x01347B5C  comisd  xmm4, xmm3
  0x01347B60  jmp     0x1347b66
  0x01347B62  comisd  xmm3, xmm4
  0x01347B66  setae   al
  0x01347B69  test    eax, eax
  0x01347B6B  je      0x1344e1f
  0x01347B71  sar     ecx, 0x10
  0x01347B74  lea     edi, [edi + ecx*4]
  0x01347B77  jmp     0x1344e1f

; ---- handler 38  va=0x01344F4C  next=0x01344F7F ----
  0x01344F4C  mov     ecx, dword ptr [edi]
  0x01344F4E  mov     eax, ecx
  0x01344F50  shr     eax, 8
  0x01344F53  add     edi, 4
  0x01344F56  movzx   eax, al
  0x01344F59  add     eax, eax
  0x01344F5B  sar     ecx, 0x10
  0x01344F5E  movd    xmm0, ecx
  0x01344F62  cvtdq2pd xmm1, xmm0
  0x01344F66  xorps   xmm1, xmmword ptr [0x28ad240]
  0x01344F6D  movsd   qword ptr [edx + eax*8], xmm1
  0x01344F72  mov     dword ptr [edx + eax*8 + 0xc], 4
  0x01344F7A  jmp     0x1344e1f

; ---- handler 39  va=0x013475C0  next=0x0134760A ----
  0x013475C0  mov     edx, dword ptr [edi]
  0x013475C2  mov     eax, edx
  0x013475C4  shr     eax, 0x10
  0x013475C7  mov     ecx, edx
  0x013475C9  movzx   esi, al
  0x013475CC  add     edi, 4
  0x013475CF  shl     esi, 4
  0x013475D2  add     esi, dword ptr [esp + 0x14]
  0x013475D6  shr     ecx, 0x18
  0x013475D9  shl     ecx, 4
  0x013475DC  add     ecx, dword ptr [esp + 0x30]
  0x013475E0  mov     eax, dword ptr [esi]
  0x013475E2  or      eax, 0xfffffffe
  0x013475E5  test    dword ptr [esi + 0xc], eax
  0x013475E8  cmove   esi, ecx
  0x013475EB  movups  xmm0, xmmword ptr [esi]
  0x013475EE  mov     esi, dword ptr [ebp + 8]
  0x013475F1  mov     ecx, dword ptr [esp + 0x38]
  0x013475F5  shr     edx, 8
  0x013475F8  movzx   eax, dl
  0x013475FB  mov     edx, dword ptr [esp + 0x14]
  0x013475FF  add     eax, eax
  0x01347601  movups  xmmword ptr [edx + eax*8], xmm0
  0x01347605  jmp     0x1344e22

; ---- handler 40  va=0x01347077  next=0x013470D7 ----
  0x01347077  mov     ecx, dword ptr [edi]
  0x01347079  mov     eax, ecx
  0x0134707B  shr     eax, 8
  0x0134707E  add     edi, 4
  0x01347081  movzx   eax, al
  0x01347084  shl     eax, 4
  0x01347087  add     eax, edx
  0x01347089  mov     dword ptr [esp + 0x18], eax
  0x0134708D  mov     eax, ecx
  0x0134708F  shr     eax, 0x10
  0x01347092  movzx   eax, al
  0x01347095  shl     eax, 4
  0x01347098  shr     ecx, 0x18
  0x0134709B  add     eax, edx
  0x0134709D  shl     ecx, 4
  0x013470A0  add     ecx, dword ptr [esp + 0x30]
  0x013470A4  mov     dword ptr [esp + 0x24], eax
  0x013470A8  cmp     dword ptr [eax + 0xc], 4
  0x013470AC  jne     0x13470d0
  0x013470AE  movaps  xmm3, xmmword ptr [0x28ad240]
  0x013470B5  movsd   xmm1, qword ptr [eax]
  0x013470B9  movsd   xmm2, qword ptr [ecx]
  0x013470BD  xorps   xmm1, xmm3
  0x013470C0  mov     eax, dword ptr [esp + 0x18]
  0x013470C4  xorps   xmm2, xmm3
  0x013470C7  addsd   xmm2, xmm1
  0x013470CB  jmp     0x134728c
  0x013470D0  push    9
  0x013470D2  jmp     0x13474c9

; ---- handler 41  va=0x013464D1  next=0x013467B9 ----
  0x013464D1  mov     ecx, dword ptr [edi]
  0x013464D3  add     edi, 4
  0x013464D6  mov     eax, ecx
  0x013464D8  mov     dword ptr [esp + 0x20], ecx
  0x013464DC  shr     eax, 8
  0x013464DF  movzx   eax, al
  0x013464E2  mov     esi, dword ptr [edi]
  0x013464E4  shl     eax, 4
  0x013464E7  add     eax, edx
  0x013464E9  shl     esi, 4
  0x013464EC  add     esi, edx
  0x013464EE  mov     dword ptr [esp + 0x1c], eax
  0x013464F2  mov     dword ptr [esp + 0x28], esi
  0x013464F6  mov     edx, dword ptr [eax + 0xc]
  0x013464F9  cmp     edx, dword ptr [esi + 0xc]
  0x013464FC  mov     esi, dword ptr [ebp + 8]
  0x013464FF  mov     edx, dword ptr [esp + 0x14]
  0x01346503  jne     0x1347b71
  0x01346509  cmp     dword ptr [eax + 0xc], 9
  0x0134650D  ja      0x1346781
  0x01346513  mov     esi, dword ptr [eax + 0xc]
  0x01346516  jmp     dword ptr [esi*4 + 0x1348710]
  0x0134651D  mov     esi, dword ptr [ebp + 8]
  0x01346520  add     edi, 4
  0x01346523  jmp     0x1344e1f
  0x01346528  movsd   xmm2, qword ptr [eax]
  0x0134652C  mov     eax, dword ptr [esp + 0x28]
  0x01346530  xorps   xmm2, xmmword ptr [0x28ad240]
  0x01346537  mov     esi, dword ptr [ebp + 8]
  0x0134653A  movsd   xmm1, qword ptr [eax]
  0x0134653E  xorps   xmm1, xmmword ptr [0x28ad240]
  0x01346545  ucomisd xmm2, xmm1
  0x01346549  lahf    
  0x0134654A  test    ah, 0x44
  0x0134654D  jnp     0x1346aa1
  0x01346553  sar     ecx, 0x10
  0x01346556  lea     edi, [edi + ecx*4]
  0x01346559  jmp     0x1344e1f
  0x0134655E  push    dword ptr [esp + 0x28]
  0x01346562  push    eax
  0x01346563  call    0x1344d90   ; ->RVA 0xF44D90
  0x01346568  mov     esi, dword ptr [ebp + 8]
  0x0134656B  add     esp, 8
  0x0134656E  test    al, al
  0x01346570  jne     0x1346ae2
  0x01346576  mov     eax, dword ptr [esp + 0x20]
  0x0134657A  mov     edx, dword ptr [esp + 0x14]
  0x0134657E  sar     eax, 0x10
  0x01346581  lea     edi, [edi + eax*4]
  0x01346584  jmp     0x1344e1f
  0x01346589  mov     eax, dword ptr [eax]
  0x0134658B  mov     esi, dword ptr [ebp + 8]
  0x0134658E  mov     dword ptr [esp + 0x18], eax
  0x01346592  mov     eax, dword ptr [esp + 0x28]
  0x01346596  mov     ecx, dword ptr [eax]
  0x01346598  mov     eax, dword ptr [esp + 0x18]
  0x0134659C  add     ecx, 0x1c
  0x0134659F  mov     dword ptr [esp + 0x24], ecx
  0x013465A3  mov     ecx, dword ptr [eax + 0x1c]
  0x013465A6  add     eax, 0x1c
  0x013465A9  add     eax, ecx
  0x013465AB  mov     ecx, dword ptr [esp + 0x24]
  0x013465AF  mov     dword ptr [esp + 0x10], eax
  0x013465B3  mov     eax, dword ptr [ecx]
  0x013465B5  add     eax, ecx
  0x013465B7  mov     ecx, dword ptr [esp + 0x10]
  0x013465BB  cmp     ecx, eax
  0x013465BD  jne     0x1346781
  0x013465C3  test    ecx, ecx
  0x013465C5  je      0x134660e
  0x013465C7  mov     eax, dword ptr [esp + 0x18]
  0x013465CB  mov     ecx, dword ptr [eax + 0x1c]
  0x013465CE  add     eax, 0x1c
  0x013465D1  add     eax, ecx
  0x013465D3  mov     dword ptr [esp + 0x24], eax
  0x013465D7  test    byte ptr [eax + 6], 0x10
  0x013465DB  jne     0x134660e
  0x013465DD  mov     ecx, dword ptr [esi + 0x18]
  0x013465E0  lea     eax, [esi + 0x18]
  0x013465E3  xor     ecx, eax
  0x013465E5  mov     eax, dword ptr [ecx + 0xe4]
  0x013465EB  add     ecx, 0xe4
  0x013465F1  add     eax, ecx
  0x013465F3  push    eax
  0x013465F4  push    4
  0x013465F6  push    dword ptr [esp + 0x2c]
  0x013465FA  call    0x1359390   ; ->RVA 0xF59390
  0x013465FF  add     esp, 0xc
  0x01346602  test    eax, eax
  0x01346604  jne     0x1346781
  0x0134660A  mov     edx, dword ptr [esp + 0x14]
  0x0134660E  mov     ecx, dword ptr [esp + 0x1c]
  0x01346612  mov     eax, dword ptr [ecx]
  0x01346614  mov     ecx, dword ptr [esp + 0x28]
  0x01346618  cmp     eax, dword ptr [ecx]
  0x0134661A  je      0x1346b24
  0x01346620  mov     eax, dword ptr [esp + 0x20]
  0x01346624  sar     eax, 0x10
  0x01346627  lea     edi, [edi + eax*4]
  0x0134662A  jmp     0x1344e1f
  0x0134662F  mov     eax, dword ptr [eax]
  0x01346631  add     eax, 0xc
  0x01346634  mov     dword ptr [esp + 0x10], eax
  0x01346638  mov     eax, dword ptr [esp + 0x28]
  0x0134663C  mov     esi, dword ptr [esp + 0x10]
  0x01346640  mov     eax, dword ptr [eax]
  0x01346642  add     eax, 0xc
  0x01346645  mov     dword ptr [esp + 0x24], eax
  0x01346649  mov     eax, dword ptr [esi]
  0x0134664B  sub     esi, eax
  0x0134664D  mov     dword ptr [esp + 0x18], eax
  0x01346651  mov     eax, dword ptr [esp + 0x24]
  0x01346655  mov     dword ptr [esp + 0x2c], esi
  0x01346659  sub     eax, dword ptr [eax]
  0x0134665B  cmp     esi, eax
  0x0134665D  mov     esi, dword ptr [ebp + 8]
  0x01346660  jne     0x1346781
  0x01346666  cmp     dword ptr [esp + 0x2c], 0
  0x0134666B  je      0x1346761
  0x01346671  mov     eax, dword ptr [esp + 0x10]
  0x01346675  sub     eax, dword ptr [esp + 0x18]
  0x01346679  test    byte ptr [eax + 6], 0x10
  0x0134667D  jne     0x1346761
  0x01346683  mov     eax, dword ptr [esi + 0x18]
  0x01346686  lea     ecx, [esi + 0x18]
  0x01346689  xor     eax, ecx
  0x0134668B  mov     ecx, dword ptr [eax + 0xe4]
  0x01346691  add     eax, 0xe4
  0x01346696  add     ecx, eax
  0x01346698  mov     eax, dword ptr [esp + 0x10]
  0x0134669C  sub     eax, dword ptr [esp + 0x18]
  0x013466A0  push    ecx
  0x013466A1  push    4
  0x013466A3  push    eax
  0x013466A4  call    0x1359390   ; ->RVA 0xF59390
  0x013466A9  mov     edx, eax
  0x013466AB  add     esp, 0xc
  0x013466AE  test    edx, edx
  0x013466B0  je      0x1346759
  0x013466B6  cmp     dword ptr [edx + 0xc], 6
  0x013466BA  jne     0x1346781
  0x013466C0  mov     ecx, dword ptr [edx]
  0x013466C2  cmp     byte ptr [ecx + 6], 0
  0x013466C6  je      0x1346781
  0x013466CC  mov     eax, dword ptr [esi + 0x10]
  0x013466CF  movups  xmm0, xmmword ptr [edx]
  0x013466D2  mov     ecx, dword ptr [esp + 0x1c]
  0x013466D6  movups  xmmword ptr [eax], xmm0
  0x013466D9  mov     eax, dword ptr [esi + 0x10]
  0x013466DC  movups  xmm0, xmmword ptr [ecx]
  0x013466DF  mov     ecx, dword ptr [esp + 0x28]
  0x013466E3  movups  xmmword ptr [eax + 0x10], xmm0
  0x013466E7  mov     eax, dword ptr [esi + 0x10]
  0x013466EA  movups  xmm0, xmmword ptr [ecx]
  0x013466ED  mov     ecx, dword ptr [ebp + 8]
  0x013466F0  movups  xmmword ptr [eax + 0x20], xmm0
  0x013466F4  mov     eax, dword ptr [esi + 0x10]
  0x013466F7  mov     esi, eax
  0x013466F9  sub     esi, dword ptr [ecx + 0x14]
  0x013466FC  add     eax, 0x30
  0x013466FF  mov     dword ptr [ecx + 0x10], eax
  0x01346702  mov     eax, dword ptr [ecx + 8]
  0x01346705  sar     esi, 4
  0x01346708  push    esi
  0x01346709  push    2
  0x0134670B  push    ecx
  0x0134670C  mov     dword ptr [eax + 4], edi
  0x0134670F  call    0x134c460   ; ->RVA 0xF4C460
  0x01346714  mov     eax, dword ptr [ebp + 8]
  0x01346717  add     esi, esi
  0x01346719  add     esp, 0xc
  0x0134671C  mov     edx, dword ptr [eax + 0x14]
  0x0134671F  mov     dword ptr [esp + 0x14], edx
  0x01346723  mov     eax, dword ptr [edx + esi*8]
  0x01346726  or      eax, 0xfffffffe
  0x01346729  test    dword ptr [edx + esi*8 + 0xc], eax
  0x0134672D  jne     0x1346745
  0x0134672F  mov     eax, dword ptr [esp + 0x20]
  0x01346733  mov     esi, dword ptr [ebp + 8]
  0x01346736  mov     ecx, dword ptr [esp + 0x38]
  0x0134673A  sar     eax, 0x10
  0x0134673D  lea     edi, [edi + eax*4]
  0x01346740  jmp     0x1344e22
  0x01346745  mov     esi, dword ptr [ebp + 8]
  0x01346748  mov     eax, 1
  0x0134674D  mov     ecx, dword ptr [esp + 0x38]
  0x01346751  lea     edi, [edi + eax*4]
  0x01346754  jmp     0x1344e22
  0x01346759  mov     edx, dword ptr [esp + 0x14]
  0x0134675D  mov     ecx, dword ptr [esp + 0x20]
  0x01346761  mov     eax, dword ptr [esp + 0x1c]
  0x01346765  mov     esi, dword ptr [esp + 0x28]
  0x01346769  mov     eax, dword ptr [eax]
  0x0134676B  cmp     eax, dword ptr [esi]
  0x0134676D  mov     esi, dword ptr [ebp + 8]
  0x01346770  je      0x1346aa1
  0x01346776  sar     ecx, 0x10
  0x01346779  lea     edi, [edi + ecx*4]
  0x0134677C  jmp     0x1344e1f
  0x01346781  mov     esi, dword ptr [ebp + 8]
  0x01346784  push    dword ptr [esp + 0x28]
  0x01346788  push    dword ptr [esp + 0x20]
  0x0134678C  mov     eax, dword ptr [esi + 8]
  0x0134678F  push    esi
  0x01346790  mov     dword ptr [eax + 4], edi
  0x01346793  call    0x1358d90   ; ->RVA 0xF58D90
  0x01346798  mov     edx, dword ptr [esi + 0x14]
  0x0134679B  add     esp, 0xc
  0x0134679E  mov     dword ptr [esp + 0x14], edx
  0x013467A2  test    eax, eax
  0x013467A4  jne     0x1346b24
  0x013467AA  mov     eax, dword ptr [esp + 0x20]
  0x013467AE  sar     eax, 0x10
  0x013467B1  lea     edi, [edi + eax*4]
  0x013467B4  jmp     0x1344e1f

; ---- handler 42  va=0x01345C9D  next=0x013460B4 ----
  0x01345C9D  mov     ecx, dword ptr [esp + 0x14]
  0x01345CA1  mov     eax, dword ptr [esi + 0x18]
  0x01345CA4  lea     edx, [esi + 0x18]
  0x01345CA7  xor     eax, edx
  0x01345CA9  mov     edx, dword ptr [eax + 0x3a8]
  0x01345CAF  add     eax, 0x3a8
  0x01345CB4  add     edx, eax
  0x01345CB6  je      0x1345cd8
  0x01345CB8  mov     eax, dword ptr [esi + 8]
  0x01345CBB  mov     ecx, edx
  0x01345CBD  mov     dword ptr [eax + 4], edi
  0x01345CC0  mov     eax, dword ptr [0x2941254]
  0x01345CC5  sub     ecx, eax
  0x01345CC7  cmp     ecx, dword ptr [0x2941258]
  0x01345CCD  jae     0x1345cd5
  0x01345CCF  push    esi
  0x01345CD0  call    edx
  0x01345CD2  add     esp, 4
  0x01345CD5  mov     ecx, dword ptr [esi + 0x14]
  0x01345CD8  mov     eax, dword ptr [edi]
  0x01345CDA  add     edi, 4
  0x01345CDD  mov     dword ptr [esp + 0x2c], eax
  0x01345CE1  shr     eax, 8
  0x01345CE4  movzx   eax, al
  0x01345CE7  shl     eax, 4
  0x01345CEA  add     eax, ecx
  0x01345CEC  mov     dword ptr [esp + 0x1c], edi
  0x01345CF0  mov     ecx, dword ptr [esp + 0x2c]
  0x01345CF4  mov     dword ptr [esp + 0x20], eax
  0x01345CF8  mov     eax, ecx
  0x01345CFA  shr     eax, 0x10
  0x01345CFD  movzx   edx, al
  0x01345D00  mov     eax, dword ptr [esp + 0x20]
  0x01345D04  dec     edx
  0x01345D05  shr     ecx, 0x18
  0x01345D08  dec     ecx
  0x01345D09  mov     dword ptr [esp + 0x28], edx
  0x01345D0D  mov     dword ptr [esp + 0x2c], ecx
  0x01345D11  cmp     edx, -1
  0x01345D14  jne     0x1345d23
  0x01345D16  mov     edx, dword ptr [esi + 0x10]
  0x01345D19  sub     edx, eax
  0x01345D1B  sar     edx, 4
  0x01345D1E  dec     edx
  0x01345D1F  mov     dword ptr [esp + 0x28], edx
  0x01345D23  cmp     dword ptr [eax + 0xc], 6
  0x01345D27  je      0x1345d49
  0x01345D29  mov     eax, dword ptr [esi + 8]
  0x01345D2C  push    dword ptr [esp + 0x20]
  0x01345D30  push    esi
  0x01345D31  mov     dword ptr [eax + 4], edi
  0x01345D34  call    0x134d5e0   ; ->RVA 0xF4D5E0
  0x01345D39  mov     edx, dword ptr [esp + 0x30]
  0x01345D3D  add     esp, 8
  0x01345D40  inc     edx
  0x01345D41  mov     dword ptr [esp + 0x20], eax
  0x01345D45  mov     dword ptr [esp + 0x28], edx
  0x01345D49  mov     ecx, dword ptr [eax]
  0x01345D4B  mov     dword ptr [esp + 0x10], ecx
  0x01345D4F  mov     ecx, dword ptr [esi + 8]
  0x01345D52  mov     dword ptr [ecx + 4], edi
  0x01345D55  mov     ecx, dword ptr [esi + 8]
  0x01345D58  cmp     ecx, dword ptr [esi + 0x28]
  0x01345D5B  jne     0x1345f33
  0x01345D61  push    esi
  0x01345D62  call    0x1343e60   ; ->RVA 0xF43E60
  0x01345D67  mov     edx, dword ptr [esp + 0x2c]
  0x01345D6B  mov     ecx, eax
  0x01345D6D  mov     dword ptr [esp + 0x18], eax
  0x01345D71  add     esp, 4
  0x01345D74  mov     eax, dword ptr [esp + 0x20]
  0x01345D78  jmp     0x1345f3d
  0x01345D7D  mov     edx, dword ptr [esp + 0x28]
  0x01345D81  mov     ecx, dword ptr [esp + 0x2c]
  0x01345D85  mov     esi, dword ptr [ebp + 8]
  0x01345D88  mov     eax, dword ptr [esp + 0x10]
  0x01345D8C  movups  xmm0, xmmword ptr [edx]
  0x01345D8F  push    ecx
  0x01345D90  push    dword ptr [esp + 0x24]
  0x01345D94  movups  xmmword ptr [ecx + 0x10], xmm0
  0x01345D98  shr     eax, 0x18
  0x01345D9B  mov     dword ptr [esi + 0x68], eax
  0x01345D9E  mov     eax, dword ptr [esi + 8]
  0x01345DA1  push    edx
  0x01345DA2  push    esi
  0x01345DA3  mov     dword ptr [eax + 4], edi
  0x01345DA6  call    0x1358ec0   ; ->RVA 0xF58EC0
  0x01345DAB  mov     al, byte ptr [esi + 0x68]
  0x01345DAE  add     esp, 0x10
  0x01345DB1  mov     ecx, dword ptr [esi + 0x14]
  0x01345DB4  mov     byte ptr [edi - 5], al
  0x01345DB7  jmp     0x1345ca1
  0x01345DBC  lea     ecx, [esi + 0x18]
  0x01345DBF  cmp     edx, 9
  0x01345DC2  jne     0x1345dcd
  0x01345DC4  mov     edx, dword ptr [eax]
  0x01345DC6  add     edx, 0xc
  0x01345DC9  sub     edx, dword ptr [edx]
  0x01345DCB  jmp     0x1345dd8
  0x01345DCD  mov     eax, dword ptr [ecx]
  0x01345DCF  xor     eax, ecx
  0x01345DD1  mov     edx, dword ptr [eax + edx*4 + 0x158]
  0x01345DD8  mov     dword ptr [esp + 0x18], edx
  0x01345DDC  test    edx, edx
  0x01345DDE  je      0x1345f07
  0x01345DE4  test    byte ptr [edx + 6], 2
  0x01345DE8  jne     0x1345e36
  0x01345DEA  mov     ecx, dword ptr [ecx]
  0x01345DEC  lea     eax, [esi + 0x18]
  0x01345DEF  xor     ecx, eax
  0x01345DF1  mov     eax, dword ptr [ecx + 0xd8]
  0x01345DF7  add     ecx, 0xd8
  0x01345DFD  add     eax, ecx
  0x01345DFF  push    eax
  0x01345E00  push    1
  0x01345E02  push    edx
  0x01345E03  call    0x1359390   ; ->RVA 0xF59390
  0x01345E08  add     esp, 0xc
  0x01345E0B  test    eax, eax
  0x01345E0D  je      0x1345e32
  0x01345E0F  mov     edx, dword ptr [esp + 0x28]
  0x01345E13  mov     ecx, dword ptr [esp + 0x2c]
  0x01345E17  movups  xmm0, xmmword ptr [edx]
  0x01345E1A  movups  xmmword ptr [ecx + 0x10], xmm0
  0x01345E1E  movups  xmm0, xmmword ptr [eax]
  0x01345E21  mov     eax, dword ptr [esp + 0x20]
  0x01345E25  movups  xmmword ptr [ecx], xmm0
  0x01345E28  mov     eax, dword ptr [eax]
  0x01345E2A  mov     dword ptr [esi + 0x64], eax
  0x01345E2D  jmp     0x1345c9d
  0x01345E32  mov     edx, dword ptr [esp + 0x18]
  0x01345E36  test    byte ptr [edx + 6], 4
  0x01345E3A  jne     0x1345f07
  0x01345E40  mov     ecx, dword ptr [esi + 0x18]
  0x01345E43  lea     eax, [esi + 0x18]
  0x01345E46  xor     ecx, eax
  0x01345E48  mov     eax, dword ptr [ecx + 0xdc]
  0x01345E4E  add     ecx, 0xdc
  0x01345E54  add     eax, ecx
  0x01345E56  push    eax
  0x01345E57  push    2
  0x01345E59  push    edx
  0x01345E5A  call    0x1359390   ; ->RVA 0xF59390
  0x01345E5F  add     esp, 0xc
  0x01345E62  test    eax, eax
  0x01345E64  je      0x1345f07
  0x01345E6A  cmp     dword ptr [eax + 0xc], 8
  0x01345E6E  jne     0x1345f07
  0x01345E74  mov     eax, dword ptr [eax]
  0x01345E76  mov     edx, dword ptr [esp + 0x10]
  0x01345E7A  shr     edx, 0x18
  0x01345E7D  movzx   ecx, byte ptr [eax + 0xa]
  0x01345E81  add     eax, 0x20
  0x01345E84  and     ecx, edx
  0x01345E86  mov     dword ptr [esp + 0x18], ecx
  0x01345E8A  shl     ecx, 5
  0x01345E8D  add     ecx, eax
  0x01345E8F  add     ecx, dword ptr [eax]
  0x01345E91  mov     dword ptr [esp + 0x24], ecx
  0x01345E95  mov     eax, dword ptr [ecx + 0x1c]
  0x01345E98  and     eax, 0xf
  0x01345E9B  cmp     al, 5
  0x01345E9D  jne     0x1345ece
  0x01345E9F  mov     edx, dword ptr [esp + 0x20]
  0x01345EA3  mov     eax, dword ptr [ecx + 0x10]
  0x01345EA6  cmp     eax, dword ptr [edx]
  0x01345EA8  jne     0x1345ece
  0x01345EAA  cmp     dword ptr [ecx + 0xc], 0
  0x01345EAE  je      0x1345ece
  0x01345EB0  mov     edx, dword ptr [esp + 0x28]
  0x01345EB4  mov     ecx, dword ptr [esp + 0x2c]
  0x01345EB8  mov     eax, dword ptr [esp + 0x24]
  0x01345EBC  movups  xmm0, xmmword ptr [edx]
  0x01345EBF  movups  xmmword ptr [ecx + 0x10], xmm0
  0x01345EC3  movups  xmm0, xmmword ptr [eax]
  0x01345EC6  movups  xmmword ptr [ecx], xmm0
  0x01345EC9  jmp     0x1345c9d
  0x01345ECE  mov     edx, dword ptr [esp + 0x28]
  0x01345ED2  mov     ecx, dword ptr [esp + 0x2c]
  0x01345ED6  mov     eax, dword ptr [esp + 0x18]
  0x01345EDA  push    ecx
  0x01345EDB  movups  xmm0, xmmword ptr [edx]
  0x01345EDE  push    dword ptr [esp + 0x24]
  0x01345EE2  movups  xmmword ptr [ecx + 0x10], xmm0
  0x01345EE6  mov     dword ptr [esi + 0x68], eax
  0x01345EE9  mov     eax, dword ptr [esi + 8]
  0x01345EEC  push    edx
  0x01345EED  push    esi
  0x01345EEE  mov     dword ptr [eax + 4], edi
  0x01345EF1  call    0x1358ec0   ; ->RVA 0xF58EC0
  0x01345EF6  mov     al, byte ptr [esi + 0x68]
  0x01345EF9  add     esp, 0x10
  0x01345EFC  mov     ecx, dword ptr [esi + 0x14]
  0x01345EFF  mov     byte ptr [edi - 5], al
  0x01345F02  jmp     0x1345ca1
  0x01345F07  mov     edx, dword ptr [esp + 0x28]
  0x01345F0B  mov     ecx, dword ptr [esp + 0x2c]
  0x01345F0F  push    ecx
  0x01345F10  push    dword ptr [esp + 0x24]
  0x01345F14  movups  xmm0, xmmword ptr [edx]
  0x01345F17  push    edx
  0x01345F18  push    esi
  0x01345F19  movups  xmmword ptr [ecx + 0x10], xmm0
  0x01345F1D  mov     eax, dword ptr [esi + 8]
  0x01345F20  mov     dword ptr [eax + 4], edi
  0x01345F23  call    0x1358ec0   ; ->RVA 0xF58EC0
  0x01345F28  mov     ecx, dword ptr [esi + 0x14]
  0x01345F2B  add     esp, 0x10
  0x01345F2E  jmp     0x1345ca1
  0x01345F33  add     ecx, 0x18
  0x01345F36  mov     dword ptr [esp + 0x14], ecx
  0x01345F3A  mov     dword ptr [esi + 8], ecx
  0x01345F3D  mov     esi, dword ptr [esp + 0x14]
  0x01345F41  mov     dword ptr [ecx], eax
  0x01345F43  lea     ecx, [eax + 0x10]
  0x01345F46  mov     eax, dword ptr [esp + 0x14]
  0x01345F4A  mov     dword ptr [eax + 8], ecx
  0x01345F4D  mov     eax, dword ptr [esp + 0x10]
  0x01345F51  movzx   eax, byte ptr [eax + 8]
  0x01345F55  add     eax, edx
  0x01345F57  shl     edx, 4
  0x01345F5A  shl     eax, 4
  0x01345F5D  add     eax, ecx
  0x01345F5F  mov     dword ptr [esi + 0xc], eax
  0x01345F62  mov     eax, esi
  0x01345F64  mov     esi, dword ptr [esp + 0x2c]
  0x01345F68  mov     dword ptr [eax + 0x10], esi
  0x01345F6B  mov     esi, dword ptr [ebp + 8]
  0x01345F6E  mov     dword ptr [eax + 0x14], 0
  0x01345F75  mov     dword ptr [esi + 0x14], ecx
  0x01345F78  mov     eax, dword ptr [eax + 8]
  0x01345F7B  add     eax, edx
  0x01345F7D  mov     edx, dword ptr [esp + 0x10]
  0x01345F81  mov     dword ptr [esi + 0x10], eax
  0x01345F84  movzx   ecx, byte ptr [edx + 8]
  0x01345F88  mov     dword ptr [esp + 0x18], ecx
  0x01345F8C  mov     ecx, dword ptr [esi + 0x1c]
  0x01345F8F  sub     ecx, eax
  0x01345F91  mov     eax, dword ptr [esp + 0x18]
  0x01345F95  shl     eax, 4
  0x01345F98  cmp     ecx, eax
  0x01345F9A  jg      0x1345fad
  0x01345F9C  push    dword ptr [esp + 0x18]
  0x01345FA0  push    esi
  0x01345FA1  call    0x1343ec0   ; ->RVA 0xF43EC0
  0x01345FA6  mov     edx, dword ptr [esp + 0x18]
  0x01345FAA  add     esp, 8
  0x01345FAD  cmp     byte ptr [edx + 6], 0
  0x01345FB1  lea     eax, [edx + 0x18]
  0x01345FB4  jne     0x1345fdd
  0x01345FB6  mov     ecx, dword ptr [eax]
  0x01345FB8  xor     ecx, eax
  0x01345FBA  mov     dword ptr [esp + 0x34], edx
  0x01345FBE  mov     edi, dword ptr [ecx + 0xc]
  0x01345FC1  lea     eax, [ecx + 0xc]
  0x01345FC4  mov     edx, dword ptr [esi + 0x14]
  0x01345FC7  sub     edi, eax
  0x01345FC9  mov     dword ptr [esp + 0x14], edx
  0x01345FCD  lea     eax, [ecx + 0x24]
  0x01345FD0  mov     ecx, dword ptr [eax]
  0x01345FD2  sub     ecx, eax
  0x01345FD4  mov     dword ptr [esp + 0x30], ecx
  0x01345FD8  jmp     0x1344e1f
  0x01345FDD  mov     edx, dword ptr [eax]
  0x01345FDF  xor     edx, eax
  0x01345FE1  mov     eax, dword ptr [0x2941254]
  0x01345FE6  mov     ecx, edx
  0x01345FE8  sub     ecx, eax
  0x01345FEA  cmp     ecx, dword ptr [0x2941258]
  0x01345FF0  jae     0x1346004
  0x01345FF2  push    esi
  0x01345FF3  call    edx
  0x01345FF5  mov     ecx, eax
  0x01345FF7  add     esp, 4
  0x01345FFA  test    ecx, ecx
  0x01345FFC  js      0x13484c3
  0x01346002  jmp     0x1346006
  0x01346004  xor     ecx, ecx
  0x01346006  mov     eax, dword ptr [esi + 8]
  0x01346009  shl     ecx, 4
  0x0134600C  lea     edx, [eax - 0x18]
  0x0134600F  mov     dword ptr [esp + 0x28], edx
  0x01346013  mov     edx, dword ptr [eax]
  0x01346015  mov     eax, dword ptr [esi + 0x10]
  0x01346018  mov     dword ptr [esp + 0x20], eax
  0x0134601C  sub     eax, ecx
  0x0134601E  mov     ecx, dword ptr [esp + 0x2c]
  0x01346022  mov     dword ptr [esp + 0x24], eax
  0x01346026  mov     eax, ecx
  0x01346028  mov     dword ptr [esp + 0x10], edx
  0x0134602C  mov     dword ptr [esp + 0x18], eax
  0x01346030  test    ecx, ecx
  0x01346032  je      0x1346070
  0x01346034  mov     esi, dword ptr [esp + 0x24]
  0x01346038  mov     edi, dword ptr [esp + 0x20]
  0x0134603C  nop     dword ptr [eax]
  0x01346040  cmp     esi, edi
  0x01346042  jae     0x1346061
  0x01346044  mov     ecx, esi
  0x01346046  mov     eax, edx
  0x01346048  add     esi, 0x10
  0x0134604B  add     edx, 0x10
  0x0134604E  movups  xmm0, xmmword ptr [ecx]
  0x01346051  movups  xmmword ptr [eax], xmm0
  0x01346054  mov     eax, dword ptr [esp + 0x18]
  0x01346058  sub     eax, 1
  0x0134605B  mov     dword ptr [esp + 0x18], eax
  0x0134605F  jne     0x1346040
  0x01346061  mov     edi, dword ptr [esp + 0x1c]
  0x01346065  mov     esi, dword ptr [ebp + 8]
  0x01346068  mov     ecx, dword ptr [esp + 0x2c]
  0x0134606C  mov     dword ptr [esp + 0x10], edx
  0x01346070  test    eax, eax
  0x01346072  jle     0x1346087
  0x01346074  dec     eax
  0x01346075  mov     dword ptr [edx + 0xc], 0
  0x0134607C  add     edx, 0x10
  0x0134607F  test    eax, eax
  0x01346081  jg      0x1346074
  0x01346083  mov     dword ptr [esp + 0x10], edx
  0x01346087  mov     eax, dword ptr [esp + 0x28]
  0x0134608B  mov     dword ptr [esi + 8], eax
  0x0134608E  mov     edx, dword ptr [eax + 8]
  0x01346091  mov     dword ptr [esp + 0x14], edx
  0x01346095  mov     dword ptr [esi + 0x14], edx
  0x01346098  cmp     ecx, -1
  0x0134609B  jne     0x13460a9
  0x0134609D  mov     eax, dword ptr [esp + 0x10]
  0x013460A1  mov     dword ptr [esi + 0x10], eax
  0x013460A4  jmp     0x1344e1f
  0x013460A9  mov     eax, dword ptr [eax + 0xc]
  0x013460AC  mov     dword ptr [esi + 0x10], eax
  0x013460AF  jmp     0x1344e1f

; ---- handler 43  va=0x013481F6  next=0x01348319 ----
  0x013481F6  mov     eax, dword ptr [edi]
  0x013481F8  add     edi, 4
  0x013481FB  shr     eax, 8
  0x013481FE  movzx   ecx, al
  0x01348201  mov     eax, dword ptr [esi + 8]
  0x01348204  mov     dword ptr [esp + 0x10], ecx
  0x01348208  mov     dword ptr [eax + 4], edi
  0x0134820B  mov     eax, dword ptr [esp + 0x34]
  0x0134820F  mov     edx, dword ptr [esi + 0x10]
  0x01348212  mov     dword ptr [esp + 0x14], edx
  0x01348216  movzx   eax, byte ptr [eax + 8]
  0x0134821A  add     eax, ecx
  0x0134821C  mov     ecx, dword ptr [esi + 0x1c]
  0x0134821F  mov     dword ptr [esp + 0x40], eax
  0x01348223  sub     ecx, edx
  0x01348225  shl     eax, 4
  0x01348228  cmp     ecx, eax
  0x0134822A  jg      0x1348240
  0x0134822C  push    dword ptr [esp + 0x40]
  0x01348230  push    esi
  0x01348231  call    0x1343ec0   ; ->RVA 0xF43EC0
  0x01348236  mov     edx, dword ptr [esi + 0x10]
  0x01348239  add     esp, 8
  0x0134823C  mov     dword ptr [esp + 0x14], edx
  0x01348240  mov     ecx, dword ptr [esp + 0x10]
  0x01348244  mov     eax, edx
  0x01348246  sub     eax, dword ptr [esi + 0x14]
  0x01348249  sar     eax, 4
  0x0134824C  mov     dword ptr [esp + 0x1c], eax
  0x01348250  cmp     eax, ecx
  0x01348252  jge     0x1348294
  0x01348254  mov     eax, ecx
  0x01348256  sub     eax, dword ptr [esp + 0x1c]
  0x0134825A  mov     dword ptr [esp + 0x1c], ecx
  0x0134825E  mov     ecx, eax
  0x01348260  mov     dword ptr [esp + 0x40], eax
  0x01348264  nop     dword ptr [eax]
  0x01348268  nop     dword ptr [eax + eax]
  0x01348270  mov     eax, dword ptr [esi + 0x10]
  0x01348273  mov     dword ptr [eax + 0xc], 0
  0x0134827A  mov     edx, dword ptr [esi + 0x10]
  0x0134827D  add     edx, 0x10
  0x01348280  mov     dword ptr [esp + 0x14], edx
  0x01348284  mov     dword ptr [esi + 0x10], edx
  0x01348287  sub     ecx, 1
  0x0134828A  jne     0x1348270
  0x0134828C  mov     ecx, dword ptr [esp + 0x10]
  0x01348290  mov     eax, dword ptr [esp + 0x1c]
  0x01348294  shl     eax, 4
  0x01348297  mov     dword ptr [esp + 0x1c], eax
  0x0134829B  mov     eax, edx
  0x0134829D  sub     eax, dword ptr [esp + 0x1c]
  0x013482A1  test    ecx, ecx
  0x013482A3  je      0x13482cb
  0x013482A5  mov     esi, edx
  0x013482A7  sub     esi, eax
  0x013482A9  mov     dword ptr [esp + 0x40], esi
  0x013482AD  nop     dword ptr [eax]
  0x013482B0  lea     eax, [eax + 0x10]
  0x013482B3  movups  xmm0, xmmword ptr [eax - 0x10]
  0x013482B7  movups  xmmword ptr [esi + eax - 0x10], xmm0
  0x013482BC  mov     dword ptr [eax - 4], 0
  0x013482C3  sub     ecx, 1
  0x013482C6  jne     0x13482b0
  0x013482C8  mov     esi, dword ptr [ebp + 8]
  0x013482CB  mov     eax, dword ptr [esi + 8]
  0x013482CE  mov     dword ptr [eax + 8], edx
  0x013482D1  mov     eax, dword ptr [esp + 0x34]
  0x013482D5  movzx   ecx, byte ptr [eax + 8]
  0x013482D9  mov     eax, dword ptr [esi + 8]
  0x013482DC  shl     ecx, 4
  0x013482DF  add     ecx, edx
  0x013482E1  mov     dword ptr [eax + 0xc], ecx
  0x013482E4  mov     eax, dword ptr [esi + 8]
  0x013482E7  mov     ecx, dword ptr [eax + 0xc]
  0x013482EA  mov     eax, dword ptr [esp + 0x10]
  0x013482EE  shl     eax, 4
  0x013482F1  add     eax, edx
  0x013482F3  cmp     eax, ecx
  0x013482F5  jae     0x134830e
  0x013482F7  nop     word ptr [eax + eax]
  0x01348300  mov     dword ptr [eax + 0xc], 0
  0x01348307  add     eax, 0x10
  0x0134830A  cmp     eax, ecx
  0x0134830C  jb      0x1348300
  0x0134830E  mov     dword ptr [esi + 0x14], edx
  0x01348311  mov     dword ptr [esi + 0x10], ecx
  0x01348314  jmp     0x1344e1f

; ---- handler 44  va=0x01345252  next=0x013452DA ----
  0x01345252  mov     ecx, dword ptr [edi]
  0x01345254  mov     dword ptr [esp + 0x10], ecx
  0x01345258  sar     ecx, 0x10
  0x0134525B  shl     ecx, 4
  0x0134525E  add     ecx, dword ptr [esp + 0x30]
  0x01345262  cmp     dword ptr [ecx + 0xc], 0
  0x01345266  je      0x1345290
  0x01345268  mov     eax, dword ptr [esp + 0x34]
  0x0134526C  mov     eax, dword ptr [eax + 0x10]
  0x0134526F  cmp     byte ptr [eax + 9], 0
  0x01345273  je      0x1345290
  0x01345275  mov     eax, dword ptr [esp + 0x10]
  0x01345279  movups  xmm0, xmmword ptr [ecx]
  0x0134527C  shr     eax, 8
  0x0134527F  movzx   eax, al
  0x01345282  add     eax, eax
  0x01345284  add     edi, 8
  0x01345287  movups  xmmword ptr [edx + eax*8], xmm0
  0x0134528B  jmp     0x1344e1f
  0x01345290  mov     eax, dword ptr [esi + 8]
  0x01345293  mov     ecx, dword ptr [edi + 4]
  0x01345296  add     edi, 8
  0x01345299  push    0
  0x0134529B  push    ecx
  0x0134529C  push    dword ptr [esp + 0x38]
  0x013452A0  mov     dword ptr [eax + 4], edi
  0x013452A3  mov     eax, dword ptr [esp + 0x40]
  0x013452A7  push    dword ptr [eax + 0x10]
  0x013452AA  push    esi
  0x013452AB  call    0x134d440   ; ->RVA 0xF4D440
  0x013452B0  mov     ecx, dword ptr [esi + 0x10]
  0x013452B3  add     esp, 0x14
  0x013452B6  mov     eax, dword ptr [esp + 0x10]
  0x013452BA  mov     edx, dword ptr [esi + 0x14]
  0x013452BD  shr     eax, 8
  0x013452C0  movups  xmm0, xmmword ptr [ecx - 0x10]
  0x013452C4  movzx   eax, al
  0x013452C7  add     eax, eax
  0x013452C9  mov     dword ptr [esp + 0x14], edx
  0x013452CD  movups  xmmword ptr [edx + eax*8], xmm0
  0x013452D1  add     dword ptr [esi + 0x10], -0x10
  0x013452D5  jmp     0x1344e1f

; ---- handler 45  va=0x01347A2F  next=0x01347AC8 ----
  0x01347A2F  mov     eax, dword ptr [edi]
  0x01347A31  add     edi, 4
  0x01347A34  mov     dword ptr [esp + 0x10], eax
  0x01347A38  shr     eax, 8
  0x01347A3B  movzx   ecx, al
  0x01347A3E  shl     ecx, 4
  0x01347A41  add     ecx, edx
  0x01347A43  mov     dword ptr [esp + 0x24], ecx
  0x01347A47  cmp     dword ptr [ecx + 0xc], 4
  0x01347A4B  jne     0x1347a59
  0x01347A4D  cmp     dword ptr [ecx + 0x1c], 4
  0x01347A51  jne     0x1347a59
  0x01347A53  cmp     dword ptr [ecx + 0x2c], 4
  0x01347A57  je      0x1347a7c
  0x01347A59  mov     eax, dword ptr [esi + 8]
  0x01347A5C  mov     dword ptr [eax + 4], edi
  0x01347A5F  lea     eax, [ecx + 0x20]
  0x01347A62  push    eax
  0x01347A63  lea     eax, [ecx + 0x10]
  0x01347A66  push    eax
  0x01347A67  push    ecx
  0x01347A68  push    esi
  0x01347A69  call    0x134d3a0   ; ->RVA 0xF4D3A0
  0x01347A6E  mov     edx, dword ptr [esi + 0x14]
  0x01347A71  add     esp, 0x10
  0x01347A74  mov     ecx, dword ptr [esp + 0x24]
  0x01347A78  mov     dword ptr [esp + 0x14], edx
  0x01347A7C  movaps  xmm2, xmmword ptr [0x28ad240]
  0x01347A83  xorps   xmm0, xmm0
  0x01347A86  movsd   xmm1, qword ptr [ecx + 0x10]
  0x01347A8B  movsd   xmm3, qword ptr [ecx]
  0x01347A8F  xorps   xmm1, xmm2
  0x01347A92  movsd   xmm4, qword ptr [ecx + 0x20]
  0x01347A97  xorps   xmm3, xmm2
  0x01347A9A  xor     ecx, ecx
  0x01347A9C  xorps   xmm4, xmm2
  0x01347A9F  comisd  xmm1, xmm0
  0x01347AA3  jbe     0x1347aab
  0x01347AA5  comisd  xmm3, xmm4
  0x01347AA9  jmp     0x1347aaf
  0x01347AAB  comisd  xmm4, xmm3
  0x01347AAF  setae   cl
  0x01347AB2  sar     dword ptr [esp + 0x10], 0x10
  0x01347AB7  xor     eax, eax
  0x01347AB9  test    ecx, ecx
  0x01347ABB  cmove   eax, dword ptr [esp + 0x10]
  0x01347AC0  lea     edi, [edi + eax*4]
  0x01347AC3  jmp     0x1344e1f

; ---- handler 46  va=0x01344F1B  next=0x01344F4C ----
  0x01344F1B  mov     edx, dword ptr [edi]
  0x01344F1D  mov     eax, edx
  0x01344F1F  shr     eax, 8
  0x01344F22  movzx   ecx, al
  0x01344F25  mov     eax, edx
  0x01344F27  shl     ecx, 4
  0x01344F2A  add     ecx, dword ptr [esp + 0x14]
  0x01344F2E  shr     eax, 0x10
  0x01344F31  shr     edx, 0x18
  0x01344F34  movzx   eax, al
  0x01344F37  mov     dword ptr [ecx], eax
  0x01344F39  mov     dword ptr [ecx + 0xc], 1
  0x01344F40  lea     edi, [edi + edx*4]
  0x01344F43  mov     edx, dword ptr [esp + 0x14]
  0x01344F47  jmp     0x1344e1c

; ---- handler 47  va=0x01347573  next=0x013475C0 ----
  0x01347573  mov     edx, dword ptr [edi]
  0x01347575  mov     eax, edx
  0x01347577  shr     eax, 0x10
  0x0134757A  add     edi, 4
  0x0134757D  movzx   ecx, al
  0x01347580  shl     ecx, 4
  0x01347583  add     ecx, dword ptr [esp + 0x14]
  0x01347587  mov     dword ptr [esp + 0x24], edx
  0x0134758B  shr     edx, 0x18
  0x0134758E  shl     edx, 4
  0x01347591  mov     eax, dword ptr [ecx]
  0x01347593  add     edx, dword ptr [esp + 0x30]
  0x01347597  or      eax, 0xfffffffe
  0x0134759A  test    dword ptr [ecx + 0xc], eax
  0x0134759D  mov     eax, dword ptr [esp + 0x24]
  0x013475A1  cmove   edx, ecx
  0x013475A4  shr     eax, 8
  0x013475A7  movzx   eax, al
  0x013475AA  shl     eax, 4
  0x013475AD  add     eax, dword ptr [esp + 0x14]
  0x013475B1  movups  xmm0, xmmword ptr [edx]
  0x013475B4  mov     edx, dword ptr [esp + 0x14]
  0x013475B8  movups  xmmword ptr [eax], xmm0
  0x013475BB  jmp     0x1344e1f

; ---- handler 48  va=0x01346FF1  next=0x01347077 ----
  0x01346FF1  mov     ecx, dword ptr [edi]
  0x01346FF3  mov     eax, ecx
  0x01346FF5  shr     eax, 8
  0x01346FF8  add     edi, 4
  0x01346FFB  movzx   eax, al
  0x01346FFE  shl     eax, 4
  0x01347001  add     eax, edx
  0x01347003  mov     dword ptr [esp + 0x18], eax
  0x01347007  mov     eax, ecx
  0x01347009  shr     eax, 0x10
  0x0134700C  movzx   eax, al
  0x0134700F  shl     eax, 4
  0x01347012  shr     ecx, 0x18
  0x01347015  add     eax, edx
  0x01347017  shl     ecx, 4
  0x0134701A  add     ecx, edx
  0x0134701C  mov     dword ptr [esp + 0x24], eax
  0x01347020  cmp     dword ptr [eax + 0xc], 4
  0x01347024  jne     0x13474c7
  0x0134702A  cmp     dword ptr [ecx + 0xc], 4
  0x0134702E  jne     0x13474c7
  0x01347034  movaps  xmm3, xmmword ptr [0x28ad240]
  0x0134703B  movsd   xmm0, qword ptr [eax]
  0x0134703F  movsd   xmm1, qword ptr [ecx]
  0x01347043  xorps   xmm0, xmm3
  0x01347046  xorps   xmm1, xmm3
  0x01347049  movups  xmmword ptr [esp + 0x50], xmm3
  0x0134704E  call    0x1927850   ; ->RVA 0x1527850
  0x01347053  mov     eax, dword ptr [esp + 0x18]
  0x01347057  xorps   xmm1, xmm1
  0x0134705A  mov     edx, dword ptr [esp + 0x14]
  0x0134705E  movsd   xmm1, xmm0
  0x01347062  xorps   xmm1, xmmword ptr [esp + 0x50]
  0x01347067  movsd   qword ptr [eax], xmm1
  0x0134706B  mov     dword ptr [eax + 0xc], 4
  0x01347072  jmp     0x1344e1f

; ---- handler 49  va=0x01346957  next=0x01346A35 ----
  0x01346957  mov     ecx, dword ptr [edi]
  0x01346959  mov     eax, ecx
  0x0134695B  shr     eax, 8
  0x0134695E  add     edi, 4
  0x01346961  movzx   eax, al
  0x01346964  shl     eax, 4
  0x01346967  add     eax, edx
  0x01346969  mov     dword ptr [esp + 0x18], ecx
  0x0134696D  mov     dword ptr [esp + 0x1c], eax
  0x01346971  mov     esi, dword ptr [esp + 0x1c]
  0x01346975  mov     eax, dword ptr [edi]
  0x01346977  shl     eax, 4
  0x0134697A  add     eax, edx
  0x0134697C  mov     esi, dword ptr [esi + 0xc]
  0x0134697F  cmp     esi, 4
  0x01346982  mov     dword ptr [esp + 0x24], esi
  0x01346986  mov     esi, dword ptr [ebp + 8]
  0x01346989  mov     dword ptr [esp + 0x10], eax
  0x0134698D  jne     0x13469c7
  0x0134698F  cmp     dword ptr [eax + 0xc], 4
  0x01346993  jne     0x13469c7
  0x01346995  mov     esi, dword ptr [esp + 0x1c]
  0x01346999  movsd   xmm1, qword ptr [eax]
  0x0134699D  xorps   xmm1, xmmword ptr [0x28ad240]
  0x013469A4  movsd   xmm2, qword ptr [esi]
  0x013469A8  xorps   xmm2, xmmword ptr [0x28ad240]
  0x013469AF  comisd  xmm1, xmm2
  0x013469B3  mov     esi, dword ptr [ebp + 8]
  0x013469B6  jbe     0x1346aa1
  0x013469BC  sar     ecx, 0x10
  0x013469BF  lea     edi, [edi + ecx*4]
  0x013469C2  jmp     0x1344e1f
  0x013469C7  cmp     dword ptr [esp + 0x24], 5
  0x013469CC  jne     0x13469ff
  0x013469CE  cmp     dword ptr [eax + 0xc], 5
  0x013469D2  jne     0x13469ff
  0x013469D4  push    dword ptr [eax]
  0x013469D6  mov     eax, dword ptr [esp + 0x20]
  0x013469DA  push    dword ptr [eax]
  0x013469DC  call    0x134d540   ; ->RVA 0xF4D540
  0x013469E1  add     esp, 8
  0x013469E4  test    eax, eax
  0x013469E6  jns     0x1346ae2
  0x013469EC  mov     eax, dword ptr [esp + 0x18]
  0x013469F0  mov     edx, dword ptr [esp + 0x14]
  0x013469F4  sar     eax, 0x10
  0x013469F7  lea     edi, [edi + eax*4]
  0x013469FA  jmp     0x1344e1f
  0x013469FF  push    dword ptr [esp + 0x10]
  0x01346A03  mov     eax, dword ptr [esi + 8]
  0x01346A06  push    dword ptr [esp + 0x20]
  0x01346A0A  push    esi
  0x01346A0B  mov     dword ptr [eax + 4], edi
  0x01346A0E  call    0x1359090   ; ->RVA 0xF59090
  0x01346A13  mov     edx, dword ptr [esi + 0x14]
  0x01346A16  add     esp, 0xc
  0x01346A19  mov     dword ptr [esp + 0x14], edx
  0x01346A1D  cmp     eax, 1
  0x01346A20  jne     0x1346b24
  0x01346A26  mov     eax, dword ptr [esp + 0x18]
  0x01346A2A  sar     eax, 0x10
  0x01346A2D  lea     edi, [edi + eax*4]
  0x01346A30  jmp     0x1344e1f

; ---- handler 50  va=0x01345B48  next=0x01345C9D ----
  0x01345B48  mov     ecx, dword ptr [edi]
  0x01345B4A  mov     eax, ecx
  0x01345B4C  shr     eax, 8
  0x01345B4F  movzx   eax, al
  0x01345B52  shl     eax, 4
  0x01345B55  add     eax, edx
  0x01345B57  mov     dword ptr [esp + 0x10], ecx
  0x01345B5B  mov     dword ptr [esp + 0x2c], eax
  0x01345B5F  mov     eax, ecx
  0x01345B61  mov     ecx, dword ptr [edi + 4]
  0x01345B64  add     edi, 8
  0x01345B67  shr     eax, 0x10
  0x01345B6A  movzx   eax, al
  0x01345B6D  shl     eax, 4
  0x01345B70  add     eax, edx
  0x01345B72  shl     ecx, 4
  0x01345B75  add     ecx, dword ptr [esp + 0x30]
  0x01345B79  mov     dword ptr [esp + 0x28], eax
  0x01345B7D  mov     dword ptr [esp + 0x20], ecx
  0x01345B81  mov     edx, dword ptr [eax + 0xc]
  0x01345B84  cmp     edx, 8
  0x01345B87  jne     0x1345dbc
  0x01345B8D  mov     eax, dword ptr [eax]
  0x01345B8F  lea     esi, [eax + 0x20]
  0x01345B92  mov     dword ptr [esp + 0x18], eax
  0x01345B96  mov     eax, dword ptr [ecx]
  0x01345B98  mov     ecx, dword ptr [esp + 0x18]
  0x01345B9C  mov     dword ptr [esp + 0x24], eax
  0x01345BA0  lea     edx, [eax + 8]
  0x01345BA3  mov     eax, 1
  0x01345BA8  mov     cl, byte ptr [ecx + 8]
  0x01345BAB  shl     eax, cl
  0x01345BAD  mov     ecx, eax
  0x01345BAF  mov     dword ptr [esp + 0x1c], eax
  0x01345BB3  mov     eax, dword ptr [edx]
  0x01345BB5  dec     ecx
  0x01345BB6  add     eax, edx
  0x01345BB8  and     ecx, eax
  0x01345BBA  shl     ecx, 5
  0x01345BBD  add     ecx, dword ptr [esi]
  0x01345BBF  mov     eax, dword ptr [ecx + esi + 0x1c]
  0x01345BC3  test    eax, 0xfffffff0
  0x01345BC8  jne     0x1345d7d
  0x01345BCE  cmp     dword ptr [ecx + esi + 0xc], 0
  0x01345BD3  je      0x1345bea
  0x01345BD5  and     eax, 0xf
  0x01345BD8  cmp     al, 5
  0x01345BDA  jne     0x1345bea
  0x01345BDC  mov     eax, dword ptr [esp + 0x24]
  0x01345BE0  cmp     dword ptr [ecx + esi + 0x10], eax
  0x01345BE4  je      0x1345d7d
  0x01345BEA  mov     edx, dword ptr [esp + 0x18]
  0x01345BEE  mov     esi, dword ptr [edx + 0x1c]
  0x01345BF1  lea     eax, [edx + 0x1c]
  0x01345BF4  add     eax, esi
  0x01345BF6  je      0x1345d7d
  0x01345BFC  test    byte ptr [esi + edx + 0x22], 4
  0x01345C01  jne     0x1345d7d
  0x01345C07  mov     ecx, dword ptr [esp + 0x38]
  0x01345C0B  mov     eax, dword ptr [ecx]
  0x01345C0D  xor     eax, ecx
  0x01345C0F  mov     ecx, dword ptr [eax + 0xdc]
  0x01345C15  add     eax, 0xdc
  0x01345C1A  add     ecx, eax
  0x01345C1C  lea     eax, [edx + 0x1c]
  0x01345C1F  push    ecx
  0x01345C20  add     eax, esi
  0x01345C22  push    2
  0x01345C24  push    eax
  0x01345C25  call    0x1359390   ; ->RVA 0xF59390
  0x01345C2A  add     esp, 0xc
  0x01345C2D  test    eax, eax
  0x01345C2F  je      0x1345d7d
  0x01345C35  cmp     dword ptr [eax + 0xc], 8
  0x01345C39  jne     0x1345d7d
  0x01345C3F  mov     eax, dword ptr [eax]
  0x01345C41  lea     ecx, [eax + 0x20]
  0x01345C44  movzx   esi, byte ptr [eax + 0xa]
  0x01345C48  mov     eax, dword ptr [esp + 0x10]
  0x01345C4C  shr     eax, 0x18
  0x01345C4F  and     esi, eax
  0x01345C51  shl     esi, 5
  0x01345C54  add     esi, dword ptr [ecx]
  0x01345C56  add     esi, ecx
  0x01345C58  je      0x1345d7d
  0x01345C5E  mov     eax, dword ptr [esi + 0x1c]
  0x01345C61  and     eax, 0xf
  0x01345C64  cmp     al, 5
  0x01345C66  jne     0x1345d7d
  0x01345C6C  mov     edx, dword ptr [esp + 0x20]
  0x01345C70  mov     eax, dword ptr [esi + 0x10]
  0x01345C73  cmp     eax, dword ptr [edx]
  0x01345C75  jne     0x1345d7d
  0x01345C7B  cmp     dword ptr [esi + 0xc], 0
  0x01345C7F  je      0x1345d7d
  0x01345C85  mov     edx, dword ptr [esp + 0x28]
  0x01345C89  mov     ecx, dword ptr [esp + 0x2c]
  0x01345C8D  movups  xmm0, xmmword ptr [edx]
  0x01345C90  movups  xmmword ptr [ecx + 0x10], xmm0
  0x01345C94  movups  xmm0, xmmword ptr [esi]
  0x01345C97  mov     esi, dword ptr [ebp + 8]
  0x01345C9A  movups  xmmword ptr [ecx], xmm0

; ---- handler 51  va=0x013481C6  next=0x013481F6 ----
  0x013481C6  mov     eax, dword ptr [esi + 8]
  0x013481C9  add     edi, 4
  0x013481CC  mov     ecx, dword ptr [eax + 0xc]
  0x013481CF  mov     eax, dword ptr [esi + 0x10]
  0x013481D2  cmp     eax, ecx
  0x013481D4  jae     0x13481ee
  0x013481D6  nop     word ptr [eax + eax]
  0x013481E0  mov     dword ptr [eax + 0xc], 0
  0x013481E7  add     eax, 0x10
  0x013481EA  cmp     eax, ecx
  0x013481EC  jb      0x13481e0
  0x013481EE  mov     dword ptr [esi + 0x10], ecx
  0x013481F1  jmp     0x1344e1f

; ---- handler 52  va=0x01345218  next=0x01345252 ----
  0x01345218  mov     eax, dword ptr [edi]
  0x0134521A  add     edi, 4
  0x0134521D  mov     ecx, dword ptr [esi + 0x5c]
  0x01345220  shr     eax, 8
  0x01345223  movzx   eax, al
  0x01345226  shl     eax, 4
  0x01345229  add     eax, edx
  0x0134522B  test    ecx, ecx
  0x0134522D  je      0x1344e1f
  0x01345233  cmp     dword ptr [ecx + 8], eax
  0x01345236  lea     ecx, [esi + 0x18]
  0x01345239  jb      0x1344e22
  0x0134523F  push    eax
  0x01345240  push    esi
  0x01345241  call    0x1355560   ; ->RVA 0xF55560
  0x01345246  mov     edx, dword ptr [esp + 0x1c]
  0x0134524A  add     esp, 8
  0x0134524D  jmp     0x1344e1f

; ---- handler 53  va=0x013478FA  next=0x01347A2F ----
  0x013478FA  mov     ecx, dword ptr [edi]
  0x013478FC  mov     eax, ecx
  0x013478FE  shr     eax, 8
  0x01347901  movzx   eax, al
  0x01347904  shl     eax, 4
  0x01347907  add     eax, edx
  0x01347909  mov     dword ptr [esp + 0x28], ecx
  0x0134790D  mov     dword ptr [esp + 0x18], eax
  0x01347911  mov     eax, ecx
  0x01347913  mov     esi, dword ptr [esp + 0x18]
  0x01347917  shr     eax, 0x10
  0x0134791A  movzx   ecx, al
  0x0134791D  mov     eax, dword ptr [esp + 0x28]
  0x01347921  shr     eax, 0x18
  0x01347924  dec     eax
  0x01347925  shl     ecx, 4
  0x01347928  mov     dword ptr [esp + 0x28], eax
  0x0134792C  add     ecx, edx
  0x0134792E  mov     eax, dword ptr [edi + 4]
  0x01347931  add     edi, 8
  0x01347934  cmp     dword ptr [esi + 0xc], 8
  0x01347938  mov     dword ptr [esp + 0x10], ecx
  0x0134793C  mov     dword ptr [esp + 0x20], eax
  0x01347940  mov     dword ptr [esp + 0x1c], edi
  0x01347944  jne     0x13484c3
  0x0134794A  cmp     dword ptr [esp + 0x28], -1
  0x0134794F  mov     esi, dword ptr [ebp + 8]
  0x01347952  jne     0x134796d
  0x01347954  mov     eax, dword ptr [esi + 0x10]
  0x01347957  sub     eax, ecx
  0x01347959  sar     eax, 4
  0x0134795C  mov     dword ptr [esp + 0x28], eax
  0x01347960  mov     eax, dword ptr [esi + 8]
  0x01347963  mov     eax, dword ptr [eax + 0xc]
  0x01347966  mov     dword ptr [esi + 0x10], eax
  0x01347969  mov     eax, dword ptr [esp + 0x20]
  0x0134796D  mov     ecx, dword ptr [esp + 0x18]
  0x01347971  mov     ecx, dword ptr [ecx]
  0x01347973  mov     dword ptr [esp + 0x2c], ecx
  0x01347977  mov     ecx, dword ptr [esp + 0x28]
  0x0134797B  dec     ecx
  0x0134797C  add     ecx, eax
  0x0134797E  mov     eax, dword ptr [esp + 0x2c]
  0x01347982  mov     dword ptr [esp + 0x24], ecx
  0x01347986  cmp     ecx, dword ptr [eax + 0xc]
  0x01347989  mov     ecx, dword ptr [esp + 0x10]
  0x0134798D  jle     0x13479a9
  0x0134798F  push    dword ptr [esp + 0x24]
  0x01347993  push    eax
  0x01347994  push    esi
  0x01347995  call    0x13578e0   ; ->RVA 0xF578E0
  0x0134799A  mov     edx, dword ptr [esp + 0x20]
  0x0134799E  add     esp, 0xc
  0x013479A1  mov     ecx, dword ptr [esp + 0x10]
  0x013479A5  mov     eax, dword ptr [esp + 0x2c]
  0x013479A9  cmp     dword ptr [esp + 0x28], 0
  0x013479AE  jle     0x1344e1f
  0x013479B4  mov     edx, dword ptr [esp + 0x20]
  0x013479B8  add     eax, 0x14
  0x013479BB  mov     edi, dword ptr [esp + 0x28]
  0x013479BF  shl     edx, 4
  0x013479C2  mov     dword ptr [esp + 0x18], eax
  0x013479C6  mov     dword ptr [esp + 0x20], edx
  0x013479CA  nop     word ptr [eax + eax]
  0x013479D0  mov     eax, dword ptr [eax]
  0x013479D2  add     eax, dword ptr [esp + 0x18]
  0x013479D6  movups  xmm0, xmmword ptr [ecx]
  0x013479D9  movups  xmmword ptr [eax + edx - 0x10], xmm0
  0x013479DE  cmp     dword ptr [ecx + 0xc], 5
  0x013479E2  jl      0x1347a0b
  0x013479E4  mov     eax, dword ptr [esp + 0x2c]
  0x013479E8  test    byte ptr [eax + 5], 4
  0x013479EC  je      0x1347a0b
  0x013479EE  mov     eax, dword ptr [ecx]
  0x013479F0  test    byte ptr [eax + 5], 3
  0x013479F4  je      0x1347a0b
  0x013479F6  push    dword ptr [esp + 0x2c]
  0x013479FA  push    esi
  0x013479FB  call    0x1355b60   ; ->RVA 0xF55B60
  0x01347A00  mov     ecx, dword ptr [esp + 0x18]
  0x01347A04  add     esp, 8
  0x01347A07  mov     edx, dword ptr [esp + 0x20]
  0x01347A0B  mov     eax, dword ptr [esp + 0x18]
  0x01347A0F  add     edx, 0x10
  0x01347A12  add     ecx, 0x10
  0x01347A15  mov     dword ptr [esp + 0x20], edx
  0x01347A19  mov     dword ptr [esp + 0x10], ecx
  0x01347A1D  sub     edi, 1
  0x01347A20  jne     0x13479d0
  0x01347A22  mov     edi, dword ptr [esp + 0x1c]
  0x01347A26  mov     edx, dword ptr [esp + 0x14]
  0x01347A2A  jmp     0x1344e1f

; ---- handler 54  va=0x01344F01  next=0x01344F1B ----
  0x01344F01  mov     eax, dword ptr [edi]
  0x01344F03  add     edi, 4
  0x01344F06  shr     eax, 8
  0x01344F09  movzx   eax, al
  0x01344F0C  add     eax, eax
  0x01344F0E  mov     dword ptr [edx + eax*8 + 0xc], 0
  0x01344F16  jmp     0x1344e1f

; ---- handler 55  va=0x01347540  next=0x01347573 ----
  0x01347540  mov     edx, dword ptr [edi]
  0x01347542  mov     eax, edx
  0x01347544  shr     eax, 0x10
  0x01347547  add     edi, 4
  0x0134754A  movzx   esi, al
  0x0134754D  mov     ecx, esi
  0x0134754F  shl     ecx, 4
  0x01347552  add     ecx, dword ptr [esp + 0x14]
  0x01347556  mov     eax, dword ptr [ecx]
  0x01347558  mov     ecx, dword ptr [ecx + 0xc]
  0x0134755B  or      eax, 0xfffffffe
  0x0134755E  and     ecx, eax
  0x01347560  mov     eax, edx
  0x01347562  shr     eax, 0x18
  0x01347565  test    ecx, ecx
  0x01347567  cmove   esi, eax
  0x0134756A  shl     esi, 4
  0x0134756D  add     esi, dword ptr [esp + 0x14]
  0x01347571  jmp     0x13475eb

; ---- handler 56  va=0x01346F45  next=0x01346FF1 ----
  0x01346F45  mov     ecx, dword ptr [edi]
  0x01346F47  mov     eax, ecx
  0x01346F49  shr     eax, 8
  0x01346F4C  add     edi, 4
  0x01346F4F  movzx   eax, al
  0x01346F52  shl     eax, 4
  0x01346F55  add     eax, edx
  0x01346F57  mov     dword ptr [esp + 0x18], eax
  0x01346F5B  mov     eax, ecx
  0x01346F5D  shr     eax, 0x10
  0x01346F60  movzx   eax, al
  0x01346F63  shl     eax, 4
  0x01346F66  shr     ecx, 0x18
  0x01346F69  add     eax, edx
  0x01346F6B  shl     ecx, 4
  0x01346F6E  add     ecx, edx
  0x01346F70  mov     dword ptr [esp + 0x24], eax
  0x01346F74  cmp     dword ptr [eax + 0xc], 4
  0x01346F78  jne     0x1346fea
  0x01346F7A  cmp     dword ptr [ecx + 0xc], 4
  0x01346F7E  jne     0x1346fea
  0x01346F80  movaps  xmm3, xmmword ptr [0x28ad240]
  0x01346F87  sub     esp, 8
  0x01346F8A  movsd   xmm2, qword ptr [eax]
  0x01346F8E  movsd   xmm1, qword ptr [ecx]
  0x01346F92  xorps   xmm2, xmm3
  0x01346F95  xorps   xmm1, xmm3
  0x01346F98  movaps  xmmword ptr [esp + 0x58], xmm3
  0x01346F9D  movaps  xmm0, xmm2
  0x01346FA0  divsd   xmm0, xmm1
  0x01346FA4  movups  xmmword ptr [esp + 0x78], xmm2
  0x01346FA9  movsd   qword ptr [esp + 0x48], xmm0
  0x01346FAF  fld     qword ptr [esp + 0x48]
  0x01346FB3  fstp    qword ptr [esp]
  0x01346FB6  movups  xmmword ptr [esp + 0x68], xmm1
  0x01346FBB  call    0x1924ea0   ; ->RVA 0x1524EA0
  0x01346FC0  movups  xmm1, xmmword ptr [esp + 0x78]
  0x01346FC5  fstp    qword ptr [esp + 0x48]
  0x01346FC9  movsd   xmm0, qword ptr [esp + 0x48]
  0x01346FCF  mulsd   xmm0, qword ptr [esp + 0x68]
  0x01346FD5  subsd   xmm1, xmm0
  0x01346FD9  xorps   xmm0, xmm0
  0x01346FDC  movsd   xmm0, xmm1
  0x01346FE0  xorps   xmm0, xmmword ptr [esp + 0x58]
  0x01346FE5  jmp     0x13473e2
  0x01346FEA  push    0xb
  0x01346FEC  jmp     0x13474c9

; ---- handler 57  va=0x013467B9  next=0x0134687A ----
  0x013467B9  mov     ecx, dword ptr [edi]
  0x013467BB  mov     eax, ecx
  0x013467BD  shr     eax, 8
  0x013467C0  add     edi, 4
  0x013467C3  movzx   eax, al
  0x013467C6  shl     eax, 4
  0x013467C9  add     eax, edx
  0x013467CB  mov     dword ptr [esp + 0x18], ecx
  0x013467CF  mov     dword ptr [esp + 0x1c], eax
  0x013467D3  mov     esi, dword ptr [esp + 0x1c]
  0x013467D7  mov     eax, dword ptr [edi]
  0x013467D9  shl     eax, 4
  0x013467DC  add     eax, edx
  0x013467DE  mov     esi, dword ptr [esi + 0xc]
  0x013467E1  cmp     esi, 4
  0x013467E4  mov     dword ptr [esp + 0x24], esi
  0x013467E8  mov     esi, dword ptr [ebp + 8]
  0x013467EB  mov     dword ptr [esp + 0x10], eax
  0x013467EF  jne     0x1346829
  0x013467F1  cmp     dword ptr [eax + 0xc], 4
  0x013467F5  jne     0x1346829
  0x013467F7  mov     esi, dword ptr [esp + 0x1c]
  0x013467FB  movsd   xmm1, qword ptr [eax]
  0x013467FF  xorps   xmm1, xmmword ptr [0x28ad240]
  0x01346806  movsd   xmm2, qword ptr [esi]
  0x0134680A  xorps   xmm2, xmmword ptr [0x28ad240]
  0x01346811  comisd  xmm1, xmm2
  0x01346815  mov     esi, dword ptr [ebp + 8]
  0x01346818  jb      0x1346aa1
  0x0134681E  sar     ecx, 0x10
  0x01346821  lea     edi, [edi + ecx*4]
  0x01346824  jmp     0x1344e1f
  0x01346829  cmp     dword ptr [esp + 0x24], 5
  0x0134682E  jne     0x1346861
  0x01346830  cmp     dword ptr [eax + 0xc], 5
  0x01346834  jne     0x1346861
  0x01346836  push    dword ptr [eax]
  0x01346838  mov     eax, dword ptr [esp + 0x20]
  0x0134683C  push    dword ptr [eax]
  0x0134683E  call    0x134d540   ; ->RVA 0xF4D540
  0x01346843  add     esp, 8
  0x01346846  test    eax, eax
  0x01346848  jg      0x1346ae2
  0x0134684E  mov     eax, dword ptr [esp + 0x18]
  0x01346852  mov     edx, dword ptr [esp + 0x14]
  0x01346856  sar     eax, 0x10
  0x01346859  lea     edi, [edi + eax*4]
  0x0134685C  jmp     0x1344e1f
  0x01346861  push    dword ptr [esp + 0x10]
  0x01346865  mov     eax, dword ptr [esi + 8]
  0x01346868  push    dword ptr [esp + 0x20]
  0x0134686C  push    esi
  0x0134686D  mov     dword ptr [eax + 4], edi
  0x01346870  call    0x1358ff0   ; ->RVA 0xF58FF0
  0x01346875  jmp     0x1346a13

; ---- handler 58  va=0x01345A2B  next=0x01345B48 ----
  0x01345A2B  mov     eax, dword ptr [esp + 0x34]
  0x01345A2F  mov     ecx, dword ptr [edi]
  0x01345A31  add     eax, 0x18
  0x01345A34  mov     dword ptr [esp + 0x10], ecx
  0x01345A38  add     edi, 4
  0x01345A3B  sar     ecx, 0x10
  0x01345A3E  shl     ecx, 2
  0x01345A41  mov     edx, dword ptr [eax]
  0x01345A43  xor     edx, eax
  0x01345A45  mov     eax, dword ptr [edx + 8]
  0x01345A48  add     edx, 8
  0x01345A4B  sub     ecx, edx
  0x01345A4D  mov     eax, dword ptr [ecx + eax]
  0x01345A50  mov     ecx, dword ptr [esp + 0x34]
  0x01345A54  push    eax
  0x01345A55  mov     dword ptr [esp + 0x20], eax
  0x01345A59  movzx   eax, byte ptr [eax + 0x52]
  0x01345A5D  push    dword ptr [ecx + 0x10]
  0x01345A60  push    eax
  0x01345A61  push    esi
  0x01345A62  call    0x1355880   ; ->RVA 0xF55880
  0x01345A67  mov     edx, dword ptr [esp + 0x24]
  0x01345A6B  add     esp, 0x10
  0x01345A6E  mov     dword ptr [esp + 0x18], eax
  0x01345A72  mov     eax, dword ptr [esp + 0x10]
  0x01345A76  shr     eax, 8
  0x01345A79  movzx   ecx, al
  0x01345A7C  mov     eax, dword ptr [esp + 0x18]
  0x01345A80  add     ecx, ecx
  0x01345A82  mov     dword ptr [esp + 0x10], 0
  0x01345A8A  mov     dword ptr [edx + ecx*8], eax
  0x01345A8D  mov     eax, dword ptr [esp + 0x1c]
  0x01345A91  mov     dword ptr [edx + ecx*8 + 0xc], 6
  0x01345A99  cmp     byte ptr [eax + 0x52], 0
  0x01345A9D  jbe     0x13478ce
  0x01345AA3  mov     eax, dword ptr [esp + 0x18]
  0x01345AA7  add     eax, 0x20
  0x01345AAA  mov     dword ptr [esp + 0x28], eax
  0x01345AAE  nop     
  0x01345AB0  mov     ecx, dword ptr [edi]
  0x01345AB2  mov     eax, ecx
  0x01345AB4  shr     eax, 8
  0x01345AB7  add     edi, 4
  0x01345ABA  movzx   eax, al
  0x01345ABD  sub     eax, 0
  0x01345AC0  je      0x1345b33
  0x01345AC2  sub     eax, 1
  0x01345AC5  je      0x1345ae8
  0x01345AC7  sub     eax, 1
  0x01345ACA  jne     0x1345b0e
  0x01345ACC  shr     ecx, 0x10
  0x01345ACF  movzx   eax, cl
  0x01345AD2  add     eax, 2
  0x01345AD5  shl     eax, 4
  0x01345AD8  add     eax, dword ptr [esp + 0x34]
  0x01345ADC  movups  xmm0, xmmword ptr [eax]
  0x01345ADF  mov     eax, dword ptr [esp + 0x28]
  0x01345AE3  movups  xmmword ptr [eax], xmm0
  0x01345AE6  jmp     0x1345b12
  0x01345AE8  shr     ecx, 0x10
  0x01345AEB  movzx   eax, cl
  0x01345AEE  shl     eax, 4
  0x01345AF1  add     eax, edx
  0x01345AF3  push    eax
  0x01345AF4  push    esi
  0x01345AF5  call    0x13555f0   ; ->RVA 0xF555F0
  0x01345AFA  mov     edx, dword ptr [esp + 0x30]
  0x01345AFE  add     esp, 8
  0x01345B01  mov     dword ptr [edx], eax
  0x01345B03  mov     dword ptr [edx + 0xc], 0xb
  0x01345B0A  mov     edx, dword ptr [esp + 0x14]
  0x01345B0E  mov     eax, dword ptr [esp + 0x28]
  0x01345B12  mov     ecx, dword ptr [esp + 0x10]
  0x01345B16  add     eax, 0x10
  0x01345B19  mov     dword ptr [esp + 0x28], eax
  0x01345B1D  inc     ecx
  0x01345B1E  mov     eax, dword ptr [esp + 0x1c]
  0x01345B22  mov     dword ptr [esp + 0x10], ecx
  0x01345B26  movzx   eax, byte ptr [eax + 0x52]
  0x01345B2A  cmp     ecx, eax
  0x01345B2C  jl      0x1345ab0
  0x01345B2E  jmp     0x13478ce
  0x01345B33  shr     ecx, 0x10
  0x01345B36  movzx   eax, cl
  0x01345B39  add     eax, eax
  0x01345B3B  movups  xmm0, xmmword ptr [edx + eax*8]
  0x01345B3F  mov     eax, dword ptr [esp + 0x28]
  0x01345B43  movups  xmmword ptr [eax], xmm0
  0x01345B46  jmp     0x1345b12

; ---- handler 59  va=0x013480A5  next=0x013481C6 ----
  0x013480A5  mov     ecx, dword ptr [edi]
  0x013480A7  mov     eax, ecx
  0x013480A9  shr     eax, 8
  0x013480AC  add     edi, 4
  0x013480AF  movzx   eax, al
  0x013480B2  shl     eax, 4
  0x013480B5  mov     dword ptr [esp + 0x40], eax
  0x013480B9  add     eax, edx
  0x013480BB  shr     ecx, 0x10
  0x013480BE  mov     dword ptr [esp + 0x2c], eax
  0x013480C2  movzx   eax, cl
  0x013480C5  mov     ecx, dword ptr [esp + 0x34]
  0x013480C9  dec     eax
  0x013480CA  add     ecx, 0x18
  0x013480CD  mov     dword ptr [esp + 0x20], eax
  0x013480D1  mov     eax, dword ptr [esi + 8]
  0x013480D4  mov     dword ptr [esp + 0x10], eax
  0x013480D8  mov     esi, dword ptr [esp + 0x10]
  0x013480DC  mov     eax, dword ptr [ecx]
  0x013480DE  xor     eax, ecx
  0x013480E0  mov     dword ptr [esp + 0x1c], edi
  0x013480E4  mov     ecx, dword ptr [esp + 0x10]
  0x013480E8  movzx   eax, byte ptr [eax + 0x50]
  0x013480EC  mov     ecx, dword ptr [ecx + 8]
  0x013480EF  sub     ecx, dword ptr [esi]
  0x013480F1  mov     esi, dword ptr [ebp + 8]
  0x013480F4  sar     ecx, 4
  0x013480F7  sub     ecx, eax
  0x013480F9  mov     eax, dword ptr [esp + 0x20]
  0x013480FD  dec     ecx
  0x013480FE  mov     dword ptr [esp + 0x28], ecx
  0x01348102  cmp     eax, -1
  0x01348105  jne     0x1348151
  0x01348107  mov     eax, dword ptr [esp + 0x10]
  0x0134810B  mov     edx, ecx
  0x0134810D  shl     edx, 4
  0x01348110  mov     dword ptr [esp + 0x24], edx
  0x01348114  mov     dword ptr [eax + 4], edi
  0x01348117  mov     eax, dword ptr [esi + 0x1c]
  0x0134811A  sub     eax, dword ptr [esi + 0x10]
  0x0134811D  cmp     eax, edx
  0x0134811F  jg      0x134812f
  0x01348121  push    ecx
  0x01348122  push    esi
  0x01348123  call    0x1343ec0   ; ->RVA 0xF43EC0
  0x01348128  mov     ecx, dword ptr [esp + 0x30]
  0x0134812C  add     esp, 8
  0x0134812F  mov     edx, dword ptr [esi + 0x14]
  0x01348132  mov     eax, dword ptr [esp + 0x40]
  0x01348136  add     eax, edx
  0x01348138  mov     dword ptr [esp + 0x14], edx
  0x0134813C  mov     dword ptr [esp + 0x2c], eax
  0x01348140  mov     eax, dword ptr [esp + 0x24]
  0x01348144  add     eax, dword ptr [esp + 0x2c]
  0x01348148  mov     dword ptr [esi + 0x10], eax
  0x0134814B  mov     eax, ecx
  0x0134814D  mov     dword ptr [esp + 0x20], ecx
  0x01348151  xor     ecx, ecx
  0x01348153  test    eax, eax
  0x01348155  jle     0x1348190
  0x01348157  mov     edi, dword ptr [esp + 0x28]
  0x0134815B  mov     esi, edi
  0x0134815D  mov     edx, dword ptr [esp + 0x2c]
  0x01348161  neg     esi
  0x01348163  shl     esi, 4
  0x01348166  cmp     ecx, edi
  0x01348168  jge     0x1348185
  0x0134816A  mov     eax, dword ptr [esp + 0x10]
  0x0134816E  inc     ecx
  0x0134816F  mov     eax, dword ptr [eax + 8]
  0x01348172  movups  xmm0, xmmword ptr [eax + esi]
  0x01348176  add     esi, 0x10
  0x01348179  movups  xmmword ptr [edx], xmm0
  0x0134817C  add     edx, 0x10
  0x0134817F  cmp     ecx, dword ptr [esp + 0x20]
  0x01348183  jl      0x1348166
  0x01348185  mov     edi, dword ptr [esp + 0x1c]
  0x01348189  mov     esi, dword ptr [ebp + 8]
  0x0134818C  mov     edx, dword ptr [esp + 0x14]
  0x01348190  mov     ecx, dword ptr [esp + 0x20]
  0x01348194  mov     eax, dword ptr [esp + 0x28]
  0x01348198  cmp     eax, ecx
  0x0134819A  jge     0x1344e1f
  0x013481A0  mov     esi, dword ptr [esp + 0x2c]
  0x013481A4  add     esi, 0xc
  0x013481A7  shl     eax, 4
  0x013481AA  add     eax, esi
  0x013481AC  sub     ecx, dword ptr [esp + 0x28]
  0x013481B0  mov     esi, dword ptr [ebp + 8]
  0x013481B3  mov     dword ptr [eax], 0
  0x013481B9  lea     eax, [eax + 0x10]
  0x013481BC  sub     ecx, 1
  0x013481BF  jne     0x13481b3
  0x013481C1  jmp     0x1344e1f

; ---- handler 60  va=0x013451A7  next=0x01345218 ----
  0x013451A7  mov     ecx, dword ptr [edi]
  0x013451A9  mov     eax, ecx
  0x013451AB  shr     eax, 8
  0x013451AE  add     edi, 4
  0x013451B1  movzx   eax, al
  0x013451B4  shl     eax, 4
  0x013451B7  add     eax, edx
  0x013451B9  shr     ecx, 0x10
  0x013451BC  mov     dword ptr [esp + 0x18], eax
  0x013451C0  movzx   eax, cl
  0x013451C3  mov     ecx, dword ptr [esp + 0x34]
  0x013451C7  add     eax, 2
  0x013451CA  add     eax, eax
  0x013451CC  mov     eax, dword ptr [ecx + eax*8]
  0x013451CF  mov     ecx, dword ptr [esp + 0x18]
  0x013451D3  mov     dword ptr [esp + 0x10], eax
  0x013451D7  mov     eax, dword ptr [eax + 8]
  0x013451DA  movups  xmm0, xmmword ptr [ecx]
  0x013451DD  movups  xmmword ptr [eax], xmm0
  0x013451E0  cmp     dword ptr [ecx + 0xc], 5
  0x013451E4  jl      0x1344e1f
  0x013451EA  mov     eax, dword ptr [esp + 0x10]
  0x013451EE  test    byte ptr [eax + 5], 4
  0x013451F2  je      0x1344e1f
  0x013451F8  mov     ecx, dword ptr [ecx]
  0x013451FA  test    byte ptr [ecx + 5], 3
  0x013451FE  je      0x1344e1f
  0x01345204  push    ecx
  0x01345205  push    eax
  0x01345206  push    esi
  0x01345207  call    0x1355b80   ; ->RVA 0xF55B80
  0x0134520C  mov     edx, dword ptr [esp + 0x20]
  0x01345210  add     esp, 0xc
  0x01345213  jmp     0x1344e1f

; ---- handler 61  va=0x01347898  next=0x013478FA ----
  0x01347898  mov     ecx, dword ptr [edi]
  0x0134789A  mov     eax, ecx
  0x0134789C  shr     eax, 8
  0x0134789F  add     edi, 4
  0x013478A2  movzx   esi, al
  0x013478A5  mov     eax, dword ptr [esp + 0x30]
  0x013478A9  sar     ecx, 0x10
  0x013478AC  add     ecx, ecx
  0x013478AE  shl     esi, 4
  0x013478B1  add     esi, edx
  0x013478B3  push    dword ptr [eax + ecx*8]
  0x013478B6  mov     eax, dword ptr [ebp + 8]
  0x013478B9  push    eax
  0x013478BA  call    0x1357290   ; ->RVA 0xF57290
  0x013478BF  add     esp, 8
  0x013478C2  mov     dword ptr [esi], eax
  0x013478C4  mov     dword ptr [esi + 0xc], 8
  0x013478CB  mov     esi, dword ptr [ebp + 8]
  0x013478CE  mov     eax, dword ptr [esi + 8]
  0x013478D1  mov     dword ptr [eax + 4], edi
  0x013478D4  lea     eax, [esi + 0x18]
  0x013478D7  mov     ecx, dword ptr [eax]
  0x013478D9  xor     ecx, eax
  0x013478DB  mov     eax, dword ptr [ecx + 0x44]
  0x013478DE  cmp     eax, dword ptr [ecx + 0x40]
  0x013478E1  jb      0x13478ee
  0x013478E3  push    1
  0x013478E5  push    esi
  0x013478E6  call    0x1355e40   ; ->RVA 0xF55E40
  0x013478EB  add     esp, 8
  0x013478EE  mov     edx, dword ptr [esi + 0x14]
  0x013478F1  mov     dword ptr [esp + 0x14], edx
  0x013478F5  jmp     0x1344e1f

; ---- handler 62  va=0x01344E8E  next=0x01344F01 ----
  0x01344E8E  mov     eax, dword ptr [esp + 0x34]
  0x01344E92  add     eax, 0x18
  0x01344E95  mov     ecx, dword ptr [eax]
  0x01344E97  xor     ecx, eax
  0x01344E99  lea     eax, [ecx + 0xc]
  0x01344E9C  sub     eax, dword ptr [eax]
  0x01344E9E  add     eax, edi
  0x01344EA0  sar     eax, 2
  0x01344EA3  sub     eax, dword ptr [ecx + 0x2c]
  0x01344EA6  mov     al, byte ptr [eax + ecx + 0x2c]
  0x01344EAA  lea     ecx, [esi + 0x18]
  0x01344EAD  mov     byte ptr [esp + 0x3f], al
  0x01344EB1  mov     eax, dword ptr [esi + 0x18]
  0x01344EB4  xor     eax, ecx
  0x01344EB6  cmp     dword ptr [eax + 0x3b4], 0
  0x01344EBD  je      0x1344eee
  0x01344EBF  mov     eax, dword ptr [esi + 8]
  0x01344EC2  lea     edx, [esi + 0x18]
  0x01344EC5  push    0
  0x01344EC7  mov     dword ptr [eax + 4], edi
  0x01344ECA  mov     eax, dword ptr [edx]
  0x01344ECC  xor     eax, edx
  0x01344ECE  push    dword ptr [eax + 0x3b4]
  0x01344ED4  push    esi
  0x01344ED5  call    0x134c580   ; ->RVA 0xF4C580
  0x01344EDA  mov     edx, dword ptr [esi + 0x14]
  0x01344EDD  add     esp, 0xc
  0x01344EE0  cmp     byte ptr [esi + 6], 0
  0x01344EE4  mov     dword ptr [esp + 0x14], edx
  0x01344EE8  jne     0x13484c3
  0x01344EEE  movzx   eax, byte ptr [esp + 0x3f]
  0x01344EF3  movzx   eax, byte ptr [eax + 0x13485e8]
  0x01344EFA  jmp     dword ptr [eax*4 + 0x13484cc]

; ---- handler 63  va=0x013474EE  next=0x01347540 ----
  0x013474EE  mov     eax, dword ptr [edi]
  0x013474F0  add     edi, 4
  0x013474F3  mov     dword ptr [esp + 0x24], eax
  0x013474F7  shr     eax, 0x10
  0x013474FA  movzx   edx, al
  0x013474FD  mov     ecx, edx
  0x013474FF  shl     ecx, 4
  0x01347502  add     ecx, dword ptr [esp + 0x14]
  0x01347506  mov     eax, dword ptr [ecx]
  0x01347508  mov     ecx, dword ptr [ecx + 0xc]
  0x0134750B  or      eax, 0xfffffffe
  0x0134750E  and     ecx, eax
  0x01347510  mov     eax, dword ptr [esp + 0x24]
  0x01347514  mov     esi, eax
  0x01347516  shr     esi, 0x18
  0x01347519  test    ecx, ecx
  0x0134751B  mov     ecx, dword ptr [esp + 0x38]
  0x0134751F  cmove   esi, edx
  0x01347522  mov     edx, dword ptr [esp + 0x14]
  0x01347526  add     esi, esi
  0x01347528  shr     eax, 8
  0x0134752B  movzx   eax, al
  0x0134752E  add     eax, eax
  0x01347530  movups  xmm0, xmmword ptr [edx + esi*8]
  0x01347534  mov     esi, dword ptr [ebp + 8]
  0x01347537  movups  xmmword ptr [edx + eax*8], xmm0
  0x0134753B  jmp     0x1344e22

; ---- handler 64  va=0x01346E38  next=0x01346F45 ----
  0x01346E38  mov     esi, dword ptr [edi]
  0x01346E3A  mov     eax, esi
  0x01346E3C  shr     eax, 8
  0x01346E3F  add     edi, 4
  0x01346E42  movzx   eax, al
  0x01346E45  mov     dword ptr [esp + 0x2c], eax
  0x01346E49  shl     eax, 4
  0x01346E4C  add     eax, edx
  0x01346E4E  mov     dword ptr [esp + 0x18], eax
  0x01346E52  mov     eax, esi
  0x01346E54  shr     eax, 0x10
  0x01346E57  movzx   eax, al
  0x01346E5A  mov     ecx, eax
  0x01346E5C  shr     esi, 0x18
  0x01346E5F  shl     ecx, 4
  0x01346E62  add     ecx, edx
  0x01346E64  mov     dword ptr [esp + 0x10], esi
  0x01346E68  mov     dword ptr [esp + 0x20], ecx
  0x01346E6C  mov     ecx, esi
  0x01346E6E  mov     esi, dword ptr [esp + 0x20]
  0x01346E72  shl     ecx, 4
  0x01346E75  add     ecx, edx
  0x01346E77  mov     dword ptr [esp + 0x1c], ecx
  0x01346E7B  mov     esi, dword ptr [esi + 0xc]
  0x01346E7E  cmp     esi, 4
  0x01346E81  mov     dword ptr [esp + 0x24], esi
  0x01346E85  mov     esi, dword ptr [ebp + 8]
  0x01346E88  jne     0x1346eb6
  0x01346E8A  cmp     dword ptr [ecx + 0xc], 4
  0x01346E8E  jne     0x1346eb6
  0x01346E90  mov     eax, dword ptr [esp + 0x20]
  0x01346E94  movaps  xmm3, xmmword ptr [0x28ad240]
  0x01346E9B  movsd   xmm1, qword ptr [ecx]
  0x01346E9F  xorps   xmm1, xmm3
  0x01346EA2  movsd   xmm2, qword ptr [eax]
  0x01346EA6  mov     eax, dword ptr [esp + 0x18]
  0x01346EAA  xorps   xmm2, xmm3
  0x01346EAD  divsd   xmm2, xmm1
  0x01346EB1  jmp     0x134728c
  0x01346EB6  cmp     dword ptr [esp + 0x24], 4
  0x01346EBB  cmove   eax, dword ptr [esp + 0x10]
  0x01346EC0  shl     eax, 4
  0x01346EC3  add     eax, edx
  0x01346EC5  cmp     dword ptr [eax + 0xc], 9
  0x01346EC9  jne     0x1346f39
  0x01346ECB  push    0xa
  0x01346ECD  push    eax
  0x01346ECE  push    esi
  0x01346ECF  call    0x13593c0   ; ->RVA 0xF593C0
  0x01346ED4  mov     edx, eax
  0x01346ED6  add     esp, 0xc
  0x01346ED9  test    edx, edx
  0x01346EDB  je      0x1346f35
  0x01346EDD  cmp     dword ptr [edx + 0xc], 6
  0x01346EE1  jne     0x1346f35
  0x01346EE3  mov     ecx, dword ptr [edx]
  0x01346EE5  cmp     byte ptr [ecx + 6], 0
  0x01346EE9  je      0x1346f35
  0x01346EEB  mov     eax, dword ptr [esi + 0x10]
  0x01346EEE  movups  xmm0, xmmword ptr [edx]
  0x01346EF1  mov     ecx, dword ptr [esp + 0x20]
  0x01346EF5  push    dword ptr [esp + 0x2c]
  0x01346EF9  movups  xmmword ptr [eax], xmm0
  0x01346EFC  mov     eax, dword ptr [esi + 0x10]
  0x01346EFF  movups  xmm0, xmmword ptr [ecx]
  0x01346F02  mov     ecx, dword ptr [esp + 0x20]
  0x01346F06  push    2
  0x01346F08  movups  xmmword ptr [eax + 0x10], xmm0
  0x01346F0C  mov     eax, dword ptr [esi + 0x10]
  0x01346F0F  movups  xmm0, xmmword ptr [ecx]
  0x01346F12  push    esi
  0x01346F13  movups  xmmword ptr [eax + 0x20], xmm0
  0x01346F17  mov     eax, dword ptr [esi + 8]
  0x01346F1A  add     dword ptr [esi + 0x10], 0x30
  0x01346F1E  mov     dword ptr [eax + 4], edi
  0x01346F21  call    0x134c460   ; ->RVA 0xF4C460
  0x01346F26  mov     edx, dword ptr [esi + 0x14]
  0x01346F29  add     esp, 0xc
  0x01346F2C  mov     dword ptr [esp + 0x14], edx
  0x01346F30  jmp     0x1344e1f
  0x01346F35  mov     ecx, dword ptr [esp + 0x1c]
  0x01346F39  push    0xa
  0x01346F3B  push    ecx
  0x01346F3C  push    dword ptr [esp + 0x28]
  0x01346F40  jmp     0x13474ce

; ---- handler 65  va=0x013461F5  next=0x013464D1 ----
  0x013461F5  mov     ecx, dword ptr [edi]
  0x013461F7  add     edi, 4
  0x013461FA  mov     eax, ecx
  0x013461FC  mov     dword ptr [esp + 0x20], ecx
  0x01346200  shr     eax, 8
  0x01346203  movzx   eax, al
  0x01346206  mov     esi, dword ptr [edi]
  0x01346208  shl     eax, 4
  0x0134620B  add     eax, edx
  0x0134620D  shl     esi, 4
  0x01346210  add     esi, edx
  0x01346212  mov     dword ptr [esp + 0x1c], eax
  0x01346216  mov     dword ptr [esp + 0x28], esi
  0x0134621A  mov     edx, dword ptr [eax + 0xc]
  0x0134621D  cmp     edx, dword ptr [esi + 0xc]
  0x01346220  mov     esi, dword ptr [ebp + 8]
  0x01346223  mov     edx, dword ptr [esp + 0x14]
  0x01346227  jne     0x1344e1c
  0x0134622D  cmp     dword ptr [eax + 0xc], 9
  0x01346231  ja      0x1346498
  0x01346237  mov     esi, dword ptr [eax + 0xc]
  0x0134623A  jmp     dword ptr [esi*4 + 0x13486e8]
  0x01346241  mov     esi, dword ptr [ebp + 8]
  0x01346244  sar     ecx, 0x10
  0x01346247  lea     edi, [edi + ecx*4]
  0x0134624A  jmp     0x1344e1f
  0x0134624F  movsd   xmm2, qword ptr [eax]
  0x01346253  mov     eax, dword ptr [esp + 0x28]
  0x01346257  xorps   xmm2, xmmword ptr [0x28ad240]
  0x0134625E  mov     esi, dword ptr [ebp + 8]
  0x01346261  movsd   xmm1, qword ptr [eax]
  0x01346265  xorps   xmm1, xmmword ptr [0x28ad240]
  0x0134626C  ucomisd xmm2, xmm1
  0x01346270  lahf    
  0x01346271  test    ah, 0x44
  0x01346274  jp      0x1346aa1
  0x0134627A  sar     ecx, 0x10
  0x0134627D  lea     edi, [edi + ecx*4]
  0x01346280  jmp     0x1344e1f
  0x01346285  push    dword ptr [esp + 0x28]
  0x01346289  push    eax
  0x0134628A  call    0x1344d90   ; ->RVA 0xF44D90
  0x0134628F  mov     esi, dword ptr [ebp + 8]
  0x01346292  add     esp, 8
  0x01346295  test    al, al
  0x01346297  je      0x1346ae2
  0x0134629D  mov     eax, dword ptr [esp + 0x20]
  0x013462A1  mov     edx, dword ptr [esp + 0x14]
  0x013462A5  sar     eax, 0x10
  0x013462A8  lea     edi, [edi + eax*4]
  0x013462AB  jmp     0x1344e1f
  0x013462B0  mov     eax, dword ptr [eax]
  0x013462B2  mov     esi, dword ptr [ebp + 8]
  0x013462B5  mov     dword ptr [esp + 0x18], eax
  0x013462B9  mov     eax, dword ptr [esp + 0x28]
  0x013462BD  mov     ecx, dword ptr [eax]
  0x013462BF  mov     eax, dword ptr [esp + 0x18]
  0x013462C3  add     ecx, 0x1c
  0x013462C6  mov     dword ptr [esp + 0x24], ecx
  0x013462CA  mov     ecx, dword ptr [eax + 0x1c]
  0x013462CD  add     eax, 0x1c
  0x013462D0  add     eax, ecx
  0x013462D2  mov     ecx, dword ptr [esp + 0x24]
  0x013462D6  mov     dword ptr [esp + 0x10], eax
  0x013462DA  mov     eax, dword ptr [ecx]
  0x013462DC  add     eax, ecx
  0x013462DE  mov     ecx, dword ptr [esp + 0x10]
  0x013462E2  cmp     ecx, eax
  0x013462E4  jne     0x1346498
  0x013462EA  test    ecx, ecx
  0x013462EC  je      0x1346335
  0x013462EE  mov     eax, dword ptr [esp + 0x18]
  0x013462F2  mov     ecx, dword ptr [eax + 0x1c]
  0x013462F5  add     eax, 0x1c
  0x013462F8  add     eax, ecx
  0x013462FA  mov     dword ptr [esp + 0x24], eax
  0x013462FE  test    byte ptr [eax + 6], 0x10
  0x01346302  jne     0x1346335
  0x01346304  mov     ecx, dword ptr [esi + 0x18]
  0x01346307  lea     eax, [esi + 0x18]
  0x0134630A  xor     ecx, eax
  0x0134630C  mov     eax, dword ptr [ecx + 0xe4]
  0x01346312  add     ecx, 0xe4
  0x01346318  add     eax, ecx
  0x0134631A  push    eax
  0x0134631B  push    4
  0x0134631D  push    dword ptr [esp + 0x2c]
  0x01346321  call    0x1359390   ; ->RVA 0xF59390
  0x01346326  add     esp, 0xc
  0x01346329  test    eax, eax
  0x0134632B  jne     0x1346498
  0x01346331  mov     edx, dword ptr [esp + 0x14]
  0x01346335  mov     ecx, dword ptr [esp + 0x1c]
  0x01346339  mov     eax, dword ptr [ecx]
  0x0134633B  mov     ecx, dword ptr [esp + 0x28]
  0x0134633F  cmp     eax, dword ptr [ecx]
  0x01346341  jne     0x1346b24
  0x01346347  mov     eax, dword ptr [esp + 0x20]
  0x0134634B  sar     eax, 0x10
  0x0134634E  lea     edi, [edi + eax*4]
  0x01346351  jmp     0x1344e1f
  0x01346356  mov     eax, dword ptr [eax]
  0x01346358  add     eax, 0xc
  0x0134635B  mov     dword ptr [esp + 0x10], eax
  0x0134635F  mov     eax, dword ptr [esp + 0x28]
  0x01346363  mov     esi, dword ptr [esp + 0x10]
  0x01346367  mov     eax, dword ptr [eax]
  0x01346369  add     eax, 0xc
  0x0134636C  mov     dword ptr [esp + 0x24], eax
  0x01346370  mov     eax, dword ptr [esi]
  0x01346372  sub     esi, eax
  0x01346374  mov     dword ptr [esp + 0x18], eax
  0x01346378  mov     eax, dword ptr [esp + 0x24]
  0x0134637C  mov     dword ptr [esp + 0x2c], esi
  0x01346380  sub     eax, dword ptr [eax]
  0x01346382  cmp     esi, eax
  0x01346384  mov     esi, dword ptr [ebp + 8]
  0x01346387  jne     0x1346498
  0x0134638D  cmp     dword ptr [esp + 0x2c], 0
  0x01346392  je      0x1346478
  0x01346398  mov     eax, dword ptr [esp + 0x10]
  0x0134639C  sub     eax, dword ptr [esp + 0x18]
  0x013463A0  test    byte ptr [eax + 6], 0x10
  0x013463A4  jne     0x1346478
  0x013463AA  mov     eax, dword ptr [esi + 0x18]
  0x013463AD  lea     ecx, [esi + 0x18]
  0x013463B0  xor     eax, ecx
  0x013463B2  mov     ecx, dword ptr [eax + 0xe4]
  0x013463B8  add     eax, 0xe4
  0x013463BD  add     ecx, eax
  0x013463BF  mov     eax, dword ptr [esp + 0x10]
  0x013463C3  sub     eax, dword ptr [esp + 0x18]
  0x013463C7  push    ecx
  0x013463C8  push    4
  0x013463CA  push    eax
  0x013463CB  call    0x1359390   ; ->RVA 0xF59390
  0x013463D0  mov     edx, eax
  0x013463D2  add     esp, 0xc
  0x013463D5  test    edx, edx
  0x013463D7  je      0x1346470
  0x013463DD  cmp     dword ptr [edx + 0xc], 6
  0x013463E1  jne     0x1346498
  0x013463E7  mov     ecx, dword ptr [edx]
  0x013463E9  cmp     byte ptr [ecx + 6], 0
  0x013463ED  je      0x1346498
  0x013463F3  mov     eax, dword ptr [esi + 0x10]
  0x013463F6  movups  xmm0, xmmword ptr [edx]
  0x013463F9  mov     ecx, dword ptr [esp + 0x1c]
  0x013463FD  movups  xmmword ptr [eax], xmm0
  0x01346400  mov     eax, dword ptr [esi + 0x10]
  0x01346403  movups  xmm0, xmmword ptr [ecx]
  0x01346406  mov     ecx, dword ptr [esp + 0x28]
  0x0134640A  movups  xmmword ptr [eax + 0x10], xmm0
  0x0134640E  mov     eax, dword ptr [esi + 0x10]
  0x01346411  movups  xmm0, xmmword ptr [ecx]
  0x01346414  mov     ecx, dword ptr [ebp + 8]
  0x01346417  movups  xmmword ptr [eax + 0x20], xmm0
  0x0134641B  mov     eax, dword ptr [esi + 0x10]
  0x0134641E  mov     esi, eax
  0x01346420  sub     esi, dword ptr [ecx + 0x14]
  0x01346423  add     eax, 0x30
  0x01346426  mov     dword ptr [ecx + 0x10], eax
  0x01346429  mov     eax, dword ptr [ecx + 8]
  0x0134642C  sar     esi, 4
  0x0134642F  push    esi
  0x01346430  push    2
  0x01346432  push    ecx
  0x01346433  mov     dword ptr [eax + 4], edi
  0x01346436  call    0x134c460   ; ->RVA 0xF4C460
  0x0134643B  mov     eax, dword ptr [ebp + 8]
  0x0134643E  add     esi, esi
  0x01346440  add     esp, 0xc
  0x01346443  mov     edx, dword ptr [eax + 0x14]
  0x01346446  mov     dword ptr [esp + 0x14], edx
  0x0134644A  mov     eax, dword ptr [edx + esi*8]
  0x0134644D  or      eax, 0xfffffffe
  0x01346450  test    dword ptr [edx + esi*8 + 0xc], eax
  0x01346454  je      0x1346745
  0x0134645A  mov     eax, dword ptr [esp + 0x20]
  0x0134645E  mov     esi, dword ptr [ebp + 8]
  0x01346461  mov     ecx, dword ptr [esp + 0x38]
  0x01346465  sar     eax, 0x10
  0x01346468  lea     edi, [edi + eax*4]
  0x0134646B  jmp     0x1344e22
  0x01346470  mov     edx, dword ptr [esp + 0x14]
  0x01346474  mov     ecx, dword ptr [esp + 0x20]
  0x01346478  mov     eax, dword ptr [esp + 0x1c]
  0x0134647C  mov     esi, dword ptr [esp + 0x28]
  0x01346480  mov     eax, dword ptr [eax]
  0x01346482  cmp     eax, dword ptr [esi]
  0x01346484  mov     esi, dword ptr [ebp + 8]
  0x01346487  jne     0x1346aa1
  0x0134648D  sar     ecx, 0x10
  0x01346490  lea     edi, [edi + ecx*4]
  0x01346493  jmp     0x1344e1f
  0x01346498  mov     esi, dword ptr [ebp + 8]
  0x0134649B  push    dword ptr [esp + 0x28]
  0x0134649F  push    dword ptr [esp + 0x20]
  0x013464A3  mov     eax, dword ptr [esi + 8]
  0x013464A6  push    esi
  0x013464A7  mov     dword ptr [eax + 4], edi
  0x013464AA  call    0x1358d90   ; ->RVA 0xF58D90
  0x013464AF  mov     edx, dword ptr [esi + 0x14]
  0x013464B2  add     esp, 0xc
  0x013464B5  mov     dword ptr [esp + 0x14], edx
  0x013464B9  cmp     eax, 1
  0x013464BC  jne     0x1346b24
  0x013464C2  mov     eax, dword ptr [esp + 0x20]
  0x013464C6  sar     eax, 0x10
  0x013464C9  lea     edi, [edi + eax*4]
  0x013464CC  jmp     0x1344e1f

; ---- handler 66  va=0x01345935  next=0x01345A2B ----
  0x01345935  mov     ecx, dword ptr [edi]
  0x01345937  mov     eax, ecx
  0x01345939  shr     eax, 8
  0x0134593C  add     edi, 4
  0x0134593F  movzx   eax, al
  0x01345942  shl     eax, 4
  0x01345945  add     eax, edx
  0x01345947  mov     dword ptr [esp + 0x1c], eax
  0x0134594B  mov     eax, ecx
  0x0134594D  shr     eax, 0x10
  0x01345950  movzx   eax, al
  0x01345953  shl     eax, 4
  0x01345956  add     eax, edx
  0x01345958  shr     ecx, 0x18
  0x0134595B  mov     dword ptr [esp + 0x20], eax
  0x0134595F  mov     dword ptr [esp + 0x10], ecx
  0x01345963  cmp     dword ptr [eax + 0xc], 8
  0x01345967  jne     0x13459d9
  0x01345969  mov     eax, dword ptr [eax]
  0x0134596B  mov     dword ptr [esp + 0x18], eax
  0x0134596F  cmp     ecx, dword ptr [eax + 0xc]
  0x01345972  jae     0x13459d9
  0x01345974  lea     ecx, [eax + 0x1c]
  0x01345977  mov     eax, dword ptr [ecx]
  0x01345979  add     eax, ecx
  0x0134597B  mov     ecx, dword ptr [esp + 0x10]
  0x0134597F  jne     0x13459d9
  0x01345981  mov     eax, dword ptr [esp + 0x18]
  0x01345985  cmp     byte ptr [eax + 7], 0
  0x01345989  jne     0x13459d9
  0x0134598B  add     eax, 0x14
  0x0134598E  shl     ecx, 4
  0x01345991  add     ecx, eax
  0x01345993  add     ecx, dword ptr [eax]
  0x01345995  mov     eax, dword ptr [esp + 0x1c]
  0x01345999  movups  xmm0, xmmword ptr [eax]
  0x0134599C  movups  xmmword ptr [ecx], xmm0
  0x0134599F  cmp     dword ptr [eax + 0xc], 5
  0x013459A3  lea     ecx, [esi + 0x18]
  0x013459A6  jl      0x1344e22
  0x013459AC  mov     ecx, dword ptr [esp + 0x18]
  0x013459B0  test    byte ptr [ecx + 5], 4
  0x013459B4  je      0x1344e1f
  0x013459BA  mov     eax, dword ptr [eax]
  0x013459BC  test    byte ptr [eax + 5], 3
  0x013459C0  je      0x1344e1f
  0x013459C6  push    ecx
  0x013459C7  push    esi
  0x013459C8  call    0x1355b60   ; ->RVA 0xF55B60
  0x013459CD  mov     edx, dword ptr [esp + 0x1c]
  0x013459D1  add     esp, 8
  0x013459D4  jmp     0x1344e1f
  0x013459D9  lea     eax, [ecx + 1]
  0x013459DC  mov     dword ptr [esp + 0xbc], 4
  0x013459E7  movd    xmm0, eax
  0x013459EB  mov     eax, dword ptr [esi + 8]
  0x013459EE  cvtdq2pd xmm1, xmm0
  0x013459F2  xorps   xmm1, xmmword ptr [0x28ad240]
  0x013459F9  movsd   qword ptr [esp + 0xb0], xmm1
  0x01345A02  mov     dword ptr [eax + 4], edi
  0x01345A05  mov     eax, dword ptr [esp + 0x1c]
  0x01345A09  push    eax
  0x01345A0A  lea     eax, [esp + 0xb4]
  0x01345A11  push    eax
  0x01345A12  push    dword ptr [esp + 0x28]
  0x01345A16  push    esi
  0x01345A17  call    0x1359130   ; ->RVA 0xF59130
  0x01345A1C  mov     edx, dword ptr [esi + 0x14]
  0x01345A1F  add     esp, 0x10
  0x01345A22  mov     dword ptr [esp + 0x14], edx
  0x01345A26  jmp     0x1344e1f

; ---- handler 67  va=0x01347EA4  next=0x013480A5 ----
  0x01347EA4  mov     eax, dword ptr [esi + 0x18]
  0x01347EA7  lea     ecx, [esi + 0x18]
  0x01347EAA  xor     eax, ecx
  0x01347EAC  mov     ecx, dword ptr [eax + 0x3a8]
  0x01347EB2  add     eax, 0x3a8
  0x01347EB7  add     ecx, eax
  0x01347EB9  mov     dword ptr [esp + 0x24], ecx
  0x01347EBD  je      0x1347ee3
  0x01347EBF  mov     eax, dword ptr [esi + 8]
  0x01347EC2  mov     dword ptr [eax + 4], edi
  0x01347EC5  mov     eax, dword ptr [0x2941254]
  0x01347ECA  sub     ecx, eax
  0x01347ECC  cmp     ecx, dword ptr [0x2941258]
  0x01347ED2  jae     0x1347edc
  0x01347ED4  push    esi
  0x01347ED5  call    dword ptr [esp + 0x28]
  0x01347ED9  add     esp, 4
  0x01347EDC  mov     edx, dword ptr [esi + 0x14]
  0x01347EDF  mov     dword ptr [esp + 0x14], edx
  0x01347EE3  mov     eax, dword ptr [edi]
  0x01347EE5  add     edi, 4
  0x01347EE8  mov     dword ptr [esp + 0x1c], eax
  0x01347EEC  shr     eax, 8
  0x01347EEF  movzx   ecx, al
  0x01347EF2  mov     eax, ecx
  0x01347EF4  shl     eax, 4
  0x01347EF7  add     eax, edx
  0x01347EF9  mov     dword ptr [esp + 0x28], eax
  0x01347EFD  cmp     dword ptr [eax + 0x1c], 8
  0x01347F01  jne     0x134806f
  0x01347F07  cmp     dword ptr [eax + 0x2c], 3
  0x01347F0B  jne     0x134806f
  0x01347F11  mov     ecx, dword ptr [eax + 0x10]
  0x01347F14  mov     eax, dword ptr [eax + 0x20]
  0x01347F17  mov     dword ptr [esp + 0x24], eax
  0x01347F1B  mov     eax, 1
  0x01347F20  mov     dword ptr [esp + 0x20], ecx
  0x01347F24  mov     cl, byte ptr [ecx + 8]
  0x01347F27  shl     eax, cl
  0x01347F29  mov     ecx, dword ptr [esp + 0x24]
  0x01347F2D  mov     dword ptr [esp + 0x2c], eax
  0x01347F31  mov     eax, dword ptr [esp + 0x20]
  0x01347F35  cmp     ecx, dword ptr [eax + 0xc]
  0x01347F38  jae     0x1347f7e
  0x01347F3A  mov     eax, dword ptr [eax + 0x14]
  0x01347F3D  mov     dword ptr [esp + 0x24], eax
  0x01347F41  mov     eax, ecx
  0x01347F43  shl     eax, 4
  0x01347F46  mov     dword ptr [esp + 0x18], eax
  0x01347F4A  nop     word ptr [eax + eax]
  0x01347F50  add     eax, dword ptr [esp + 0x20]
  0x01347F54  lea     esi, [ecx + 1]
  0x01347F57  mov     dword ptr [esp + 0x10], esi
  0x01347F5B  mov     esi, dword ptr [esp + 0x24]
  0x01347F5F  cmp     dword ptr [eax + esi + 0x20], 0
  0x01347F64  jne     0x1347fe3
  0x01347F66  mov     esi, dword ptr [esp + 0x20]
  0x01347F6A  mov     eax, dword ptr [esp + 0x18]
  0x01347F6E  mov     ecx, dword ptr [esp + 0x10]
  0x01347F72  add     eax, 0x10
  0x01347F75  mov     dword ptr [esp + 0x18], eax
  0x01347F79  cmp     ecx, dword ptr [esi + 0xc]
  0x01347F7C  jb      0x1347f50
  0x01347F7E  mov     esi, dword ptr [esp + 0x20]
  0x01347F82  mov     eax, ecx
  0x01347F84  sub     eax, dword ptr [esi + 0xc]
  0x01347F87  mov     esi, dword ptr [ebp + 8]
  0x01347F8A  mov     dword ptr [esp + 0x18], eax
  0x01347F8E  cmp     eax, dword ptr [esp + 0x2c]
  0x01347F92  jae     0x1344e1f
  0x01347F98  mov     esi, dword ptr [esp + 0x20]
  0x01347F9C  add     esi, 0x20
  0x01347F9F  shl     eax, 5
  0x01347FA2  mov     dword ptr [esp + 0x20], esi
  0x01347FA6  mov     dword ptr [esp + 0x10], eax
  0x01347FAA  mov     esi, dword ptr [esi]
  0x01347FAC  mov     dword ptr [esp + 0x24], esi
  0x01347FB0  add     eax, dword ptr [esp + 0x24]
  0x01347FB4  inc     ecx
  0x01347FB5  add     eax, dword ptr [esp + 0x20]
  0x01347FB9  mov     esi, dword ptr [ebp + 8]
  0x01347FBC  mov     dword ptr [esp + 0x40], eax
  0x01347FC0  cmp     dword ptr [eax + 0xc], 0
  0x01347FC4  jne     0x1348023
  0x01347FC6  mov     eax, dword ptr [esp + 0x18]
  0x01347FCA  add     dword ptr [esp + 0x10], 0x20
  0x01347FCF  inc     eax
  0x01347FD0  cmp     eax, dword ptr [esp + 0x2c]
  0x01347FD4  mov     dword ptr [esp + 0x18], eax
  0x01347FD8  mov     eax, dword ptr [esp + 0x10]
  0x01347FDC  jb      0x1347fb0
  0x01347FDE  jmp     0x1344e1f
  0x01347FE3  mov     eax, dword ptr [esp + 0x10]
  0x01347FE7  mov     esi, dword ptr [esp + 0x28]
  0x01347FEB  shl     ecx, 4
  0x01347FEE  movd    xmm0, eax
  0x01347FF2  mov     dword ptr [esi + 0x20], eax
  0x01347FF5  mov     eax, esi
  0x01347FF7  cvtdq2pd xmm1, xmm0
  0x01347FFB  mov     dword ptr [esi + 0x2c], 3
  0x01348002  mov     esi, dword ptr [esp + 0x20]
  0x01348006  xorps   xmm1, xmmword ptr [0x28ad240]
  0x0134800D  movsd   qword ptr [eax + 0x30], xmm1
  0x01348012  mov     dword ptr [eax + 0x3c], 4
  0x01348019  add     ecx, dword ptr [esi + 0x14]
  0x0134801C  movups  xmm0, xmmword ptr [ecx + esi + 0x14]
  0x01348021  jmp     0x1348055
  0x01348023  mov     esi, dword ptr [esp + 0x28]
  0x01348027  mov     dword ptr [esi + 0x20], ecx
  0x0134802A  mov     ecx, esi
  0x0134802C  mov     dword ptr [ecx + 0x2c], 3
  0x01348033  mov     eax, dword ptr [eax + 0x10]
  0x01348036  mov     dword ptr [ecx + 0x30], eax
  0x01348039  mov     ecx, dword ptr [esp + 0x40]
  0x0134803D  mov     eax, dword ptr [ecx + 0x14]
  0x01348040  mov     dword ptr [esi + 0x34], eax
  0x01348043  mov     eax, dword ptr [ecx + 0x18]
  0x01348046  mov     dword ptr [esi + 0x38], eax
  0x01348049  mov     eax, dword ptr [ecx + 0x1c]
  0x0134804C  and     eax, 0xf
  0x0134804F  mov     dword ptr [esi + 0x3c], eax
  0x01348052  movups  xmm0, xmmword ptr [ecx]
  0x01348055  mov     eax, dword ptr [esp + 0x28]
  0x01348059  mov     esi, dword ptr [ebp + 8]
  0x0134805C  movups  xmmword ptr [eax + 0x40], xmm0
  0x01348060  mov     eax, dword ptr [esp + 0x1c]
  0x01348064  sar     eax, 0x10
  0x01348067  lea     edi, [edi + eax*4]
  0x0134806A  jmp     0x1344e1f
  0x0134806F  mov     eax, dword ptr [esi + 8]
  0x01348072  push    2
  0x01348074  push    ecx
  0x01348075  push    esi
  0x01348076  mov     dword ptr [eax + 4], edi
  0x01348079  call    0x134d160   ; ->RVA 0xF4D160
  0x0134807E  mov     edx, dword ptr [esi + 0x14]
  0x01348081  add     esp, 0xc
  0x01348084  mov     dword ptr [esp + 0x14], edx
  0x01348088  test    al, al
  0x0134808A  je      0x1348096
  0x0134808C  xor     eax, eax
  0x0134808E  lea     edi, [edi + eax*4]
  0x01348091  jmp     0x1344e1f
  0x01348096  mov     eax, dword ptr [esp + 0x1c]
  0x0134809A  sar     eax, 0x10
  0x0134809D  lea     edi, [edi + eax*4]
  0x013480A0  jmp     0x1344e1f

; ---- handler 68  va=0x01345167  next=0x013451A7 ----
  0x01345167  mov     ecx, dword ptr [edi]
  0x01345169  mov     eax, ecx
  0x0134516B  shr     ecx, 0x10
  0x0134516E  add     edi, 4
  0x01345171  movzx   ecx, cl
  0x01345174  add     ecx, 2
  0x01345177  shr     eax, 8
  0x0134517A  shl     ecx, 4
  0x0134517D  add     ecx, dword ptr [esp + 0x34]
  0x01345181  movzx   eax, al
  0x01345184  shl     eax, 4
  0x01345187  add     eax, edx
  0x01345189  cmp     dword ptr [ecx + 0xc], 0xb
  0x0134518D  mov     dword ptr [esp + 0x18], eax
  0x01345191  jne     0x134519c
  0x01345193  mov     eax, dword ptr [ecx]
  0x01345195  mov     ecx, dword ptr [eax + 8]
  0x01345198  mov     eax, dword ptr [esp + 0x18]
  0x0134519C  movups  xmm0, xmmword ptr [ecx]
  0x0134519F  movups  xmmword ptr [eax], xmm0
  0x013451A2  jmp     0x1344e1f

; ---- handler 69  va=0x01347842  next=0x01347898 ----
  0x01347842  mov     ecx, dword ptr [edi]
  0x01347844  mov     eax, ecx
  0x01347846  shr     eax, 0x10
  0x01347849  movzx   eax, al
  0x0134784C  mov     dword ptr [esp + 0x24], eax
  0x01347850  mov     eax, dword ptr [edi + 4]
  0x01347853  add     edi, 8
  0x01347856  mov     dword ptr [esp + 0x18], eax
  0x0134785A  shr     ecx, 8
  0x0134785D  movzx   eax, cl
  0x01347860  shl     eax, 4
  0x01347863  add     eax, edx
  0x01347865  mov     dword ptr [esp + 0x10], eax
  0x01347869  mov     eax, dword ptr [esp + 0x24]
  0x0134786D  test    eax, eax
  0x0134786F  je      0x134787b
  0x01347871  lea     ecx, [eax - 1]
  0x01347874  mov     eax, 1
  0x01347879  shl     eax, cl
  0x0134787B  push    eax
  0x0134787C  push    dword ptr [esp + 0x1c]
  0x01347880  push    esi
  0x01347881  call    0x1357690   ; ->RVA 0xF57690
  0x01347886  mov     ecx, dword ptr [esp + 0x1c]
  0x0134788A  add     esp, 0xc
  0x0134788D  mov     dword ptr [ecx], eax
  0x0134788F  mov     dword ptr [ecx + 0xc], 8
  0x01347896  jmp     0x13478ce
