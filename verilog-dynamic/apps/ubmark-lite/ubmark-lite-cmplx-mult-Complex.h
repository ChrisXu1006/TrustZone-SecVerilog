//========================================================================
// ubmark-cmlpx-mult-Complex
//========================================================================
// Simple complex value struct

#ifndef UBMARK_CMPLX_MULT_COMPLEX_H
#define UBMARK_CMPLX_MULT_COMPLEX_H

#include <iostream>

struct Complex
{
  Complex() : real(0.0f), imag(0.0f) { }
  Complex( int real_, int imag_ ) : real(real_), imag(imag_) { }
  int real;
  int imag;
};

inline
Complex operator*( const Complex& complex0, const Complex& complex1 )
{
  int src0_r = complex0.real;
  int src0_i = complex0.imag;
  int src1_r = complex1.real;
  int src1_i = complex1.imag;

  Complex result;
  result.real = (src0_r * src1_r) - (src0_i * src1_i);
  result.imag = (src0_r * src1_i) + (src0_i * src1_r);

  return result;
}

inline
bool operator==( const Complex& complex0, const Complex& complex1 )
{
  return (    complex0.real == complex1.real
           && complex0.imag == complex1.imag );
}

inline
std::ostream& operator<<( std::ostream& os, const Complex& complex )
{
  os << complex.real << "+" << complex.imag << "i";
  return os;
}

#endif /* UBMARK_CMPLX_MULT_COMPLEX_H */

