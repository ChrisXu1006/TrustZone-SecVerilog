//=========================================================================
// This file is used to define macros in the project 
//=========================================================================

// Enable DEBUG, if unenbale, just comment the following line
`define DEBUG

// MACROS to determine secure or insecure memory access control module
`define MEM_ACC_SECURE

// MACROS to determine secure or insecure processor access control module
`define PROC_ACC_INSECURE

// MACROS to determone secure or insecure network adapter of requests
`define MEM_REQ_TRANS_SECURE 

// MACROS to determone secure or insecure network adapter of response
`define MEM_RESP_TRANS_SECURE

// MACROS to control secure or insecure cache design
`define CACHE_INSECURE

// MACROS to control secure or insecure DMA checker
`define DMA_CHECKER_SECURE
