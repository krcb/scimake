/**
 * $Id$
 * 
 * Copyright &copy; 2014-2014, Tech-X Corporation
 */

template <class TYPE> class X {
  public:
    static int r;
};
template <class TYPE> int X<TYPE>::r = 0;

int main (int argc, char* argv[]) {
  X<double> x;
  int rr = x.r + X<float>::r;
};

